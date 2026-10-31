@tool
extends Control

const CardSkin = preload("res://scripts/card_skin.gd")
@export var card_data: CardData:
 set(value):
  if card_data and card_data.changed.is_connected(refresh):
   card_data.changed.disconnect(refresh)
  card_data = value
  if card_data:
   card_data.changed.connect(refresh)
  refresh()
var current_health := -1
var current_attack := -1
var current_block := -1
var hint_forced := false
var hint_layer: CanvasLayer
var hint_panel: PanelContainer
var hint_body: VBoxContainer
const ArtViewer = preload("res://scripts/art_viewer.gd")
const HOVER_DELAY := 0.25
var hover_started_at := -1
var ability_context: Dictionary = {}
const UiTheme = preload("res://scripts/ui_theme.gd")

func _ready() -> void:
 resized.connect(layout_card)
 refresh()
 layout_card()
 set_process(not Engine.is_editor_hint())

func layout_card() -> void:
 var canvas: Control = $CardCanvas
 var factor := minf(size.x / 360.0, size.y / 480.0)
 canvas.scale = Vector2.ONE * factor
 canvas.position = (size - Vector2(360, 480) * factor) / 2.0

func refresh() -> void:
 if not is_node_ready() or not card_data:
  return
 $CardCanvas/Artwork.texture = card_data.artwork
 var art: TextureRect = $CardCanvas/Artwork
 if not art.material:
  var material := ShaderMaterial.new()
  material.shader = preload("res://scripts/artwork.gdshader")
  art.material = material
 if card_data.artwork:
  var image_size: Vector2 = card_data.artwork.get_size()
  art.material.set_shader_parameter("view_aspect", 354.0 / 474.0)
  art.material.set_shader_parameter("source_aspect", image_size.x / image_size.y)
  art.material.set_shader_parameter("artwork_zoom", card_data.artwork_zoom)
  art.material.set_shader_parameter("artwork_focus", card_data.artwork_focus)
 $CardCanvas/Title.text = card_data.title
 $CardCanvas/Cost.text = str(card_data.cost)
 $CardCanvas/Stats.visible = card_data.card_type == CardData.CardType.CREATURE
 $CardCanvas/TypeLabel.visible = true
 $CardCanvas/TypeLabel.text = card_data.creature_type_name().to_upper()
 var attack := card_data.attack if current_attack < 0 else current_attack
 var health := card_data.health if current_health < 0 else current_health
 var stat_text := "%d/%d" % [attack,health]
 $CardCanvas/Stats.add_theme_font_size_override("font_size", 25 if stat_text.length() <= 3 else 19)
 $CardCanvas/Stats.variable_stats=card_data.collective and current_attack<0 and current_health<0
 $CardCanvas/Stats.set_values(attack,health,card_data.attack,card_data.health,int(ability_context.get("max_health",card_data.health)))
 var frame_style: StyleBoxFlat = $CardCanvas/Frame.get_theme_stylebox("panel").duplicate()
 frame_style.border_color = CardSkin.class_color(card_data.card_class)
 $CardCanvas/Frame.add_theme_stylebox_override("panel",frame_style)
 $CardCanvas/CostGem.texture = CardSkin.texture("mana-cost-symbol")
 # Adapt the type size to long names and ability text without rasterizing text.
 var title_size := 22 if card_data.title.length() >= 20 else 24
 var title_font: Font = $CardCanvas/Title.get_theme_font("font")
 while title_size > 20 and title_font.get_string_size(card_data.title,HORIZONTAL_ALIGNMENT_LEFT,-1,title_size).x > $CardCanvas/Title.size.x:
  title_size -= 1
 $CardCanvas/Title.add_theme_font_size_override("font_size",title_size)
 build_ability_rows()
 tooltip_text = ""

func set_card(data: CardData, remaining_health: int = -1, modified_attack: int = -1, remaining_block: int = -1) -> void:
 current_health = remaining_health
 current_attack = modified_attack
 current_block = remaining_block
 card_data = data


func build_ability_rows() -> void:
 var holder: VBoxContainer = $CardCanvas/Ability
 for child in holder.get_children():
  holder.remove_child(child)
  child.queue_free()
 for entry in view_entries():
  if entry.get("runtime",false):continue
  var row := HBoxContainer.new()
  row.alignment = BoxContainer.ALIGNMENT_CENTER
  row.mouse_filter = Control.MOUSE_FILTER_IGNORE
  row.add_theme_constant_override("separation", 5)
  holder.add_child(row)
  var state := ability_state(entry)
  row.set_meta("ability_state",state)
  if state.kind == "unavailable":
   row.modulate = Color(0.82,0.86,0.92,1)
  elif state.kind == "available":
   var dot := Label.new()
   dot.text = "•"
   dot.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
   dot.add_theme_font_size_override("font_size",12)
   dot.add_theme_color_override("font_color",Color("62efa3"))
   dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
   row.add_child(dot)
  if entry.has("icon") and not (entry.icon=="tap-icon" and entry.get("tap",false)):
   row.add_child(ability_icon(entry.icon))
  var label := Label.new()
  label.text = entry.name+(" — "+str(entry.summary) if entry.get("summary","")!="" else "")
  var boosted: bool=int(ability_context.get("magic_bonus",0))>0 and (entry.get("badge","")=="Arcane" or (entry.get("spell",false) and card_data.spell_effect in [CardData.SpellEffect.AREA_ARCANE,CardData.SpellEffect.ARCANE,CardData.SpellEffect.CONDUCTIVE,CardData.SpellEffect.MAGIC_MISSILES]))
  var boosted_value: String=""
  if boosted:
   for index in range(label.text.length()):
    if label.text.substr(index,1) in ["0","1","2","3","4","5","6","7","8","9"]:
     boosted_value=label.text.substr(index)
     label.text=label.text.substr(0,index)
     break
  label.mouse_filter = Control.MOUSE_FILTER_IGNORE
  label.add_theme_font_size_override("font_size", 16)
  label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
  label.add_theme_color_override("font_color", Color("f1ead9"))
  label.add_theme_color_override("font_outline_color",Color(0.015,0.02,0.03,0.9))
  label.add_theme_constant_override("outline_size",2)
  row.add_child(label)
  if not boosted_value.is_empty():
   var value_label:=Label.new()
   value_label.name="BoostedMagicValue"
   value_label.text=boosted_value
   value_label.mouse_filter=Control.MOUSE_FILTER_IGNORE
   value_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
   value_label.add_theme_font_size_override("font_size",16)
   value_label.add_theme_color_override("font_color",Color("62efa3"))
   value_label.add_theme_color_override("font_outline_color",Color(0.015,0.02,0.03,0.9))
   value_label.add_theme_constant_override("outline_size",2)
   row.add_child(value_label)
  if entry.has("cost") and not entry.get("spell",false):
   var separator := Label.new()
   separator.text = "—"
   separator.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
   separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
   separator.add_theme_font_size_override("font_size", 14)
   row.add_child(separator)
   var cost := Control.new()
   cost.name = "AbilityManaCost"
   cost.custom_minimum_size = Vector2(28,28)
   cost.mouse_filter = Control.MOUSE_FILTER_IGNORE
   row.add_child(cost)
   var gem := ability_icon("mana-cost-symbol", 28)
   gem.size = Vector2(28,28)
   cost.add_child(gem)
   var value := Label.new()
   value.text = str(entry.cost)
   value.position = Vector2(0,-2)
   value.size = Vector2(28,28)
   value.add_theme_font_override("font", $CardCanvas/Cost.get_theme_font("font"))
   value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
   value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
   value.add_theme_font_size_override("font_size", 20)
   value.add_theme_color_override("font_color", Color("111319"))
   value.add_theme_color_override("font_outline_color", Color("071322"))
   value.add_theme_constant_override("outline_size", 0)
   value.mouse_filter = Control.MOUSE_FILTER_IGNORE
   cost.add_child(value)
  if entry.get("tap", false):
   row.add_child(ability_icon("tap-icon"))
 var needed: float=0.0
 for row in holder.get_children():needed+=row.get_combined_minimum_size().y
 needed+=maxi(0,holder.get_child_count()-1)*5
 holder.position.y=416-needed
 holder.size.y=needed
 if is_instance_valid(hint_panel):
  update_hint_contents()

func ability_icon(asset: String, icon_size: int = 20) -> TextureRect:
 var icon := TextureRect.new()
 icon.custom_minimum_size = Vector2(icon_size,icon_size)
 icon.texture = CardSkin.texture(asset)
 icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
 return icon

func set_hint_forced(value: bool, immediate: bool = false) -> void:
 hint_forced = value
 hover_started_at = Time.get_ticks_msec() - int(HOVER_DELAY*1000) if immediate and value else -1
 if not value and is_instance_valid(hint_panel):
  hint_panel.hide()

func _process(_delta: float) -> void:
 if not card_data or not is_visible_in_tree() or ArtViewer.is_open(self):
  hover_started_at = -1
  if is_instance_valid(hint_panel):
   hint_panel.hide()
  return
 var hovered := get_viewport().gui_get_hovered_control()
 var local_hover: bool = mouse_filter != Control.MOUSE_FILTER_IGNORE and not get_meta("preview_managed", false) and (hovered == self or (is_instance_valid(hovered) and is_ancestor_of(hovered)))
 if not hint_forced and not local_hover:
  hover_started_at = -1
  if is_instance_valid(hint_panel):
   hint_panel.hide()
  return
 if hover_started_at < 0:
  hover_started_at = Time.get_ticks_msec()
 if Time.get_ticks_msec() - hover_started_at < int(HOVER_DELAY*1000):
  return
 ensure_hint()
 hint_panel.show()
 position_hint()

func ensure_hint() -> void:
 if is_instance_valid(hint_panel):
  return
 hint_layer = CanvasLayer.new()
 hint_layer.layer = 35
 add_child(hint_layer)
 hint_panel = PanelContainer.new()
 hint_panel.name = "AbilityHint"
 hint_panel.custom_minimum_size.x = 300
 hint_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
 hint_panel.add_theme_stylebox_override("panel", UiTheme.panel(Color("0b1420"), Color("697384"), 16))
 hint_layer.add_child(hint_panel)
 hint_body = VBoxContainer.new()
 hint_body.add_theme_constant_override("separation", 10)
 hint_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
 hint_panel.add_child(hint_body)
 update_hint_contents()

func update_hint_contents() -> void:
 for child in hint_body.get_children():
  hint_body.remove_child(child)
  child.queue_free()
 for entry in view_entries():
  var heading := Label.new()
  heading.text = entry.name
  heading.add_theme_font_size_override("font_size", 18)
  heading.add_theme_color_override("font_color", Color("e9d09a"))
  heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
  hint_body.add_child(heading)
  var state := ability_state(entry)
  if state.kind != "neutral":
   var status := Label.new()
   status.text = state.label
   status.add_theme_font_size_override("font_size",13)
   status.modulate = Color("62efa3") if state.kind == "available" else Color("92a1b3")
   status.mouse_filter = Control.MOUSE_FILTER_IGNORE
   hint_body.add_child(status)
  var details := Label.new()
  details.text = entry.description
  details.custom_minimum_size.x = 268
  details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
  details.add_theme_font_size_override("font_size", 16)
  details.add_theme_color_override("font_color", Color("ccd5e0"))
  details.mouse_filter = Control.MOUSE_FILTER_IGNORE
  hint_body.add_child(details)

 hint_panel.reset_size()

func position_hint() -> void:
 var bounds := get_global_rect()
 var view := get_viewport_rect().size
 var hint_size := hint_panel.size
 var x := bounds.end.x + 12
 if x + hint_size.x > view.x - 12:
  x = bounds.position.x - hint_size.x - 12
 hint_panel.position = Vector2(clampf(x,12,maxf(12,view.x-hint_size.x-12)), clampf(bounds.position.y+24,12,maxf(12,view.y-hint_size.y-12)))

func ability_state(entry: Dictionary) -> Dictionary:
 if not entry.has("cost"):
  return {"kind":"neutral","label":"Passiva"}
 if ability_context.is_empty():
  return {"kind":"neutral","label":""}
 var reason := ""
 if not ability_context.get("on_board",false) and not entry.get("spell",false):
  reason = "Invoque esta criatura primeiro"
 elif ability_context.get("side",0)!=0:
  reason = "Habilidade do adversário"
 elif ability_context.get("turn",0)!=0:
  reason = "Aguarde seu turno"
 elif ability_context.get("busy",false) or ability_context.get("winner",-1)!=-1:
  reason = "Indisponível agora"
 elif int(ability_context.get("mana",0)) < int(entry.cost):
  reason = "Mana insuficiente"
 elif entry.get("tap",false) and not ability_context.get("ready",false):
  reason = "Criatura esgotada"
 elif entry.get("spell",false) and not ability_context.get("castable",false):
  reason = "Sem alvo válido"
 elif entry.get("badge","")=="QuickHeal" and ability_context.get("quick_heal_used",false):
  reason = "Já usada neste turno"
 elif entry.get("badge","")=="QuickHeal" and not ability_context.get("quick_heal_target",true):
  reason = "Sem alvo válido"
 elif card_data.magic_damage>0 and not ability_context.get("magic_target",true):
  reason = "Sem criatura inimiga como alvo"
 elif card_data.heal_amount>0 and not ability_context.get("heal_target",true):
  reason = "Nenhum aliado precisa de cura"
 return {"kind":"available" if reason.is_empty() else "unavailable","label":"Disponível" if reason.is_empty() else reason}

func _gui_input(event: InputEvent) -> void:
 if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_RIGHT and card_data:
  accept_event()
  if get_meta("disable_art_viewer",false):return
  set_hint_forced(false)
  ArtViewer.open(self,card_data)

func view_entries() -> Array[Dictionary]:
 var entries := card_data.ability_entries(current_block,int(ability_context.get("magic_bonus",0)),int(ability_context.get("armor",-1)),bool(ability_context.get("vigor",false)),int(ability_context.get("poison",0)),int(ability_context.get("aura_attack",0)),int(ability_context.get("abascanto",-1)))
 if int(ability_context.get("bleeding",0))>0:
  entries.append({"name":"Sangramento %d" % int(ability_context.bleeding),"icon":"bleed-icon","runtime":true,"description":"Após cada ação, perde esta quantidade de vida ignorando Armadura. Termina ao fim do turno do dono ou com Cura."})
 for entry in entries:
  if card_data.collective and ability_context.get("on_board",false) and entry.name not in ["Multidão","Lendária"]:entry["runtime"]=true
  if entry.name=="Vigor":
   var attack := card_data.attack if current_attack<0 else current_attack
   var health := card_data.health if current_health<0 else current_health
   entry.description += "\nForça física atual (ataque e defesa): %d." % maxi(attack,health)
 if int(ability_context.get("turn_attack",0))>0:
  entries.append({"name":"Bônus temporário","icon":"fury-icon","runtime":true,"description":"Recebe +%d de ataque até o fim deste turno." % int(ability_context.turn_attack)})
 if ability_context.get("turn_flying",false) and not card_data.flying:
  entries.append({"name":"Voo temporário","icon":"flying-icon","runtime":true,"description":"Ignora Bloqueio até o fim do turno."})
 if ability_context.get("turn_swift",false) and not card_data.swift:
  entries.append({"name":"Arrancada temporária","icon":"swift-icon","runtime":true,"description":"Pode atacar no turno de invocação se ainda não tiver agido. Não permite agir novamente."})
 return entries
