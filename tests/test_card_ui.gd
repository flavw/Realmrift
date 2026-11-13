extends SceneTree

func _initialize() -> void:
 call_deferred("verify")

func verify() -> void:
 var main = load("res://main.tscn").instantiate()
 main.enable_opening=false
 root.add_child(main)
 var match_data = load("res://scripts/match.gd")
 for side in range(2):
  main.duel.players[side].board.clear()
  for key in ["warrior", "mage", "squire", "wolf"]:
   var unit: Dictionary = match_data.CARDS[key].duplicate(true)
   unit.merge({"key": key, "ready": true, "id": side * 10 + main.duel.players[side].board.size()})
   main.duel.players[side].board.append(unit)
 main.duel.players[0].board[0].health = 1
 main.redraw()
 await process_frame
 await process_frame
 var fields: Array = main.find_children("FieldCard", "Control", true, false)
 assert(fields.size() == 8)
 var field = fields[4]
 var motion := InputEventMouseMotion.new()
 motion.position = field.get_global_rect().get_center()
 root.push_input(motion, true)
 await process_frame
 await create_timer(0.3).timeout
 await process_frame
 assert(main.preview.visible, "Mouse sobre campo deve exibir carta completa")
 assert(main.preview.card_data == match_data.CARD_DATA.warrior)
 assert(main.preview.get_node("CardCanvas/Stats").text == "3/1")
 assert(field.get_node("Canvas/Stats").text == "3/1")
 assert(main.preview.position.x >= 0 and main.preview.position.y >= 0)
 assert(not main.preview.has_node("CardCanvas/Shield"))
 assert(not fields[6].has_node("Canvas/Shield"))
 var color_script=load("res://scripts/card_skin.gd")
 assert(color_script.faction_color(fields[6].card_data.faction)==color_script.faction_color(fields[7].card_data.faction),"Lobo e Escudeiro são aldeões")
 if DisplayServer.get_name() != "headless":
  await RenderingServer.frame_post_draw
  var output: String = OS.get_environment("CARDGAME_PREVIEW_PATH")
  if not output.is_empty():
   root.get_texture().get_image().save_png(output)
 motion.position = Vector2(20, 20)
 root.push_input(motion, true)
 await process_frame
 assert(not main.preview.visible, "Prévia fecha quando mouse sai")
 motion.position = field.get_global_rect().get_center()
 root.push_input(motion, true)
 var click := InputEventMouseButton.new()
 click.position = motion.position
 click.button_index = MOUSE_BUTTON_LEFT
 click.pressed = true
 root.push_input(click, true)
 await process_frame
 assert(main.selected == 0, "Carta quadrada pode ser selecionada com a prévia aberta")
 fields = main.find_children("FieldCard", "Control", true, false)
 main.show_preview(match_data.CARD_DATA.mage, 1, fields[1])
 assert(main.preview.get_node("CardCanvas/Stats").text == "0/1", "Prévia usa vida atual")
 main.redraw()
 assert(not main.preview.visible, "Atualizar campo fecha a prévia")
 main.duel.players[0].mana = 3
 main.selected = 3
 main.use_fury()
 assert(main.duel.players[0].board[3].attack == 3)
 fields = main.find_children("FieldCard", "Control", true, false)
 assert(fields[7].get_node("Canvas/Stats").text == "3/2")
 main.show_preview(match_data.CARD_DATA.wolf, 2, fields[7])
 assert(main.preview.get_node("CardCanvas/Stats").text == "3/2", "Prévia mostra bônus de Fúria")
 main.select(0)
 var castle: Button = main.find_child("EnemyCastle", true, false)
 assert(castle.disabled, "Castelo protegido por Bloqueio")
 main.duel.players[1].board[2].block = 0
 main.redraw()
 castle = main.find_child("EnemyCastle", true, false)
 assert(not castle.disabled)
 await process_frame
 await process_frame
 motion.position = castle.get_global_rect().get_center()
 root.push_input(motion, true)
 click.position = motion.position
 root.push_input(click, true)
 click.pressed = false
 root.push_input(click, true)
 await process_frame
 assert(main.duel.players[1].hp == 17, "Clique no castelo executa ataque direto")
 for i in range(100):
  if not main.busy:
   break
  await create_timer(0.02).timeout
 assert(not main.busy)
 print("OK: 8 cartas quadradas, hover e clique reais, prévia, facções, vida atual e fechamento.")
 quit()

