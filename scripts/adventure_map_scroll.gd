extends ScrollContainer

var drag_active := false
var drag_moved := false
var drag_origin := Vector2.ZERO
var initial_scroll := 0
var follow_tween: Tween
var run
var restored_scroll := 0

func configure(state) -> void:
 run=state;restored_scroll=roundi(run.map_scroll_position)
 get_h_scroll_bar().value_changed.connect(func(value: float):run.map_scroll_position=value)

func _ready() -> void:
 await get_tree().process_frame
 scroll_horizontal=restored_scroll

func _init() -> void:
 horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_SHOW_NEVER
 vertical_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
 mouse_default_cursor_shape=Control.CURSOR_DRAG
 follow_focus=false

func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.is_action_pressed("ui_accept"):drag_moved=false
 if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
  if event.pressed and get_global_rect().has_point(event.position):
   if follow_tween and follow_tween.is_valid():follow_tween.kill()
   drag_active=true;drag_moved=false;drag_origin=event.position;initial_scroll=scroll_horizontal
  elif not event.pressed:drag_active=false
 elif event is InputEventMouseMotion and drag_active:
  var delta: Vector2=event.position-drag_origin
  if delta.length()>8.0:drag_moved=true
  if drag_moved:
   scroll_horizontal=roundi(initial_scroll-delta.x)
   get_viewport().set_input_as_handled()

func follow_stage(center_x: float) -> void:
 var content:=get_child(0) as Control
 if content==null:return
 var target:=clampf(center_x-size.x*0.45,0.0,maxf(0.0,content.size.x-size.x))
 if follow_tween and follow_tween.is_valid():follow_tween.kill()
 follow_tween=create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
 follow_tween.tween_property(self,"scroll_horizontal",roundi(target),0.45)
