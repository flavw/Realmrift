extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 State.current=State.new()
 var view=load("res://adventure.tscn").instantiate()
 root.add_child(view)
 view.choose_faction(0)
 for i in range(14):view.pick_card(State.current.options[0])
 await process_frame
 var key: String=State.current.options[0]
 var card: Control=view.find_child("AdventureCard_"+key,true,false)
 var event:=InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT;event.pressed=true
 card.gui_input.emit(event)
 assert(State.current.deck.size()==15 and State.current.deck.back()==key)
 assert(State.current.phase=="power" and not view.deck_open)
 await process_frame
 await process_frame
 await process_frame
 assert(view.find_child("CardAddFlight",true,false)!=null)
 await create_timer(0.4).timeout
 assert(not view.selection_busy)
 assert(view.find_children("Choose_*","Button",true,false).is_empty())
 State.current.step=State.STAGES.find("power_event");State.current.phase="map";State.current.options.clear();view.render()
 await process_frame
 await process_frame
 assert(view.find_child("Route_%d_0" % State.current.step,true,false).get_child(0).texture.resource_path=="res://assets/ui/adventure-power-sanctuary.webp")
 if DisplayServer.get_name()!="headless":get_root().get_texture().get_image().save_png("res://.local/adventure-power-node.png")
 view.queue_free()
 await process_frame
 await process_frame
 State.current=null
 print("OK: clique recruta, animação compartilhada, sem botão extra e arte de poder")
 quit()

