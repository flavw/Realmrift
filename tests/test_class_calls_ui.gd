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
 main.deck_store=Store.new("user://test_class_calls_ui.json",false)
 root.add_child(main)
 main.duel.players[0].board=[unit("cleric",50)]
 main.duel.players[1].board=[unit("squire",60)]
 main.duel.players[0].hand=["mist_alchemist"]
 main.duel.players[0].mana=10
 main.redraw();main.play(0)
 assert(main.summoning==0 and main.field_nodes[1][60].available and not main.field_nodes[0][50].available)
 assert(main.find_child("EnemyCastle",true,false).disabled and main.find_child("PlayerCastle",true,false).disabled)
 assert(main.duel.players[0].mana==10)
 main.summon_target(0,0)
 assert(main.summoning==0 and main.duel.players[0].mana==10)
 main.field_nodes[1][60].activated.emit()
 assert(main.duel.players[1].board[0].poison==2 and main.duel.players[0].mana==7 and main.summoning==-1)
 main.duel.players[0].hand=["wall_smith"]
 main.play(0)
 assert(main.field_nodes[0][50].available and not main.field_nodes[1][60].available)
 main.field_nodes[0][50].activated.emit()
 assert(main.duel.players[0].board[0].armor==1)
 main.duel.players[0].hand=["dawn_oracle"]
 main.duel.players[0].mana=10
 main.play(0);main.field_nodes[0][50].activated.emit()
 assert(main.duel.players[0].board[0].health==6 and main.duel.players[0].board[0].max_health==6)
 assert(main.field_nodes[0][50].get_node("Canvas/Stats").text=="1/6")
 main.duel.players[0].board=[]
 main.duel.players[0].hand=["aether_summoner"]
 main.duel.players[0].mana=10
 main.redraw();main.play(0)
 assert(main.summoning==-1 and main.duel.players[0].board.size()==2 and main.duel.magic_bonus(0)==1)
 main.open_decks()
 var editor=main.deck_editor
 editor.choose_slot(3)
 await process_frame
 editor.draft=Match.default_deck(3);editor.render()
 assert(editor.draft_name=="Aurora Vital" and editor.draft.count("dawn_oracle")==2 and Match.deck_faction(editor.draft)==CardData.Faction.CLERIC)
 assert(editor.save_deck() and main.deck_store.slots.size()==Store.SLOT_COUNT)
 var saved=Store.new(main.deck_store.path)
 assert(saved.slots[3].cards==editor.draft and saved.slots[3].name=="Aurora Vital")
 main.close_decks()
 main.queue_free()
 await process_frame
 await create_timer(0.35).timeout
 DirAccess.remove_absolute(ProjectSettings.globalize_path(saved.path))
 print("OK: alvos de Chamado por lado, veneno/Armadura/vida no campo, invocação automática e sugestão de Clérigo nos 9 espaços.")
 quit()
