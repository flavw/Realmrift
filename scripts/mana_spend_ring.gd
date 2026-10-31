extends Control
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 resized.connect(queue_redraw)
func _draw() -> void:
 var center:=size*0.5
 var radius:=minf(size.x,size.y)*0.43
 draw_arc(center,radius,0,TAU,48,Color(0.55,0.32,0.07,0.65),4.0,true)
 draw_arc(center,radius,0,TAU,48,Color("ffdc80"),2.0,true)
