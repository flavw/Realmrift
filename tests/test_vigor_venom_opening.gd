extends SceneTree
const Match=preload("res://scripts/match.gd")
func unit(key: String,id: int=0) -> Dictionary:
 var u: Dictionary=Match.CARDS[key].duplicate(true)
 u.merge({"key":key,"id":id,"ready":true,"max_health":u.health,"poison":0})
 return u
func game():
 var m=Match.new()
 for p in m.players:
  p.board=[]
  p.hand=[]
  p.mana=10
 return m
func _init() -> void:
 var grant: Dictionary=Match.CARD_DATA.vigor_vow.ability_entries()[0]
 var bolt: Dictionary=Match.CARD_DATA.conductive_bolt.ability_entries(-1,1)[0]
 assert(grant.name=="Conceder Vigor" and "Não acumula" in grant.description)
 assert(bolt.name=="Descarga 3/6" and "dobre o dano para 6" in bolt.description)
 for key in Match.CARD_DATA:
  if Match.CARD_DATA[key].card_type==CardData.CardType.SPELL:
   assert(Match.CARD_DATA[key].ability_entries()[0].name!="Magia","Magias têm resumo e ajuda do efeito escolhido")
 vigor()
 lightning()
 venom()
 opening()
 print("OK: Vigor ofensivo/defensivo, concessão não cumulativa, Descarga/Armadura/Amplificar, Veneno e mulligan 3/4.")
 quit()
func vigor() -> void:
 assert(Match.CARD_DATA.cleric.vigor and Match.CARD_DATA.dawn_warden.vigor)
 assert(Match.CARD_DATA.dawn_warden.block==3)
 var guard_match=game()
 guard_match.players[0].board=[unit("dawn_warden")]
 guard_match.players[1].board=[unit("sentinel",1)]
 guard_match.turn=1
 assert(not guard_match.can_target(1,0,-1) and guard_match.can_target(1,0,0))
 assert(guard_match.act(1,0,0) and guard_match.players[0].board[0].block==2)
 guard_match.end_turn(1)
 assert(guard_match.players[0].board[0].block==3,"Guardião recupera uma carga de Bloqueio")
 var m=game()
 var a=unit("sentinel")
 a.health=10
 var d=unit("cleric",1)
 d.ready=false
 m.players[0].board=[a]
 m.players[1].board=[d]
 assert(m.act(0,0,0))
 assert(d.health==3 and a.health==7,"Vigor usa vida 4 antes do dano; armadura 1 reduz contra-ataque")
 assert(d.attack==1 and Match.defense_attack(d)==3)
 d.health=1
 d.attack=2
 assert(Match.defense_attack(d)==2)
 m=game()
 a=unit("cleric")
 d=unit("wolf",1)
 d.attack=0
 m.players[0].board=[a];m.players[1].board=[d]
 assert(m.act(0,0,0))
 assert(d.health==-2,"Atacar com Vigor usa vida atual 4")
 m=game()
 a=unit("cleric")
 m.players[0].board=[a]
 assert(m.act(0,0,-1) and m.players[1].hp==16)
 a.ready=true;a.health=2
 assert(m.act(0,0,-1) and m.players[1].hp==14,"Ferimentos reduzem força do próximo ataque")
 a.ready=true;a.attack=3;a.health=1
 assert(m.act(0,0,-1) and m.players[1].hp==11,"Vigor nunca reduz ataque base maior")
 m=game()
 a=unit("farmer");a.attack=0;a.health=4
 m.players[0].board=[a];m.players[0].hand=["vigor_vow"]
 assert(m.cast(0,0,0,0) and m.can_target(0,0,-1))
 assert(m.act(0,0,-1) and m.players[1].hp==16,"Vigor concedido funciona ofensivamente em qualquer classe")
 for key in ["fire_mage","eclipse_channeler"]:
  m=game();a=unit(key)
  var target=unit("sentinel",1)
  m.players[0].mana=1;m.players[0].board=[a];m.players[1].board=[target]
  assert(m.act(0,0,0,true) and m.players[0].mana==0 and not a.ready and target.health==1)
  assert(Match.CARD_DATA[key].ability_entries()[0].cost==1,"Disparo Arcano 2 custa uma mana")
 m=game()
 a=unit("mage");d=unit("cleric",1)
 m.players[0].board=[a];m.players[1].board=[d]
 assert(m.act(0,0,0,true))
 assert(a.health==2 and d.health==3,"Magia não provoca Vigor nem contra-ataque")
 m=game()
 a=unit("farmer")
 m.players[0].board=[a];m.players[1].board=[unit("wolf",1)]
 m.players[0].hand=["vigor_vow","vigor_vow"]
 assert(not m.cast(0,0,1,0) and not m.cast(0,0,0,-1))
 assert(m.cast(0,0,0,0) and a.vigor and m.players[0].mana==8)
 assert(not m.cast(0,0,0,0) and m.players[0].mana==8 and m.players[0].hand.size()==1)
 assert(m.end_turn(0) and m.end_turn(1))
 assert(a.health==4 and Match.defense_attack(a)==4 and a.attack==1,"Cultivo atualiza Vigor sem mudar ataque")
func lightning() -> void:
 for armor in [0,1,4]:
  for boost in [0,1]:
   var m=game()
   var d=unit("wall_guard",1)
   d.health=20;d.armor=armor
   m.players[1].board=[d]
   if boost>0:m.players[0].board=[unit("runic_familiar")]
   m.players[0].hand=["conductive_bolt"]
   assert(not m.cast(0,0,0,0) and not m.cast(0,0,1,-1))
   assert(m.cast(0,0,1,0))
   var expected: int=(2+boost)*(2 if armor>0 else 1)
   assert(d.health==20-expected and d.armor==armor and m.players[0].mana==7)
   assert(m.players[0].board.is_empty() or m.players[0].board[0].health==3)
 var m=game()
 var d=unit("farmer",1)
 m.players[0].board=[d];m.players[0].hand=["iron_stance"]
 assert(m.cast(0,0,0,0) and d.armor==1)
 m.turn=1;m.players[1].hand=["conductive_bolt"]
 assert(m.cast(1,0,0,0) and m.players[0].board.is_empty(),"Armadura concedida também dobra o dano")
func venom() -> void:
 assert(Match.CARD_DATA.lightning_rogue.envenom==1 and Match.CARD_DATA.raven.envenom==0)
 var m=game()
 var a=unit("lightning_rogue")
 a.attack=1;a.health=10
 var d=unit("raven",1)
 d.armor=9;d.health=10;d.envenom=1
 m.players[0].board=[a];m.players[1].board=[d]
 assert(m.act(0,0,0))
 assert(d.health==10 and d.poison==1 and a.poison==1,"Veneno aplica mesmo com dano absorvido e no contra-ataque")
 a.ready=true
 assert(m.act(0,0,0) and d.poison==2 and a.poison==2)
 var old_hp: int=d.health
 assert(m.end_turn(0))
 assert(d.health==old_hp and d.poison==2 and a.poison==0,"Só o dono do alvo sofre no fim do próprio turno")
 assert(m.end_turn(1))
 assert(d.health==old_hp-2 and d.poison==0 and d.armor==9)
 m.end_turn(0);m.end_turn(1)
 assert(d.health==old_hp-2 and d.poison==0)
 m=game()
 a=unit("mage");a.envenom=5
 d=unit("cleric",1);d.envenom=5
 m.players[0].board=[a];m.players[1].board=[d]
 assert(m.act(0,0,0,true) and d.poison==0 and a.poison==0)
 m=game()
 a=unit("lightning_rogue");a.health=1
 d=unit("sentinel",1);d.health=10
 m.players[0].board=[a];m.players[1].board=[d]
 assert(m.act(0,0,0) and m.players[0].board.is_empty() and d.poison==1,"Fonte morrer não cancela veneno")
 m=game()
 a=unit("raven")
 m.players[0].board=[a]
 assert(m.act(0,0,-1) and m.players[1].hp==19 and m.players[1].poison==0)
 a.ready=true
 assert(m.act(0,0,-1) and m.players[1].poison==0)
 m.players[1].hp=2
 m.end_turn(0)
 var hand_before: int=m.players[0].hand.size()
 var mana_before: int=m.players[0].max_mana
 assert(m.end_turn(1) and m.winner==-1 and m.turn==0 and m.players[1].hp==2)
 assert(m.players[0].hand.size()==hand_before+1 and m.players[0].max_mana==mini(10,mana_before+1),"Castelo imune não impede próximo turno")
 m=game()
 a=unit("cleric");a.health=2;a.poison=2
 m.players[0].board=[a];m.players[0].hp=18;m.players[0].poison=2
 assert(m.heal(0,0,0) and a.health==4 and a.poison==0)
 m.players[0].board.append(unit("wolf",1))
 m.players[0].board[1].poison=2
 assert(m.end_turn(0) and a.health==4 and a.poison==0 and m.players[0].hp==18 and m.players[0].poison==0)
 assert(m.players[0].board.size()==1 and m.last_action.dead.size()==1)
func sorted_pool(m,side: int) -> Array:
 var result: Array=m.players[side].hand.duplicate()
 result.append_array(m.players[side].deck)
 result.sort()
 return result
func opening() -> void:
 for starter in [0,1]:
  var m=Match.new([],[],starter,true)
  var pools=[sorted_pool(m,0),sorted_pool(m,1)]
  assert(m.opening and m.turn==starter and m.players[starter].hand.size()==3 and m.players[1-starter].hand.size()==4)
  assert(m.players[0].mana==0 and m.players[1].mana==0 and not m.end_turn(starter) and not m.play(starter,0))
  var before: Array=m.players[0].hand.duplicate()
  assert(not m.mulligan(0,[0,0]) and not m.mulligan(0,[-1]) and not m.mulligan(0,[9]) and not m.mulligan(0,[0.0]))
  assert(m.players[0].hand==before)
  assert(m.mulligan(0,[0]) and m.opening and sorted_pool(m,0)==pools[0])
  assert((not m.mulligan(0,[]) if starter==0 else not m.mulligan(0,[0,1])) and not m.play(starter,0))
  assert(m.mulligan(1,[]) and m.opening)
  assert(m.mulligan(1-starter,[]) and not m.opening and m.turn==starter)
  assert(m.players[starter].hand.size()==4 and m.players[1-starter].hand.size()==4)
  assert(m.players[starter].mana==1 and sorted_pool(m,0)==pools[0] and sorted_pool(m,1)==pools[1])
  assert(not m.mulligan(1,[]))
  assert(m.end_turn(starter) and m.players[1-starter].hand.size()==5)
 var m=Match.new([],[],0,true)
 m.players[0].hand=["warrior","mage","wolf"]
 m.players[0].deck=["squire","raven","cleric"]
 assert(m.mulligan(0,[0,2]))
 assert(m.players[0].hand==["cleric","mage","raven"],"Substituições são compradas antes de devolver as cartas escolhidas")
