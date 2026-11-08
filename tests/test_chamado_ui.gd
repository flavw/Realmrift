extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _initialize() -> void:call_deferred("verify")
func unit(key: String,id: int) -> Dictionary:
 var u: Dictionary=Match.CARDS[key].duplicate(true)
 u.merge({"key":key,"id":id,"ready":false,"max_health":u.health,"poison":0})
 return u
func verify() -> void:
 var main=load("res://main.tscn").instantiate()
 main.enable_opening=false
 main.deck_store=Store.new("user://test_chamado_ui.json",false)
 root.add_child(main)
 main.duel.players[0].board=[unit("squire",101)]
 main.duel.players[1].board=[unit("wolf",201)]
 main.duel.players[0].hand=["moon_herald"]
 main.duel.players[0].mana=5
 main.redraw()
 main.play(0)
 assert(main.summoning==0 and main.selected==-1 and main.casting==-1)
 assert(main.duel.players[0].hand.size()==1 and main.duel.players[0].mana==5)
 assert(main.field_nodes[0][101].available and not main.field_nodes[1][201].available)
 assert(main.find_child("PlayerCastle",true,false).disabled and main.find_child("EnemyCastle",true,false).disabled)
 for button in main.find_children("*","Button",true,false):
  if button.text=="Cancelar":button.pressed.emit();break
 assert(main.summoning==-1 and main.duel.players[0].hand.size()==1 and main.duel.players[0].mana==5)
 main.play(0)
 main.summon_target(1,0);main.summon_target(0,9)
 assert(main.summoning==0 and main.duel.players[0].mana==5)
 main.field_nodes[0][101].activated.emit()
 assert(main.summoning==-1 and main.duel.players[0].hand.is_empty() and main.duel.players[0].mana==3)
 assert(main.duel.players[0].board[0].attack==2 and main.duel.players[0].board[0].health==3 and main.duel.players[0].board[0].max_health==3 and main.duel.players[0].board.size()==2)
 assert(not main.duel.players[0].board[0].ready)
 main.open_decks()
 var editor=main.deck_editor
 editor.choose_slot(editor.slot)
 await process_frame
 var badges=editor.find_children("DeckManaCost","Control",true,false)
 assert(not badges.is_empty() and badges[0].get_child(1).text.is_valid_int())
 editor.clear_draft()
 assert(editor.add_card("mage") and not editor.add_card("warrior") and editor.add_card("moon_herald"))
 editor.remove_card("mage")
 assert(editor.add_card("cleric"),"Remover a última carta da classe libera outra")
 main.close_decks()
 main.queue_free()
 await process_frame
 var legacy=Store.new("user://test_legacy_ui.json",false)
 legacy.slots[0].cards[0]="mage"
 var repair=load("res://main.tscn").instantiate()
 repair.deck_store=legacy
 root.add_child(repair)
 await process_frame
 assert(repair.needs_deck_fix and is_instance_valid(repair.deck_editor) and not repair.can_act())
 assert(not is_instance_valid(repair.mulligan_layer))
 assert(Match.deck_class(repair.deck_editor.draft)==-2)
 repair.deck_editor.choose_slot(0)
 repair.deck_editor.draft=Match.default_deck(0);repair.deck_editor.draft_base=0;repair.deck_editor.render()
 repair.deck_editor.play_deck()
 await process_frame
 assert(not repair.needs_deck_fix and not is_instance_valid(repair.deck_editor) and is_instance_valid(repair.mulligan_view))
 assert(Match.valid_deck(legacy.active_cards()))
 repair.queue_free()
 await process_frame
 await create_timer(0.35).timeout
 DirAccess.remove_absolute(ProjectSettings.globalize_path(legacy.path))
 print("OK: Chamado com escolha/cancelamento/alvos/consumo, ícone de mana na lista, trava de classes e reparo de deck legado antes do mulligan.")
 quit()
