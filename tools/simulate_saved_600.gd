extends "res://tools/simulate_current_decks.gd"
func game(a: Array,b: Array,starter: int,game_seed: int) -> Dictionary:
 seed(game_seed)
 var m=Match.new(a,b,starter,true)
 for side in range(2):
  var swaps: Array=[]
  for i in range(m.players[side].hand.size()):
   if Match.CARD_DATA[m.players[side].hand[i]].cost>=4:swaps.append(i)
  assert(m.mulligan(side,swaps))
 var turns:=1
 var actions:=0
 var fire_uses:=0
 var rogue_choices: Dictionary={"loot":0,"envenom":0}
 while m.winner==-1 and turns<180 and actions<4000:
  if seat_step(m):
   actions+=1
   if m.last_action.has("fire_hits"):fire_uses+=1
   if m.last_action.has("granted_ability"):rogue_choices[m.last_action.granted_ability]+=1
  else:
   assert(m.end_turn(m.turn))
   turns+=1
  for p in m.players:
   assert(p.board.size()<=Match.MAX_BOARD and p.hand.size()<=Match.MAX_HAND_SIZE)
   assert(p.mana>=0 and p.temporary_mana>=0)
 var burns:=0
 for event in m.draw_events:
  if event.get("destroyed",false):burns+=1
 return {"winner":m.winner,"turns":turns,"actions":actions,"starter":starter,"seed":game_seed,"health":[m.players[0].hp,m.players[1].hp],"fatigue":[m.players[0].fatigue,m.players[1].fatigue],"burns":burns,"fire_uses":fire_uses,"rogue_choices":rogue_choices}
func run() -> void:
 var source=JSON.parse_string(FileAccess.get_file_as_string("res://docs/decks-simulacao-600-atual.json"))
 var decks: Array=source.slots
 assert(decks.size()==6)
 for deck in decks:assert(Match.valid_deck(deck.cards),deck.name)
 var wins: Array=[0,0,0,0,0,0]
 var played: Array=[0,0,0,0,0,0]
 var first_wins:=0
 var draws:=0
 var unfinished:=0
 var total_turns:=0
 var pairs: Array=[]
 for i in range(decks.size()):
  for j in range(i+1,decks.size()):
   var pair: Dictionary={"a":decks[i].name,"b":decks[j].name,"a_index":i,"b_index":j,"a_wins":0,"b_wins":0,"draws":0,"unfinished":0,"turns":0,"games":[]}
   for n in range(40):
    var inverted: bool=n%4>=2
    var starter: int=n%2
    var result: Dictionary=game(decks[j].cards if inverted else decks[i].cards,decks[i].cards if inverted else decks[j].cards,starter,202610316000+i*100000+j*1000+n)
    var winner: int=result.winner
    if winner==-1:pair.unfinished+=1;unfinished+=1
    elif winner==2:pair.draws+=1;draws+=1
    else:
     if winner==starter:first_wins+=1
     if (winner==1 if inverted else winner==0):pair.a_wins+=1;wins[i]+=1
     else:pair.b_wins+=1;wins[j]+=1
    played[i]+=1;played[j]+=1
    pair.turns+=result.turns;total_turns+=result.turns
    result["inverted"]=inverted
    pair.games.append(result)
   pairs.append(pair)
   print("%s x %s: %d-%d; empates %d; sem conclusão %d" % [pair.a,pair.b,pair.a_wins,pair.b_wins,pair.draws,pair.unfinished])
 var cards: Dictionary={}
 for deck in decks:
  for key in deck.cards:cards[key]=Match.CARD_DATA[key].combat_data()
 var report={"method":"IA atual nos dois lados; listas salvas do jogador; 40 partidas por confronto, lados e iniciativa balanceados; mulligan troca custo 4 ou maior; teto 180 turnos individuais/4000 ações.","source":source,"card_snapshot":cards,"pairs":pairs,"wins":wins,"played":played,"first_wins":first_wins,"draws":draws,"unfinished":unfinished,"total_turns":total_turns}
 var file=FileAccess.open("res://docs/simulacao-600-decks-atuais.json",FileAccess.WRITE)
 assert(file!=null)
 file.store_string(JSON.stringify(report,"  "));file.close()
 print("TOTAL ",wins," inicia ",first_wins," empates ",draws," sem conclusão ",unfinished," turnos ",total_turns)
 quit()
