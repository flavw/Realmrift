extends SceneTree
const Match=preload("res://scripts/match.gd")
func game():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10
 return m
func _initialize():
 var leader=Match.CARD_DATA.wastes_jackal_leader
 var worm=Match.CARD_DATA.wastes_ancient_worm
 assert(leader.cost==3 and leader.aura_targets==CardData.AuraTargets.ALLIED_WASTES)
 assert(worm.cost==7 and worm.legendary and worm.copy_limit()==1 and worm.trample and worm.end_random_attack)
 for side in [0,1]:
  var m=game();m.turn=side
  var a=m.spawn_unit(side,"wastes_jackal_leader")
  var w=m.spawn_unit(side,"wastes_ancient_worm")
  var other=m.spawn_unit(side,"farmer")
  var enemy=m.spawn_unit(1-side,"wastes_hyena")
  assert(a.aura_attack==0 and w.aura_attack==1 and other.aura_attack==0 and enemy.aura_attack==0)
  var second=m.spawn_unit(side,"wastes_jackal_leader")
  assert(a.aura_attack==1 and second.aura_attack==1 and w.aura_attack==2)
  m.players[side].board.erase(second);m.refresh_auras();assert(w.aura_attack==1 and a.aura_attack==0)
  m.players[side].board.erase(a);m.players[side].board.erase(other);m.refresh_auras();assert(w.aura_attack==0)
  w.ready=true;assert(not m.can_target(side,0,0) and not m.can_target(side,0,-1))
  w.ready=false
  assert(m.automatic_hunt_targets(side,0).is_empty())
  var prey=m.spawn_unit(1-side,"farmer");prey.health=2;prey.attack=0
  assert(m.automatic_hunt_targets(side,0)==[{"side":1-side,"index":1}])
  assert(m.perform_automatic_hunt(side))
  assert(m.players[1-side].board.size()==1 and m.players[1-side].hp==14)
  assert(not m.perform_automatic_hunt(side))
  m.end_turn(side)
  assert(m.players[1-side].hp==14)
  m=game();m.turn=side
  w=m.spawn_unit(side,"wastes_ancient_worm")
  var guard=m.spawn_unit(1-side,"wastes_hyena");guard["block"]=1
  m.spawn_unit(1-side,"farmer")
  assert(m.automatic_hunt_targets(side,0)==[{"side":1-side,"index":1}])
  guard.block=0
  w["rooted"]=true;assert(m.automatic_hunt_targets(side,0).is_empty())
  w.rooted=false;assert(m.automatic_hunt_targets(side,0)==[{"side":1-side,"index":1}])
  assert(m.end_turn(side) and m.players[1-side].board.size()==1)
 for side in [0,1]:
  var m=game();m.turn=side
  var w=m.spawn_unit(side,"wastes_ancient_worm")
  var ally=m.spawn_unit(side,"farmer");ally.health=2;ally.attack=0
  var foe=m.spawn_unit(1-side,"wastes_hyena")
  assert(m.automatic_hunt_targets(side,0)==[{"side":side,"index":1}])
  assert(m.perform_automatic_hunt(side) and m.last_action.target_side==side)
  assert(m.players[side].board.size()==1 and m.players[1-side].hp==14)
  m=game();m.turn=side
  w=m.spawn_unit(side,"wastes_ancient_worm")
  ally=m.spawn_unit(side,"farmer")
  foe=m.spawn_unit(1-side,"farmer")
  assert(m.automatic_hunt_targets(side,0).size()==2)
  foe["block"]=1
  var foe2=m.spawn_unit(1-side,"mage")
  assert(m.automatic_hunt_targets(side,0)==[{"side":side,"index":1},{"side":1-side,"index":0},{"side":1-side,"index":1}])
 assert(load("res://scripts/main.gd")!=null)
 print("OK: aura dos Ermos, alvo aleatório, Bloqueio, Atropelar e limites do ataque automático.")
 quit()

