extends SceneTree
const Match=preload("res://scripts/match.gd")
func _init() -> void:
 var m=Match.new()
 var card=Match.CARD_DATA["street_urchin"]
 assert(card.cost==1 and card.attack==1 and card.health==1 and card.loot==1)
 assert(card.ability_entries().any(func(entry): return entry.name=="Saquear 1"))
 m.players[0].board.clear();m.players[1].board.clear()
 m.players[0].hand.clear();m.players[0].deck=["wolf","squire"]
 var unit=m.spawn_unit(0,"street_urchin");unit.ready=true
 assert(m.act(0,0,-1))
 assert(m.players[0].hand.size()==1 and m.players[1].hp==19)
 assert(m.history.any(func(entry): return "Saquear 1" in entry))
 unit.ready=true
 m.spawn_unit(1,"wolf")
 assert(m.act(0,0,0))
 assert(m.players[0].hand.size()==1)
 var enemy=Match.new([],[],1)
 enemy.players[0].board.clear();enemy.players[1].board.clear()
 enemy.players[1].hand.clear();enemy.players[1].deck=["wolf"]
 var thief=enemy.spawn_unit(1,"street_urchin");thief.ready=true
 assert(enemy.act(1,0,-1) and enemy.players[1].hand.size()==1)
 var fatigue=Match.new()
 fatigue.players[0].board.clear();fatigue.players[1].board.clear()
 fatigue.players[0].deck.clear();fatigue.players[0].hand.clear()
 var tired=fatigue.spawn_unit(0,"street_urchin");tired.ready=true
 assert(fatigue.act(0,0,-1) and fatigue.players[0].hp==19)
 print("OK: Trombadinha, Saquear, criatura, IA e fadiga.")
 quit()
