extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var store=Store.new("user://test_six_decks.json",false)
 assert(store.slots.size()==Store.SLOT_COUNT and store.slots[3].name=="Aurora Vital")
 assert(store.slots[3].cards==Match.default_deck(3) and store.slots[4].cards.is_empty() and store.slots[5].cards.is_empty())
 var original: Array=store.slots.slice(0,3).duplicate(true)
 original[0].name="Meu Guerreiro"
 original[2].name="Minhas magias"
 var file:=FileAccess.open(store.path,FileAccess.WRITE)
 file.store_string(JSON.stringify({"version":2,"active":2,"slots":original}));file.close()
 var migrated=Store.new(store.path)
 assert(migrated.slots.size()==Store.SLOT_COUNT and migrated.slots.slice(0,3)==original and migrated.active==2,"Ampliação preserva decks e ativo antigos")
 assert(migrated.slots[3].name=="Aurora Vital" and migrated.slots[3].cards==Match.default_deck(3))
 assert(migrated.slots[4].cards.is_empty() and migrated.slots[5].cards.is_empty())
 var stored=JSON.parse_string(FileAccess.get_file_as_string(store.path))
 assert(stored.version==Store.DECKSET_VERSION and stored.slots.size()==Store.SLOT_COUNT)
 assert(not migrated.activate(4) and migrated.active==2,"Espaço vazio não pode iniciar partida")
 var editor=load("res://deck_editor.tscn").instantiate()
 editor.configure(migrated)
 root.add_child(editor)
 await process_frame
 await process_frame
 var tabs=editor.find_child("DeckLibrary",true,false)
 assert(tabs is GridContainer and tabs.columns==(5 if editor.get_viewport_rect().size.x>=1800 else 3) and tabs.get_child_count()==Store.SLOT_COUNT)
 assert(tabs.get_global_rect().end.x<=root.get_visible_rect().size.x)
 editor.choose_slot(4)
 assert(editor.draft.is_empty() and editor.find_child("DeckSuggestion",true,false)==null)
 assert(editor.screen=="choose_class")
 editor.select_base_class(CardData.CardClass.LADINO)
 var play: Button
 for b in editor.find_children("*","Button",true,false):
  if b.text=="Jogar com este deck":play=b
 assert(play!=null and play.disabled)
 editor.draft_name="Meu novo deck"
 assert(editor.save_deck())
 var reopened=Store.new(store.path)
 assert(reopened.slots[4].name=="Meu novo deck" and reopened.slots[4].cards.is_empty(),"Espaço vazio é persistido sem ganhar cartas automaticamente")
 assert(editor.add_card("lightning_rogue") and not editor.add_card("mage"))
 assert(not editor.save_deck(),"Rascunho incompleto não é salvo como deck jogável")
 editor.clear_draft()
 for key in Match.default_deck(1):
  assert(editor.add_card(key))
  await process_frame
 assert(editor.save_deck() and migrated.activate(4))
 reopened=Store.new(store.path)
 assert(reopened.active==4 and reopened.slots[4].cards==Match.default_deck(1) and reopened.slots[5].cards.is_empty())
 assert(reopened.save_slot(4,"Meu novo deck",[]) and reopened.active==0,"Limpar deck ativo escolhe outro completo")
 var reloaded=Store.new(store.path)
 assert(reloaded.slots[4].cards.is_empty() and reloaded.slots[5].cards.is_empty())
 assert(reloaded.slots.slice(0,3)==original and reloaded.slots[3].name=="Aurora Vital")
 editor.queue_free()
 await process_frame
 await create_timer(0.35).timeout
 DirAccess.remove_absolute(ProjectSettings.globalize_path(store.path))
 print("OK: seis espaços em 2 linhas, Aurora no quarto, quinto/sexto vazios, migração preservada, criação/salvamento e bloqueio de jogar vazio.")
 quit()
