extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 State.current=State.new()
 var view=load("res://adventure.tscn").instantiate()
 root.add_child(view)
 view.choose_faction(0)
 for i in range(5):view.pick_card(State.current.options[0])
 await process_frame
 await process_frame
 var grid=view.find_child("AdventureCardChoices",true,false)
 assert(grid.get_child_count()==3)
 for column in grid.get_children():
  var card=column.get_child(0)
  assert(card.card_data==DuelMatch.CARD_DATA[String(card.name).trim_prefix("AdventureCard_")])
  assert(card.get_node("CardCanvas/Ability").get_child_count()==card.view_entries().filter(func(e):return not e.get("runtime",false)).size())
 assert(view.find_child("AdventureManaCurve",true,false)!=null)
 assert(view.find_child("AdventureDeckList",true,false).get_child_count()>0)
 await create_timer(0.4).timeout
 if DisplayServer.get_name()!="headless":
  get_root().get_texture().get_image().save_png("res://.local/adventure-draft.png")
 view.queue_free()
 await process_frame
 await process_frame
 State.current=null
 print("OK: cartas originais, habilidades e barra lateral")
 quit()

