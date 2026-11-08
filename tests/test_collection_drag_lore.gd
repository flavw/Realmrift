extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _initialize():call_deferred("verify")
func verify():
 var editor=load("res://deck_editor.tscn").instantiate()
 editor.configure(Store.new("user://collection_drag_test.json",false))
 root.add_child(editor)
 editor.show_full_collection()
 await process_frame;await process_frame;await process_frame
 var scroll: ScrollContainer=editor.collection_scroll
 var card: Control=editor.find_child("CollectionView_wild_elf",true,false)
 assert(card!=null and scroll.get_v_scroll_bar().max_value>scroll.size.y)
 var click:=InputEventMouseButton.new()
 click.button_index=MOUSE_BUTTON_LEFT;click.pressed=true
 click.position=scroll.get_global_rect().position+Vector2(80,80)
 editor._input(click)
 card.gui_input.emit(click)
 assert(not is_instance_valid(editor.collection_dialog) or not editor.collection_dialog.visible)
 var motion:=InputEventMouseMotion.new()
 motion.position=click.position+Vector2(0,-140)
 motion.button_mask=MOUSE_BUTTON_MASK_LEFT
 editor._input(motion)
 assert(scroll.scroll_vertical>0,"Arrastar para cima deve rolar a coleção para baixo")
 click.pressed=false;editor._input(click)
 var previous=scroll.scroll_vertical
 motion.position.y-=100
 editor._input(motion)
 assert(scroll.scroll_vertical==previous,"Soltar encerra o arraste")
 for key in Match.CARD_DATA:
  if String(key).begins_with("wild_"):assert(not Match.CARD_DATA[key].lore.is_empty(),"Falta texto: "+String(key))
 assert(Match.CARD_DATA.wild_elf.lore.contains("humanos"))
 editor.queue_free();await process_frame
 print("OK: clique, arraste, liberação e textos das cartas Selvagem.")
 quit()
