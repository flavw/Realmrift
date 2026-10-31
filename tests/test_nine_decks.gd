extends SceneTree
const Store=preload("res://scripts/deck_store.gd")
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var initial=Store.new("user://test_nine_decks.json",false)
 var previous: Array=initial.slots.slice(0,6).duplicate(true)
 previous[0].name="Meu Guerreiro"
 previous[0].cover="warrior"
 previous[4]={"name":"Meu deck criado","cards":Match.default_deck(1),"cover":"raven","base_class":CardData.CardClass.LADINO}
 var file:=FileAccess.open(initial.path,FileAccess.WRITE)
 file.store_string(JSON.stringify({"version":4,"active":4,"slots":previous}));file.close()
 var store=Store.new(initial.path)
 assert(store.slots.size()==9 and store.slots.slice(0,6)==previous and store.active==4)
 for i in range(6,9):assert(store.slots[i].cards.is_empty() and store.cover_for(i)=="")
 assert(JSON.parse_string(FileAccess.get_file_as_string(store.path)).version==Store.DECKSET_VERSION)
 assert(not store.activate(8) and store.active==4)
 var editor=load("res://deck_editor.tscn").instantiate()
 editor.configure(store)
 root.add_child(editor)
 await process_frame
 await process_frame
 assert(editor.find_child("DeckLibrary",true,false).get_child_count()==9)
 editor.select_library_deck(8)
 await process_frame
 await process_frame
 var scroll=editor.find_child("DeckLibraryScroll",true,false)
 assert(scroll.get_global_rect().grow(1).encloses(editor.find_child("DeckTile9",true,false).get_global_rect()),"Nono espaço selecionado fica visível")
 assert(editor.find_child("DeckActionPlay",true,false).disabled)
 editor.find_child("DeckActionEdit",true,false).pressed.emit()
 assert(editor.slot==8 and editor.draft.is_empty())
 editor.select_base_class(CardData.CardClass.CLERIC)
 editor.draft=Match.default_deck(3)
 editor.draft_name="Meu nono deck"
 assert(editor.save_deck() and store.activate(8))
 assert(store.save_metadata(8,"Meu nono deck","dawn_oracle"))
 var loaded=Store.new(store.path)
 assert(loaded.slots.size()==9 and loaded.active==8 and loaded.slots[8].name=="Meu nono deck" and loaded.cover_for(8)=="dawn_oracle")
 assert(loaded.slots.slice(0,6)==previous and loaded.slots[6].cards.is_empty() and loaded.slots[7].cards.is_empty())
 editor.queue_free()
 await process_frame
 var reopened_editor=load("res://deck_editor.tscn").instantiate()
 reopened_editor.configure(loaded)
 root.add_child(reopened_editor)
 await process_frame
 await process_frame
 assert(reopened_editor.library_selected==8 and reopened_editor.find_child("DeckLibraryScroll",true,false).get_global_rect().grow(1).encloses(reopened_editor.find_child("DeckTile9",true,false).get_global_rect()),"Ao abrir, deck ativo fica visível")
 reopened_editor.queue_free()
 await process_frame
 await create_timer(0.35).timeout
 DirAccess.remove_absolute(ProjectSettings.globalize_path(store.path))
 print("OK: nove espaços, migração preserva seis decks/capas/ativo, novos vazios, rolagem e criação no nono espaço.")
 quit()
