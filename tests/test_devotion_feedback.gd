extends SceneTree
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var main=load("res://main.tscn").instantiate()
 main.enable_opening=false
 root.add_child(main)
 for key in ["devotion","regeneration","poison_throw","buff"]:
  assert(main.sounds[key].stream is AudioStreamOggVorbis)
 main.duel.players[0].board=[];main.duel.players[1].board=[]
 var devotee:Dictionary=main.duel.spawn_unit(0,"dawn_devotee")
 var enemy:Dictionary=main.duel.spawn_unit(1,"dawn_paladin")
 main.redraw();await process_frame;await process_frame
 var snapshot:Array=main.field_nodes.duplicate()
 var action={"kind":"heal","side":0,"attacker":devotee.id,"target_side":0,"target":devotee.id,"castle":false,"healed":[],"devotion_buffs":[{"side":0,"id":devotee.id,"amount":1},{"side":1,"id":enemy.id,"amount":2}]}
 main.animate_action(action,snapshot)
 await process_frame;await process_frame;await process_frame
 assert(main.sound_counts.get("devotion",0)==1)
 var effects:=0
 for child in main.vfx_layer.get_children():
  if child.get_script()==load("res://scripts/status_vfx.gd") and child.kind=="devotion":effects+=1
 assert(effects==2)
 await create_timer(0.6).timeout
 var old: int=main.sound_counts.devotion
 main.animate_action({"kind":"turn_end","side":0,"healed":[],"devotion_buffs":[]},snapshot)
 await process_frame
 assert(main.sound_counts.devotion==old)
 main.queue_free()
 print("OK: animação de Devoção nos dois lados, sem falso gatilho e quatro sons Ogg")
 quit()

