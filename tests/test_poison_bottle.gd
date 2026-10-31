extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var main=load("res://main.tscn").instantiate()
 main.enable_opening=false
 root.add_child(main)
 main.duel.players[0].board=[];main.duel.players[1].board=[]
 main.duel.players[0].hand=["mist_alchemist"];main.duel.players[0].mana=10
 main.duel.spawn_unit(1,"wolf")
 main.redraw()
 await process_frame;await process_frame
 main.play(0);main.summon_target(1,0)
 await process_frame;await process_frame;await process_frame;await process_frame
 assert(main.vfx_layer.find_child("PoisonBottle",true,false)!=null)
 await create_timer(0.55).timeout
 assert(main.sound_counts.get("poison_apply",0)>0)
 print("OK: frasco e impacto de veneno")
 main.queue_free()
 quit()
