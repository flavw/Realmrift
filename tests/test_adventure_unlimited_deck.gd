extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var run=State.new();run.gold=100
 for key in Match.CARD_DATA:
  var data: CardData=Match.CARD_DATA[key]
  if data.collectible and not data.neutral_deck_only:
   for i in range(3):run.deck.append(key)
 assert(run.reward_options(0).size()==3)
 run.generate_shop();assert(run.options.size()==9 and not run.shop_premium_key.is_empty())
 var key: String=run.options[0]
 var before: int=run.card_copies(key)
 assert(before>=3 and run.buy_card(key,run.market_price(key)) and run.card_copies(key)==before+1)
 key=run.shop_premium_key;before=run.card_copies(key)
 assert(before>=3 and run.buy_premium_card(key) and run.card_copies(key)==before+1)
 run.phase="farm";run.visit_farm_recruits();assert(run.options.size()==3)
 key=run.options[0];before=run.card_copies(key)
 assert(before>=3 and run.recruit_from_farm(key) and run.card_copies(key)==before+1)
 var legendary=State.new();legendary.deck=["valeria_implacavel","valeria_implacavel"];legendary.gold=10
 assert(legendary.buy_card("valeria_implacavel",legendary.market_price("valeria_implacavel")) and legendary.card_copies("valeria_implacavel")==3)
 run=State.new();run.faction=0;run.deck=["squire","squire"];run.draft_curve.fill(1)
 var seen:=false
 for i in range(30):
  if "squire" in run.draft_options():seen=true;break
 assert(seen)
 run.deck.clear()
 for i in range(30):run.add_card_to_deck("warrior")
 var battle=Match.new(run.deck,[],0,false,run.rules())
 assert(battle.players[0].hand.size()+battle.players[0].deck.size()==30)
 assert((battle.players[0].hand+battle.players[0].deck).all(func(card):return card=="warrior"))
 assert(not Match.valid_deck(run.deck) and Match.copy_limit("warrior")==2 and Match.copy_limit("valeria_implacavel")==1)
 run.phase="faction";State.current=run
 var view=load("res://adventure.tscn").instantiate();root.add_child(view)
 assert(view.body.get_children().any(func(node):return node is Label and node.text==State.DECK_RULES))
 run.phase="shop";run.options=["warrior"];run.gold=10;view.render()
 var card=view.find_child("AdventureCard_warrior",true,false)
 assert(card!=null and card.modulate==Color.WHITE)
 view.queue_free();await process_frame;await process_frame;State.current=null
 print("OK: aventura aceita deck acima de 22 e mais de duas cópias no draft, recompensas, fazenda, compras e combate; regras visíveis e duelo normal preservado")
 quit()
