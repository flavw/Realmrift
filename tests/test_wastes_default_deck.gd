extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _initialize():
 var deck=Match.default_deck(7)
 assert(deck.size()==22 and Match.valid_deck(deck) and Match.deck_faction(deck)==CardData.Faction.WASTES)
 assert(Store.accepts_base(CardData.Faction.WASTES,deck))
 assert(deck.count("wastes_ancient_worm")==1 and deck.count("wastes_caravan_guide")==2 and deck.count("wastes_anubite_stalker")==2 and deck.count("wastes_jackal_leader")==2)
 for key in deck:assert(Match.CARD_DATA[key].faction==CardData.Faction.WASTES and deck.count(key)<=Match.copy_limit(key))
 var store=Store.new("user://deck-validation-unused.json",false)
 assert(store.slots[7].cards==deck and store.slots[7].cover=="wastes_ancient_worm" and store.base_for(7)==CardData.Faction.WASTES)
 print("OK: deck dos Ermos com 22 cartas, limites, facção e capa.")
 quit()
