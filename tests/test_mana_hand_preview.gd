extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void: call_deferred("verify")
func verify() -> void:
 var main=load("res://main.tscn").instantiate()
 main.enable_opening=false;main.muted=true
 root.add_child(main);await process_frame
 main.duel.turn=0
 main.duel.players[0].hand=["astral_flame"]
 main.duel.players[0].mana=5
 main.duel.players[0].max_mana=4
 main.duel.players[0].temporary_mana=1
 main.redraw();await process_frame
 var card=main.find_child("HandCard_0",true,false)
 main.hover_hand_card(card,true)
 await create_timer(0.35).timeout
 assert(is_equal_approx(card.scale.x,1.72))
 var bar=main.find_child("PlayerMana",true,false)
 assert(bar.find_child("TemporaryMana",true,false).text=="+1 → +0")
 assert(bar.find_child("TemporaryManaGem",true,false).get_node("ManaSpendRing").visible)
 assert(bar.find_child("ManaGem3",true,false).get_node("ManaSpendRing").visible)
 assert(bar.find_child("ManaGem3",true,false).get_node("ManaSpendRing").size.x>0)
 assert(bar.find_child("ManaGem2",true,false).get_node("ManaSpendRing").visible)
 assert(bar.find_child("ManaGem1",true,false).get_node("ManaSpendRing").visible)
 assert(not bar.find_child("ManaGem0",true,false).get_node("ManaSpendRing").visible)
 main.hover_hand_card(card,false)
 await create_timer(0.2).timeout
 assert(bar.find_child("TemporaryMana",true,false).text=="+1")
 assert(not bar.find_child("ManaGem3",true,false).get_node("ManaSpendRing").visible)
 assert(not bar.find_child("TemporaryManaGem",true,false).get_node("ManaSpendRing").visible)
 main.queue_free();await process_frame
 print("OK: prévia ampliada e custo de mana, incluindo mana temporária.")
 quit()
