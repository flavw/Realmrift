extends SceneTree
const Setup=preload("res://scripts/match_setup.gd")
const Store=preload("res://scripts/deck_store.gd")
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var menu=load("res://start_menu.tscn").instantiate()
 menu.store=Store.new("user://test_opponent_choice.json",false)
 root.add_child(menu);current_scene=menu;await process_frame
 menu.show_deck_selector()
 var picker: OptionButton=menu.enemy_deck_picker
 assert(picker.item_count==7 and picker.get_item_text(0)=="Aleatório" and picker.get_selected_id()==0)
 picker.select(6)
 var expected: Array=menu.store.slots[5].cards.duplicate()
 Setup.enemy_slot=5
 assert(Setup.choose_enemy(menu.store)==expected)
 menu.find_child("SelectDeck_0",true,false).pressed.emit()
 await process_frame;await process_frame
 var duel=current_scene
 assert(Setup.enemy_slot==5)
 duel.deck_store=Store.new("user://test_opponent_choice.json")
 duel.enable_opening=false;duel.restart()
 assert(duel.enemy_deck==expected)
 Setup.enemy_slot=-1
 var chosen=Setup.choose_enemy(Store.new("user://no-file.json",false))
 assert(Match.valid_deck(chosen))
 Setup.enemy_slot=-1
 DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_opponent_choice.json"))
 duel.queue_free()
 print("OK: seletor, adversário neutro personalizado, reinício e aleatório.")
 quit()
