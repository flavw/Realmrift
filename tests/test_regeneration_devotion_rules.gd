extends SceneTree
const Match=preload("res://scripts/match.gd")
func fresh():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10;p.hp=20
 return m
func _initialize() -> void:
 for side in [0,1]:
  var m=fresh();m.turn=side
  var ally=m.spawn_unit(side,"dawn_devotee")
  var enemy=m.spawn_unit(1-side,"dawn_devotee")
  var target=m.spawn_unit(side,"farmer");target.health=1
  m.last_action={}
  m.apply_healing(side,target,1)
  assert(ally.attack==2 and enemy.attack==1 and m.last_action.devotion_buffs.size()==1)
  assert(m.last_action.devotion_buffs[0].side==side)
  m.players[side].hp=18;m.players[side].hand=["restoring_light"]
  assert(m.cast(side,0,side,-1))
  assert(ally.attack==3 and enemy.attack==1)
  var regen=m.spawn_unit(side,"marsh_troll")
  regen.health=1;regen.poison=2;regen.bleeding=1
  m.last_action={}
  m.resolve_regeneration(side)
  assert(regen.health>1 and regen.poison==2 and regen.bleeding==1)
  assert(ally.attack==3 and enemy.attack==1 and not m.last_action.has("healed") and not m.last_action.has("devotion_buffs"))
  assert(m.last_action.regenerated.size()==1)
  regen.creature_type=CardData.CreatureType.UNDEAD;regen.health=1;regen.abascanto=1
  m.last_action={};m.resolve_regeneration(side)
  assert(regen.health>1 and regen.abascanto==1 and regen.poison==2)
  regen.wall=true;regen.health=1
  m.last_action={};m.resolve_regeneration(side)
  assert(regen.health>1)
  var m2=fresh();m2.turn=side
  var victim=m2.spawn_unit(side,"marsh_troll");victim.health=1;victim.poison=1
  assert(m2.end_turn(side) and m2.players[side].board.is_empty())
 print("OK: Cura aliada ativa somente Devoção aliada; Regeneração não é Cura.")
 quit()
