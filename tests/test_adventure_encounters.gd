extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
const Items=preload("res://scripts/adventure_items.gd")
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var run=State.new();run.deck=Match.default_deck(0).duplicate();run.pending_item="heart";run.prepare_item()
 assert(run.options.size()==3)
 var key: String=run.options[0]
 var before: int=Match.CARD_DATA[key].health
 assert(run.apply_item(key))
 var improved: String=run.deck.filter(func(k):return k.begins_with("adventure_item_"))[0]
 assert(Match.CARD_DATA[improved].health==before+2 and Match.CARD_DATA[key].health==before)
 assert(run.card_copies(key)==Match.default_deck(0).count(key))
 var game=Match.new(run.deck,[],0,false,run.rules())
 assert(game.players[0].deck.size()+game.players[0].hand.size()==22)
 var unit=game.spawn_unit(0,improved)
 assert(unit.health==before+2)
 var card=load("res://card_model.tscn").instantiate();card.set_card(Match.CARD_DATA[improved]);root.add_child(card)
 assert(card.find_child("AdventureItems",true,false)!=null)
 assert(card.view_entries().any(func(e):return e.name=="Amuleto vital"))
 card.ensure_hint()
 assert(card.hint_body.get_children().any(func(n):return n is Label and n.text.contains("+2 de vida permanente")))
 assert(not Match.valid_deck(run.deck))
 var normal=Match.new(run.deck)
 assert(normal.players[0].deck.size()+normal.players[0].hand.size()==Match.DECK_SIZE)
 var field=load("res://field_card.tscn").instantiate();field.card_data=game.card_for_unit(unit);root.add_child(field)
 assert(field.find_child("AdventureItems",true,false)!=null)
 card.queue_free();field.queue_free()
 run=State.new();run.phase="bridge";run.gold=5;run.current_life=10
 assert(run.resolve_bridge("pay") and run.gold==0 and run.current_life==12 and run.phase=="event_result")
 assert(not run.resolve_bridge("pay"))
 run.phase="bridge";assert(run.resolve_bridge("fight") and run.encounter=="bandits" and run.enemy.size()==20)
 run.finish_combat(true,10)
 assert(run.gold==3 and run.extra_item_reward)
 var mimic_count:=0;var item_count:=0;var gold_count:=0
 for i in range(200):
  var chest=State.new();chest.deck=Match.default_deck(0);chest.rng.seed=i+10;chest.phase="chest"
  var outcome: String=chest.resolve_chest()
  if outcome=="mimic":mimic_count+=1
  elif outcome=="item":item_count+=1
  else:gold_count+=1
  assert(chest.resolve_chest()==outcome)
 assert(mimic_count>70 and mimic_count<130 and item_count>0 and gold_count>0)
 run=State.new();run.deck=Match.default_deck(0);run.encounter="mimic"
 var mimic=Match.new(run.deck,[],0,false,run.rules())
 assert(mimic.creature_boss_id>=0 and mimic.players[1].board.size()==1)
 assert(mimic.players[1].board[0].health==14 and mimic.players[1].deck.is_empty())
 mimic.players[1].hp=0;mimic.check_winner();assert(mimic.winner==-1)
 mimic.spawn_unit(0,"warrior").ready=true
 assert(not mimic.can_target(0,0,-1))
 mimic.players[0].mana=10;mimic.players[0].hand=["astral_flame"]
 assert(not mimic.can_cast(0,0,1,-1))
 mimic.players[1].hp=20;mimic.turn=1;mimic.players[1].board[0].ready=true
 assert(mimic.ai_step() and not mimic.players[1].board[0].ready)
 mimic.draw(1);assert(mimic.players[1].fatigue==0)
 mimic.players[1].board[0].health=0;mimic.remove_dead();mimic.check_winner();assert(mimic.winner==0)
 run.ensure_routes()
 assert(run.route_rows[2].size()==4 and run.route_rows[7].size()==2)
 for at in range(run.route_rows.size()-1):
  for target in range(run.route_rows[at+1].size()):
   var reachable:=false
   for source in range(run.route_rows[at].size()):reachable=reachable or run.linked(at,source,target)
   assert(reachable)
 await process_frame
 print("OK: itens compartilhados entre cópias e ícones, ponte, três resultados do baú, mímico e ramificações")
 quit()


