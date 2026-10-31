extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:
 for caster_side in [0,1]:
  var m=Match.new()
  for p in m.players:p.board.clear();p.hand.clear();p.mana=10
  m.turn=caster_side
  var raven=m.spawn_unit(1-caster_side,"raven")
  var mage=m.spawn_unit(caster_side,"mage")
  mage.ready=true
  assert(m.act(caster_side,0,0,true))
  assert(raven.abascanto==0 and raven.health==3 and m.last_action.abascanto_blocked)
  m.players[caster_side].hand=["astral_flame"]
  assert(m.cast(caster_side,0,1-caster_side,0))
  assert(raven.health==0 and raven.abascanto==0 and not m.last_action.abascanto_blocked)
  assert(m.players[1-caster_side].board.is_empty())
  var reverse=Match.new()
  for p in reverse.players:p.board.clear();p.hand.clear();p.mana=10
  reverse.turn=caster_side
  var other_raven=reverse.spawn_unit(1-caster_side,"raven")
  var other_mage=reverse.spawn_unit(caster_side,"mage")
  other_mage.ready=true
  reverse.players[caster_side].hand=["astral_flame"]
  assert(reverse.cast(caster_side,0,1-caster_side,0))
  assert(other_raven.abascanto==0 and other_raven.health==3)
  assert(reverse.act(caster_side,0,0,true))
  assert(other_raven.health==2 and other_raven.abascanto==0)
  reverse.turn=1-caster_side
  reverse.begin_turn()
  assert(other_raven.abascanto==1)
  print("OK: lado ",caster_side,"; as duas ordens e recarga no turno do Corvo")
 quit()
