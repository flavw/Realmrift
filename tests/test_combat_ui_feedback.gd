extends SceneTree
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 load("res://scripts/adventure_save.gd").enabled=false
 var main=load("res://main.tscn").instantiate();main.enable_opening=false;main.muted=true;root.add_child(main)
 var game=main.duel
 game.players[0].board.clear();game.players[1].board.clear()
 var mage=game.spawn_unit(0,"mage");mage.ready=true
 game.spawn_unit(1,"warrior");game.spawn_unit(1,"wolf")
 game.players[0].hand.assign(["magic_missiles","conductive_bolt","astral_flame"])
 game.players[0].mana=5;game.players[0].max_mana=4;game.players[0].temporary_mana=1
 game.log_event("IA conjura Chama Astral.",1)
 game.log_event("Turno da IA — 4 mana.",1)
 game.log_event("IA compra uma carta",1)
 main.selected=0;main.magic=false;main.redraw()
 assert(main.find_child("PhysicalAttackMode",true,false).get_meta("active_mode"))
 assert(main.find_child("LastEnemyAction",true,false).text=="Última ação da IA: IA conjura Chama Astral.")
 assert(main.find_child("ManaAmount",true,false).text=="Mana 4/4 + 1 temporária")
 main.find_child("Ability_arcane-icon",true,false).pressed.emit()
 assert(main.magic and main.find_child("Ability_arcane-icon",true,false).get_meta("active_mode"))
 assert(not main.find_child("PhysicalAttackMode",true,false).get_meta("active_mode"))
 main.selected=-1;main.casting=0;main.spell_targets.clear();main.redraw()
 assert(main.find_child("BattleHint",true,false).text.contains("primeiro alvo"))
 main.spell_targets.append({"side":1,"index":0});main.redraw()
 assert(main.find_child("BattleHint",true,false).text.contains("segundo alvo"))
 var hand=main.find_child("HandCard_0",true,false)
 for row in hand.get_node("CardCanvas/Ability").get_children():
  assert(row.alignment==BoxContainer.ALIGNMENT_CENTER)
  for child in row.get_children():
   if child.name=="RuleText":assert(child.horizontal_alignment==HORIZONTAL_ALIGNMENT_CENTER)
 await process_frame;await process_frame
 assert(hand.get_global_rect().size.is_equal_approx(Vector2(204,272)))
 var amount=main.find_child("ManaAmount",true,false)
 var mana=main.find_child("PlayerMana",true,false).find_child("ManaBar",true,false)
 assert(amount.get_global_rect().end.y<=mana.get_global_rect().position.y)
 var counts=main.find_child("PlayerCardCounts",true,false)
 assert(counts.get_global_rect().position.x>root.size.x*0.75)
 assert(counts.get_global_rect().end.y<=amount.get_global_rect().position.y)
 assert(main.find_child("HandCountText",true,false).text=="Mão 3")
 assert(main.find_child("DeckCountText",true,false).text=="Baralho %d" % game.players[0].deck.size())
 for counter in counts.get_children():assert(counter.get_child(0).texture!=null)
 if DisplayServer.get_name()!="headless":
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://work/combat-ui-feedback.png")
 for sound in main.sounds.values():sound.stop();sound.stream=null
 main.queue_free();await process_frame;await process_frame
 print("OK: modos ativos, instruções de dois alvos, mana temporária, última ação da IA e magias centralizadas")
 quit()
