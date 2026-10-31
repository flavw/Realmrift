extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _init() -> void:
 var store=Store.new("user://unused-test.json",false)
 var names=["Baluarte das Cicatrizes","Caçada das Brumas","Círculo Arcano","Aurora Vital","Horda dos Ermos","União da Colheita"]
 var styles=[0,1,2,3,5,4]
 for i in range(6):
  assert(store.slots[i].name==names[i])
  assert(store.slots[i].cards==Match.default_deck(styles[i]))
  assert(Match.valid_deck(store.slots[i].cards) and store.accepts_base(store.base_for(i),store.slots[i].cards))
 assert(store.slots[0].cover=="bloodblade")
 for i in range(6,9):assert(store.slots[i].cards.is_empty())
 print("OK: seis decks padrão válidos, capa e três espaços livres.")
 quit()
