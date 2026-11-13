extends Control
const Match=preload("res://scripts/match.gd")
const Identity=preload("res://scripts/player_identity.gd")
var avatar_key := ""
var level := 1
var xp_progress := 0.0
var show_level := true
var portrait: TextureRect
var level_badge: Label

func configure(key: String,player_level: int=1,progress: float=0.0) -> void:
 avatar_key=key;level=player_level;xp_progress=clampf(progress,0.0,1.0)
 if is_node_ready():refresh()

func _ready() -> void:
 custom_minimum_size=Vector2(128,128);mouse_filter=Control.MOUSE_FILTER_IGNORE
 portrait=TextureRect.new();portrait.name="AvatarPortrait";portrait.mouse_filter=Control.MOUSE_FILTER_IGNORE
 portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;portrait.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 portrait.offset_left=13;portrait.offset_right=-13;portrait.offset_top=13;portrait.offset_bottom=-13;add_child(portrait)
 level_badge=Label.new();level_badge.name="AvatarLevel";level_badge.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;level_badge.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
 level_badge.offset_left=-17;level_badge.offset_right=17;level_badge.offset_top=-28;level_badge.offset_bottom=0;level_badge.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var style:=preload("res://scripts/ui_theme.gd").panel(Color("111f2b"),Color("dabf7e"),0);style.set_corner_radius_all(12);level_badge.add_theme_stylebox_override("normal",style);level_badge.add_theme_font_size_override("font_size",16);add_child(level_badge)
 resized.connect(queue_redraw)
 refresh()

func refresh() -> void:
 if avatar_key.is_empty():avatar_key=Identity.avatar()
 var data: CardData=Match.CARD_DATA.get(avatar_key,Match.CARD_DATA.warrior)
 portrait.texture=data.artwork
 level_badge.text=str(level);level_badge.visible=show_level
 var material:=ShaderMaterial.new();material.shader=preload("res://scripts/adventure_node.gdshader")
 material.set_shader_parameter("focus",Identity.FACE_FOCUS.get(avatar_key,Vector2(0.5,0.22)))
 material.set_shader_parameter("crop",Vector2(0.48,0.36));material.set_shader_parameter("rim",Color("c5a56c"));portrait.material=material
 queue_redraw()

func _draw() -> void:
 var center:=size*0.5
 var radius:=minf(size.x,size.y)*0.5-6
 draw_circle(center,radius+4,Color("0b141f"))
 draw_arc(center,radius+2,0,TAU,96,Color("987a4b"),2,true)
 draw_arc(center,radius-3,0,TAU,96,Color("334b56"),5,true)
 if xp_progress>0:draw_arc(center,radius-3,-PI*0.5,-PI*0.5+TAU*xp_progress,96,Color("87e1df"),5,true)
