extends SceneTree
const Match=preload("res://scripts/match.gd")
func fixture():
 var m=Match.new()
 for p in m.players:p.board=[];p.hand=[];p.mana=10
 return m
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var m=fixture()
 var fungus=m.spawn_unit(0,"brood_fungus")
 var beast=m.spawn_unit(0,"wolf")
 assert(fungus.attack==1 and fungus.health==3)
 m.begin_turn()
 assert(fungus.health==3 and fungus.max_health==3 and beast.health==3)
 var second=m.spawn_unit(0,"brood_fungus")
 m.begin_turn()
 assert(fungus.health==4 and second.health==4 and beast.health==5)
 m=fixture()
 var caster=m.spawn_unit(0,"fire_mage");caster.ready=true
 var apprentice=m.spawn_unit(0,"wizard_apprentice")
 m.spawn_unit(0,"runic_familiar")
 for i in range(4):
  var enemy=m.spawn_unit(1,"farmer");enemy.health=8;enemy.max_health=8;enemy.armor=10;enemy.block=2
 assert(not m.act(0,0,-1,true) and caster.ready and m.players[0].mana==10)
 var before: String=JSON.stringify(m.players)
 var preview=m.attack_forecast(0,0,1,true)
 assert(preview.damage==3 and preview.splash_hits.size()==3 and JSON.stringify(m.players)==before)
 assert(m.act(0,0,1,true))
 assert(m.players[0].mana==8 and not caster.ready and caster.health==4)
 assert(m.players[1].board[0].health==6 and m.players[1].board[1].health==5 and m.players[1].board[2].health==6 and m.players[1].board[3].health==8)
 assert(m.players[1].board[1].block==2)
 assert(apprentice.attack==1 and apprentice.health==3 and m.last_action.resonance_buffs.size()==1)
 assert(not m.act(0,0,0,true))
 m=fixture();caster=m.spawn_unit(0,"fire_mage");caster.ready=true
 var left=m.spawn_unit(1,"wolf")
 var guard=m.spawn_unit(1,"abascanto_guardian")
 var right=m.spawn_unit(1,"wolf")
 var guard_hp: int=guard.health
 assert(m.act(0,0,1,true))
 assert(guard.health==guard_hp and guard.abascanto==0 and left.health==1 and right.health==1)
 m=fixture();caster=m.spawn_unit(0,"fire_mage");caster.ready=true
 for i in range(3):
  var enemy=m.spawn_unit(1,"wolf");enemy.health=2 if i==1 else 1
 assert(m.act(0,0,1,true) and m.players[1].board.is_empty() and m.last_action.dead.size()==3)
 m=fixture();m.turn=1;caster=m.spawn_unit(1,"fire_mage");caster.ready=true
 for i in range(3):m.spawn_unit(0,"farmer")
 assert(m.ai_step() and m.last_action.has("fire_hits") and m.last_action.fire_hits.size()==3)
 var main=load("res://main.tscn").instantiate();main.enable_opening=false
 root.add_child(main)
 main.duel=fixture()
 caster=main.duel.spawn_unit(0,"fire_mage");caster.ready=true
 main.duel.spawn_unit(0,"wizard_apprentice")
 for i in range(3):
  var enemy=main.duel.spawn_unit(1,"farmer");enemy.health=8
 main.duel.draw_events.clear();main.redraw();await process_frame;await process_frame
 main.select(0);main._process(0.016)
 assert(main.magic and main.arcane_cursor_active and main.find_child("EnemyCastle",true,false).disabled)
 var snapshot=main.field_nodes.duplicate()
 assert(main.duel.act(0,0,1,true))
 await main.animate_action(main.duel.last_action,snapshot)
 assert(main.sound_counts.get("fire",0)==1 and main.sound_counts.get("resonance",0)==1)
 main.duel.players[0].hand=["fireball"];main.redraw();await process_frame;await process_frame
 snapshot=main.field_nodes.duplicate()
 assert(main.duel.cast(0,0,1,-1))
 await main.animate_action(main.duel.last_action,snapshot)
 assert(main.sound_counts.fire==2 and main.sound_counts.resonance==2)
 for key in ["fire","resonance"]:assert(main.sounds[key].stream is AudioStreamOggVorbis)
 main.queue_free();await process_frame;await process_frame
 print("OK: Esporos sem auto-bônus, dano adjacente, Amplificar, Guarda Arcana, mortes simultâneas, IA, cursor e sons/efeitos de fogo e Ressonância")
 quit()
