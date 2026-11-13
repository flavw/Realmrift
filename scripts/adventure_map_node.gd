extends Button
func _has_point(point: Vector2) -> bool:
 return point.distance_to(size*0.5)<=size.x*0.5
