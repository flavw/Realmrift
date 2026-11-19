extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
const Items=preload("res://scripts/adventure_items.gd")
const Music=preload("res://scripts/game_music.gd")
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var normal: String="warrior"
 assert(not Match.CARD_DATA[normal].swift)
 var boots: String=Items.enhance(normal,"boots")
 assert(Match.CARD_DATA[boots].swift and Match.CARD_DATA[boots].attack==Match.CARD_DATA[normal].attack)
 var haste: String="goblin_raider"
 assert(Match.CARD_DATA[haste].swift)
 var faster: String=Items.enhance(haste,"boots")
 assert(Match.CARD_DATA[faster].swift and Match.CARD_DATA[faster].attack==Match.CARD_DATA[haste].attack+1)
 assert(Match.CARD_DATA[faster].get_meta("adventure_items").back()=="boots_attack")
 var run=State.new();run.deck=Match.default_deck(0).slice(0,15);run.step=4;run.encounter="mimic"
 run.finish_combat(true,10)
 assert(run.gold==5 and run.extra_item_reward and not run.reward_message.is_empty()) # 1 initial + 4 prize
 State.current=run
 var view=load("res://adventure.tscn").instantiate();root.add_child(view)
 view.pick_card(run.options[0])
 assert(run.phase=="item" and run.options.size()==3)
 view.equip(run.options[0]);assert(run.equipment.size()==1 and run.step==5)
 run.step=6;run.gold=3;view.open_shop()
 assert(not run.shop_premium_key.is_empty())
 var key: String=run.shop_premium_key
 var price: int=run.market_price(key,true)
 assert(Match.CARD_DATA[key].has_meta("adventure_items"))
 run.gold=price-1
 assert(not run.buy_premium_card(key) and run.gold==price-1)
 run.gold=price
 var before: int=run.deck.size()
 assert(run.buy_premium_card(key) and run.gold==0 and run.deck.size()==before+1 and run.shop_premium_sold)
 assert(not run.buy_premium_card(key))
 run.generate_shop();assert(run.shop_premium_key.is_empty() and run.shop_premium_sold)
 var battle=Match.new(run.deck,[],0,false,run.rules())
 assert(battle.players[0].deck.size()+battle.players[0].hand.size()==run.deck.size())
 run.step=9;run.gold=9;run.preparation_active=true;view.open_shop()
 assert(not run.shop_premium_key.is_empty())
 await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":get_root().get_texture().get_image().save_png("res://.local/adventure-merchant-polished.png")
 run.ensure_routes();run.phase="map";run.step=0;view.render()
 await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":get_root().get_texture().get_image().save_png("res://.local/adventure-world-map-view.png")
 run.step=State.STAGES.size()-1;view.render()
 await process_frame;await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":get_root().get_texture().get_image().save_png("res://.local/adventure-world-map-final.png")
 view.queue_free();await process_frame;await process_frame
 var music=Music.ensure(self)
 for child in music.get_children():
  if child is AudioStreamPlayer and child.name!="BackgroundMusic":child.stop();child.stream=null;child.queue_free()
 await create_timer(0.1).timeout
 State.current=null
 print("OK: Botas/Disparada e bônus alternativo, prêmio do mímico, oferta aprimorada única e mapa ilustrado")
 quit()

