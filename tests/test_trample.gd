extends SceneTree
const Match=preload("res://scripts/match.gd")
func game():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10
 return m
func _initialize():
 var data=Match.CARD_DATA.minotaur_brute
 assert(data.trample and data.ability_entries().any(func(e):return e.name=="Atropelar"))
 for side in [0,1]:
  var m=game();m.turn=side
  var bull=m.spawn_unit(side,"minotaur_brute");bull.ready=true;bull.health=1
  var target=m.spawn_unit(1-side,"squire");target.health=1;target.armor=2;target.attack=3
  var preview=m.attack_forecast(side,0,0)
  assert(preview.damage==1 and preview.absorbed==2 and preview.castle_damage==2 and preview.received==3)
  assert(not m.can_target(side,0,-1) and m.act(side,0,0))
  assert(m.players[1-side].hp==18 and m.last_action.amount==1 and m.last_action.castle_damage==2)
  assert(m.players[side].board.is_empty() and m.players[1-side].board.is_empty())
  m=game();m.turn=side
  bull=m.spawn_unit(side,"minotaur_brute");bull.ready=true
  target=m.spawn_unit(1-side,"raven");target.health=1;target.armor=1
  preview=m.attack_forecast(side,0,0)
  assert(preview.damage==1 and preview.flight_reduction==1 and preview.castle_damage==2)
  assert(m.act(side,0,0) and m.players[1-side].hp==18)
  m=game();m.turn=side
  var ordinary=m.spawn_unit(side,"wolf");ordinary.ready=true;ordinary.health=8
  var defender=m.spawn_unit(1-side,"minotaur_brute");defender.health=8
  assert(m.act(side,0,0) and m.players[side].hp==20)
 var m=game();m.turn=1;m.players[0].hp=2
 var attacker=m.spawn_unit(1,"minotaur_brute");attacker.ready=true
 var blocker=m.spawn_unit(0,"squire");blocker.health=1;blocker.armor=2
 assert(m.ai_step() and m.winner==1 and m.players[0].hp==0)
 print("OK: Atropelar, Armadura, Voo, Bloqueio, contra-ataque simultâneo e letal da IA.")
 quit()
