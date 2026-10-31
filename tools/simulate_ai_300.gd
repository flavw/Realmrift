extends "res://tools/simulate_current_decks.gd"
func run() -> void:
 var decks=JSON.parse_string(FileAccess.get_file_as_string("res://docs/decks-simulacao-ia-2026-10-31.json"))
 assert(decks is Array and decks.size()==6)
 for deck in decks:assert(Match.valid_deck(deck.cards),deck.name)
 var wins: Array=[0,0,0,0,0,0]
 var played: Array=[0,0,0,0,0,0]
 var first_wins:=0
 var draws:=0
 var unfinished:=0
 var total_turns:=0
 var pairs: Array=[]
 for i in range(6):
  for j in range(i+1,6):
   var pair: Dictionary={"a":decks[i].name,"b":decks[j].name,"a_wins":0,"b_wins":0,"draws":0,"unfinished":0,"turns":0,"games":[]}
   for n in range(20):
    var inverted: bool=n%4>=2
    var starter: int=n%2
    var run_seed: int=2026110100+i*100000+j*1000+n
    var result: Dictionary=game(decks[j].cards if inverted else decks[i].cards,decks[i].cards if inverted else decks[j].cards,starter,run_seed)
    var winner: int=result.winner
    if winner==-1:
     pair.unfinished+=1;unfinished+=1
    elif winner==2:
     pair.draws+=1;draws+=1
    else:
     if winner==starter:first_wins+=1
     if (winner==1 if inverted else winner==0):pair.a_wins+=1;wins[i]+=1
     else:pair.b_wins+=1;wins[j]+=1
    played[i]+=1;played[j]+=1
    pair.turns+=result.turns;total_turns+=result.turns
    result["inverted"]=inverted
    result["seed"]=run_seed
    pair.games.append(result)
   pairs.append(pair)
   print("%s × %s: %d–%d; empates %d; sem conclusão %d" % [pair.a,pair.b,pair.a_wins,pair.b_wins,pair.draws,pair.unfinished])
 var report={"method":"IA atual nos dois lados; mulligan troca custo 4 ou mais; 20 partidas por confronto; lados e iniciativa alternados.","decks":decks,"pairs":pairs,"wins":wins,"played":played,"first_wins":first_wins,"draws":draws,"unfinished":unfinished,"total_turns":total_turns}
 var file=FileAccess.open("res://docs/simulacao-ia-2026-10-31.json",FileAccess.WRITE)
 assert(file!=null)
 file.store_string(JSON.stringify(report,"  "));file.close()
 print("TOTAL ",wins," primeira iniciativa ",first_wins," empate ",draws," sem conclusão ",unfinished," turnos ",total_turns)
 quit()
