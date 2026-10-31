extends SceneTree
const Match=preload("res://scripts/match.gd")
func fixture():
 var m=Match.new()
 for p in m.players:p.board=[];p.hand=[];p.mana=10
 m.players[0].hand=["secrets_dealer"]
 return m
func _init() -> void:
 assert(Match.CARD_DATA.venom_rooftop.loot==0)
 for choice in ["loot","envenom"]:
  var amount: int=1 if choice=="loot" else 2
  var m=fixture()
  var ally=m.spawn_unit(0,"rooftop_leaper")
  assert(not m.play(0,0,0) and m.players[0].hand.size()==1)
  assert(not m.play(0,0,1,choice))
  assert(m.play(0,0,0,choice))
  assert(ally[choice]==amount and m.players[0].board[1][choice]==0 and m.players[0].mana==8)
  assert(m.card_for_unit(ally).get(choice)==amount)
  m.players[0].hand=["secrets_dealer"]
  assert(m.play(0,0,0,choice) and ally[choice]==amount*2)
  assert(Match.CARD_DATA.rooftop_leaper.get(choice)==0)
 var m=fixture()
 assert(m.play(0,0) and m.players[0].board.size()==1)
 m=fixture();m.turn=1;m.players[1].hand=["secrets_dealer"];m.players[1].deck=["wolf"]
 var ally=m.spawn_unit(1,"rooftop_leaper")
 assert(m.ai_step() and ally.loot==1)
 print("OK: escolha, acúmulo, alvo aliado, sem aliado, exibição e IA; Sombra sem Saquear")
 quit()
