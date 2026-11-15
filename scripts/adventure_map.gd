extends Control
signal route_selected(index: int)
const Match=preload("res://scripts/match.gd")
const MapTexture=preload("res://assets/ui/adventure-world-map.webp")
const Names=preload("res://scripts/faction_names.gd")
var run
func configure(state) -> void:
 run=state
 run.ensure_routes()
 custom_minimum_size=Vector2((run.route_rows.size()-1)*190+260,720)
 var backdrop:=TextureRect.new()
 backdrop.name="AdventureMapBackdrop"
 backdrop.texture=MapTexture
 backdrop.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 backdrop.stretch_mode=TextureRect.STRETCH_SCALE
 backdrop.mouse_filter=Control.MOUSE_FILTER_IGNORE
 backdrop.show_behind_parent=true
 var reveal:=ShaderMaterial.new()
 reveal.shader=preload("res://scripts/adventure_map_reveal.gdshader")
 reveal.set_shader_parameter("revealed_until",reveal_progress())
 backdrop.material=reveal
 add_child(backdrop)
 backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 for at in range(run.route_rows.size()):
  var caption:=Label.new();caption.text=str(at+1)+" · "+["Vila","Estrada","Campos","Bosque","Encruzilhada","Ruínas","Entreposto","Fronteira","Portões","Último fogo","Abrigo","Fenda"][at];caption.position=Vector2(20+at*190,4);caption.add_theme_font_size_override("font_size",14);caption.add_theme_color_override("font_color",Color("f2dbae"));caption.add_theme_color_override("font_shadow_color",Color.BLACK);caption.add_theme_constant_override("shadow_offset_y",2);add_child(caption)
  for branch in range(run.route_rows[at].size()):
   var data: Dictionary=run.route_rows[at][branch]
   var b:=Button.new();b.set_script(preload("res://scripts/adventure_map_node.gd"))
   b.name="Route_%d_%d" % [at,branch]
   b.position=node_center(at,branch)-Vector2(50,50);b.size=Vector2(100,100)
   for style in ["normal","hover","pressed","disabled","focus"]:b.add_theme_stylebox_override(style,StyleBoxEmpty.new())
   b.disabled=at!=run.step or not run.route_available(branch)
   b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND if at==run.step else Control.CURSOR_ARROW
   b.pressed.connect(func():
    if not get_parent().get("drag_moved"):route_selected.emit(branch))
   add_child(b)
   var art:=TextureRect.new();art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
   art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;art.mouse_filter=Control.MOUSE_FILTER_IGNORE
   var special: String={"treasure":"res://assets/ui/adventure-gold-icon.svg","healer":"res://assets/ui/adventure-healer-icon.svg","shop":"res://assets/ui/adventure-merchant-icon.svg","power_event":"res://assets/ui/adventure-power-sanctuary.webp","chest":"res://assets/ui/adventure-chest.webp","item":"res://assets/ui/adventure-items.webp"}.get(data.kind,"")
   art.texture=load(special) if not special.is_empty() else Match.CARD_DATA[data.portrait].artwork
   var material:=ShaderMaterial.new();material.shader=preload("res://scripts/adventure_node.gdshader")
   if not special.is_empty():material.set_shader_parameter("crop",Vector2.ONE);material.set_shader_parameter("focus",Vector2(0.5,0.5))
   if data.kind=="chest":material.set_shader_parameter("crop",Vector2(0.42,0.58));material.set_shader_parameter("focus",Vector2(0.40,0.49))
   material.set_shader_parameter("rim",Color("f5ca68") if at==run.step and run.route_available(branch) else Color("bd6558") if data.kind=="boss" else Color("76b89b") if data.kind not in ["combat","boss"] else Color("8e9aa4"))
   art.material=material;b.add_child(art)
   if at!=run.step:b.modulate=Color(0.8,0.82,0.85) if at>run.step else Color(0.65,0.65,0.65)
   if at<run.step and run.chosen_routes.get(at,-1)==branch:b.modulate=Color.WHITE
   var label:=Label.new();label.position=b.position+Vector2(-32,104);label.size=Vector2(164,52);label.add_theme_font_size_override("font_size",18);label.max_lines_visible=2;label.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS;label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
   var title: String={"farm":"Fazenda","item":"Item","bridge":"Ponte dos bandidos","chest":"Baú · 50% mímico","healer":"Curandeira","treasure":"Tesouro","shop":"Loja","power_event":"Poder"}.get(data.kind,"")
   if data.kind in ["combat","boss"]:title="Dragão Negro · chefe final" if data.kind=="boss" else "Duelo · "+Names.PT[data.faction]
   if data.get("preparation",false):title="Reforço · "+title
   label.add_theme_color_override("font_color",Color("fff4de"));label.add_theme_color_override("font_shadow_color",Color.BLACK);label.add_theme_constant_override("shadow_offset_x",1);label.add_theme_constant_override("shadow_offset_y",2);label.add_theme_constant_override("outline_size",3);label.add_theme_color_override("font_outline_color",Color("172028"))
   label.text=title;add_child(label)
   b.tooltip_text=title+(" · escolha este caminho" if at==run.step else " · caminho futuro" if at>run.step else " · etapa concluída")
 queue_redraw()
func _ready() -> void:
 await get_tree().process_frame
 await get_tree().process_frame
 if get_parent().has_method("follow_stage"):get_parent().follow_stage(node_center(run.step,0).x)
func node_center(at: int,branch: int) -> Vector2:
 return Vector2(89+at*190,100+(4-run.route_rows[at].size())*80+branch*160)
func _draw() -> void:
 if run==null:return
 var bounds:=Rect2(Vector2.ZERO,Vector2(custom_minimum_size.x,720))
 draw_rect(bounds,Color("a58c5b"),false,2)
 for at in range(run.route_rows.size()-1):
  for a in range(run.route_rows[at].size()):
   for b in range(run.route_rows[at+1].size()):
    if run.linked(at,a,b):
     var used: bool=run.chosen_routes.get(at,-1)==a and run.chosen_routes.get(at+1,-1)==b
     var next: bool=at==run.step-1 and run.chosen_routes.get(at,-1)==a and run.route_available(b)
     draw_line(node_center(at,a),node_center(at+1,b),Color(0.05,0.07,0.08,0.8),6,true)
     draw_line(node_center(at,a),node_center(at+1,b),Color("e3bd70") if used or next else Color("80918c"),3 if used or next else 2,true)








func reveal_progress() -> float:
 return clampf(float(run.step+1)/maxi(1,run.route_rows.size()),0.0,1.0)
