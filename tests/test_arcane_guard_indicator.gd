extends SceneTree
func _initialize() -> void: call_deferred("verify")
func verify() -> void:
 var main=load("res://main.tscn").instantiate()
 main.enable_opening=false
 main.muted=true
 root.add_child(main)
 await process_frame
 for p in main.duel.players:p.board.clear();p.hand.clear();p.mana=10
 main.duel.turn=0
 var mage=main.duel.spawn_unit(0,"mage")
 mage.ready=true
 var raven=main.duel.spawn_unit(1,"raven")
 main.selected=0;main.magic=true
 main.redraw()
 await process_frame
 var field=main.field_nodes[1][raven.id]
 assert(field.find_child("ArcaneGuardTargetIndicator",true,false)!=null)
 main.magic=false
 main.redraw();await process_frame
 field=main.field_nodes[1][raven.id]
 assert(field.find_child("ArcaneGuardTargetIndicator",true,false)==null)
 main.selected=-1
 main.duel.players[0].hand=["astral_flame"]
 main.casting=0
 main.redraw();await process_frame
 field=main.field_nodes[1][raven.id]
 assert(field.find_child("ArcaneGuardTargetIndicator",true,false)!=null)
 raven.abascanto=0
 main.redraw();await process_frame
 field=main.field_nodes[1][raven.id]
 assert(field.find_child("ArcaneGuardTargetIndicator",true,false)==null)
 main.queue_free()
 await process_frame
 print("OK: símbolo durante seleção mágica, oculto para ataques físicos e sem carga.")
 quit()
