extends SceneTree
const Match=preload("res://scripts/match.gd")
func unit(key: String,id: int) -> Dictionary:
 var u: Dictionary=Match.CARDS[key].duplicate(true)
 u.merge({"key":key,"id":id,"ready":true,"max_health":u.health,"poison":0})
 return u
func fixture():
 var m=Match.new()
 for p in m.players:p.board=[];p.hand=[];p.mana=10
 m.next_id=100
 return m
func _init() -> void:
 var data: CardData=Match.CARD_DATA.village_wall
 assert(data.cost==4 and data.attack==0 and data.health==4 and data.armor==1 and data.block==4 and data.wall)
 assert(data.card_class==CardData.CardClass.NEUTRAL)
 var m=fixture();var wall=unit("village_wall",1)
 m.players[0].board=[wall];m.players[0].hand=["iron_stance"]
 assert(m.cast(0,0,0,0) and wall.attack==1 and not m.can_target(0,0,-1) and not m.act(0,0,-1))
 wall.vigor=true
 assert(Match.physical_attack(wall)==4 and not m.can_target(0,0,-1),"Vigor não permite declarar ataque com Muralha")
 # Every physical hit is reduced, while magic bypasses armor.
 wall=unit("village_wall",1)
 assert(Match.damage(wall,1)==0 and wall.health==4)
 assert(Match.damage(wall,3,true)==3 and wall.health==1)
 # Four mandatory targets, then only one charge replenishes on own turn.
 m=fixture();wall=unit("village_wall",1)
 var attacker=unit("squire",2);m.turn=1
 m.players[0].board=[wall];m.players[1].board=[attacker]
 for i in range(4):
  attacker.ready=true
  assert(not m.can_target(1,0,-1) and m.act(1,0,0) and wall.block==3-i and wall.health==4)
 attacker.ready=true;assert(m.can_target(1,0,-1))
 m.end_turn(1);assert(wall.block==1)
 m.end_turn(0);assert(not m.can_target(1,0,-1))
 # Flying and magic still bypass the target restriction.
 m.players[1].board=[unit("raven",3)];assert(m.can_target(1,0,-1))
 # Poison through direct helpers, entry effects and physical hits is ignored.
 assert(not Match.apply_poison(wall,4) and wall.poison==0)
 wall.poison=3;m.resolve_poison(0)
 assert(wall.poison==0 and wall.health==4)
 m=fixture();wall=unit("village_wall",1);m.players[1].board=[wall]
 m.players[0].hand=["mist_alchemist"]
 assert(m.play(0,0,0) and wall.poison==0 and not m.last_action.has("poison_target"))
 var rogue=unit("lightning_rogue",2);m.players[0].board=[rogue]
 assert(m.act(0,0,0) and wall.poison==0)
 # Both creature healing and spell healing reject wounded walls atomically.
 m=fixture();wall=unit("village_wall",1);wall.health=1
 var cleric=unit("cleric",2);m.players[0].board=[wall,cleric]
 assert(not m.can_heal(0,1,0) and not m.heal(0,1,0) and cleric.ready and m.players[0].mana==10)
 m.players[0].hand=["restoring_light"]
 assert(not m.cast(0,0,0,0) and m.players[0].mana==10 and m.players[0].hand.size()==1)
 # Increasing maximum life is a stat bonus, not healing.
 m.players[0].hand=["generous_peasant"]
 assert(m.play(0,0) and wall.health==2 and wall.max_health==5)
 # AI must skip an attack-buffed wall without wasting other creatures' actions.
 m=fixture();m.turn=1;wall=unit("village_wall",1);wall.attack=3
 m.players[1].board=[wall,unit("wolf",2)]
 assert(m.ai_step() and m.last_action.attacker==2 and m.players[0].hp==18)
 print("OK: Muralha 0/4, custo 4, Armadura/Bloqueio 4, imunidade a Veneno, cura recusada, nenhum ataque com buffs/Vigor e IA.")
 quit()
