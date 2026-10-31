extends SceneTree
const Match = preload("res://scripts/match.gd")
const Viewer = preload("res://scripts/art_viewer.gd")
const GREEN = Color("62efa3")
const RED = Color("ff7682")
func _initialize() -> void:
 call_deferred("verify")
func verify() -> void:
 var card = load("res://card_model.tscn").instantiate()
 card.ability_context = {"on_board":true,"side":0,"turn":0,"mana":1,"ready":false,"max_health":3}
 card.set_card(Match.CARD_DATA.wolf,3,3)
 root.add_child(card)
 await process_frame
 var stats = card.get_node("CardCanvas/Stats")
 assert(stats.attack_label.get_theme_color("font_color")==GREEN)
 assert(stats.health_label.get_theme_color("font_color")==GREEN)
 card.set_card(Match.CARD_DATA.wolf,2,1)
 assert(stats.attack_label.get_theme_color("font_color")==RED)
 assert(stats.health_label.get_theme_color("font_color")==RED,"Vida ferida vermelha mesmo no máximo aumentado")
 assert(card.ability_state(card.card_data.ability_entries()[0]).kind=="available","Fúria não exige pronta")
 card.ability_context.mana=0
 assert(card.ability_state(card.card_data.ability_entries()[0]).label=="Mana insuficiente")
 card.ability_context.mana=1
 card.set_card(Match.CARD_DATA.mage)
 assert(card.ability_state(card.card_data.ability_entries()[0]).label=="Criatura esgotada")
 card.ability_context.ready=true
 assert(card.ability_state(card.card_data.ability_entries()[0]).kind=="available")
 card.ability_context.turn=1
 assert(card.ability_state(card.card_data.ability_entries()[0]).label=="Aguarde seu turno")
 card.queue_free()
 await process_frame
 var main = load("res://main.tscn").instantiate()
 main.enable_opening=false
 root.add_child(main)
 var unit: Dictionary=Match.CARDS.wolf.duplicate(true)
 unit.merge({"key":"wolf","ready":true,"id":123,"max_health":2})
 main.duel.players[0].board=[unit]
 main.redraw()
 await process_frame
 await process_frame
 var field=main.field_nodes[0][123]
 var pos: Vector2=field.get_global_rect().get_center()
 var move:=InputEventMouseMotion.new()
 move.position=pos
 root.push_input(move,true)
 await process_frame
 assert(not main.preview.visible,"Prévia aguarda hover")
 var right:=InputEventMouseButton.new()
 right.position=pos
 right.button_index=MOUSE_BUTTON_RIGHT
 right.pressed=true
 root.push_input(right,true)
 await process_frame
 assert(Viewer.is_open(main),"Botão direito abre arte")
 var viewer=root.get_meta("card_art_viewer")
 assert(viewer.artwork.texture==Match.CARD_DATA.wolf.artwork)
 assert(viewer.find_child("LoreText",true,false).text==Match.CARD_DATA.wolf.lore,"Arte mostra história da carta")
 for data in Match.CARD_DATA.values():assert(not data.lore.is_empty(),"Toda carta possui história")
 assert(main.selected==-1,"Botão direito não seleciona para atacar")
 var turn=main.duel.turn
 var enter:=InputEventKey.new()
 enter.pressed=true
 enter.keycode=KEY_ENTER
 root.push_input(enter,true)
 await create_timer(0.3).timeout
 assert(main.duel.turn==turn and not main.preview.visible,"Visualizador bloqueia turno e prévia pendente")
 var escape:=InputEventKey.new()
 escape.pressed=true
 escape.keycode=KEY_ESCAPE
 root.push_input(escape,true)
 await process_frame
 assert(not Viewer.is_open(main),"Esc fecha arte")
 main.queue_free()
 await process_frame
 await process_frame
 print("OK: bônus/penalidades, estados de habilidade, atraso, botão direito, arte limpa e entrada modal.")
 quit()
