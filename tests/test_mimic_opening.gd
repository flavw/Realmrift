extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:
 var duel=Match.new([],[],0,false,{"enabled":true,"encounter":"mimic"})
 var boss: Dictionary=duel.players[1].board[0]
 assert(boss.armor==0 and not boss.ready and boss.mimic_sleeping)
 assert(duel.end_turn(0))
 assert(duel.players[1].mana==0 and not boss.ready and boss.mimic_sleeping)
 assert(not duel.can_target(1,0,-1))
 assert(duel.end_turn(1) and duel.end_turn(0))
 assert(duel.players[1].mana==1 and boss.ready and not boss.mimic_sleeping)
 print("OK: mímico sem armadura, dorme no primeiro turno e desperta no segundo")
 quit()
