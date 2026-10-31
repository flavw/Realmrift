extends Button

func _ready() -> void:
 mouse_entered.connect(queue_redraw)
 mouse_exited.connect(queue_redraw)
 focus_entered.connect(queue_redraw)
 focus_exited.connect(queue_redraw)

func _draw() -> void:
 var gold:=Color("dfc38a") if is_hovered() else Color("8f7954")
 gold.a=0.9 if is_hovered() else 0.6
 var y:=size.y*0.5
 for x in [12.0,size.x-12.0]:
  draw_colored_polygon(PackedVector2Array([Vector2(x,y-4),Vector2(x+3,y),Vector2(x,y+4),Vector2(x-3,y)]),gold)
 for x in [5.0,size.x-5.0]:
  draw_line(Vector2(x,9),Vector2(x,19),gold,1,true)
  draw_line(Vector2(x,size.y-9),Vector2(x,size.y-19),gold,1,true)
