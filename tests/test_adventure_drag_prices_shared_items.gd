extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
const Match=preload("res://scripts/match.gd")
const Items=preload("res://scripts/adventure_items.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var run=State.new()
 for key in Match.CARD_DATA:
  assert(run.market_price(key)==clampi(Match.CARD_DATA[key].cost,1,3))
  assert(run.market_price(key,true)==mini(5,clampi(Match.CARD_DATA[key].cost,1,3)+2))
 run.deck=["warrior","warrior","squire"]
 run.phase="item";run.options=["warrior"];run.pending_item="heart"
 assert(run.apply_item("warrior"))
 assert(run.deck[0]==run.deck[1] and Match.CARD_DATA[run.deck[0]].health==Match.CARD_DATA.warrior.health+2)
 assert(Match.CARD_DATA.warrior.health==1 and run.deck[2]=="squire")
 run.deck.remove_at(1)
 var future: String=run.add_card_to_deck("warrior")
 assert(future==run.deck[0])
 run.phase="item";run.pending_item="sword";run.options=[future]
 assert(run.apply_item(future))
 assert(run.deck[0]==run.deck.back() and Match.CARD_DATA[run.deck[0]].attack==Match.CARD_DATA.warrior.attack+1)
 assert(Match.CARD_DATA[run.deck[0]].health==Match.CARD_DATA.warrior.health+2)
 var normal=Match.new();assert(normal.spawn_unit(0,"warrior").health==Match.CARD_DATA.warrior.health)
 run=State.new();run.deck=["squire"];run.phase="shop";run.gold=10
 run.shop_premium_key=Items.enhance("squire","boots");run.shop_premium_price=run.market_price(run.shop_premium_key,true)
 assert(run.buy_premium_card(run.shop_premium_key) and run.gold==7)
 assert(run.deck.size()==2 and run.deck.all(func(key):return Match.CARD_DATA[key].swift))
 assert(run.deck.all(func(key):return Match.CARD_DATA[key].attack==Match.CARD_DATA.squire.attack))
 assert(not Match.CARD_DATA.squire.swift)
 run.phase="map";run.step=0;State.current=run
 var view=load("res://adventure.tscn").instantiate();root.add_child(view)
 await process_frame;await process_frame;await create_timer(0.5).timeout
 var scroll=view.find_child("AdventureMapScroll",true,false)
 assert(scroll.horizontal_scroll_mode==ScrollContainer.SCROLL_MODE_SHOW_NEVER and not scroll.get_h_scroll_bar().visible)
 var press:=InputEventMouseButton.new();press.button_index=MOUSE_BUTTON_LEFT;press.pressed=true;press.position=scroll.get_global_rect().get_center()
 scroll._input(press)
 var motion:=InputEventMouseMotion.new();motion.position=press.position-Vector2(250,0);scroll._input(motion)
 assert(scroll.drag_moved and scroll.scroll_horizontal>150)
 var release:=InputEventMouseButton.new();release.button_index=MOUSE_BUTTON_LEFT;release.pressed=false;release.position=motion.position;scroll._input(release)
 assert(not scroll.drag_active and scroll.drag_moved)
 var selected: Array=[]
 var map=scroll.get_child(0);map.route_selected.disconnect(view.choose_route);map.route_selected.connect(func(index):selected.append(index))
 map.find_child("Route_0_0",true,false).pressed.emit();assert(selected.is_empty())
 scroll._input(press);map.find_child("Route_0_0",true,false).pressed.emit();assert(selected==[0]);scroll._input(release)
 run.step=10;view.render()
 await process_frame;await process_frame;await create_timer(0.55).timeout
 scroll=view.find_child("AdventureMapScroll",true,false)
 assert(scroll.scroll_horizontal>300 and run.map_scroll_position>300)
 run.step=4;view.render();await process_frame;await process_frame;await create_timer(0.55).timeout
 var chest: Control=view.find_child("Route_4_2",true,false)
 assert(chest.get_child(0).material.get_shader_parameter("focus")==Vector2(0.40,0.49))
 assert(chest.get_child(0).material.get_shader_parameter("crop")==Vector2(0.42,0.58))
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("res://.local/adventure-drag-chest.png")
 run.phase="treasure";run.treasure_roll=4;view.render()
 for node in view.body.get_children():
  if node is Label:assert(not node.text.contains("1d6") and not node.text.contains("dado"))
 view.queue_free();await process_frame;State.current=null
 var main=load("res://main.tscn").instantiate();main.enable_opening=false;main.starting_player=0;root.add_child(main)
 for p in main.duel.players:p.board.clear()
 for side in [0,1]:
  var unit=main.duel.spawn_unit(side,"warrior");unit.ready=false;unit.attacked_this_turn=true;unit.exhausting_action_taken=true
 main.duel.turn=0;main.redraw();await process_frame
 var own: Control=main.field_nodes[0][main.duel.players[0].board[0].id]
 var foe: Control=main.field_nodes[1][main.duel.players[1].board[0].id]
 assert(own.get_node("Canvas/Exhausted").visible and not foe.get_node("Canvas/Exhausted").visible)
 foe.mouse_entered.emit();assert(foe.get_node("Canvas/Exhausted").visible)
 foe.mouse_exited.emit();assert(not foe.get_node("Canvas/Exhausted").visible)
 main.duel.turn=1;main.redraw();await process_frame
 own=main.field_nodes[0][main.duel.players[0].board[0].id];foe=main.field_nodes[1][main.duel.players[1].board[0].id]
 assert(not own.get_node("Canvas/Exhausted").visible and foe.get_node("Canvas/Exhausted").visible)
 for player in main.sounds.values():player.stop();player.stream=null
 main.queue_free();await process_frame;await process_frame
 print("OK: arraste sem selecionar nodos, mapa acompanha avanço, preços 1–3/+2, itens em cópias atuais/futuras, baú ampliado e ícones por turno/hover")
 quit()
