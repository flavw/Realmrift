@tool
extends Control
var outlined := false
var legendary := false
var shadow_enabled := false
var text_outline_size := 0
var text_outline_color := Color("51350f")
var fill_color := Color.WHITE
var last_outline_scale := -1.0

func _process(_delta: float) -> void:
 if not outlined or not is_visible_in_tree():return
 var scale_now: float=get_global_transform_with_canvas().get_scale().abs().x
 if not is_equal_approx(scale_now,last_outline_scale):
  last_outline_scale=scale_now
  queue_redraw()

func _draw() -> void:
 var label: Label=get_parent()
 var font: Font=label.get_theme_font("font")
 var font_size: int=label.get_theme_font_size("font_size")
 var server:=TextServerManager.get_primary_interface()
 var bounds:=Rect2()
 var cursor:=0.0
 var first:=true
 for character in label.text:
  for rid in font.get_rids():
   var glyph: int=server.font_get_glyph_index(rid,font_size,character.unicode_at(0),0)
   if glyph==0:continue
   var offset: Vector2=server.font_get_glyph_offset(rid,Vector2i(font_size,0),glyph)
   var glyph_size: Vector2=server.font_get_glyph_size(rid,Vector2i(font_size,0),glyph)
   var ink:=Rect2(Vector2(cursor,0)+offset,glyph_size)
   bounds=ink if first else bounds.merge(ink)
   first=false
   cursor+=server.font_get_glyph_advance(rid,font_size,glyph).x
   break
 if first:return
 var origin: Vector2=(label.size-bounds.size)*0.5-bounds.position
 if shadow_enabled:
  var shadow_origin:=origin+Vector2(1,2)
  draw_string_outline(font,shadow_origin,label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,2,Color(0.015,0.02,0.03,0.85))
  draw_string(font,shadow_origin,label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color(0.015,0.02,0.03,0.9))
 if outlined:
  var display_scale: float=maxf(0.05,get_global_transform_with_canvas().get_scale().abs().x)
  # Raster font outlines do not reliably match their requested pixel width.
  # Stamp the glyph silhouette instead, keeping the border constant on screen.
  draw_mana_border(font,origin,label.text,font_size,3.5/display_scale,Color("a47830") if legendary else Color("318cc5"))
  draw_mana_border(font,origin,label.text,font_size,1.25/display_scale,Color("291907") if legendary else Color("071525"))
 if text_outline_size>0:
  draw_string_outline(font,origin,label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,text_outline_size,text_outline_color)
 draw_string(font,origin,label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,fill_color)

func draw_mana_border(font: Font,origin: Vector2,text: String,font_size: int,radius: float,color: Color) -> void:
 for ring in [0.5,1.0]:
  for index in range(24):
   var offset: Vector2=Vector2.from_angle(TAU*index/24.0)*radius*float(ring)
   draw_string(font,origin+offset,text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,color)
