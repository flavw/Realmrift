extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize():
 var data=Match.CARD_DATA.wild_wolf
 assert(data.pack==1 and data.fury==0 and data.cost==1 and data.attack==2 and data.health==1)
 assert(data.ability_entries().any(func(e):return e.name=="Matilha 1"))
 assert(not data.ability_entries().any(func(e):return e.name.begins_with("Fúria")))
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10;p.deck=["squire","wolf"]
 var wolf=m.spawn_unit(0,"wild_wolf")
 assert(Match.attack_value(wolf)==2)
 m.spawn_unit(1,"wolf");m.spawn_unit(0,"farmer")
 assert(Match.attack_value(wolf)==2)
 m.spawn_unit(0,"wolf")
 assert(Match.attack_value(wolf)==3)
 assert(not m.fury(0,0))
 assert(m.end_turn(0) and Match.attack_value(wolf)==2)
 print("OK: Lobo com Matilha 1, sem Fúria; gatilhos e fim do turno.")
 quit()
