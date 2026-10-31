extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func fresh():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10
 return m
func verify() -> void:
 var m=fresh()
 var attacker=m.spawn_unit(0,"bloodblade");attacker.ready=true
 var victim=m.spawn_unit(1,"warrior");victim.health=10;victim.max_health=10
 assert(m.act(0,0,0) and victim.bleeding==1)
 m.apply_bleeding(victim,1,1);assert(victim.bleeding==2)
 assert(m.end_turn(0))
 var before:int=victim.health
 assert(m.act(1,0,-1) and victim.health==before-2 and victim.bleeding==2)
 assert(m.end_turn(1) and victim.bleeding==0)
 m=fresh();victim=m.spawn_unit(0,"warrior");victim.bleeding=2
 assert(m.end_turn(0) and victim.bleeding==0 and victim.health==1)
 m=fresh();var wall=m.spawn_unit(0,"village_wall")
 m.apply_bleeding(wall,2,0);assert(int(wall.get("bleeding",0))==0)
 m=fresh();var healer=m.spawn_unit(0,"cleric");healer.ready=true
 victim=m.spawn_unit(0,"warrior");victim.bleeding=2
 assert(m.heal(0,0,1) and victim.bleeding==0)
 m=fresh();var wolf=m.spawn_unit(0,"wolf");wolf.bleeding=1;wolf.health=1
 assert(m.fury(0,0) and m.players[0].board.is_empty() and m.last_action.dead.size()==1)
 print("OK: Sangrar acumula, causa dano após ação, expira, é removido por Cura e respeita imunidade.")
 quit()
