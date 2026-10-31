extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var main=load("res://main.tscn").instantiate()
 main.enable_opening=false;main.muted=true
 root.add_child(main);await process_frame
 var segments=main.log_card_segments("Maga Arcana ataca Lobo da Noite e Maga Arcana.")
 var keys: Array=[]
 for segment in segments:
  if not segment.key.is_empty():keys.append(segment.key)
 assert(keys==["mage","wolf","mage"])
 assert(main.log_card_segments("xMaga Arcanax")[0].key=="")
 main.duel.log_event("Maga Arcana ataca Lobo da Noite.")
 main.show_match_log();await process_frame
 assert(not main.log_text.selection_enabled)
 assert(main.log_text.get_parsed_text().contains("Maga Arcana ataca Lobo da Noite."))
 main.log_text.meta_clicked.emit("wolf");await process_frame
 assert(main.log_card_dialog is PopupPanel and main.log_card_dialog.visible and main.log_card_view.card_data==Match.CARD_DATA.wolf)
 assert(main.log_card_view.custom_minimum_size==Vector2(400,534))
 var click:=InputEventMouseButton.new()
 click.button_index=MOUSE_BUTTON_RIGHT;click.pressed=true
 main.log_card_view._gui_input(click)
 assert(not preload("res://scripts/art_viewer.gd").is_open(main))
 main.log_card_dialog.hide();main.log_dialog.hide()
 var m=Match.new([],[],1)
 m.players[0].board.clear();m.players[1].board.clear()
 m.players[1].mana=10;m.players[1].hand=["astral_flame"]
 assert(m.cast(1,0,0,-1))
 var preview=main.create_enemy_spell_preview(m.last_action)
 assert(preview!=null and preview.find_child("EnemySpellCard",true,false).card_data==Match.CARD_DATA.astral_flame)
 assert(main.create_enemy_spell_preview({"kind":"spell","side":0,"card":"astral_flame"})==null)
 assert(main.create_enemy_spell_preview({"kind":"attack","side":1,"card":"astral_flame"})==null)
 preview.queue_free()
 main.queue_free();await process_frame
 print("OK: histórico com links por carta e prévia de magia da IA.")
 quit()
