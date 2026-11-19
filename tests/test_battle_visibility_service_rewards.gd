extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var main=load("res://main.tscn").instantiate();main.enable_opening=false;main.starting_player=0;root.add_child(main)
 for p in main.duel.players:p.board.clear()
 main.duel.draw_events.clear()
 for side in [0,1]:
  var attacked=main.duel.spawn_unit(side,"warrior");attacked.ready=false;attacked.attacked_this_turn=true;attacked.exhausting_action_taken=true
  var tapped=main.duel.spawn_unit(side,"mage");tapped.ready=false;tapped.exhausting_action_taken=true
  var waiting=main.duel.spawn_unit(side,"squire");waiting.ready=false
 main.duel.players[0].hand=["warrior"];main.duel.players[0].mana=0
 main.redraw();await process_frame;await process_frame
 for side in [0,1]:
  for index in range(3):
   var unit: Dictionary=main.duel.players[side].board[index]
   var card: Control=main.field_nodes[side][unit.id]
   var icon=card.get_node("Canvas/Exhausted")
   assert(card.get_node("Canvas/Artwork").modulate==Color.WHITE and card.modulate==Color.WHITE)
   assert(icon.visible==(side==main.duel.turn))
   assert(icon.texture==preload("res://scripts/card_skin.gd").texture(["attack-spent-icon","tap-icon","exhausted-zzz"][index]))
   unit.ready=true
 assert(main.find_child("HandCard_0",true,false).modulate==Color.WHITE)
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("res://.local/battle-bright-status.png")
 main.redraw();await process_frame
 for side in [0,1]:
  for unit in main.duel.players[side].board:assert(not main.field_nodes[side][unit.id].get_node("Canvas/Exhausted").visible)
 for player in main.sounds.values():player.stop();player.stream=null
 main.queue_free();await process_frame;await process_frame
 var fortune_step: int=State.STAGES.find("fortune")
 var run=State.new();run.deck=Match.default_deck(0).slice(0,15);run.phase="map";run.step=fortune_step;State.current=run
 var view=load("res://adventure.tscn").instantiate();root.add_child(view)
 view.choose_route(run.route_rows[fortune_step].find_custom(func(node):return node.kind=="treasure"))
 assert(run.phase=="treasure" and run.gold==1+run.treasure_roll)
 var gold: int=run.gold
 var deck: int=run.deck.size()
 view.finish_service_encounter()
 assert(run.phase=="map" and run.step==fortune_step+1 and run.gold==gold and run.permanent_life==0 and run.deck.size()==deck and run.equipment.is_empty())
 run.phase="healer";run.current_life=1;view.heal_at_node(false)
 assert(run.phase=="map" and run.step==fortune_step+2 and run.current_life==6 and run.gold==gold and run.permanent_life==0)
 var first_shop: int=State.STAGES.find("shop")
 run.step=first_shop;run.gold=10;view.open_shop()
 var premium: String=run.shop_premium_key
 var premium_price: int=run.market_price(run.shop_premium_key,true)
 view.purchase_premium(premium)
 assert(run.gold==10-premium_price and State.Items.base_key(run.deck.back())==State.Items.base_key(premium))
 var regular: String=""
 for key in run.options:
  if run.card_copies(key)<Match.copy_limit(key):regular=key;break
 assert(not regular.is_empty())
 var expected_gold: int=run.gold-run.market_price(regular)
 view.purchase(regular);assert(run.gold==expected_gold and run.deck.size()==deck+2)
 var equipment: int=run.equipment.size()
 view.finish_service_encounter()
 assert(run.phase=="map" and run.step==first_shop+1 and run.gold==expected_gold and run.permanent_life==0 and run.equipment.size()==equipment)
 var second_shop: int=State.STAGES.rfind("shop")
 run.step=second_shop;run.gold=1;run.chosen_routes.clear();view.render();view.choose_route(0)
 assert(run.phase=="shop" and run.gold==1)
 await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("res://.local/adventure-shop-prices.png")
 view.open_upgrade()
 assert(run.phase=="map" and run.step==second_shop+1 and run.gold==1 and run.permanent_life==0)
 view.queue_free();await process_frame;await process_frame;State.current=null
 print("OK: cartas claras dos dois lados, ícones por turno, preços por custo de mana e serviços sem bônus adicionais")
 quit()
