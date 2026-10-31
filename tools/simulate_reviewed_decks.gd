extends "res://tools/simulate_balance.gd"
# Real rules and production AI on both seats, with the current two-round mulligan.
func seat_step(m) -> bool:
 if m.turn==1:return m.ai_step()
 m.players.reverse();m.turn=1
 var moved: bool=m.ai_step()
 m.players.reverse();m.turn=0
 if m.winner in [0,1]:m.winner=1-m.winner
 if moved and not m.last_action.is_empty():
  m.last_action.side=0
  if m.last_action.has("target_side"):m.last_action.target_side=1-int(m.last_action.target_side)
  for field in ["dead","healed","poisoned","area_hits","ticks"]:
   for item in m.last_action.get(field,[]):
    if item.has("side"):item.side=1-int(item.side)
 return moved

func one_game(cards: Array,reference: Array,number: int,seed_value: int) -> Dictionary:
 seed(seed_value)
 var starter: int=(number-1)%2
 var m=Match.new(cards,reference,starter,true)
 for side in range(2):
  m.players[side].hand=[]
  m.players[side].deck=shuffled(cards if side==0 else reference,seed_value*1009+side*211)
  for i in range(3 if side==starter else 4):m.draw(side)
 var initial: Array=[m.players[0].hand.duplicate(),m.players[1].hand.duplicate()]
 var exchanges: Array=[]
 for side in range(2):
  while not m.mulligan_done[side]:
   var selected: Array=[]
   for index in range(m.players[side].hand.size()):
    if Match.CARD_DATA[m.players[side].hand[index]].cost>=4 and selected.size()<m.mulligan_max_cards(side):selected.append(index)
   exchanges.append({"side":side,"round":m.mulligan_rounds[side]+1,"indices":selected.duplicate()})
   assert(m.mulligan(side,selected))
 assert(not m.opening and m.turn==starter and m.mulligan_rounds[starter]==1 and m.mulligan_rounds[1-starter]==2)
 var turns:=1
 var actions:=0
 var trace: Array=[]
 var played: Array=[{},{}]
 while m.winner==-1 and turns<180 and actions<4000:
  var side: int=m.turn
  var action_turn: int=turns
  var hand: Array=m.players[side].hand.duplicate()
  if seat_step(m):
   actions+=1
   for key in hand:
    if hand.count(key)>m.players[side].hand.count(key):
     played[side][key]=int(played[side].get(key,0))+1
     break
  else:
   assert(m.end_turn(side))
   assert(m.players[side].get("poison",0)==0)
   for u in m.players[side].board:assert(u.get("poison",0)==0)
   if m.winner==-1:turns+=1
  trace.append({"turn":action_turn,"side":side,"action":m.last_action.duplicate(true),"hp":[m.players[0].hp,m.players[1].hp]})
  for p in m.players:
   assert(p.board.size()<=Match.MAX_BOARD and p.hand.size()<=Match.MAX_HAND_SIZE and p.mana>=0)
   for u in p.board:assert(u.health>0)
 assert(m.winner!=-1,"A partida deve terminar pelas regras, sem vitória artificial")
 return {"game":number,"seed":seed_value,"starter":starter,"winner":m.winner,"turns":turns,"actions":actions,"hp":[m.players[0].hp,m.players[1].hp],"fatigue":[m.players[0].fatigue,m.players[1].fatigue],"initial_hands":initial,"mulligans":exchanges,"played":played,"trace":trace}

func run() -> void:
 var saved=JSON.parse_string(FileAccess.get_file_as_string("res://docs/decks-revisados.json"))
 var reference: Array=saved.slots[0].cards
 var results: Array=[]
 var summaries: Array=[]
 for index in range(5):
  var cards: Array=saved.slots[index].cards
  assert(Match.valid_deck(cards) and cards==Match.default_deck(index))
  var summary:={"deck":saved.slots[index].name,"slot":index,"wins":0,"losses":0,"draws":0,"starts":0,"wins_starting":0,"wins_second":0,"turns":0}
  for number in range(1,11):
   var game:=one_game(cards,reference,number,2026102500+index*100+(number-1)/2)
   game["slot"]=index;game["deck"]=summary.deck
   results.append(game)
   summary.turns+=game.turns
   if game.starter==0:summary.starts+=1
   if game.winner==0:
    summary.wins+=1
    if game.starter==0:summary.wins_starting+=1
    else:summary.wins_second+=1
   elif game.winner==1:summary.losses+=1
   else:summary.draws+=1
  assert(summary.starts==5 and summary.wins+summary.losses+summary.draws==10)
  summary["average_turns"]=summary.turns/10.0
  summaries.append(summary);print(JSON.stringify(summary))
 var output:={"total_games":results.size(),"policy":"Production AI on both seats; cost >=4 mulligan, including second player extra one-card round; five paired seeds, alternating starter","decks":saved.slots.slice(0,5),"reference":saved.slots[0].name,"summaries":summaries,"games":results}
 assert(results.size()==50)
 var file=FileAccess.open("res://docs/simulacao-decks-50-partidas.json",FileAccess.WRITE)
 assert(file!=null);file.store_string(JSON.stringify(output," "));file.close()
 print("OK: 50 partidas concluídas e registradas.");quit()
