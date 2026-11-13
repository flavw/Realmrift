extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var run=State.new();run.deck=Match.default_deck(0);run.phase="map";run.ensure_routes();State.current=run
 var view=load("res://adventure.tscn").instantiate();root.add_child(view)
 await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":get_root().get_texture().get_image().save_png("res://.local/adventure-expanded-map.png")
 run.pending_item="sword";run.prepare_item();view.render()
 await process_frame;await process_frame
 assert(view.find_child("AdventureCardChoices",true,false).get_child_count()==3)
 if DisplayServer.get_name()!="headless":get_root().get_texture().get_image().save_png("res://.local/adventure-item-choices.png")
 view.equip(run.options[0])
 assert(run.equipment.size()==1)
 view.queue_free();await process_frame
 run.encounter="mimic";run.in_combat=true
 var main=load("res://main.tscn").instantiate();main.starting_player=0;root.add_child(main)
 await process_frame;await process_frame
 assert(main.duel.creature_boss_id>=0 and main.duel.players[1].board.size()==1)
 assert(main.opponent_label().contains("Mímico"))
 main.finish_mulligan([])
 assert(not main.duel.opening and main.mulligan_layer==null)
 var upgraded: String=run.equipment[0].card
 main.duel.players[0].hand=[upgraded]
 main.duel.spawn_unit(0,upgraded)
 main.redraw()
 await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":get_root().get_texture().get_image().save_png("res://.local/adventure-mimic-battle.png")
 main.queue_free();await process_frame;await process_frame
 State.current=null
 print("OK: telas do mapa ramificado, três cartas de item e entrada no encontro do mímico")
 quit()

