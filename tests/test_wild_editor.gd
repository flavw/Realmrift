extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _initialize():call_deferred("verify")
func verify():
 var store=Store.new("user://wild_test.json",false)
 var e=load("res://deck_editor.tscn").instantiate();e.configure(store);root.add_child(e)
 await process_frame
 e.choose_slot(6);e.select_base_faction(CardData.Faction.WILD)
 assert(e.draft_base==6 and "wild_elf" in e.collection_keys() and "wild_roots" in e.collection_keys())
 assert(Store.accepts_base(6,["wild_elf","squire"]) and not Store.accepts_base(6,["wild_elf","mage"]))
 var deck=[]
 for k in ["wild_elf","wild_scout","wild_archer","wild_badger","wild_wolf","wild_wasp","wild_roots_druid","wild_sprout_druid","wild_guardian","wild_roots","wild_regeneration"]:deck.append(k);deck.append(k)
 assert(Match.valid_deck(deck) and store.save_slot(6,"Selvagens",deck,6))
 e.queue_free();await process_frame
 print("OK: editor, coleção e deck Selvagem válido.")
 quit()
