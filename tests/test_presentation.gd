extends SceneTree
const Match = preload("res://scripts/match.gd")

func _initialize() -> void:
 call_deferred("verify")

func creature(key: String, id: int, ready: bool = true) -> Dictionary:
 var unit: Dictionary = Match.CARDS[key].duplicate(true)
 unit.merge({"key": key, "id": id, "ready": ready})
 return unit

func verify() -> void:
 var main = load("res://main.tscn").instantiate()
 main.enable_opening=false
 root.add_child(main)
 assert(main.sounds.size() == 10)
 for key in ["magic", "victory", "castle"]:
  assert(main.sounds[key].stream.get_length() > 0.3)
 main.duel.players[0].board = [creature("warrior", 10), creature("fire_mage", 11), creature("squire", 12), creature("wolf", 13, false)]
 main.duel.players[1].board = [creature("lightning_rogue", 20, false), creature("raven", 21), creature("sentinel", 22)]
 main.duel.players[0].hp = 14
 main.duel.players[0].mana = 4
 main.duel.players[0].max_mana = 6
 main.duel.players[1].mana = 2
 main.duel.players[1].max_mana = 5
 main.duel.players[0].hand = ["mage", "sentinel", "raven", "lightning_rogue", "fire_mage"]
 main.duel.players[1].hp = 3
 main.redraw()
 await process_frame
 await process_frame
 if DisplayServer.get_name() != "headless":
  await RenderingServer.frame_post_draw
  var path: String = OS.get_environment("CARDGAME_POLISH_PREVIEW")
  if not path.is_empty():
   root.get_texture().get_image().save_png(path)
 main.select(0)
 await process_frame
 await process_frame
 main.target(-1)
 for i in range(100):
  await create_timer(0.02).timeout
  if main.result_overlay != null and main.result_overlay.intro_finished:
   break
 assert(main.duel.winner == 0 and main.result_shown)
 assert(main.result_overlay != null and main.result_overlay.intro_finished)
 assert(main.sound_counts.get("castle", 0) == 1)
 assert(main.sound_counts.get("victory", 0) == 1)
 var shown = main.result_overlay
 main.redraw()
 assert(main.result_overlay == shown and main.sound_counts.victory == 1, "Vitória só aparece/toca uma vez")
 if DisplayServer.get_name() != "headless":
  await RenderingServer.frame_post_draw
  var path: String = OS.get_environment("CARDGAME_VICTORY_PREVIEW")
  if not path.is_empty():
   root.get_texture().get_image().save_png(path)
 shown.find_child("ReplayButton", true, false).pressed.emit()
 await process_frame
 assert(main.result_overlay == null and not main.result_shown and main.duel.winner == -1)
 assert(main.duel.players[1].hp == 20)
 main.toggle_sound()
 var old_count: int = main.sound_counts.get("magic", 0)
 main.play_sound("magic")
 assert(main.sound_counts.get("magic", 0) == old_count, "Som desligado respeitado")
 print("OK: 3 novos sons, vitória única após combate, painel animado, jogar novamente e controle de som.")
 main.queue_free()
 await process_frame
 await process_frame
 quit()
