extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _init() -> void:
 var store=Store.new("user://unused-test.json",false)
 var names=["Baluarte das Cicatrizes","Caçada das Brumas","Círculo Arcano","Aurora Vital","Ruína dos Ermos","União da Colheita","Aliança da Floresta","Ecos das Dunas"]
 var styles=[0,1,2,3,5,4,6,7]
 for i in range(8):
  if i==4:
   assert(store.slots[i].cards.is_empty())
   continue
  assert(store.slots[i].name==names[i])
  assert(store.slots[i].cards==Match.default_deck(styles[i]))
  assert(Match.valid_deck(store.slots[i].cards) and store.accepts_base(store.base_for(i),store.slots[i].cards))
 assert(store.slots[0].cover=="bloodblade")
 for i in range(8,15):assert(store.slots[i].cards.is_empty())
 print("OK: sete decks padrão válidos e oito espaços livres.")
 quit()
