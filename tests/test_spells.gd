extends SceneTree
const Match=preload("res://scripts/match.gd")
func unit(key: String, id: int, ready: bool = true) -> Dictionary:
 var u: Dictionary=Match.CARDS[key].duplicate(true)
 u.merge({"key":key,"id":id,"ready":ready,"max_health":u.health})
 return u
func fixture():
 var m=Match.new()
 m.players[0].board=[]
 m.players[1].board=[]
 m.players[0].mana=10
 m.players[0].hand=[]
 return m
func _init() -> void:
 assert(Match.CARD_DATA.size()==47)
 for style in range(3):
  assert(Match.valid_deck(Match.default_deck(style)))
 for key in ["iron_stance","astral_flame","shadow_step","restoring_light"]:
  assert(Match.CARD_DATA[key].card_type==CardData.CardType.SPELL)
 var m=fixture()
 m.players[0].board=[unit("warrior",10,false)]
 m.players[0].hand=["iron_stance"]
 assert(not m.play(0,0),"Magia não entra no campo como criatura")
 assert(not m.cast(0,0,1,-1) and m.players[0].mana==10 and m.players[0].hand.size()==1)
 assert(m.cast(0,0,0,0))
 assert(m.players[0].board[0].attack==4 and m.players[0].board[0].armor==3 and m.players[0].board[0].block==1 and m.block_capacity(m.players[0].board[0])==1)
 assert(not m.players[0].board[0].ready and m.players[0].mana==8 and m.players[0].hand.is_empty())
 m=fixture()
 m.players[0].board=[unit("runic_familiar",11)]
 var tank=unit("wall_guard",12)
 tank.armor=20
 m.players[1].board=[tank]
 m.players[0].hand=["astral_flame"]
 assert(m.magic_bonus(0)==1)
 assert(not m.cast(0,0,1,-1),"Chama Astral não atinge castelo")
 assert(m.cast(0,0,1,0))
 assert(m.players[1].board.is_empty(),"3+1 mágico ignora armadura e mata vida 4")
 assert(tank.block==2,"Magia não consome Bloqueio")
 assert(m.last_action.dead.size()==1 and m.players[0].board[0].health==3)
 m=fixture()
 m.players[0].board=[unit("mage",13),unit("runic_familiar",14)]
 tank=unit("wall_guard",15)
 m.players[1].board=[tank]
 assert(m.act(0,0,0,true))
 assert(tank.health==2,"Amplificar também afeta Disparo Arcano")
 m.players[0].board.remove_at(1)
 assert(m.magic_bonus(0)==0,"Aura termina ao sair do campo")
 m.players[0].board[0].ready=true
 assert(m.act(0,0,0,true) and tank.health==1)
 assert(Match.CARD_DATA.mage.ability_entries(-1,1)[0].name=="Disparo Arcano 2")
 m=fixture()
 m.players[0].board=[unit("lightning_rogue",16,false)]
 m.players[0].hand=["shadow_step"]
 assert(m.cast(0,0,0,0))
 assert(m.players[0].board[0].ready and m.players[0].board[0].attack==4)
 assert(m.act(0,0,-1) and m.players[1].hp==16)
 m=fixture()
 var grown=unit("farmer",17,false)
 grown.max_health=6
 grown.health=3
 m.players[0].board=[grown]
 m.players[0].hand=["restoring_light","restoring_light"]
 assert(m.cast(0,0,0,0) and grown.health==6)
 assert(not grown.ready,"Cura de carta não prepara nem esgota criaturas")
 assert(not m.cast(0,0,0,0) and m.players[0].mana==8)
 assert(not m.cast(0,0,1,-1))
 m.players[0].hp=17
 assert(m.cast(0,0,0,-1) and m.players[0].hp==20)
 m=fixture()
 for i in range(Match.MAX_BOARD):m.players[0].board.append(unit("squire",30+i))
 m.players[0].hand=["iron_stance"]
 assert(m.has_spell_target(0,0) and m.cast(0,0,0,0))
 assert(m.players[0].board.size()==Match.MAX_BOARD,"Magia funciona em campo cheio e não ocupa espaço")
 m=fixture()
 m.players[0].board=[unit("wall_guard",40)]
 m.players[0].board[0].block=0
 m.begin_turn()
 assert(m.players[0].board[0].block==1,"Bloqueio 2 recupera só 1")
 m=fixture()
 m.turn=1
 m.players[1].mana=3
 m.players[1].hand=["astral_flame"]
 m.players[0].board=[unit("mage",41)]
 assert(m.ai_step() and m.players[0].board.is_empty())
 m=fixture()
 m.turn=1
 m.players[1].mana=2
 m.players[1].hand=["shadow_step"]
 m.players[1].board=[unit("lightning_rogue",42,false)]
 assert(m.ai_step() and m.players[1].board[0].ready)
 assert(m.ai_step() and m.players[0].hp==16)
 print("OK: 47 recursos, magias, alvos, custos, aura, buffs, preparo, cura, campo cheio e IA.")
 quit()
