extends SceneTree
const Match=preload("res://scripts/match.gd")
func fixture():
 var m=Match.new()
 for p in m.players:p.board=[];p.hand=[];p.deck=["wolf","wolf"];p.mana=10
 return m
func _init() -> void:
 for side in [0,1]:
  var m=fixture();m.turn=side
  var unit=m.spawn_unit(side,"wizard_apprentice")
  Match.grant_stats(unit,2,3)
  var base_attack: int=unit.attack
  var base_health: int=unit.health
  m.last_action={};m.trigger_resonance(side);m.trigger_resonance(side)
  assert(unit.attack==base_attack+2 and unit.health==base_health+2 and unit.max_health==base_health+2)
  assert(m.end_turn(side))
  assert(unit.attack==base_attack+2 and unit.resonance_bonus==2)
  unit.health=1
  assert(m.end_turn(1-side))
  assert(unit.attack==base_attack and unit.health==1 and unit.max_health==base_health and unit.resonance_bonus==0)
  assert(m.end_turn(side) and m.end_turn(1-side))
  assert(unit.attack==base_attack and unit.health==1 and unit.max_health==base_health)
 var m=fixture();var unit=m.spawn_unit(0,"wizard_apprentice")
 m.last_action={};m.trigger_resonance(0);m.trigger_resonance(0)
 unit.health-=1
 assert(m.end_turn(0) and m.end_turn(1))
 assert(unit.attack==0 and unit.health==1 and unit.max_health==2)
 m=fixture();unit=m.spawn_unit(0,"wizard_apprentice")
 unit.growth=1
 m.last_action={};m.trigger_resonance(0);unit.health=1
 assert(m.end_turn(0) and m.end_turn(1))
 assert(unit.health==2 and unit.max_health==3 and unit.attack==0)
 print("OK: Ressonância temporária, acúmulo, expiração no turno do dono, mínimo 1, danos e bônus permanentes preservados")
 quit()
