extends Control

var kind: String
var amount: int=0
var progress: float=0.0:
 set(value):
  progress=value
  queue_redraw()

func configure(effect: String,rect: Rect2,value: int=0) -> void:
 kind=effect;amount=value
 position=rect.position;size=rect.size
 mouse_filter=Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
 var fade: float=sin(progress*PI)
 var center:=size*0.5
 var radius: float=minf(size.x,size.y)*0.38
 if kind=="block":
  draw_rect(Rect2(Vector2.ZERO,size),Color(1.0,0.85,0.3,fade*0.22))
  draw_rect(Rect2(Vector2(2,2),size-Vector2(4,4)),Color(1.0,0.85,0.35,fade),false,6)
  var c:=center+Vector2(0,-12)
  var shield:=PackedVector2Array([c+Vector2(-19,-22),c+Vector2(19,-22),c+Vector2(17,8),c+Vector2(0,25),c+Vector2(-17,8),c+Vector2(-19,-22)])
  draw_colored_polygon(shield,Color(0.15,0.22,0.32,fade*.8))
  draw_polyline(shield,Color(1,0.9,0.5,fade),3,true)
  return
 if kind=="fire":
  for i in range(9):
   var x: float=size.x*(0.14+0.09*i)
   var base:=Vector2(x,size.y*(0.82-0.25*progress))
   var height: float=(28+18*sin(i*1.7+progress*12))*(0.6+fade)
   var sway: float=sin(progress*16+i)*8
   var flame:=PackedVector2Array([base+Vector2(-12,0),base+Vector2(-10,-height*0.4),base+Vector2(sway,-height),base+Vector2(10,-height*0.45),base+Vector2(13,0)])
   draw_colored_polygon(flame,Color(1.0,0.25+0.07*(i%3),0.04,fade*0.9))
   draw_colored_polygon(PackedVector2Array([base+Vector2(-6,0),base+Vector2(sway*0.5,-height*0.6),base+Vector2(7,0)]),Color(1.0,0.85,0.22,fade))
  if amount>0:draw_string(ThemeDB.fallback_font,center+Vector2(-12,-progress*30),"−%d" % amount,HORIZONTAL_ALIGNMENT_LEFT,-1,28,Color(1,0.9,0.6,fade))
  return
 if kind=="resonance":
  var tint:=Color(0.5,0.75,1.0,fade)
  for i in range(3):
   var r: float=radius*(0.3+fmod(progress+i*0.24,1.0))
   draw_arc(center,r,0,TAU,48,Color(tint,fade*(1.0-i*0.18)),2.5,true)
  for i in range(6):
   var angle: float=TAU*i/6.0+progress*2.5
   var at:=center+Vector2(cos(angle),sin(angle))*radius*0.7
   draw_circle(at,3.5,tint)
  return
 if kind=="destroy":
  var ember:=Color(1.0,0.48,0.16,1.0-progress)
  for i in range(16):
   var angle: float=TAU*i/16.0
   var at:=center+Vector2(cos(angle),sin(angle))*radius*(0.25+progress*1.4)
   at.y-=progress*35
   var shard:=PackedVector2Array([at+Vector2(-5,3),at+Vector2(2,-7),at+Vector2(6,4)])
   draw_colored_polygon(shard,ember)
  return
 if kind=="devotion":
  var gold:=Color(1.0,0.84,0.38,fade)
  draw_circle(center,radius*1.1,Color(1.0,0.78,0.32,fade*0.12))
  draw_arc(center,radius*(0.65+progress*0.35),0,TAU,48,gold,3.0,true)
  for i in range(8):
   var angle: float=TAU*i/8.0+progress*0.35
   var direction:=Vector2(cos(angle),sin(angle))
   var at:=center+direction*radius*(0.55+progress*0.45)
   draw_line(at-direction*8,at+direction*8,gold,2.5,true)
   draw_circle(at,3.0,Color(1.0,0.97,0.73,fade))
  return
 var tint:=Color("9ad9ff") if kind=="spell_buff" else Color("ef5968") if kind=="bleed" else Color("ff9b47") if kind=="fury" else Color("7bf2b0") if kind in ["heal","attack_buff"] else Color("ffc370") if kind=="arcane_area" else Color("acde58")
 tint.a=fade
 draw_arc(center,radius*(0.7+progress*.5),0,TAU,48,Color(tint,fade*.65),3,true)
 for i in range(7):
  var angle: float=TAU*i/7.0
  var at:=center+Vector2(cos(angle)*radius*.65,sin(angle)*radius*.35)-Vector2(0,progress*45)
  if kind=="fury":
   draw_line(at+Vector2(-5,5),at+Vector2(0,-7),tint,3,true)
   draw_line(at+Vector2(0,-7),at+Vector2(5,5),tint,3,true)
  elif kind=="heal":
   draw_line(at-Vector2(5,0),at+Vector2(5,0),tint,3,true)
   draw_line(at-Vector2(0,5),at+Vector2(0,5),tint,3,true)
  else:
   draw_circle(at,3.0+sin(progress*PI+i)*1.4,tint)
   draw_circle(at,6.0,Color(0.4,0.15,0.6,fade*.4),false,1,true)
 if amount>0:
  var text: String=("+" if kind=="heal" else "−" if kind in ["poison_tick","arcane_area"] else "+")+str(amount)
  draw_string(ThemeDB.fallback_font,center+Vector2(-12,-progress*30),text,HORIZONTAL_ALIGNMENT_LEFT,-1,24,tint)
