extends SceneTree
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 root.mode=Window.MODE_WINDOWED
 root.size=Vector2i(1920,1080)
 var main=load("res://main.tscn").instantiate()
 main.enable_opening=false
 root.add_child(main)
 for p in main.duel.players:p.board=[]
 main.duel.draw_events.clear()
 var attacker:Dictionary=main.duel.spawn_unit(0,"wolf")
 attacker.ready=true
 assert(main.duel.act(0,0,-1) and attacker.attacked_this_turn)
 var caster:Dictionary=main.duel.spawn_unit(0,"mage")
 caster.exhausting_action_taken=true
 main.duel.spawn_unit(0,"iron_recruit")
 main.duel.players[0].hand=["wolf","raven","warrior","mage","iron_recruit","secrets_dealer"]
 main.duel.players[0].mana=8;main.duel.players[0].max_mana=10;main.duel.players[0].temporary_mana=2
 main.redraw();await process_frame;await process_frame
 var gems=main.find_child("ManaGems",true,false)
 assert(gems.columns==5 and gems.get_child_count()==10)
 assert(absf(gems.get_child(5).position.y-gems.get_child(9).position.y)<1)
 assert(gems.get_child(0).position.y<gems.get_child(5).position.y)
 assert(main.find_child("TemporaryMana",true,false).text=="+2")
 var icon=main.field_nodes[0][attacker.id].get_node("Canvas/Exhausted")
 assert(not icon.visible and icon.texture.resource_path.ends_with("attack-spent-icon.svg"))
 main.select(0);await process_frame;await process_frame
 assert(main.field_nodes[0][attacker.id].get_node("Canvas/Exhausted").visible)
 assert(main.field_nodes[0][caster.id].get_node("Canvas/Exhausted").texture.resource_path.ends_with("tap-icon.svg"))
 main.animate_destroyed_draw({"side":0,"key":"raven","destroyed":true})
 await create_timer(0.25).timeout
 assert(main.vfx_layer.find_child("DestroyedDraw",true,false)!=null)
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://.local/compact-mana-destruction.png")
 await create_timer(0.6).timeout
 assert(main.vfx_layer.find_child("DestroyedDraw",true,false)==null)
 main.duel.begin_turn()
 assert(not attacker.attacked_this_turn and attacker.ready)
 main.queue_free();await process_frame;await process_frame
 print("OK: mana 5x2, temporária dourada, espada/ampulheta, destruição e recuperação")
 quit()
