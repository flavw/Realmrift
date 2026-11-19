extends SceneTree
const Match=preload("res://scripts/match.gd")
const Rules=preload("res://scripts/network_duel.gd")
func fixture(side: int=0):
 var m=Match.new([],[],side,false,{},["Host","Convidado"])
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10;p.max_mana=10
 return m
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var m=Match.new([],[],0,true,{},["Host","Convidado"])
 m.castle_traps=[[{"remaining":2,"damage":5}],[{"remaining":1,"damage":5}]]
 for side in [0,1]:
  var state:=Rules.view(m,side)
  assert(state.players[0].hand==m.players[side].hand)
  assert(state.players[1].hand.all(func(key):return key==""))
  assert(state.players[0].deck.all(func(key):return key==""))
  assert(state.players[1].deck.all(func(key):return key==""))
  assert(state.castle_traps[0][0].remaining==m.castle_traps[side][0].remaining)
  assert(state.castle_traps[1][0].remaining==0)
  assert(state.first_player==side and state.mulligan_done==[false,false])
  for line in state.history:assert(not line.contains("IA") and (not line.contains("compra") or line.contains("uma carta")))
  var local=fixture();Rules.apply_view(local,state)
  assert(local.players[0].hand==m.players[side].hand and local.opening)
 assert(m.castle_traps[0][0].remaining==2 and m.players[1].hand.all(func(key):return key!=""))
 var nested: Dictionary=Rules.map_records({"side":1,"target_side":0,"target":1,"hits":[{"side":1,"id":0}]},1)
 assert(nested.side==0 and nested.target_side==1 and nested.target==1 and nested.hits[0].side==0 and nested.hits[0].id==0)
 for side in [0,1]:
  m=fixture(side);m.players[side].hand=["squire"]
  assert(Rules.execute(m,side,{"kind":"play","hand":0}))
  assert(m.players[side].board.size()==1 and m.players[1-side].board.is_empty())
  assert(not Rules.execute(m,1-side,{"kind":"end_turn"}))
  var actor=m.spawn_unit(side,"wizard_apprentice");actor.ready=true
  assert(Rules.execute(m,side,{"kind":"act","index":1,"target":-1,"target_side":1,"magical":true}))
  assert(m.players[1-side].hp==19)
  m.players[side].hand=["alley_ambush"]
  assert(not Rules.execute(m,side,{"kind":"cast","hand":0,"target_side":0,"target":-1}))
  assert(Rules.execute(m,side,{"kind":"cast","hand":0,"target_side":0,"target":-1,"trap_choice":2}))
  assert(m.castle_traps[side][0].remaining==2 and Rules.view(m,1-side).castle_traps[1][0].remaining==0)
  m=fixture(side);actor=m.spawn_unit(side,"cleric");actor.ready=true
  var ally=m.spawn_unit(side,"squire");ally.health=1
  assert(Rules.execute(m,side,{"kind":"heal","index":0,"target":1,"target_side":0}) and ally.health==2)
  m=fixture(side);m.players[side].hand=["magic_missiles"]
  var enemy=m.spawn_unit(1-side,"rotting_guardian")
  assert(Rules.execute(m,side,{"kind":"cast_multiple","hand":0,"targets":[{"side":1,"index":0},{"side":1,"index":-1}]}))
  assert(enemy.health==5 and m.players[1-side].hp==18)
  assert(Rules.execute(m,side,{"kind":"surrender"}) and m.winner==1-side)
 for command in [{},{"kind":"unknown"},{"kind":"act","index":"1"},{"kind":"mulligan","indices":[-1]},{"kind":"cast_multiple","targets":[{"side":2,"index":0},{}]}]:assert(not Rules.valid_command(command))
 var session=root.get_node("DuelNetwork")
 assert(not session.valid_profile({"cards":["adventure_black_dragon"],"name":"x","deck_name":"x"}))
 assert(session.valid_profile(session.profile(Match.default_deck(0),"Vanguarda","Host")))
 assert(session.host(80,session.profile(Match.default_deck(0),"Vanguarda","Host"))==ERR_INVALID_PARAMETER)
 print("OK: projeção dos dois jogadores, privacidade, validação de comandos, alvos aliados/inimigos, magias e decks.")
 quit()
