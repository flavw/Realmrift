extends SceneTree
const Match=preload("res://scripts/match.gd")
func fresh():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10
 return m
func _initialize() -> void:
 for side in [0,1]:
  for target_side in [side,1-side]:
   var m=fresh();m.turn=side
   var devotee=m.spawn_unit(side,"dawn_devotee");devotee.ready=true
   var enemy=m.spawn_unit(1-side,"dawn_devotee")
   var victim=m.spawn_unit(target_side,"zombie_helper");victim.health=8;victim.max_health=8
   var target_index: int=m.players[target_side].board.find(victim)
   assert(m.heal(side,0,target_index,target_side))
   assert(victim.health==7 and devotee.attack==2 and enemy.attack==1)
   assert(m.last_action.devotion_buffs.size()==1 and m.last_action.devotion_buffs[0].side==side)
   devotee.ready=true;victim.abascanto=1
   assert(m.heal(side,0,target_index,target_side))
   assert(victim.health==7 and devotee.attack==2 and not m.last_action.has("devotion_buffs"))
   m.players[side].hand=["restoring_light"]
   assert(m.cast(side,0,target_side,target_index))
   assert(victim.health<7 and devotee.attack==3 and enemy.attack==1)
  var m=fresh();m.turn=side
  var d=m.spawn_unit(side,"dawn_devotee")
  var u=m.spawn_unit(1-side,"zombie_helper");u.health=1
  m.players[side].hand=["restoring_light"]
  assert(m.cast(side,0,1-side,0) and m.players[1-side].board.is_empty() and d.attack==2)
 print("OK: Cura ofensiva, ambos os lados, magias, anulação e dano letal.")
 quit()
