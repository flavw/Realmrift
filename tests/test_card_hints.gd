extends SceneTree
const Match = preload("res://scripts/match.gd")
func _initialize() -> void:
 call_deferred("verify")
func verify() -> void:
 var card = load("res://card_model.tscn").instantiate()
 card.card_data = Match.CARD_DATA.mage
 card.position = Vector2(90,110)
 root.add_child(card)
 await process_frame
 var motion := InputEventMouseMotion.new()
 motion.position = Vector2(200,220)
 root.push_input(motion,true)
 await process_frame
 await process_frame
 assert(not is_instance_valid(card.hint_panel) or not card.hint_panel.visible,"Hover aguarda antes de mostrar ajuda")
 await create_timer(0.3).timeout
 await process_frame
 assert(is_instance_valid(card.hint_panel) and card.hint_panel.visible,"Hover abre explicação lateral")
 assert(card.hint_panel.position.x > card.get_global_rect().end.x)
 assert(card.card_data.ability_entries()[0].name == "Disparo Arcano 1")
 assert(card.card_data.ability_entries()[0].tap)
 assert(card.card_data.ability_entries()[0].description.contains("Ignora Armadura"))
 assert(card.get_node("CardCanvas/Cost").get_rect().get_center().is_equal_approx(card.get_node("CardCanvas/CostGem").get_rect().get_center()-Vector2(0,3)))
 var badge = card.find_child("AbilityManaCost",true,false)
 assert(badge != null)
 var badge_number: Label = badge.get_child(1)
 assert(badge_number.text == str(card.card_data.magic_cost))
 assert(badge_number.position.is_equal_approx(Vector2(0,-2)),"Número de habilidade sobe 2 px para centralização óptica")
 assert(card.get_node("CardCanvas/Ability").get_child_count()==1)
 var full_description := false
 for child in card.get_node("CardCanvas/Ability").get_child(0).get_children():
  if child is Label and child.text.contains("contra-ataque"):
   full_description = true
 assert(not full_description,"Carta mostra somente resumo")
 motion.position = Vector2(20,20)
 root.push_input(motion,true)
 await process_frame
 await process_frame
 assert(not card.hint_panel.visible,"Sair da carta fecha explicação")
 card.position = Vector2(root.get_visible_rect().size.x-380,100)
 card.set_card(Match.CARD_DATA.squire,-1,-1,0)
 card.set_hint_forced(true,true)
 await process_frame
 await process_frame
 assert(card.hint_panel.visible)
 assert(card.hint_panel.position.x < card.position.x,"Explicação troca para esquerda perto da borda")
 assert(card.card_data.ability_entries(0)[0].name == "Bloqueio 0")
 assert(card.card_data.ability_entries(0)[0].description.contains("Recupera todas as cargas no início de cada turno"))
 var bounds: Rect2 = card.hint_panel.get_global_rect()
 assert(root.get_visible_rect().encloses(bounds),"Caixa fica dentro da tela")
 card.queue_free()
 await process_frame
 await process_frame
 print("OK: resumos, custo centralizado, hover abre/fecha, borda esquerda e Bloqueio atual.")
 quit()

