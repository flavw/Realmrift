extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var data=JSON.parse_string(FileAccess.get_file_as_string("res://docs/decks-revisados.json"))
 var saved=Store.new("user://test_reviewed_decks.json",false)
 for i in range(5):
  assert(Match.valid_deck(data.slots[i].cards))
  assert(Store.accepts_base(data.slots[i].base_faction,data.slots[i].cards))
  assert(data.slots[i].cards==Match.default_deck(i))
  assert(saved.save_slot(i,data.slots[i].name,data.slots[i].cards,data.slots[i].base_faction))
 assert(data.slots[0].cards.count("village_wall")==1)
 assert(data.slots[2].cards.count("fireball")==2)
 assert(Match.deck_faction(data.slots[4].cards)==-1 and data.slots[4].cards.count("village_reconstruction")==2)
 var editor=load("res://deck_editor.tscn").instantiate();editor.configure(saved);root.add_child(editor)
 for i in range(5):
  editor.choose_slot(i)
  assert(editor.find_child("DeckSuggestion",true,false)==null)
  for node in editor.find_children("*","Button",true,false):assert("sugest" not in node.text.to_lower())
 editor.choose_slot(5);editor.select_base_faction(2)
 assert(editor.draft.is_empty() and editor.draft_base==2)
 assert(editor.find_child("DeckSuggestion",true,false)==null)
 var results=JSON.parse_string(FileAccess.get_file_as_string("res://docs/simulacao-decks-50-partidas.json"))
 assert(results.total_games==50 and results.games.size()==50 and results.summaries.size()==5)
 for i in range(5):
  var batch: Array=results.games.filter(func(g):return g.slot==i)
  assert(batch.size()==10 and batch.filter(func(g):return g.starter==0).size()==5)
  for game in batch:
   assert(int(game.winner) in [0,1,2] and game.mulligans.size()==3)
   assert(game.initial_hands[int(game.starter)].size()==3 and game.initial_hands[1-int(game.starter)].size()==4)
 editor.queue_free();await process_frame;await create_timer(0.35).timeout
 DirAccess.remove_absolute(ProjectSettings.globalize_path(saved.path))
 print("OK: listas revisadas válidas, aldeões exclusivos, editor sem sugestões e 50 partidas com iniciativa alternada e mulligan atual.")
 quit()
