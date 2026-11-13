extends SceneTree
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 load("res://scripts/adventure_save.gd").enabled=false
 var main=load("res://main.tscn").instantiate();main.enable_opening=false;main.muted=true;root.add_child(main)
 var game=main.duel
 game.players[0].board.clear();game.players[1].board.clear()
 var mage=game.spawn_unit(0,"mage");mage.ready=true
 game.spawn_unit(0,"runic_familiar")
 var enemy=game.spawn_unit(1,"warrior");enemy.health=30;enemy.max_health=30;enemy.armor=2
 game.players[0].mana=10;game.players[0].max_mana=10
 main.selected=0;main.magic=true
 assert(main.aimed_magic_damage()==2)
 assert(main.aimed_magic_damage(1,0)==2,"Dano mágico ignora Armadura")
 enemy.antimagic=1
 assert(main.aimed_magic_damage(1,0)==0 and enemy.antimagic==1 and enemy.health==30)
 enemy.antimagic=0;enemy.spell_immune=true
 assert(main.aimed_magic_damage(1,0)==0)
 enemy.spell_immune=false
 game.players[0].hand.assign(["conductive_bolt"]);main.casting=0
 assert(main.aimed_magic_damage(1,0)==6,"Condutora dobra o dano já amplificado")
 enemy.armor=0;assert(main.aimed_magic_damage(1,0)==3)
 game.players[0].hand.assign(["magic_missiles"])
 assert(main.aimed_magic_damage()==3,"Mísseis indicam dano por alvo")
 game.players[0].hand.assign(["fireball"])
 assert(main.aimed_magic_damage()==game.CARD_DATA.fireball.spell_value+1)
 game.players[0].hand.assign(["vigor_vow"])
 assert(main.aimed_magic_damage()==-1,"Bônus sem dano não mostra número")
 main.casting=-1;main.selected=0;main.magic=true;main.redraw()
 await process_frame;await process_frame
 var owner: Control=main.field_nodes[1][enemy.id]
 var motion:=InputEventMouseMotion.new();motion.position=owner.get_global_rect().get_center();root.push_input(motion,true)
 await process_frame;main._process(0)
 assert(main.cursor_damage_badge.visible and main.cursor_damage_badge.text=="2")
 enemy.antimagic=1;main._process(0)
 assert(main.cursor_damage_badge.text=="0","Dano atualiza sem trocar o tipo de cursor")
 enemy.antimagic=0;main._process(0)
 if DisplayServer.get_name()!="headless":
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://work/aim-cursor-damage.png")
 main.magic=false;main._process(0);assert(not main.cursor_damage_badge.visible)
 for sound in main.sounds.values():sound.stop();sound.stream=null
 main.queue_free();await process_frame;await process_frame
 print("OK: cursor com dano amplificado, Condutora, Mísseis, Antimagia, imunidade e cancelamento sem alterar o combate")
 quit()
