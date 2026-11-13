extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _initialize() -> void:call_deferred("verify")
func unit(key: String,id: int) -> Dictionary:
 var u: Dictionary=Match.CARDS[key].duplicate(true)
 u.merge({"key":key,"id":id,"ready":true,"max_health":u.health,"poison":0})
 return u
func verify() -> void:
 var main=load("res://main.tscn").instantiate()
 main.enable_opening=false
 main.deck_store=Store.new("user://test_neutral_ui.json",false)
 root.add_child(main)
 main.duel.next_id=100
 var wolf=unit("wolf",1)
 main.duel.players[0].board=[wolf]
 main.duel.players[1].board=[]
 main.duel.players[0].hand=["village_leader","generous_peasant"]
 main.duel.players[0].mana=10
 assert(main.duel.play(0,0));main.redraw()
 var stats=main.field_nodes[0][1].get_node("Canvas/Stats")
 assert(stats.text=="3/2" and stats.attack_label.get_theme_color("font_color")==stats.BONUS)
 var entries=Match.CARD_DATA.village_leader.ability_entries()
 assert(entries[0].name=="Aura" and "Outros aliados" in entries[0].summary)
 main.show_preview(Match.CARD_DATA.wolf,wolf.health,main.field_nodes[0][1])
 var preview=main.preview
 assert(preview.get_node("CardCanvas/Stats").text=="3/2")
 assert(preview.view_entries().any(func(e):return e.name=="Bônus de Aura" and e.runtime))
 main.hide_preview()
 main.redraw();main.play(0)
 assert(main.summoning==-1 and wolf.health==3 and wolf.max_health==3)
 main.redraw()
 assert(main.field_nodes[0][1].get_node("Canvas/Stats").text=="3/3")
 main.duel.players[0].board.remove_at(1);main.redraw()
 assert(main.field_nodes[0][1].get_node("Canvas/Stats").text=="2/3")
 main.open_decks();var editor=main.deck_editor
 editor.choose_slot(4)
 await process_frame
 editor.select_base_faction(CardData.Faction.VILLAGER);editor.draft=Match.default_deck(4);editor.draft_name="União da Aldeia";editor.render()
 assert(editor.draft_name=="União da Aldeia" and Match.deck_faction(editor.draft)==-1)
 assert(editor.save_deck() and main.deck_store.cover_for(4)=="village_leader")
 var saved=Store.new(main.deck_store.path)
 assert(saved.slots[4].cards==Match.default_deck(4) and saved.active==0)
 main.queue_free();await process_frame;await create_timer(0.35).timeout
 DirAccess.remove_absolute(ProjectSettings.globalize_path(saved.path))
 print("OK: bônus verdes no campo/preview, ajuda de Aura, Chamado sem alvo, remoção imediata, receita aldeã e persistência.")
 quit()
