extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10
 var unit=m.spawn_unit(0,"wolf")
 var guard=m.spawn_unit(1,"squire")
 m.players[0].hand=["shadow_step","shadow_step"]
 assert(not unit.ready and not m.can_target(0,0,-1))
 assert(m.cast(0,0,0,0) and unit.ready and Match.has_flying(unit))
 assert(Match.attack_value(unit)==3 and unit.attack==2 and m.can_target(0,0,-1))
 assert(m.act(0,0,-1) and not unit.ready and m.players[1].hp==17 and guard.block==1)
 assert(m.cast(0,0,0,0) and not unit.ready and Match.attack_value(unit)==4)
 assert(m.end_turn(0) and unit.attack==2 and Match.attack_value(unit)==2 and not Match.has_flying(unit) and not unit.turn_swift)
 m=fresh_fury_case()
 unit=m.players[0].board[0]
 assert(m.fury(0,0) and not unit.ready)
 m.players[0].hand=["shadow_step"];assert(m.cast(0,0,0,0) and unit.ready)
 assert(m.act(0,0,-1) and not unit.ready)
 m.players[0].hand=["shadow_step"];assert(m.cast(0,0,0,0) and not unit.ready)
 print("OK: Passo das Sombras temporário, Voo, Arrancada e ações já realizadas.")
 quit()
func fresh_fury_case():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10
 m.spawn_unit(0,"wolf")
 return m
