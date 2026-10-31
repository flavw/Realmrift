extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:
 call_deferred("verify")
func creature(key: String, id: int) -> Dictionary:
 var u: Dictionary=Match.CARDS[key].duplicate(true)
 u.merge({"key":key,"id":id,"ready":true,"max_health":u.health})
 return u
func verify() -> void:
 var main=load("res://main.tscn").instantiate()
 main.enable_opening=false
 root.add_child(main)
 main.duel.players[0].mana=10
 main.duel.players[0].board=[creature("squire",50)]
 main.duel.players[1].board=[creature("mage",51)]
 main.duel.players[0].hand=["astral_flame"]
 main.redraw()
 await process_frame
 main.play(0)
 assert(main.casting==0 and main.duel.players[0].mana==10,"Escolha de alvo não gasta mana")
 assert(main.field_nodes[1][51].available)
 assert(not main.field_nodes[0][50].available)
 assert(main.find_child("EnemyCastle",true,false).disabled)
 assert(main.find_child("PlayerCastle",true,false).disabled)
 await main.cast_target(0,0)
 assert(main.casting==0 and main.duel.players[0].hand.size()==1)
 await main.cast_target(1,0)
 assert(main.duel.players[0].mana==7 and main.duel.players[0].hand.is_empty())
 assert(main.duel.players[1].board.is_empty() and not main.busy and main.casting==-1)
 var art=load("res://card_model.tscn").instantiate()
 art.card_data=Match.CARD_DATA.astral_flame
 root.add_child(art)
 assert(not art.get_node("CardCanvas/Stats").visible and art.get_node("CardCanvas/TypeLabel").visible)
 assert(load("res://scripts/card_skin.gd").texture("tap-icon").resource_path.ends_with(".svg"))
 assert(load("res://scripts/card_skin.gd").texture("mana-cost-symbol").atlas.resource_path.ends_with("mana-cost-symbol.webp"))
 main.duel.players[0].hand=["restoring_light"]
 main.duel.players[0].hp=17
 main.redraw()
 main.play(0)
 assert(not main.find_child("PlayerCastle",true,false).disabled)
 assert(main.find_child("EnemyCastle",true,false).disabled)
 main.casting=-1
 main.redraw()
 art.queue_free()
 main.queue_free()
 await process_frame
 await process_frame
 print("OK: conjuração, cancelamento/alvos, consumo, uma animação de magia, tipo visual e SVGs.")
 quit()
