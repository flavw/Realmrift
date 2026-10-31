extends SceneTree
const Match=preload("res://scripts/match.gd")
func fresh():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10
 return m
func _initialize() -> void:
 for side in [0,1]:
  var m=fresh();m.turn=side
  var a=m.spawn_unit(side,"wolf");a.ready=true;a.attack=3;a.health=8
  var d=m.spawn_unit(1-side,"raven");d.attack=2;d.health=8;d.armor=1
  var forecast=m.attack_forecast(side,0,0)
  assert(forecast.damage==1 and forecast.received==2 and forecast.absorbed==1 and forecast.flight_reduction==1)
  assert(m.act(side,0,0) and d.health==7 and a.health==6)
  assert(m.last_action.amount==forecast.damage and m.last_action.received==forecast.received and m.last_action.flight_reduction==1)
  m=fresh();m.turn=side
  a=m.spawn_unit(side,"raven");a.ready=true;a.attack=3;a.health=8
  d=m.spawn_unit(1-side,"wolf");d.attack=2;d.health=8
  assert(m.attack_forecast(side,0,0).received==2)
  assert(m.act(side,0,0) and a.health==6 and d.health==5)
  m=fresh();m.turn=side
  a=m.spawn_unit(side,"raven");a.ready=true;a.attack=3;a.health=8
  d=m.spawn_unit(1-side,"raven");d.attack=2;d.health=8;d.abascanto=0
  assert(m.act(side,0,0) and a.health==6 and d.health==6)
  m=fresh();m.turn=side
  a=m.spawn_unit(side,"wolf");a.ready=true;a.attack=1;a.envenom=1;a.health=8
  d=m.spawn_unit(1-side,"wolf");d.turn_flying=true;d.health=8
  assert(m.act(side,0,0) and d.health==8 and d.poison==1 and m.last_action.flight_reduction==1)
  m=fresh();m.turn=side
  a=m.spawn_unit(side,"mage");a.ready=true
  d=m.spawn_unit(1-side,"raven");d.abascanto=0
  assert(m.attack_forecast(side,0,0,true).damage==1)
  assert(m.act(side,0,0,true) and d.health==2)
 print("OK: Voo ao defender, contra-ataque, Armadura, Voo temporário, Veneno e magia.")
 quit()
