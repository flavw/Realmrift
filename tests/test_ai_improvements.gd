extends SceneTree
const Match=preload("res://scripts/match.gd")
func fresh():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.deck=["wolf","squire"];p.mana=5;p.max_mana=5;p.hp=20
 m.turn=1
 return m
func _init() -> void:
 var m=fresh()
 var wolf=m.spawn_unit(1,"wolf")
 assert(not wolf.ready and m.ai_step() and wolf.fury_used and wolf.attack==3 and not wolf.ready)
 assert(not m.ai_step())
 m=fresh();wolf=m.spawn_unit(1,"wolf");wolf.ready=true;m.players[0].hp=2
 assert(m.ai_step() and m.winner==1 and not wolf.get("fury_used",false))
 m=fresh();wolf=m.spawn_unit(1,"wolf");wolf.health=1;wolf.bleeding=1
 assert(not m.ai_step() and not wolf.get("fury_used",false) and wolf.health==1)
 m=fresh()
 var mage=m.spawn_unit(1,"mage");mage.ready=true
 var protected=m.spawn_unit(0,"farmer");protected.health=1;protected.abascanto=1
 var open=m.spawn_unit(0,"wolf");open.health=1
 assert(m.ai_step() and protected.abascanto==1 and m.players[0].board.has(protected) and not m.players[0].board.has(open))
 m=fresh()
 var mage2=m.spawn_unit(1,"mage");mage2.ready=true
 var only=m.spawn_unit(0,"farmer");only.abascanto=1
 assert(not m.ai_step() or only.abascanto==1,"Evita gastar disparo arcano em Guarda Arcana quando não causa dano")
 m=fresh()
 var warded=m.spawn_unit(0,"farmer");warded.abascanto=1
 var target_a=m.spawn_unit(0,"wolf");target_a.health=1
 var target_b=m.spawn_unit(0,"squire");target_b.health=1
 m.players[1].hand=["magic_missiles"]
 assert(m.ai_step())
 assert(warded.abascanto==1 and m.players[0].board.has(warded))
 assert(not m.players[0].board.has(target_a) and not m.players[0].board.has(target_b))
 m=fresh()
 var attacker=m.spawn_unit(1,"wolf");attacker.ready=true;attacker.fury=0
 var dangerous=m.spawn_unit(0,"warrior");dangerous.attack=9;dangerous.health=1
 var safer=m.spawn_unit(0,"farmer");safer.attack=0;safer.health=1
 assert(m.ai_step() and m.players[0].board.has(dangerous) and not m.players[0].board.has(safer))
 assert(m.players[1].board.has(attacker))
 print("OK: Fúria esgotada, letal, Sangramento, Guarda Arcana, mísseis e trocas seguras.")
 quit()

