extends SceneTree
const Match=preload("res://scripts/match.gd")
func _init():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10;p.deck=["wolf","squire"]
 var ranger=m.spawn_unit(0,"wild_scout")
 var flyer=m.spawn_unit(1,"raven");flyer.ready=true
 m.turn=1
 assert(not m.can_target(1,0,-1,false) and m.can_target(1,0,0,false))
 m=fresh()
 var druid=m.spawn_unit(0,"wild_roots_druid");druid.ready=true
 var enemy=m.spawn_unit(1,"wolf")
 assert(m.can_target(0,0,0,true) and m.act(0,0,0,true) and enemy.rooted and m.players[0].mana==9)
 m=fresh()
 var ally=m.spawn_unit(0,"wild_wolf");ally.health=1;ally.max_health=20
 m.players[0].hand=["wild_regeneration"]
 assert(m.cast(0,0,0,0) and ally.regeneration==2)
 for i in range(5):
  m.turn=0
  assert(m.end_turn(0))
 assert(ally.health==11 and ally.regeneration==0 and ally.nature_regen_turns==0)
 print("OK: bloqueio de voadores, habilidade de raízes e cinco turnos de regeneração.")
 quit()
func fresh():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10;p.deck=["wolf","squire","wolf","squire","wolf","squire","wolf","squire","wolf","squire","wolf","squire"]
 return m
