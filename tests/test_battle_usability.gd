extends SceneTree
const Match=preload("res://scripts/match.gd")
func fixture():
 var m=Match.new()
 for p in m.players:p.board=[];p.hand=[];p.mana=10
 return m
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var m=fixture()
 var unit=m.spawn_unit(0,"farmer")
 m.players[0].hand=["iron_stance"]
 assert(m.cast(0,0,0,0))
 var display=m.card_for_unit(unit)
 assert(display.block==1 and display.ability_entries(unit.block).any(func(e):return e.get("badge","")=="Block"))
 unit.block=0
 assert(m.card_for_unit(unit).ability_entries(0).any(func(e):return e.get("badge","")=="Block" and e.value==0))
 for magical in [false,true]:
  m=fixture()
  var a=m.spawn_unit(0,"mage" if magical else "warrior")
  a.ready=true;a.bleeding=1
  var defender=m.spawn_unit(1,"warrior")
  var before:=JSON.stringify(m.players)
  var result=m.attack_forecast(0,0,0,magical)
  assert(JSON.stringify(m.players)==before)
  assert(m.act(0,0,0,magical))
  assert(result.damage==m.last_action.amount)
  if not magical:assert(result.received==m.last_action.received and result.absorbed==m.last_action.absorbed)
 m=fixture()
 var caster=m.spawn_unit(0,"mage");caster.ready=true
 var ward=m.spawn_unit(1,"abascanto_guardian")
 var forecast=m.attack_forecast(0,0,0,true)
 assert(forecast.warded and forecast.damage==0 and ward.abascanto>0)
 var main=load("res://main.tscn").instantiate()
 main.enable_opening=false
 root.add_child(main)
 for p in main.duel.players:p.board=[]
 var wolf=main.duel.spawn_unit(0,"wolf")
 main.duel.spawn_unit(0,"iron_recruit")
 var enemy=main.duel.spawn_unit(1,"farmer")
 main.duel.players[0].mana=10
 main.duel.players[0].hand=["iron_stance","mage","wolf","raven","warrior","farmer"]
 main.duel.draw_events.clear()
 main.redraw();await process_frame;await process_frame
 var attack_y: float=main.find_child("AttackAll",true,false).global_position.y
 var attack_x: float=main.find_child("AttackAll",true,false).global_position.x
 var end_x: float=main.find_child("EndTurn",true,false).global_position.x
 assert(main.find_child("BattleHint",true,false).text.is_empty())
 assert(main.field_nodes[0][wolf.id].get_node("Canvas/Exhausted").visible)
 main.select(0);await process_frame;await process_frame
 assert(main.find_child("BattleHint",true,false).text=="Recém-invocada")
 assert(absf(main.find_child("AttackAll",true,false).global_position.x-attack_x)<1)
 assert(absf(main.find_child("AttackAll",true,false).global_position.y-attack_y)<1)
 assert(absf(main.find_child("EndTurn",true,false).global_position.x-end_x)<1)
 wolf.ready=true;wolf.summoned_this_turn=false
 main.redraw();await process_frame;await process_frame
 var target: Control=main.field_nodes[1][enemy.id]
 assert(main.show_combat_forecast(0,target) and main.forecast_panel.visible)
 main.close_preview(target)
 assert(main.forecast_panel==null)
 main.selected=-1;main.casting=0;main.redraw();await process_frame;await process_frame
 assert(absf(main.find_child("AttackAll",true,false).global_position.x-attack_x)<1)
 assert(absf(main.find_child("AttackAll",true,false).global_position.y-attack_y)<1)
 assert(absf(main.find_child("EndTurn",true,false).global_position.x-end_x)<1)
 main.casting=-1;main.redraw();await process_frame;await process_frame
 var hand_card: Control=main.find_child("HandCard_0",true,false)
 main.hover_hand_card(hand_card,true)
 await create_timer(0.35).timeout
 assert(hand_card.scale.x>1.5 and hand_card.hint_forced)
 main.hover_hand_card(hand_card,false)
 await create_timer(0.2).timeout
 assert(is_equal_approx(hand_card.scale.x,1.0) and not hand_card.hint_forced)
 main.queue_free();await process_frame;await process_frame
 print("OK: Bloqueio concedido, prévia sem mutação, botões fixos, mensagens curtas, Zzz e ampliação da mão")
 quit()
