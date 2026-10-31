extends Control
var background: Texture2D
var background_index: int=-1
const BACKGROUNDS=["res://assets/ui/arena-background.webp","res://assets/ui/arena-stone.webp","res://assets/ui/arena-forest.webp"]
var random:=RandomNumberGenerator.new()

func _ready() -> void:
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 resized.connect(queue_redraw)
 random.randomize()
 choose_random_background()

func choose_random_background() -> void:
 var next: int=random.randi_range(0,BACKGROUNDS.size()-1)
 if BACKGROUNDS.size()>1 and next==background_index:next=(next+random.randi_range(1,BACKGROUNDS.size()-1))%BACKGROUNDS.size()
 background_index=next
 background=load(BACKGROUNDS[background_index])
 queue_redraw()

func _draw() -> void:
 draw_rect(Rect2(Vector2.ZERO, size), Color("101c2b"))
 if background:
  var texture_size := background.get_size()
  var factor := maxf(size.x / texture_size.x, size.y / texture_size.y)
  var rendered := texture_size * factor
  draw_texture_rect(background, Rect2((size - rendered) * 0.5, rendered), false)
  draw_rect(Rect2(Vector2.ZERO, size), Color(0.015, 0.025, 0.055, 0.42))
 # Stone tiles, kept subtle so the cards remain readable.
 for y in range(0, int(size.y), 140):
  var offset := 35 if (y / 70) % 2 else 0
  for x in range(-70 + offset, int(size.x), 280):
   draw_rect(Rect2(x + 2, y + 2, 276, 136), Color(0.12, 0.17, 0.23, 0.1), false, 1)
 var center := size * Vector2(0.5, 0.43)
 draw_circle(center, 72, Color(0.17, 0.3, 0.45, 0.2))
 draw_arc(center, 76, 0, TAU, 64, Color(0.65, 0.52, 0.27, 0.3), 2)
 draw_line(Vector2(size.x * 0.12, center.y), Vector2(size.x * 0.34, center.y), Color(0.7, 0.58, 0.33, 0.22), 1)
 draw_line(Vector2(size.x * 0.66, center.y), Vector2(size.x * 0.88, center.y), Color(0.7, 0.58, 0.33, 0.22), 1)

