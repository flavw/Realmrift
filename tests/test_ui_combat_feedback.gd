extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var store=Store.new("user://feedback_test.json",false)
 var editor=load("res://deck_editor.tscn").instantiate()
 editor.configure(store);root.add_child(editor);await process_frame
 editor.choose_slot(1);await process_frame
 editor.find_child("ManaCurveFilter1",true,false).pressed.emit()
 assert(editor.mana_filter==1 and not editor.collection_keys().is_empty())
 for key in editor.collection_keys():assert(Match.CARD_DATA[key].cost==1)
 editor.find_child("ManaCurveFilter1",true,false).pressed.emit()
 assert(editor.mana_filter==-1)
 editor.filter_mana(2);editor.clear_collection_filters()
 assert(editor.mana_filter==-1)
 editor.queue_free();await process_frame
 var main=load("res://main.tscn").instantiate()
 main.enable_opening=false;main.muted=true
 root.add_child(main);await process_frame
 main.duel=Match.new()
 main.duel.players[0].board.clear();main.duel.players[1].board.clear()
 var attacker=main.duel.spawn_unit(0,"warrior")
 var guard=main.duel.spawn_unit(1,"squire")
 var other=main.duel.spawn_unit(1,"wolf")
 attacker.ready=true
 main.selected=0;main.redraw();await process_frame
 assert(main.field_nodes[0][attacker.id].get_meta("selection_kind")=="selected")
 assert(main.field_nodes[1][guard.id].get_meta("selection_kind")=="target")
 assert(main.field_nodes[1][other.id].get_meta("selection_kind")=="")
 assert(main.find_child("EnemyCastle",true,false).disabled)
 guard.armor=2
 assert(main.duel.act(0,0,0))
 assert(main.duel.last_action.amount==maxi(0,Match.CARD_DATA.warrior.attack-2) and main.duel.last_action.absorbed==2)
 assert(main.duel.last_action.has("received") and main.duel.last_action.has("counter_absorbed"))
 main.queue_free();await process_frame
 print("OK: filtros de mana, alvo válido e dano após armadura.")
 quit()
