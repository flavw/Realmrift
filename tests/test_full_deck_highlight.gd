extends SceneTree
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var store=DeckStore.new("user://highlight_check.json",false)
 var editor=load("res://deck_editor.tscn").instantiate()
 editor.configure(store);root.add_child(editor);editor.choose_slot(0)
 await process_frame
 assert(editor.draft.size()==20)
 var event=InputEventMouseButton.new()
 event.button_index=MOUSE_BUTTON_LEFT;event.pressed=true
 editor.collection_card_input(event,"wolf")
 assert(editor.draft.size()==20 and editor.focused_card=="wolf")
 assert(editor.find_child("CollectionView_wolf",true,false).modulate==Color.WHITE)
 assert(editor.find_child("CollectionView_squire",true,false).modulate!=Color.WHITE)
 editor.collection_card_input(event,"squire")
 assert(editor.find_child("CollectionView_squire",true,false).modulate==Color.WHITE)
 assert(editor.find_child("CollectionView_wolf",true,false).modulate!=Color.WHITE)
 editor.queue_free();await process_frame
 print("OK: carta selecionada fica clara mesmo com o deck completo.")
 quit()
