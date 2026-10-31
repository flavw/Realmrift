extends "res://tools/simulate_balance.gd"
# Exactly the requested 15 games. Uses the production AI on both seats and real rules.
func current_deck(faction: String) -> Array:
 match faction:
  "Guerreiro":return Match.default_deck(0)
  "Ladina":return Match.default_deck(1)
  "Mago":return Match.default_deck(2)
  _:return Match.default_deck(3)
func opening_match(opponent: String,starter: int,seed_value: int):
 seed(seed_value)
 var m=Match.new(current_deck("Guerreiro"),current_deck(opponent),starter,true)
 for side in range(2):
  var faction: String="Guerreiro" if side==0 else opponent
  var p: Dictionary=m.players[side]
  p.hand=[]
  p.deck=shuffled(current_deck(faction),seed_value*1009+int(SALTS[faction]))
  for i in range(3 if side==starter else 4):m.draw(side)
 var initial_hands: Array=[m.players[0].hand.duplicate(),m.players[1].hand.duplicate()]
 var exchanges: Array=[]
 for side in range(2):
  var selected_indices: Array=[]
  for i in range(m.players[side].hand.size()):
   if Match.CARD_DATA[m.players[side].hand[i]].cost>=4:selected_indices.append(i)
  exchanges.append(selected_indices)
  assert(m.mulligan(side,selected_indices))
 assert(not m.opening and m.turn==starter)
 return {"match":m,"initial_hands":initial_hands,"mulligans":exchanges,"after_mulligan_and_first_draw":[m.players[0].hand.duplicate(),m.players[1].hand.duplicate()]}
func run_requested_game(opponent: String,number: int,seed_value: int) -> Dictionary:
 var starter: int=(number-1)%2
 var setup: Dictionary=opening_match(opponent,starter,seed_value)
 var m=setup.match
 var turns:=1
 var actions:=0
 var trace: Array=[]
 var totals: Dictionary={"poison_ticks":0,"vigor_defenses":0,"conductive_bolts":0,"vigor_grants":0,"guardians_played":0,"vigor_attacks":0,"arcane_shots":0}
 while m.winner==-1 and turns<180 and actions<4000:
  var side: int=m.turn
  var before_hp: Array=[m.players[0].hp,m.players[1].hp]
  var before_board: Array=[m.players[0].board.duplicate(true),m.players[1].board.duplicate(true)]
  if production_step(m):
   actions+=1
   if m.last_action.get("kind","")=="magic":totals.arcane_shots+=1
   if m.last_action.get("kind","")=="attack":
    for attacker in before_board[side]:
     if attacker.id==m.last_action.attacker and attacker.get("vigor",false):totals.vigor_attacks+=1
   if m.last_action.get("kind","")=="attack" and not m.last_action.castle:
    for defender in before_board[1-side]:
     if defender.id==m.last_action.target and defender.get("vigor",false):totals.vigor_defenses+=1
   if m.last_action.get("kind","")=="spell":
    if m.last_action.card=="conductive_bolt":totals.conductive_bolts+=1
    if m.last_action.card=="vigor_vow":totals.vigor_grants+=1
   if m.last_action.get("kind","")=="summon":
    for u in m.players[side].board:
     if u.id==m.last_action.attacker and u.key=="dawn_warden":totals.guardians_played+=1
   trace.append({"turn":turns,"side":side,"action":m.last_action.duplicate(true),"hp_before":before_hp,"hp_after":[m.players[0].hp,m.players[1].hp],"board_before":before_board,"history_tail":m.history.slice(maxi(0,m.history.size()-3))})
  else:
   assert(m.end_turn(side))
   var ticks: Array=m.last_action.get("ticks",[])
   totals.poison_ticks+=ticks.size()
   trace.append({"turn":turns,"side":side,"action":m.last_action.duplicate(true),"hp_before":before_hp,"hp_after":[m.players[0].hp,m.players[1].hp],"board_before":before_board,"history_tail":m.history.slice(maxi(0,m.history.size()-3))})
   if m.winner!=-1:
    break
   turns+=1
  for owner in range(2):
   assert(m.players[owner].board.size()<=Match.MAX_BOARD and m.players[owner].hand.size()<=Match.MAX_HAND_SIZE)
   assert(m.players[owner].mana>=0)
   for u in m.players[owner].board:assert(u.health>0 and u.get("poison",0)>=0)
 assert(m.winner!=-1,"Simulation must reach a real conclusion")
 var finish:="combat"
 if m.last_action.get("kind","") in ["poison","turn_end"]:
  var final_side: int=trace[-1].side
  finish="poison" if int(before_hp_for(trace[-1],final_side))>0 and m.players[final_side].hp<=0 else "fatigue"
 var winner: String="Empate" if m.winner==2 else ("Guerreiro" if m.winner==0 else opponent)
 return {"opponent":opponent,"game":number,"seed":seed_value,"starter":"Guerreiro" if starter==0 else opponent,"winner":winner,"turns":turns,"actions":actions,"hp":[m.players[0].hp,m.players[1].hp],"finish":finish,"initial_hands":setup.initial_hands,"mulligans":setup.mulligans,"after_mulligan_and_first_draw":setup.after_mulligan_and_first_draw,"counters":totals,"trace":trace}
func before_hp_for(entry: Dictionary,side: int) -> int:return entry.hp_before[side]
func run() -> void:
 assert(Match.CARD_DATA.dawn_warden.block==1)
 var recipes: Dictionary={}
 for faction in FACTIONS:
  var recipe:=current_deck(faction)
  assert(Match.valid_deck(recipe))
  for key in recipe:assert(Match.CARD_DATA[key].card_class in [IDS[faction],CardData.CardClass.NEUTRAL])
  recipes[faction]=recipe
 var batch:=maxi(1,int(OS.get_environment("SIMULATION_BATCH")))
 var results: Array=[]
 var summaries: Array=[]
 var opponents=["Ladina","Clérigo","Mago"]
 for index in range(opponents.size()):
  var opponent: String=opponents[index]
  var wins:=0
  var draws:=0
  for number in range(1,6):
   var result:=run_requested_game(opponent,number,2026102500+(batch-1)*1000+index*100+number)
   results.append(result)
   if result.winner=="Guerreiro":wins+=1
   if result.winner=="Empate":draws+=1
   print(JSON.stringify(result.merged({"trace":[]},true)))
  summaries.append({"opponent":opponent,"warrior_wins":wins,"opponent_wins":5-wins-draws,"draws":draws,"games":5})
 var output:={"batch":batch,"deckset_version":2,"rules":"Vigor ofensivo e defensivo, Disparo Arcano 2 custa 1 mana, Envenenar, Descarga Condutora, mulligan 3/4 e Guardião com Bloqueio 1","policy":"production AI on both seats; mulligan cost >= 4; alternating starter (warrior 3, opponent 2)","decks":recipes,"games":results,"summaries":summaries,"patches":[],"total_games":results.size()}
 var path:=OS.get_environment("BALANCE_OUTPUT")
 assert(not path.is_empty())
 var file:=FileAccess.open(path,FileAccess.WRITE)
 assert(file!=null)
 file.store_string(JSON.stringify(output," "))
 file.close()
 print("COMPLETE ",results.size()," games ",JSON.stringify(summaries))
 quit()
