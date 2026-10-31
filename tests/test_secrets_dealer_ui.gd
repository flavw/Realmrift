extends SceneTree
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var main=load("res://main.tscn").instantiate()
 main.enable_opening=false
 root.add_child(main)
 for p in main.duel.players:p.board=[]
 var ally:Dictionary=main.duel.spawn_unit(0,"rooftop_leaper")
 main.duel.players[0].hand=["secrets_dealer"];main.duel.players[0].mana=2
 main.redraw();await process_frame;await process_frame
 main.play(0)
 assert(main.summoning==0)
 main.summon_target(0,0)
 assert(main.rogue_choice_dialog.visible and main.duel.players[0].mana==2 and main.duel.players[0].board.size()==1)
 main.rogue_choice_dialog.find_child("RogueChoice_envenom",true,false).pressed.emit()
 await process_frame;await process_frame
 assert(ally.envenom==2 and main.duel.players[0].board.size()==2 and main.duel.players[0].mana==0)
 assert(main.field_nodes[0][ally.id].card_data.envenom==2)
 assert(main.field_nodes[0][ally.id].find_child("Envenom",true,false)!=null)
 await create_timer(0.6).timeout
 main.queue_free();await process_frame;await process_frame
 print("OK: escolha no combate, custo só ao confirmar e ícone no aliado")
 quit()
