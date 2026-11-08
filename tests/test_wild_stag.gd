extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _initialize():call_deferred("verify")
func verify():
 var card=Match.CARD_DATA.wild_stag
 assert(card.title=="Cervo da Clareira" and card.cost==3 and card.attack==1 and card.health==2)
 assert(card.creature_type==CardData.CreatureType.BEAST and card.turn_draw==1 and card.aura_value==0)
 assert(card.ability_entries().any(func(e):return e.name=="Compre 1 no início do turno"))
 assert(Store.accepts_base(CardData.CardClass.WILD,["wild_stag","wild_pack_spell","wolf"]))
 var editor=load("res://deck_editor.tscn").instantiate();editor.configure(Store.new("user://stag_test.json",false));root.add_child(editor);await process_frame
 editor.choose_slot(6);assert(editor.collection_keys().has("wild_stag") and editor.collection_keys().has("wild_pack_spell"))
 editor.queue_free();await process_frame
 print("OK: Cervo de compra e União da Matilha no editor.")
 quit()
