extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func unit(key: String,id: int) -> Dictionary:
 var u: Dictionary=Match.CARDS[key].duplicate(true)
 u.merge({"key":key,"id":id,"ready":true,"max_health":u.health,"poison":0})
 return u
func _initialize() -> void:call_deferred("verify")
func click_at(at: Vector2) -> void:
 var event:=InputEventMouseButton.new()
 event.button_index=MOUSE_BUTTON_LEFT;event.pressed=true;event.position=at
 root.push_input(event,true)
 event.pressed=false;root.push_input(event,true)
func verify() -> void:
 var main=load("res://main.tscn").instantiate();main.enable_opening=false
 main.deck_store=Store.new("user://unused_status_test.json",false);root.add_child(main)
 assert(main.sounds.size()==10)
 for player in main.sounds.values():
  assert(player.stream is AudioStreamOggVorbis and player.stream.resource_path.ends_with(".ogg"))
 main.duel.players[0].board=[unit("wolf",101)]
 main.duel.players[1].board=[unit("village_wall",201),unit("wolf",202)]
 main.duel.players[0].hand=[];main.duel.players[0].mana=5;main.selected=0;main.duel.next_id=300
 main.redraw();await process_frame;await process_frame
 click_at(main.field_nodes[1][202].get_global_rect().get_center())
 assert(main.sound_counts.get("block",0)==1 and main.vfx_layer.get_child_count()>0)
 assert(main.duel.players[0].board[0].ready and main.duel.players[1].board[1].health==2 and main.duel.players[0].mana==5)
 await create_timer(0.5).timeout
 var trap=main.find_child("BlockedCastleTarget",true,false)
 assert(trap!=null)
 click_at(trap.get_global_rect().get_center())
 assert(main.sound_counts.block==2 and main.duel.players[1].hp==20)
 await create_timer(0.5).timeout
 # One click on Reconstruction resolves heal/draw immediately, with no target mode.
 main.duel.players[0].hp=15;main.duel.players[0].hand=["village_reconstruction"]
 main.duel.players[0].deck=["squire"];main.redraw()
 main.play(0)
 assert(main.casting==-1 and main.duel.players[0].hp==17 and main.duel.players[0].hand==["squire"])
 await process_frame;await process_frame;await process_frame
 assert(main.duel.players[0].mana==3 and main.sound_counts.get("heal",0)==1)
 assert(main.vfx_layer.find_child("StatusEffect_heal",true,false)!=null)
 await create_timer(0.55).timeout
 assert(not main.busy)
 # Poison entry has an application cue; its damage clears every charge once.
 var victim=unit("wolf",202);victim.health=10;victim.max_health=10;victim.armor=8
 main.duel.players[1].board=[victim];main.duel.players[0].hand=["mist_alchemist"];main.duel.players[0].mana=5
 main.redraw();main.play(0);main.summon_target(1,0)
 await process_frame;await process_frame;await process_frame
 assert(main.vfx_layer.find_child("PoisonBottle",true,false)!=null)
 await create_timer(0.5).timeout
 assert(victim.poison==2 and main.sound_counts.get("poison_apply",0)==1)
 assert(main.vfx_layer.find_child("StatusEffect_poison_apply",true,false)!=null)
 await create_timer(0.55).timeout
 var snapshot: Array=main.field_nodes.duplicate()
 main.duel.resolve_poison(1)
 assert(victim.health==8 and victim.poison==0)
 await main.animate_action(main.duel.last_action,snapshot)
 assert(main.sound_counts.get("poison_tick",0)==1)
 main.duel.resolve_poison(1)
 assert(victim.health==8 and main.duel.last_action.ticks.is_empty())
 var old_count: int=main.sound_counts.heal;main.muted=true;main.play_sound("heal")
 assert(main.sound_counts.heal==old_count)
 main.queue_free();await process_frame;await create_timer(0.35).timeout
 print("OK: dez sons Ogg, cliques inválidos campo/castelo, escudo sem gastar ação, Reconstrução automática, cura, aplicação/dano único de Veneno e mudo.")
 quit()
