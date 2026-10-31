extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var main=load("res://main.tscn").instantiate()
 main.enable_opening=false;main.muted=true
 root.add_child(main);await process_frame
 main.duel=Match.new()
 main.duel.players[0].board.clear();main.duel.players[1].board.clear()
 var wizard=main.duel.spawn_unit(0,"wizard_apprentice")
 wizard.ready=true
 main.duel.players[0].mana=0
 main.select(0);main._process(0.016)
 assert(not main.arcane_cursor_active)
 main.duel.players[0].mana=1
 main.select(0)
 main._process(0.016)
 assert(main.arcane_cursor_active)
 wizard.ready=false
 main._process(0.016)
 assert(not main.arcane_cursor_active)
 var mana=main.find_child("ManaBarArtwork",true,false)
 assert(mana!=null and mana.texture!=null)
 main.duel.players[0].mana=2;main.duel.players[0].temporary_mana=1
 main.redraw();await process_frame
 var gems=main.find_child("ManaGems",true,false)
 assert(gems.get_child(0).texture.atlas.resource_path.ends_with("mana-crystal-blue.webp"))
 assert(gems.columns==5 and gems.get_child_count()==10)
 assert(main.find_child("TemporaryMana",true,false).text=="+1")
 var board=main.board_background
 assert(board.BACKGROUNDS.size()==3 and board.background!=null)
 var previous=board.background_index
 board.choose_random_background()
 assert(board.background_index!=previous and board.background!=null)
 main.queue_free();await process_frame
 print("OK: cursor respeita mana e prontidão; moldura e mesas.")
 quit()
