extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
const Match=preload("res://scripts/match.gd")
const Save=preload("res://scripts/adventure_save.gd")
const View=preload("res://scripts/adventure_view.gd")
const MapView=preload("res://scripts/adventure_map.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 Save.enabled=false
 var counts: Dictionary={"negative":0,"positive":0,"treasure":0}
 for roll in range(100):counts[State.river_outcome_for_roll(roll)]+=1
 assert(counts=={"negative":50,"positive":25,"treasure":25})
 var outcomes: Dictionary={}
 for i in range(150):
  var run=State.new();run.deck=Match.default_deck(0);run.phase="bridge";run.gold=4;run.current_life=12;run.rng.seed=i
  assert(run.resolve_bridge("river"))
  assert(run.river_visits==1 and run.current_life>=1)
  if not outcomes.has(run.river_outcome):outcomes[run.river_outcome]=run
  var old_gold: int=run.gold;var old_life: int=run.current_life
  assert(not run.resolve_bridge("river") and run.gold==old_gold and run.current_life==old_life)
  if run.river_outcome=="negative":assert(run.gold<4 or run.current_life<12)
  elif run.river_outcome=="treasure":assert(run.gold>=8 and run.gold<=10 and run.extra_item_reward)
  else:assert(run.phase=="river_recruit" and run.options.size()==2)
 assert(outcomes.size()==3)
 var positive=outcomes.positive
 assert(positive.recruit_from_river("adventure_river_fish") and positive.deck.size()==23)
 assert(not positive.recruit_from_river("adventure_river_turtle"))
 var game=Match.new(positive.deck,[],0,false,positive.rules())
 assert(game.players[0].hand.size()+game.players[0].deck.size()==23)
 var fish=game.spawn_unit(0,"adventure_river_fish")
 game.spawn_unit(0,"adventure_river_turtle")
 assert(fish.attack==1 and fish.health==1 and fish.pack==1 and fish.turn_attack==1)
 for key in State.RIVER_CREATURES:
  var card: CardData=Match.CARD_DATA[key]
  assert(card.adventure_only and not card.collectible and card.faction==CardData.Faction.UNALIGNED)
  var ordinary_deck: Array=Match.default_deck(0);ordinary_deck[0]=key
  assert(not Match.valid_deck(ordinary_deck,false))
  var ordinary=Match.new(ordinary_deck)
  assert(key not in ordinary.players[0].hand and key not in ordinary.players[0].deck)
 assert(preload("res://scripts/faction_names.gd").name_for(9)=="Sem facção")
 var run=State.new();run.deck=Match.default_deck(0);run.ensure_routes()
 assert(State.STAGES.count("combat")==6 and State.STAGES.count("boss")==1)
 assert(State.STAGES.count("shop")==2)
 var shops:=0
 for at in range(run.route_rows.size()):
  for node in run.route_rows[at]:
   if node.kind=="shop":shops+=1
  if at==run.route_rows.size()-1:continue
  for branch in range(run.route_rows[at].size()):
   var choices:=0
   for target in range(run.route_rows[at+1].size()):
    if run.linked(at,branch,target):choices+=1
   assert(choices>=mini(2,run.route_rows[at+1].size()))
 assert(shops==2)
 var map=MapView.new();map.configure(run)
 assert(map.custom_minimum_size.x>3000 and map.custom_minimum_size.y>900)
 assert(map.node_center(2,0).x/map.MAP_SIZE.x>0.18 and map.node_center(2,0).x/map.MAP_SIZE.x<0.21)
 assert(map.node_center(2,1).y>map.node_center(2,0).y)
 var centers: Array=[]
 for at in range(run.route_rows.size()):
  for branch in range(run.route_rows[at].size()):
   var point: Vector2=map.node_center(at,branch)
   for previous in centers:assert(point.distance_to(previous)>125.0)
   centers.append(point)
 map.free()
 # The treasure's item is delivered once, with no unrelated generic reward.
 var treasure=outcomes.treasure;State.current=treasure
 var view=View.new();root.add_child(view)
 view.finish_event();assert(treasure.phase=="item" and not treasure.extra_item_reward and treasure.options.size()==3)
 assert(treasure.apply_item(treasure.options[0]) and treasure.step==1)
 view.queue_free();State.current=null
 await process_frame;await process_frame
 # Save recruitment and equipped copies using the real expedition serializer.
 Save.enabled=true;Save.path="res://work/river-polish.save"
 positive.grant_card_item("adventure_river_fish","heart")
 positive.map_scroll_position=450.0;positive.map_scroll_vertical=190.0
 assert(positive.save_checkpoint())
 var profile=preload("res://scripts/adventure_profile.gd").new("res://work/river-polish-profile.json",false)
 var restored=Save.load_run(profile)
 assert(restored!=null and restored.deck.size()==positive.deck.size())
 assert(restored.river_outcome=="positive" and restored.event_claimed and restored.map_scroll_vertical==190.0)
 var key: String=restored.deck.back()
 assert(Match.CARD_DATA[key].adventure_only and Match.CARD_DATA[key].health==3)
 game=Match.new(restored.deck,[],0,false,restored.rules())
 assert(game.players[0].hand.size()+game.players[0].deck.size()==restored.deck.size())
 print("OK: rio 50/25/25, efeitos únicos, recrutas exclusivos, Matilha, tesouro com item, duas lojas e caminhos conectados.")
 quit()
