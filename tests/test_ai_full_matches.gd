extends "res://tools/simulate_current_decks.gd"
func run() -> void:
 var decks=JSON.parse_string(FileAccess.get_file_as_string("res://docs/decks-simulacao-atual.json"))
 var total:=0
 for i in range(6):
  for j in range(i+1,6):
   for k in range(2):
    var outcome=game(decks[i].cards,decks[j].cards,k,2026103100+i*1000+j*100+k)
    assert(outcome.winner in [0,1,2],"A partida deve chegar ao fim")
    total+=1
 print("OK: ",total," partidas completas entre os seis decks.")
 quit()
