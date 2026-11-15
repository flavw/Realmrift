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
 $CardCanvas/Ability.minimum_size_changed.connect(layout_ability_footer)
 refresh()
 layout_card()
 set_process(not Engine.is_editor_hint())

func layout_card() -> void:
 var canvas: Control = $CardCanvas
 var factor := minf(size.x / 360.0, size.y / 480.0)
 canvas.scale = Vector2.ONE * factor
 canvas.position = (size - Vector2(360, 480) * factor) / 2.0

func design_rect(node: Control,rect: Rect2) -> void:
 node.position=rect.position
 node.size=rect.size

func apply_design() -> void:

 design_rect($CardCanvas/Artwork,Rect2(5,5,350,470))
 design_rect($CardCanvas/Title,Rect2(56,16,248,28))
 design_rect($CardCanvas/CostGem,Rect2(14,14,34,34))
 design_rect($CardCanvas/Cost,Rect2(11,9,40,44))
 $CardCanvas/Cost.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 $CardCanvas/Cost.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
 design_rect($CardCanvas/Stats,Rect2(264,412,78,46))
 design_rect($CardCanvas/TypeLabel,Rect2(22,455,316,18))
 $CardCanvas/Ability.position.x=22
 $CardCanvas/Title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 $CardCanvas/TypeLabel.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 $CardCanvas/Title.add_theme_font_override("font",preload("res://assets/fonts/card_title_font.tres"))
 $CardCanvas/Cost.add_theme_font_size_override("font_size",32)
 $CardCanvas/Cost.size=Vector2(40,44)
 $CardCanvas/CostGem.hide()
 $CardCanvas/Cost.add_theme_color_override("font_color",Color.WHITE)
 # Center the visible glyph, independent of the font's ascender/descender padding.
 $CardCanvas/Cost.self_modulate.a=0
 var number: Control=$CardCanvas/Cost.get_node_or_null("CenteredNumber")
 if number==null:
  number=preload("res://scripts/centered_mana_number.gd").new()
  number.name="CenteredNumber";number.mouse_filter=Control.MOUSE_FILTER_IGNORE
  $CardCanvas/Cost.add_child(number)
 number.outlined=true
 number.legendary=card_data.legendary
 number.queue_redraw()
 $CardCanvas/Stats.add_theme_font_override("font",$CardCanvas/Cost.get_theme_font("font"))
 $CardCanvas/TypeLabel.add_theme_font_size_override("font_size",11)
 var fade: GradientTexture2D=$CardCanvas/RulesPanel.texture.duplicate(true)
 fade.gradient.colors=PackedColorArray([Color(0.018,0.02,0.025,0),Color(0.018,0.02,0.025,0.55),Color(0.018,0.02,0.025,0.91),Color(0.018,0.02,0.025,0.98)])
 $CardCanvas/RulesPanel.texture=fade

func refresh() -> void:
 if not is_node_ready() or not card_data:
  return
 apply_design()
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
 $CardCanvas/TypeLabel.text = ("LENDÁRIA · " if card_data.legendary else "")+card_data.creature_type_name().to_upper()
 var attack := card_data.attack if current_attack < 0 else current_attack
 var health := card_data.health if current_health < 0 else current_health
 var stat_text := "%d/%d" % [attack,health]
 $CardCanvas/Stats.add_theme_font_size_override("font_size", 32 if stat_text.length()<=3 else 25)
 $CardCanvas/Stats.variable_stats=card_data.collective and current_attack<0 and current_health<0
 $CardCanvas/Stats.set_values(attack,health,card_data.attack,card_data.health,int(ability_context.get("max_health",card_data.health)))
 var frame_style: StyleBoxFlat = $CardCanvas/Frame.get_theme_stylebox("panel").duplicate()
 frame_style.border_color = CardSkin.faction_color(card_data.faction)
 frame_style.set_border_width_all(4)
 frame_style.set_corner_radius_all(12)
 frame_style.draw_center=false
 $CardCanvas/Frame.z_index=1
 $CardCanvas/Frame.add_theme_stylebox_override("panel",frame_style)
 $CardCanvas/Artwork.material.set_shader_parameter("corner_radius",8.0)
 $CardCanvas/CostGem.texture = null
 # Adapt the type size to long names and ability text without rasterizing text.
 var title_size := 22
 var title_font: Font = $CardCanvas/Title.get_theme_font("font")
 while title_size > 15 and title_font.get_string_size(card_data.title,HORIZONTAL_ALIGNMENT_LEFT,-1,title_size).x > $CardCanvas/Title.size.x:
  title_size -= 1
 $CardCanvas/Title.add_theme_font_size_override("font_size",title_size)
 var title: Label=$CardCanvas/Title
 title.position.y=$CardCanvas/CostGem.get_rect().get_center().y-title.size.y*0.5
 title.self_modulate.a=0
 var centered_title: Control=title.get_node_or_null("CenteredTitle")
 if centered_title==null:
  centered_title=preload("res://scripts/centered_mana_number.gd").new()
  centered_title.name="CenteredTitle";centered_title.mouse_filter=Control.MOUSE_FILTER_IGNORE
  title.add_child(centered_title)
 centered_title.shadow_enabled=true
 centered_title.text_outline_size=2 if card_data.legendary else 0
 centered_title.queue_redraw()
 build_ability_rows()
 preload("res://scripts/adventure_items.gd").decorate(self,card_data)
 tooltip_text = ""

func set_card(data: CardData, remaining_health: int = -1, modified_attack: int = -1, remaining_block: int = -1) -> void:
 current_health = remaining_health
 current_attack = modified_attack
 current_block = remaining_block
 card_data = data


func build_ability_rows() -> void:
 var holder: VBoxContainer = $CardCanvas/Ability

 holder.size.x=316 if card_data.card_type==CardData.CardType.SPELL or card_data.wide_entry_summary else 228
 for child in holder.get_children():
  holder.remove_child(child)
  child.queue_free()
 for entry in view_entries():
  if entry.get("runtime",false):continue
  var row := HBoxContainer.new()
  row.alignment = BoxContainer.ALIGNMENT_CENTER if card_data.card_type==CardData.CardType.SPELL else BoxContainer.ALIGNMENT_BEGIN
  row.mouse_filter = Control.MOUSE_FILTER_IGNORE
  row.add_theme_constant_override("separation", 0)
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
  if entry.has("icon") and entry.icon!="tap-icon":
   var icon:=ability_icon(entry.icon)
   icon.custom_minimum_size.x=24
   row.add_child(icon)
   var icon_gap:=Control.new()
   icon_gap.name="AbilityIconGap";icon_gap.custom_minimum_size.x=3
   icon_gap.mouse_filter=Control.MOUSE_FILTER_IGNORE
   row.add_child(icon_gap)
  var label := Label.new()
  label.name="RuleText"
  label.text = String(entry.summary) if entry.get("badge","")=="Entry" and not String(entry.get("summary","")).is_empty() else String(entry.name)
  var boosted: bool=int(ability_context.get("magic_bonus",0))>0 and (entry.get("badge","") in ["Arcane","Necrotic"] or (entry.get("spell",false) and card_data.spell_effect in [CardData.SpellEffect.SEPULCHRAL_TIDE,CardData.SpellEffect.AREA_ARCANE,CardData.SpellEffect.ARCANE,CardData.SpellEffect.CONDUCTIVE,CardData.SpellEffect.MAGIC_MISSILES]))
  var boosted_value: String=""
  if boosted and not entry.get("spell",false):
   for index in range(label.text.length()):
    if label.text.substr(index,1) in ["0","1","2","3","4","5","6","7","8","9"]:
     boosted_value=label.text.substr(index)
     label.text=label.text.substr(0,index)
     break
  label.mouse_filter = Control.MOUSE_FILTER_IGNORE
  label.add_theme_font_size_override("font_size", 18)
  label.add_theme_font_override("font",preload("res://assets/fonts/spell_rules_font.tres") if card_data.card_type==CardData.CardType.SPELL else $CardCanvas/Cost.get_theme_font("font"))
  label.size_flags_horizontal=Control.SIZE_SHRINK_BEGIN
  # Explicit line breaks avoid width/height feedback while containers are sorting.
  label.autowrap_mode=TextServer.AUTOWRAP_OFF
  label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if card_data.card_type==CardData.CardType.SPELL else HORIZONTAL_ALIGNMENT_LEFT
  label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
  label.add_theme_color_override("font_color", Color("62efa3") if boosted and entry.get("spell",false) else Color("f1ead9"))
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
  if int(entry.get("cost",0))>0 and not entry.get("spell",false):
   var gap:=Control.new()
   gap.custom_minimum_size.x=6
   gap.mouse_filter=Control.MOUSE_FILTER_IGNORE
   row.add_child(gap)
   var cost := Control.new()
   cost.name = "AbilityManaCost"
   cost.custom_minimum_size = Vector2(24,24)
   cost.size_flags_vertical=Control.SIZE_SHRINK_CENTER
   cost.mouse_filter = Control.MOUSE_FILTER_IGNORE
   row.add_child(cost)
   var gem := ability_icon("ability-mana-diamond", 24)
   gem.size = Vector2(24,24)
   cost.add_child(gem)
   var value := Label.new()
   value.text = str(entry.cost)
   value.position = Vector2.ZERO
   value.size = Vector2(24,24)
   value.add_theme_font_override("font", $CardCanvas/Cost.get_theme_font("font"))
   value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
   value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
   value.add_theme_font_size_override("font_size", 14)
   value.size=Vector2(24,24)
   value.add_theme_color_override("font_color", Color.WHITE)
   value.add_theme_color_override("font_outline_color", Color("071322"))
   value.add_theme_constant_override("outline_size", 0)
   value.mouse_filter = Control.MOUSE_FILTER_IGNORE
   cost.add_child(value)
   value.self_modulate.a=0
   var number:=preload("res://scripts/centered_mana_number.gd").new()
   number.fill_color=Color("c4f2ff")
   number.mouse_filter=Control.MOUSE_FILTER_IGNORE
   value.add_child(number)
  var available_width: float=holder.size.x
  for child in row.get_children():
   if child!=label:available_width-=child.get_combined_minimum_size().x
  var font: Font=label.get_theme_font("font")
  var font_size: int=18
  var minimum_font_size: int=14 if entry.get("badge","")=="Entry" else 12
  while font_size>minimum_font_size and font.get_multiline_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>available_width:
   font_size-=1
  label.add_theme_font_size_override("font_size",font_size)
  label.text=wrap_ability_text(label.text,font,font_size,maxf(1,available_width))
  var text_width: float=font.get_multiline_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
  label.custom_minimum_size.x=maxf(1,minf(available_width,text_width))
  label.size.x=label.custom_minimum_size.x
 layout_ability_footer()
 if is_instance_valid(hint_panel):
  update_hint_contents()

func wrap_ability_text(text: String,font: Font,font_size: int,width: float) -> String:
 var lines: PackedStringArray=[]
 for paragraph in text.split("\n"):
  var line: String=""
  for word in paragraph.split(" ",false):
   var candidate: String=word if line.is_empty() else line+" "+word
   if not line.is_empty() and font.get_string_size(candidate,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>width:
    lines.append(line);line=word
   else:line=candidate
  lines.append(line)
 return "\n".join(lines)

func layout_ability_footer() -> void:
 if not is_node_ready():return
 var holder: VBoxContainer=$CardCanvas/Ability
 var needed: float=0
 for row in holder.get_children():needed+=row.get_combined_minimum_size().y
 needed+=maxi(0,holder.get_child_count()-1)*holder.get_theme_constant("separation")
 holder.size.y=needed
 holder.position.y=maxf(80,452-needed)
 design_rect($CardCanvas/TypeLabel,Rect2(22,holder.position.y-25,316,20))
 $CardCanvas/RulesPanel.position.y=clampf(holder.position.y-60,5,330)
 $CardCanvas/RulesPanel.size.y=475-$CardCanvas/RulesPanel.position.y

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
 elif (card_data.magic_damage>0 or card_data.necrotic_damage>0) and not ability_context.get("magic_target",true):
  reason = "Sem alvo válido"
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
 var entries := card_data.ability_entries(current_block,int(ability_context.get("magic_bonus",0)),int(ability_context.get("armor",-1)),bool(ability_context.get("vigor",false)),int(ability_context.get("poison",0)),int(ability_context.get("aura_attack",0)),int(ability_context.get("antimagic",-1)))
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
 if ability_context.get("granted_impulsive",false) and not card_data.impulsive:
  entries.append({"name":"Impulsivo","icon":"impulsive-icon","runtime":true,"description":"Ataca automaticamente ao encerrar seu turno, se estiver apto."})
 if ability_context.get("turn_impulsive",false) and not card_data.impulsive and not ability_context.get("granted_impulsive",false):
  entries.append({"name":"Impulsivo temporário","icon":"impulsive-icon","runtime":true,"description":"Até o fim deste turno, ataca automaticamente ao encerrar o turno se estiver apto."})
 if ability_context.get("turn_swift",false) and not card_data.swift:
  entries.append({"name":"Disparada temporária","icon":"swift-icon","runtime":true,"description":"Pode atacar no turno de invocação se ainda não tiver agido. Não permite agir novamente."})
 if ability_context.get("farm_blessing",false):entries.append({"name":"Bênção da fazenda","description":"+1 de vida atual e máxima em todos os combates restantes desta expedição. Grande presente à Camponesa Generosa." if ability_context.get("farm_blessing_persistent",false) else "+1 de vida atual e máxima durante este combate. Presente da Camponesa Generosa.","runtime":true})
 entries.append_array(preload("res://scripts/adventure_items.gd").entries(card_data))
 return entries




