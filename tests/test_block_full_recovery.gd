extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize():
 for side in [0,1]:
  var m=Match.new()
  for player in m.players:player.board.clear();player.hand.clear();player.mana=10
  m.turn=side
  var wall=m.spawn_unit(side,"village_wall")
  var enemy=m.spawn_unit(1-side,"dawn_warden")
  wall.block=0;enemy.block=1;wall["antimagic"]=0;wall["antimagic_capacity"]=2
  m.begin_turn()
  assert(wall.block==4 and enemy.block==3 and wall.antimagic==1)
  wall.block=1;enemy.block=0;wall.antimagic=0
  m.turn=1-side;m.begin_turn()
  assert(wall.block==4 and enemy.block==3 and wall.antimagic==0)
  wall.block=0;enemy.block=0
  m.refresh_auras();assert(wall.block==0 and enemy.block==0)
  m.turn=side;m.begin_turn();assert(wall.block==4 and enemy.block==3)
  # Permanent capacity changes are honored for both players.
  wall.block=0;wall["block_capacity"]=6
  m.turn=1-side;m.begin_turn();assert(wall.block==6)
 var m=Match.new();for p in m.players:p.board.clear();p.hand.clear();p.mana=10
 m.spawn_unit(0,"squire");m.spawn_unit(0,"squire")
 var mob=m.spawn_unit(0,"peasant_uprising");mob.block=0
 m.turn=1;m.begin_turn();assert(mob.block==2)
 assert(Match.CARD_DATA.squire.ability_entries(0).any(func(e):return e.get("badge","")=="Block" and e.description.contains("todas as cargas")))
 print("OK: todas as cargas dos dois lados, capacidade variável, Multidão e Antimagia independente.")
 quit()
