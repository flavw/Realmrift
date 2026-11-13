extends SceneTree
const Match=preload("res://scripts/match.gd")
const Vfx=preload("res://scripts/combat_projectile_vfx.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var main=load("res://main.tscn").instantiate();main.enable_opening=false;main.starting_player=0;root.add_child(main)
 var m=Match.new([],[],0,false,{"enabled":true,"encounter":"black_dragon"})
 for i in range(3):
  var u=m.spawn_unit(0,"farmer");u.health=12;u.max_health=12
 m.players[0].board[1].spell_immune=true
 m.castle_traps[0]=[{"remaining":2,"damage":5}];m.castle_traps[1]=[{"remaining":1,"damage":5}]
 main.duel=m;main.redraw()
 await process_frame;await process_frame
 var indicators=main.find_children("CastleTrapMark","Button",true,false)
 assert(indicators.size()==2)
 for indicator in indicators:
  if indicator.get_meta("trap_owner")==1:assert(not indicator.tooltip_text.contains("1º") and not indicator.tooltip_text.contains("2º"))
  else:assert(indicator.tooltip_text.contains("2º"))
 var snapshot: Array=main.field_nodes.duplicate()
 var dragon: Control=main.field_nodes[1][m.creature_boss_id]
 m.turn=1;m.players[1].mana=4;m.players[1].board[0].ready=true
 assert(m.dragon_breath(1,0,"poison",1))
 assert(m.last_action.cone_targets.size()==3 and m.last_action.poisoned.size()==2)
 var records: Array=m.last_action.cone_targets
 for palette in ["poison","acid","fire"]:
  var effect=main.create_cone_effect(dragon,records,snapshot,palette)
  assert(effect!=null and effect.half_width>200 and effect.palette==palette)
  for record in records:
   assert(Geometry2D.is_point_in_polygon(main.record_target(record,snapshot).get_global_rect().get_center(),PackedVector2Array([effect.origin,effect.edge_left,effect.edge_right])))
  effect.progress=0.55
  await process_frame;await process_frame
  if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("res://.local/cone-%s.png" % palette)
  effect.queue_free();await process_frame
 # Arrow integration uses real attacker snapshots and remains in the VFX layer until impact.
 var archer: Control=main.find_child("PlayerCastle",true,false)
 var target: Control=main.field_nodes[1][m.creature_boss_id]
 main.animate_trap_arrow(archer,target)
 assert(main.sound_counts.get("trap_arrow",0)==1)
 assert(is_equal_approx(main.sounds.trap_arrow.stream.get_length(),0.48))
 await create_timer(0.18).timeout
 assert(main.vfx_layer.find_child("TrapArrowEffect",true,false)!=null)
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("res://.local/trap-arrow.png")
 await create_timer(0.5).timeout
 assert(main.vfx_layer.find_child("TrapArrowEffect",true,false)==null)
 # Acid still records precisely three contiguous targets; fire uses the same cone renderer.
 m.players[1].board[0].ready=true;m.players[1].board[0].attacked_this_turn=false;m.players[1].mana=4
 assert(m.dragon_breath(1,0,"acid",1) and m.last_action.cone_targets.size()==3)
 assert(m.last_action.area_hits.size()==3)
 # Real Mãos Flamejantes uses the orange cone, not three disconnected impacts.
 m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=5
 var caster=m.spawn_unit(0,"fire_mage");caster.ready=true
 for i in range(3):
  var unit=m.spawn_unit(1,"farmer");unit.health=12;unit.max_health=12
 main.duel=m;main.redraw();await process_frame;await process_frame
 snapshot=main.field_nodes.duplicate()
 assert(m.act(0,0,1,true) and m.last_action.fire_hits.size()==3)
 main.animate_action(m.last_action,snapshot)
 await process_frame
 assert(main.vfx_layer.find_child("ConeEffect_fire",true,false)!=null)
 await create_timer(1.0).timeout
 assert(main.vfx_layer.find_child("ConeEffect_fire",true,false)==null)
 for player in main.sounds.values():player.stop();player.stream=null
 await create_timer(0.1).timeout
 main.queue_free();await process_frame;await process_frame
 print("OK: ícones de ambos os lados sem revelar segredos, cones de três alvos em três paletas e flecha até o impacto")
 quit()
