extends SceneTree
func _initialize():call_deferred("verify")
func verify():
 var main=load("res://main.tscn").instantiate();main.enable_opening=false;main.muted=true
 root.add_child(main);await process_frame
 for p in main.duel.players:p.board.clear();p.hand.clear();p.mana=10
 main.duel.turn=0
 var ally=main.duel.spawn_unit(0,"wolf")
 var enemy=main.duel.spawn_unit(1,"farmer")
 main.duel.players[0].hand=["wild_pack_spell"]
 main.redraw();await process_frame
 await main.play(0)
 await process_frame
 assert(ally.pack==1 and enemy.pack==1 and main.duel.players[0].hand.is_empty() and not main.busy)
 assert(main.field_nodes[0][ally.id].find_child("Pack",true,false)!=null)
 main.queue_free();await process_frame
 print("OK: magia sem alvo manual e ícone de Matilha no campo.")
 quit()
