extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _initialize():
 var card: CardData=Match.CARD_DATA.gallant_farmer
 assert(card.title=="Fazendeiro Galante" and card.cost==4 and card.attack==3 and card.health==4 and card.rural_pride==1 and card.faction==CardData.Faction.VILLAGER and card.creature_type==CardData.CreatureType.HUMAN)
 assert(card.artwork!=null and Store.accepts_base(CardData.Faction.VILLAGER,["gallant_farmer"]))
 for side in [0,1]:
  var m=Match.new();for p in m.players:p.board.clear();p.hand.clear();p.mana=10
  m.turn=side;var farmer=m.spawn_unit(side,"gallant_farmer");m.begin_turn()
  assert(farmer.attack==4 and farmer.health==4)
  m.begin_turn();assert(farmer.attack==5)
  var foreign=m.spawn_unit(side,"mage");m.begin_turn();assert(farmer.attack==5)
  m.players[side].board.erase(foreign);m.begin_turn();assert(farmer.attack==6)
 print("OK: Fazendeiro Galante disponível, Brio e restrição de facção em ambos os lados.")
 quit()
