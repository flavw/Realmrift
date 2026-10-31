extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _initialize() -> void:
 assert(Match.DECK_SIZE==22 and Match.MAX_HAND_SIZE==7)
 for i in range(6):
  var deck=Match.default_deck(i)
  assert(deck.size()==22 and Match.valid_deck(deck),"Deck padrão inválido: %d" % i)
 var match_game=Match.new()
 match_game.players[0].hand=["wolf","wolf","wolf","wolf","wolf","wolf"]
 match_game.players[0].deck=["squire","mage"]
 match_game.draw(0)
 assert(match_game.players[0].hand.size()==7 and match_game.players[0].deck.size()==1)
 match_game.draw(0)
 assert(match_game.players[0].hand.size()==7 and match_game.players[0].deck.is_empty() and match_game.draw_events.back().destroyed)
 var test_path="user://test_deck_22_migration.json"
 var slots=[]
 for i in range(6):
  var old=Match.default_deck(i).slice(0,20)
  slots.append({"name":"Meu deck %d" % i,"cards":old,"cover":old[0],"base_class":Store.infer_base(old)})
 for i in range(3):slots.append({"name":"Vazio %d" % i,"cards":[],"cover":"","base_class":-1})
 var mixed=slots[0].cards.duplicate()
 mixed[0]="mage"
 slots[6]={"name":"Misturado antigo","cards":mixed,"cover":"mage","base_class":-2}
 var old_cards=slots[2].cards.duplicate()
 var file=FileAccess.open(test_path,FileAccess.WRITE)
 file.store_string(JSON.stringify({"version":9,"active":2,"slots":slots}));file.close()
 var store=Store.new(test_path,true)
 assert(store.active==2 and store.slots[2].name=="Meu deck 2" and store.slots[2].cover==old_cards[0])
 for i in range(6):
  assert(store.slots[i].cards.size()==22 and Match.valid_deck(store.slots[i].cards))
  for key in slots[i].cards:assert(store.slots[i].cards.count(key)>=slots[i].cards.count(key))
 assert(store.slots[6].cards==mixed and store.slots[6].name=="Misturado antigo")
 assert(store.slots[7].cards.is_empty())
 var reloaded=Store.new(test_path,true)
 assert(reloaded.slots==store.slots and reloaded.active==2)
 DirAccess.remove_absolute(ProjectSettings.globalize_path(test_path))
 print("OK: decks padrão, migração de decks salvos e limite de mão.")
 quit()
