extends "res://tools/simulate_saved_600.gd"
func run() -> void:
 var source=JSON.parse_string(FileAccess.get_file_as_string("res://docs/decks-mago-ressonancia-temporaria.json"))
 var previous=JSON.parse_string(FileAccess.get_file_as_string("res://docs/simulacao-600-decks-atuais.json"))
 var decks: Array=source.slots
 for d in decks:assert(Match.valid_deck(d.cards),d.name)
 var mage_index: int=-1
 for i in range(decks.size()):
  if int(decks[i].base_class)==CardData.CardClass.MAGE:mage_index=i
 assert(mage_index>=0)
 var pairs: Array=[]
 var wins:=0
 var first_wins:=0
 var total_turns:=0
 var unfinished:=0
 var draws:=0
 for opponent in range(decks.size()):
  if opponent==mage_index:continue
  var i: int=mini(opponent,mage_index)
  var j: int=maxi(opponent,mage_index)
  var pair: Dictionary={"opponent":decks[opponent].name,"opponent_class":decks[opponent].base_class,"mage_wins":0,"opponent_wins":0,"draws":0,"unfinished":0,"games":[]}
  for n in range(40):
   var inverted: bool=n%4>=2
   var starter: int=n%2
   var result: Dictionary=game(decks[j].cards if inverted else decks[i].cards,decks[i].cards if inverted else decks[j].cards,starter,202610316000+i*100000+j*1000+n)
   var mage_side: int=0 if (mage_index==i)!=inverted else 1
   if result.winner==-1:pair.unfinished+=1;unfinished+=1
   elif result.winner==2:pair.draws+=1;draws+=1
   elif result.winner==mage_side:pair.mage_wins+=1;wins+=1
   else:pair.opponent_wins+=1
   if result.winner==starter:first_wins+=1
   total_turns+=result.turns
   result["mage_side"]=mage_side
   pair.games.append(result)
  for old in previous.pairs:
   if old.a_index==i and old.b_index==j:
    pair["previous_mage_wins"]=old.a_wins if mage_index==i else old.b_wins
  pairs.append(pair)
  print("Mago x %s: %d-%d; antes %d/40; empates %d; sem conclusão %d" % [pair.opponent,pair.mage_wins,pair.opponent_wins,pair.previous_mage_wins,pair.draws,pair.unfinished])
 var report={"method":"Ressonância até início do próximo turno do dono, vida mínima 1 na expiração; IA atual nos dois lados; 40 jogos por oponente; mesmas sementes, lados e iniciativa do ensaio anterior.","source":source,"mage_index":mage_index,"pairs":pairs,"mage_wins":wins,"games":200,"draws":draws,"unfinished":unfinished,"total_turns":total_turns,"first_wins":first_wins}
 var file=FileAccess.open("res://docs/simulacao-mago-ressonancia-temporaria.json",FileAccess.WRITE)
 assert(file!=null);file.store_string(JSON.stringify(report,"  "));file.close()
 print("TOTAL Mago ",wins,"/200, turnos ",total_turns," primeira iniciativa ",first_wins)
 quit()
