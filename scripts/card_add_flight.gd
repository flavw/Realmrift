extends RefCounted
const CardScene=preload("res://card_model.tscn")
# Shared by the deck constructor and adventure recruitment.
static func play(layer: CanvasLayer, data: CardData, source: Rect2, target: Rect2) -> Tween:
 var ghost=CardScene.instantiate()
 ghost.name="CardAddFlight"
 ghost.card_data=data
 ghost.custom_minimum_size=Vector2.ZERO
 ghost.position=source.position
 ghost.size=source.size
 ghost.mouse_filter=Control.MOUSE_FILTER_IGNORE
 layer.add_child(ghost)
 var destination: Vector2=target.get_center()-source.size*0.11
 var tween:=layer.create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
 tween.tween_property(ghost,"position",destination,0.28)
 tween.tween_property(ghost,"scale",Vector2.ONE*0.22,0.28)
 tween.tween_property(ghost,"modulate:a",0.25,0.28)
 tween.finished.connect(ghost.queue_free)
 return tween
