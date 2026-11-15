extends SceneTree
const Store=preload("res://scripts/deck_store.gd")
func _initialize():call_deferred("verify")
func verify():
 var path="res://work/test_15_slots.json"
 var store=Store.new(path,false)
 assert(Store.SLOT_COUNT==15 and store.slots.size()==15 and store.slots[4].cards.is_empty())
 var previous=store.slots[1].duplicate(true)
 assert(store.activate(0) and store.delete_slot(0))
 assert(store.slots[0].cards.is_empty() and store.active==1 and store.slots[1]==previous)
 var reopened=Store.new(path)
 assert(reopened.slots.size()==15 and reopened.active==1 and reopened.slots[0].cards.is_empty() and reopened.slots[1]==previous)
 var editor=load("res://deck_editor.tscn").instantiate();editor.configure(reopened);root.add_child(editor)
 await process_frame
 assert(editor.find_child("DeckLibrary",true,false).get_child_count()==15)
 var button=editor.find_child("DeckActionDelete",true,false)
 assert(button!=null and not button.disabled)
 button.pressed.emit();await process_frame
 var dialog=editor.find_child("DeleteDeckConfirmation",true,false)
 assert(dialog!=null and not reopened.slots[1].cards.is_empty())
 dialog.confirmed.emit();await process_frame
 assert(reopened.slots[1].cards.is_empty() and reopened.active!=1 and reopened.slots[2].cards.size()==22)
 assert(editor.find_child("DeckActionDelete",true,false).disabled)
 editor.queue_free()
 DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
 print("OK: 15 espaços, exclusão confirmada, persistência e novo deck ativo.")
 quit()
