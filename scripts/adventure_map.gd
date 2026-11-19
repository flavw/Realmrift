extends Control
signal route_selected(index: int)
const Match=preload("res://scripts/match.gd")
const MapTexture=preload("res://assets/ui/adventure-world-map-expanded.webp")
const MAP_SIZE=Vector2(3240,1080)
const STAGE_X=[0.055,0.12,0.20,0.31,0.39,0.47,0.56,0.63,0.71,0.77,0.83,0.875,0.92,0.965]
const STAGE_Y=[[0.40,0.68],[0.22,0.56],[0.44,0.79],[0.71,0.48],[0.28,0.69],[0.42,0.23,0.66,0.84],[0.33,0.65],[0.84,0.35,0.58],[0.28,0.62],[0.45,0.77],[0.30,0.60],[0.42,0.82],[0.36,0.68],[0.24]]
const Names=preload("res://scripts/faction_names.gd")
const State=preload("res://scripts/adventure_state.gd")
var run
func configure(state) -> void:
 run=state
 run.ensure_routes()
 custom_minimum_size=MAP_SIZE
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
  var caption:=Label.new();caption.text=str(at+1)+" · "+["Vila","Estrada","Travessia","Caravana","Bosque","Santuário","Ruínas","Destino","Entreposto","Fronteira","Portões","Último fogo","Abrigo","Fenda"][at];caption.position=Vector2(maxf(15,MAP_SIZE.x*STAGE_X[at]-65),16+(at%2)*22);caption.add_theme_font_size_override("font_size",14);caption.add_theme_color_override("font_color",Color("f2dbae"));caption.add_theme_color_override("font_shadow_color",Color.BLACK);caption.add_theme_constant_override("shadow_offset_y",2);add_child(caption)
  for branch in range(run.route_rows[at].size()):
   var data: Dictionary=run.route_rows[at][branch]
   var b:=Button.new();b.set_script(preload("res://scripts/adventure_map_node.gd"))
   b.name="Route_%d_%d" % [at,branch]
   b.position=node_center(at,branch)-Vector2(50,50);b.size=Vector2(100,100)
   for style in ["normal","hover","pressed","disabled","focus"]:b.add_theme_stylebox_override(style,StyleBoxEmpty.new())
   b.disabled=at!=run.step or not run.route_available(branch)
   b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND if not b.disabled else Control.CURSOR_ARROW
   b.pressed.connect(func():
    if not get_parent().get("drag_moved"):route_selected.emit(branch))
   add_child(b)
   var art:=TextureRect.new();art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
   art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;art.mouse_filter=Control.MOUSE_FILTER_IGNORE
   var special: String={"bridge":"res://assets/ui/adventure-bridge.webp","fortune":"res://assets/ui/fortune-icon.svg","treasure":"res://assets/ui/adventure-gold-icon.svg","healer":"res://assets/ui/adventure-healer-icon.svg","power_event":"res://assets/ui/adventure-power-sanctuary.webp","chest":"res://assets/ui/adventure-chest.webp","item":"res://assets/ui/adventure-items.webp"}.get(data.kind,"")
   if data.kind=="shop":special=State.merchant_at(at).art
   art.texture=load(special) if not special.is_empty() else Match.CARD_DATA[data.portrait].artwork
   var material:=ShaderMaterial.new();material.shader=preload("res://scripts/adventure_node.gdshader")
   if not special.is_empty():material.set_shader_parameter("crop",Vector2.ONE);material.set_shader_parameter("focus",Vector2(0.5,0.5))
   if data.kind=="chest":material.set_shader_parameter("crop",Vector2(0.42,0.58));material.set_shader_parameter("focus",Vector2(0.40,0.49))
   if data.kind=="bridge":material.set_shader_parameter("crop",Vector2(0.5,0.75));material.set_shader_parameter("focus",Vector2(0.69,0.5))
   if data.kind=="river":material.set_shader_parameter("crop",Vector2(0.50,0.32));material.set_shader_parameter("focus",Vector2(0.65,0.27))
   if data.kind=="shop":material.set_shader_parameter("crop",Vector2(0.34,0.51));material.set_shader_parameter("focus",Vector2(0.50,0.33))
   material.set_shader_parameter("rim",Color("f5ca68") if at==run.step and run.route_available(branch) else Color("bd6558") if data.kind=="boss" else Color("76b89b") if data.kind not in ["combat","boss"] else Color("8e9aa4"))
   art.material=material;b.add_child(art)
   if at!=run.step:b.modulate=Color(0.8,0.82,0.85) if at>run.step else Color(0.65,0.65,0.65)
   if at<run.step and run.chosen_routes.get(at,-1)==branch:b.modulate=Color.WHITE
   if not b.disabled:
    b.mouse_entered.connect(func():material.set_shader_parameter("highlight",true))
    b.mouse_exited.connect(func():material.set_shader_parameter("highlight",b.has_focus()))
    b.focus_entered.connect(func():material.set_shader_parameter("highlight",true))
    b.focus_exited.connect(func():material.set_shader_parameter("highlight",b.get_local_mouse_position().distance_to(b.size*0.5)<b.size.x*0.5))
   var label:=Label.new();label.position=b.position+Vector2(-32,104);label.size=Vector2(164,52);label.add_theme_font_size_override("font_size",18);label.max_lines_visible=2;label.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS;label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
   var title: String={"farm":"Fazenda","item":"Item","bridge":"Ponte dos bandidos","river":"Vau do rio","fortune":"Sorte ou revés","chest":"Baú Misterioso","healer":"Curandeira","treasure":"Tesouro","power_event":"Poder"}.get(data.kind,"")
   if data.kind in ["combat","boss"]:title="Dragão Negro · chefe final" if data.kind=="boss" else "Duelo · "+Names.PT[data.faction]
   if data.kind=="shop":title=State.merchant_at(at).name
   if data.get("preparation",false):title="Reforço · "+title
   label.add_theme_color_override("font_color",Color("fff4de"));label.add_theme_color_override("font_shadow_color",Color.BLACK);label.add_theme_constant_override("shadow_offset_x",1);label.add_theme_constant_override("shadow_offset_y",2);label.add_theme_constant_override("outline_size",3);label.add_theme_color_override("font_outline_color",Color("172028"))
   label.text=title
   if data.kind=="shop":
    var name_row:=HBoxContainer.new()
    name_row.position=b.position+Vector2(-58,104)
    name_row.size.x=216
    name_row.alignment=BoxContainer.ALIGNMENT_CENTER
    name_row.mouse_filter=Control.MOUSE_FILTER_IGNORE
    add_child(name_row)
    var icon:=TextureRect.new()
    icon.texture=preload("res://assets/ui/adventure-merchant-icon.svg")
    icon.custom_minimum_size=Vector2(20,20)
    icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    icon.mouse_filter=Control.MOUSE_FILTER_IGNORE
    name_row.add_child(icon)
    label.autowrap_mode=TextServer.AUTOWRAP_OFF
    name_row.add_child(label)
   else:add_child(label)
   b.tooltip_text=title+(" · etapa concluída" if at<run.step else " · caminho futuro" if at>run.step else " · caminho indisponível" if b.disabled else "")
   if not b.disabled and data.kind=="combat":b.tooltip_text+="\n%d cartas · %d de vida no castelo" % [data.deck.size(),run.enemy_castle_life()]
   if not b.disabled and data.kind=="fortune":b.tooltip_text+="\nOferenda de 1 ouro · 50% de sorte e 50% de revés"
 queue_redraw()
func _ready() -> void:
 await get_tree().process_frame
 await get_tree().process_frame
 if get_parent().has_method("follow_stage"):
  var center:=Vector2.ZERO;var count:=0
  for branch in range(run.route_rows[run.step].size()):
   if run.route_available(branch):center+=node_center(run.step,branch);count+=1
  center/=maxi(1,count)
  get_parent().follow_stage(center.x,center.y+28.0)
func node_center(at: int,branch: int) -> Vector2:
 var x: float=STAGE_X[at]
 var y: float=STAGE_Y[at][branch%STAGE_Y[at].size()]
 if at==2:
  x=[0.195,0.155,0.215,0.245][branch]
 elif at==3:x=0.30 if branch==0 else 0.345
 elif at==8:x=0.71 if branch==0 else 0.68
 elif at!=run.route_rows.size()-1:x+=(-0.012 if branch%2==0 else 0.012)
 return Vector2(x*MAP_SIZE.x,y*MAP_SIZE.y)
func _draw() -> void:
 if run==null:return
 var bounds:=Rect2(Vector2.ZERO,MAP_SIZE)
 draw_rect(bounds,Color("a58c5b"),false,2)
 for at in range(run.route_rows.size()-1):
  for a in range(run.route_rows[at].size()):
   for b in range(run.route_rows[at+1].size()):
    if run.linked(at,a,b):
     var used: bool=run.chosen_routes.get(at,-1)==a and run.chosen_routes.get(at+1,-1)==b
     var next: bool=at==run.step-1 and run.chosen_routes.get(at,-1)==a and run.route_available(b)
     var points:=route_curve(node_center(at,a),node_center(at+1,b))
     draw_polyline(points,Color(0.04,0.06,0.06,0.75 if used or next else 0.3),7 if used or next else 4,true)
     draw_polyline(points,Color("e3bd70") if used or next else Color(0.68,0.73,0.63,0.45),3.5 if used or next else 1.5,true)
 if run.step>0 and run.chosen_routes.has(run.step-1):
  var here:=node_center(run.step-1,int(run.chosen_routes[run.step-1]))
  draw_arc(here,58,0,TAU,48,Color("f5d38b"),3,true)

func route_curve(from: Vector2,to: Vector2) -> PackedVector2Array:
 var points:=PackedVector2Array()
 var bend:=Vector2((to.x-from.x)*0.5,0)
 for i in range(25):points.append(from.bezier_interpolate(from+bend,to-bend,to,float(i)/24.0))
 return points








func reveal_progress() -> float:
 return 1.0 if run.step>=run.route_rows.size()-1 else clampf(float(STAGE_X[run.step])+0.075,0.0,1.0)
