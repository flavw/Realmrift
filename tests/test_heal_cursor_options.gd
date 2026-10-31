extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var main=load("res://main.tscn").instantiate()
 main.enable_opening=false;main.muted=true
 root.add_child(main);await process_frame
 main.duel=Match.new()
 main.duel.players[0].board.clear();main.duel.players[1].board.clear()
 main.duel.players[0].hand=["restoring_light","astral_flame"]
 main.duel.players[0].mana=10
 main.casting=0;main._process(0.016)
 assert(main.heal_cursor_active and not main.arcane_cursor_active)
 main.casting=1;main._process(0.016)
 assert(not main.heal_cursor_active and main.arcane_cursor_active)
 var healer=main.duel.spawn_unit(0,"dawn_acolyte")
 healer.ready=true
 main.casting=-1;main.selected=0;main.healing=true;main._process(0.016)
 assert(main.heal_cursor_active and not main.arcane_cursor_active)
 main.healing=false;main.selected=-1
 main.open_combat_menu()
 assert(main.find_child("CombatOptions",true,false)!=null)
 main.show_options();await process_frame
 assert(main.options_dialog.visible and main.options_dialog.find_child("MusicVolume",true,false)!=null)
 main.options_dialog.hide()
 main.queue_free();await process_frame
 print("OK: cursor de cura para habilidade e magia; opções no menu de combate.")
 quit()
