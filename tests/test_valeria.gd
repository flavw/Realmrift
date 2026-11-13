extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var card=Match.CARD_DATA.valeria_implacavel
 assert(card.title=="Valéria, a Implacável" and card.collectible and card.legendary)
 assert(card.faction==CardData.Faction.WARRIOR and card.cost==6 and card.attack==5 and card.health==4 and card.armor==2 and card.bleed==3)
 assert(Match.copy_limit("valeria_implacavel")==1)
 var list: Array=Match.default_deck(0);list[0]="valeria_implacavel"
 assert(Match.valid_deck(list))
 list[1]="valeria_implacavel";assert(not Match.valid_deck(list))
 var m=Match.new();m.players[0].hand=["valeria_implacavel"];m.players[0].mana=10
 assert(m.play(0,0) and m.players[0].mana==4)
 var valeria: Dictionary=m.players[0].board[0]
 assert(not valeria.ready)
 valeria.ready=true
 var defender: Dictionary=m.spawn_unit(1,"vanguard_bastion")
 assert(m.act(0,0,0) and defender.health==2 and defender.bleeding==3 and valeria.health==3)
 m.turn=1;defender.ready=true
 assert(m.act(1,0,-1) and m.players[1].board.is_empty())
 var view=load("res://card_model.tscn").instantiate();view.set_card(card);view.custom_minimum_size=Vector2(360,480);root.add_child(view)
 assert(view.view_entries().any(func(e):return e.name=="Lendária"))
 assert(view.view_entries().any(func(e):return e.name=="Sangrar 3"))
 var gallery=load("res://card_gallery.tscn").instantiate();root.add_child(gallery)
 assert(gallery.find_child("valeria_implacavel",true,false)!=null)
 gallery.queue_free();await process_frame
 if DisplayServer.get_name()!="headless":
  root.remove_child(view)
  var preview:=SubViewport.new();preview.size=Vector2i(360,480);preview.transparent_bg=true;preview.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(preview)
  view.position=Vector2.ZERO;view.size=Vector2(360,480);preview.add_child(view)
  await process_frame;await RenderingServer.frame_post_draw
  preview.get_texture().get_image().save_png("res://.local/valeria-card.png")
  preview.queue_free()
 else:view.queue_free()
 await process_frame;await process_frame
 print("OK: Valéria lendária, custo 6, Armadura 2, Sangrar 3, uma cópia, combate e galeria")
 quit()


