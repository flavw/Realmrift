extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var legendary: CardData=Match.CARD_DATA.dawn_paladin
 var view=load("res://card_model.tscn").instantiate()
 view.set_card(legendary);root.add_child(view);await process_frame
 assert(view.get_node("CardCanvas/CostGem").texture.atlas.resource_path.ends_with("mana-cost-symbol.webp"))
 assert(not view.view_entries().any(func(e):return e.name=="Lendária"))
 view.set_card(Match.CARD_DATA.wolf)
 assert(view.get_node("CardCanvas/CostGem").texture.atlas.resource_path.ends_with("mana-cost-symbol.webp"))
 view.queue_free()
 var main=load("res://main.tscn").instantiate()
 main.enable_opening=false;main.muted=true
 root.add_child(main);await process_frame
 main.duel.players[0].board.clear();main.duel.players[1].board.clear()
 var unit=main.duel.spawn_unit(0,"squire")
 main.redraw();await process_frame;await process_frame
 var row=main.find_child("PlayerBattlefield",true,false)
 assert(row.get_child_count()==6)
 var field:Control=main.field_nodes[0][unit.id]
 assert(absf(field.get_global_rect().get_center().x-row.get_child(0).get_global_rect().get_center().x)<4)
 assert(field.get_global_rect().get_center().x<row.get_global_rect().get_center().x)
 var mana:Control=main.find_child("ManaReserves",true,false)
 var hand:Control=main.find_child("PlayerHandPanel",true,false)
 assert(mana.get_global_rect().end.x<=hand.get_global_rect().end.x+2)
 assert(mana.get_global_rect().position.x>hand.get_global_rect().get_center().x)
 for i in range(5):main.duel.spawn_unit(0,"wolf")
 main.redraw();await process_frame;await process_frame
 row=main.find_child("PlayerBattlefield",true,false)
 assert(row.get_child_count()==6)
 for child in row.get_children():
  assert(child.get_global_rect().position.x>=row.get_global_rect().position.x-1)
  assert(child.get_global_rect().end.x<=row.get_global_rect().end.x+1)
 main.queue_free();await process_frame
 print("OK: gema azul dos lendários, entrada pela esquerda e mana à direita.")
 quit()
