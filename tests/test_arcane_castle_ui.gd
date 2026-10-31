extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var main=load("res://main.tscn").instantiate()
 main.enable_opening=false;main.muted=true
 root.add_child(main);await process_frame
 main.duel=Match.new()
 for p in main.duel.players:p.board.clear();p.hand.clear();p.mana=10
 var mage=main.duel.spawn_unit(0,"mage");mage.ready=true
 main.selected=0;main.magic=true;main.redraw();await process_frame
 assert(not main.find_child("EnemyCastle",true,false).disabled)
 var guard=main.duel.spawn_unit(1,"squire")
 main.redraw();await process_frame
 assert(not main.find_child("EnemyCastle",true,false).disabled and guard.block==1)
 main.duel.players[0].hand=["magic_missiles"]
 main.selected=-1;main.magic=false;main.casting=0;main.redraw();await process_frame
 assert(not main.find_child("EnemyCastle",true,false).disabled)
 main.cast_target(1,-1);await process_frame
 assert(main.spell_targets==[{"side":1,"index":-1}])
 assert(main.find_child("CastleSpellTargetMark",true,false)!=null)
 main.cast_target(1,-1);await process_frame
 assert(main.spell_targets.is_empty())
 main.queue_free();await process_frame
 print("OK: seleção visual do castelo e marcador de Mísseis.")
 quit()
