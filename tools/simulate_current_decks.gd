extends SceneTree
const Match=preload("res://scripts/match.gd")
var results: Array=[]
func _initialize() -> void:call_deferred("run")
func seat_step(m) -> bool:
 if m.turn==1:return m.ai_step()
 m.players.reverse()
 m.human_deaths.reverse()
 m.turn=1
 m.first_player=1-m.first_player
 var acted: bool=m.ai_step()
 m.first_player=1-m.first_player
 m.turn=0
 m.human_deaths.reverse()
 m.players.reverse()
 if m.winner in [0,1]:m.winner=1-m.winner
 return acted
func game(a: Array,b: Array,starter: int,game_seed: int) -> Dictionary:
 seed(game_seed)
 var m=Match.new(a,b,starter,true)
 for side in range(2):
  var replacement: Array=[]
  for i in range(m.players[side].hand.size()):
   if Match.CARD_DATA[m.players[side].hand[i]].cost>=4:replacement.append(i)
  assert(m.mulligan(side,replacement))
 assert(not m.opening)
 var turns:=1
 var actions:=0
 while m.winner==-1 and turns<180 and actions<4000:
  if seat_step(m):actions+=1
  else:
   assert(m.end_turn(m.turn))
   turns+=1
  for p in m.players:
   assert(p.board.size()<=Match.MAX_BOARD and p.hand.size()<=Match.MAX_HAND_SIZE)
 return {"winner":m.winner,"turns":turns,"actions":actions,"starter":starter,"health":[m.players[0].hp,m.players[1].hp]}
func run() -> void:
 var decks=JSON.parse_string(FileAccess.get_file_as_string("res://docs/decks-simulacao-atual.json"))
 assert(decks is Array and decks.size()==6)
 for d in decks:assert(Match.valid_deck(d.cards))
 var wins: Array=[0,0,0,0,0,0]
 var played: Array=[0,0,0,0,0,0]
 for i in range(6):
  for j in range(i+1,6):
   var pair:={"a":decks[i].name,"b":decks[j].name,"a_wins":0,"b_wins":0,"draws":0,"unfinished":0,"turns":0,"games":[]}
   for n in range(10):
    var reversed: bool=n%4>=2
    var starter: int=n%2
    var result=game(decks[j].cards if reversed else decks[i].cards,decks[i].cards if reversed else decks[j].cards,starter,2026103100+i*10000+j*100+n)
    var winner: int=int(result.winner)
    if winner==-1:pair.unfinished+=1
    elif winner==2:pair.draws+=1
    elif (winner==1 if reversed else winner==0):
     pair.a_wins+=1;wins[i]+=1
    else:
     pair.b_wins+=1;wins[j]+=1
    played[i]+=1;played[j]+=1
    pair.turns+=result.turns
    result["reversed"]=reversed
    pair.games.append(result)
   pair["average_turns"]=pair.turns/10.0
   results.append(pair)
   print("%s x %s: %d–%d, empates %d, sem conclusão %d" % [pair.a,pair.b,pair.a_wins,pair.b_wins,pair.draws,pair.unfinished])
 var report={"method":"IA do jogo nos dois lados; mulligan de cartas com custo 4 ou mais; iniciativa alternada; dez partidas por confronto; baralhos salvos atuais.","decks":decks,"results":results,"wins":wins,"games_played":played}
 var file=FileAccess.open("res://docs/simulacao-atual-150-partidas.json",FileAccess.WRITE)
 file.store_string(JSON.stringify(report,"  "));file.close()
 print("Total: 150 partidas. Vitórias: ",wins)
 quit()
