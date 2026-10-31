@tool
extends Control

signal inspect_requested(data: CardData, health: int, owner: Control)
signal inspect_closed(owner: Control)
signal activated
signal activation_rejected
const ArtViewer = preload("res://scripts/art_viewer.gd")
const CardSkin = preload("res://scripts/card_skin.gd")
@export var card_data: CardData:
 set(value):
  card_data = value
  refresh()
var current_health := -1
var available := false
var selected := false
var exhausted := false

func _ready() -> void:
 mouse_entered.connect(func(): inspect_requested.emit(card_data, current_health, self))
 mouse_exited.connect(func(): inspect_closed.emit(self))
 resized.connect(layout_card)
 refresh()
 layout_card()
 if not Engine.is_editor_hint():
  var icon: Control = $Canvas/Exhausted
  icon.pivot_offset=icon.size*0.5
  if get_meta("attacked_this_turn",false):
   var pulse:=create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
   pulse.tween_property(icon,"rotation",0.12,0.7)
   pulse.parallel().tween_property(icon,"modulate:a",0.6,0.7)
   pulse.tween_property(icon,"rotation",-0.12,0.7)
   pulse.parallel().tween_property(icon,"modulate:a",1.0,0.7)
   return
  var base := icon.position
  var bob := create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
  bob.tween_property(icon, "position", base - Vector2(0, 6), 0.65)
  bob.parallel().tween_property(icon, "modulate:a", 0.55, 0.65)
  bob.tween_property(icon, "position", base, 0.65)
  bob.parallel().tween_property(icon, "modulate:a", 1.0, 0.65)

func layout_card() -> void:
 var factor := minf(size.x / 200.0, size.y / 200.0)
 $Canvas.scale = Vector2.ONE * factor
 $Canvas.position = (size - Vector2(200, 200) * factor) / 2.0

func refresh() -> void:
 if not is_node_ready() or not card_data:
  return
 # Keep the upper illustration (face) when cropping the portrait to a square.
 var art = card_data.artwork
 if art and not art is AtlasTexture and card_data.field_artwork_focus!=Vector2(0.5,0.5):
  var focused:=AtlasTexture.new()
  focused.atlas=art
  var dimensions:Vector2=art.get_size()
  var crop_size:Vector2=Vector2(dimensions.x,minf(dimensions.y,dimensions.x))
  var origin:Vector2=(dimensions*card_data.field_artwork_focus-crop_size*0.5).clamp(Vector2.ZERO,dimensions-crop_size)
  focused.region=Rect2(origin,crop_size)
  focused.filter_clip=true
  art=focused
 if art is AtlasTexture and card_data.field_artwork_focus==Vector2(0.5,0.5):
  var crop := AtlasTexture.new()
  crop.atlas = art.atlas
  crop.region = art.region
  if card_data.card_class != CardData.CardClass.NEUTRAL:
   crop.region.position.y += 35
   crop.region.size.y -= 35
  crop.region.size.y = minf(crop.region.size.y, crop.region.size.x * 0.82)
  crop.filter_clip = true
  art = crop
 $Canvas/Artwork.texture = art
 var attack: int = get_meta("attack",card_data.attack)
 var health: int = card_data.health if current_health<0 else current_health
 var stat_text := "%d/%d" % [attack,health]
 $Canvas/Stats.add_theme_font_size_override("font_size",25 if stat_text.length()<=3 else 19)
 $Canvas/Stats.set_values(attack,health,card_data.attack,card_data.health,int(get_meta("max_health",card_data.health)))
 var style := StyleBoxFlat.new()
 style.bg_color = Color("101822")
 var selection_kind: String=get_meta("selection_kind","")
 style.set_border_width_all(5 if selection_kind!="" else 2)
 style.border_color = Color("ffd36a") if selection_kind=="selected" else Color("72ead6") if selection_kind=="target" else CardSkin.class_color(card_data.card_class)
 if selection_kind!="":
  style.shadow_color=Color(1.0,0.72,0.18,0.65) if selection_kind=="selected" else Color(0.3,0.95,0.8,0.48)
  style.shadow_size=9
 style.set_corner_radius_all(10)
 $Canvas/Frame.add_theme_stylebox_override("panel", style)
 $Canvas/Artwork.modulate = Color(0.5, 0.5, 0.6) if exhausted else Color.WHITE
 $Canvas/Exhausted.texture = CardSkin.texture("attack-spent-icon" if get_meta("attacked_this_turn",false) else "tap-icon" if get_meta("exhausting_action_taken",false) else "exhausted-zzz")
 var waiting: bool=get_meta("summoned_this_turn",false) and not get_meta("attacked_this_turn",false) and not get_meta("exhausting_action_taken",false)
 $Canvas/Exhausted.visible = exhausted and (waiting or selection_kind=="selected")
 refresh_ability_icons(attack,health)

func refresh_ability_icons(attack: int, health: int) -> void:
 var holder: GridContainer=$Canvas/StatusIcons
 for child in holder.get_children():
  holder.remove_child(child)
  child.queue_free()
 var context: Dictionary=get_meta("ability_context",{})
 var block_value: int=int(get_meta("block",-1))
 var entries:=card_data.ability_entries(block_value,int(context.get("magic_bonus",0)),int(get_meta("armor",card_data.armor)),bool(get_meta("vigor",false)),int(get_meta("poison",0)),int(context.get("aura_attack",0)),int(get_meta("abascanto",card_data.abascanto)))
 if context.get("turn_flying",false) and not card_data.flying:
  entries.append({"name":"Voo temporário","badge":"Flying","icon":"flying-icon","description":"Ignora Bloqueio até o fim do turno."})
 if int(context.get("bleeding",0))>0:
  entries.append({"name":"Sangramento %d" % int(context.bleeding),"badge":"Bleeding","icon":"bleed-icon","value":int(context.bleeding),"description":"Após agir, perde vida igual ao Sangramento. Termina ao fim do turno do dono ou com Cura."})
 entries=entries.filter(func(e):return e.has("badge") and e.badge not in ["Entry","Swift","AuraBonus"])
 for entry in entries:
  var badge:=HBoxContainer.new()
  badge.name=entry.badge
  badge.mouse_filter=Control.MOUSE_FILTER_IGNORE
  badge.add_theme_constant_override("separation",1)
  holder.add_child(badge)
  var icon:=TextureRect.new()
  icon.name="Icon"
  icon.texture=CardSkin.texture(entry.get("badge_icon",entry.get("icon","")))
  icon.custom_minimum_size=Vector2(23,23)
  icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
  icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  icon.mouse_filter=Control.MOUSE_FILTER_IGNORE
  badge.add_child(icon)
  var value=entry.get("value","")
  if entry.badge=="Vigor":value=maxi(attack,health)
  var number:=Label.new()
  number.name="Value"
  number.text=str(value)
  number.mouse_filter=Control.MOUSE_FILTER_IGNORE
  number.add_theme_font_size_override("font_size",14)
  number.add_theme_color_override("font_color",Color("fff4da"))
  if entry.badge=="Arcane" and int(context.get("magic_bonus",0))>0:
   number.add_theme_color_override("font_color",Color("62efa3"))
  number.add_theme_color_override("font_outline_color",Color("060b13"))
  number.add_theme_constant_override("outline_size",3)
  badge.add_child(number)
  if entry.badge=="Armor" and int(value)!=card_data.armor:
   number.add_theme_color_override("font_color",Color("62efa3") if int(value)>card_data.armor else Color("ff7682"))
  var inactive: bool=entry.badge in ["Block","Abascanto"] and int(value)==0
  if entry.has("cost"):
   var enough_mana: bool=int(context.get("mana",entry.cost))>=int(entry.cost)
   inactive=not enough_mana or (entry.get("tap",false) and exhausted)
   if entry.badge=="Heal" and context.has("heal_target"):inactive=inactive or not context.heal_target
   if entry.badge=="QuickHeal":inactive=inactive or bool(context.get("quick_heal_used",false)) or not bool(context.get("quick_heal_target",true))
   if entry.badge=="Arcane" and context.has("magic_target"):inactive=inactive or not context.magic_target
   if entry.badge=="Fury":inactive=inactive or bool(context.get("fury_used",false))
  badge.modulate.a=0.45 if inactive else 1.0
  badge.set_meta("ability_name",entry.name)
  badge.set_meta("description",entry.description)
 # Keep the compact strip against the lower edge as the number of rows changes.
 var rows: int=ceili(entries.size()/3.0)
 holder.position.y=191-mini(rows,4)*26

func _gui_input(event: InputEvent) -> void:
 if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_RIGHT and card_data:
  accept_event()
  ArtViewer.open(self,card_data)
  return
 if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
  accept_event()
  if available:activated.emit()
  else:activation_rejected.emit()

func set_card(data: CardData, health: int, enabled: bool, highlighted: bool = false, modified_attack: int = -1, remaining_block: int = -1, is_exhausted: bool = false, remaining_armor: int = -1) -> void:
 current_health = health
 available = enabled
 selected = highlighted
 exhausted = is_exhausted
 set_meta("attack", data.attack if modified_attack < 0 else modified_attack)
 set_meta("block", remaining_block)
 set_meta("armor", data.armor if remaining_armor < 0 else remaining_armor)
 card_data = data

