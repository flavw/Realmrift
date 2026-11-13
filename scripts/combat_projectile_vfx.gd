extends Control

var kind := "cone"
var origin := Vector2.ZERO
var destination := Vector2.ZERO
var half_width := 100.0
var edge_left := Vector2.ZERO
var edge_right := Vector2.ZERO
var palette := "fire"
var progress := 0.0:
 set(value):
  progress=value
  queue_redraw()

func configure_cone(source: Vector2,targets: Array,style: String) -> void:
 kind="cone";origin=source;palette=style
 destination=Vector2.ZERO
 for rect: Rect2 in targets:destination+=rect.get_center()
 destination/=maxi(1,targets.size())
 var bounds: Rect2=targets[0]
 for rect: Rect2 in targets:bounds=bounds.merge(rect)
 var end_y: float=bounds.end.y if destination.y>=origin.y else bounds.position.y
 var left:=INF
 var right:=-INF
 for rect: Rect2 in targets:
  var offset_y: float=rect.get_center().y-origin.y
  var ratio: float=(end_y-origin.y)/offset_y if absf(offset_y)>20.0 else 1.0
  left=minf(left,origin.x+(rect.get_center().x-rect.size.x*0.4-origin.x)*ratio)
  right=maxf(right,origin.x+(rect.get_center().x+rect.size.x*0.4-origin.x)*ratio)
 edge_left=Vector2(left,end_y);edge_right=Vector2(right,end_y)
 destination=(edge_left+edge_right)*0.5
 half_width=edge_left.distance_to(edge_right)*0.5
 mouse_filter=Control.MOUSE_FILTER_IGNORE

func configure_arrow(source: Vector2,target: Vector2) -> void:
 kind="arrow";origin=source;destination=target
 mouse_filter=Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
 if origin.is_equal_approx(destination):return
 if kind=="arrow":draw_arrow();return
 var color:=Color("ff6b20") if palette=="fire" else Color("a5f239") if palette=="acid" else Color("58c887")
 var core:=Color("fff1aa") if palette=="fire" else Color("e3ff9b") if palette=="acid" else Color("bd86ed")
 var fade: float=sin(progress*PI)
 var reach:=minf(1.0,progress/0.48)
 if reach<0.01 or fade<0.001:return
 var direction: Vector2=(destination-origin).normalized()
 var normal:=direction.orthogonal()
 for layer in range(5):
  var scale: float=1.0-float(layer)*0.14
  var left: Vector2=origin.lerp(destination.lerp(edge_left,scale),reach)
  var right: Vector2=origin.lerp(destination.lerp(edge_right,scale),reach)
  var points:=PackedVector2Array([origin,left,right])
  var tint: Color=color.lerp(core,float(layer)/5.0)
  var alpha: float=fade*(0.08+layer*0.025)
  draw_polygon(points,PackedColorArray([Color(tint,alpha*0.25),Color(tint,alpha),Color(tint,alpha)]))
 for i in range(46):
  var travel: float=fmod(progress*1.75+i*0.137,1.0)*reach
  var lane: float=sin(i*12.9898)
  var center:=origin.lerp(edge_left.lerp(edge_right,(lane+1.0)*0.5),travel)
  var radius: float=(5.0+float(i%5)*3.0)*(0.4+travel)*fade
  if palette=="fire":
   draw_colored_polygon(PackedVector2Array([center-normal*radius,center+direction*radius*3,center+normal*radius,center-direction*radius]),Color(color.lerp(core,float(i%3)*0.3),fade*0.7))
  else:
   draw_circle(center,radius,Color(color,fade*0.25))
   draw_arc(center,radius,0,TAU,12,Color(core if i%3==0 else color,fade*0.65),1.5,true)

func draw_arrow() -> void:
 var direction: Vector2=(destination-origin).normalized()
 var normal:=direction.orthogonal()
 var travel:=minf(1.0,progress/0.76)
 var head:=origin.lerp(destination,travel)
 var fade:=1.0 if progress<0.76 else (1.0-progress)/0.24
 draw_line(head-direction*125,head,Color(0.85,0.73,0.5,fade*0.18),8,true)
 draw_line(head-direction*68,head-direction*12,Color(0.16,0.11,0.08,fade),7,true)
 draw_line(head-direction*68,head-direction*12,Color(0.81,0.66,0.39,fade),3,true)
 draw_colored_polygon(PackedVector2Array([head,head-direction*21+normal*7,head-direction*16,head-direction*21-normal*7]),Color(0.86,0.94,1.0,fade))
 for sign_value in [-1,1]:
  draw_colored_polygon(PackedVector2Array([head-direction*57,head-direction*72+normal*sign_value*9,head-direction*80+normal*sign_value*7,head-direction*69]),Color(0.68,0.44,0.76,fade))
 if progress>=0.76:
  var burst: float=(progress-0.76)/0.24
  for i in range(10):
   var ray:=Vector2.from_angle(TAU*i/10.0)
   draw_line(destination+ray*burst*12,destination+ray*burst*40,Color(1,0.86,0.57,1.0-burst),3,true)
