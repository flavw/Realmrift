extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func fixture():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10;p.hp=20;p.deck=Match.default_deck(0)
 return m
func _initialize():call_deferred("verify")
func verify():
 var caller:CardData=Match.CARD_DATA.orc_mine_caller
 var miner:CardData=Match.CARD_DATA.orc_miner
 assert(caller.cost==4 and caller.attack==3 and caller.health==3 and caller.faction==CardData.Faction.RUIN)
 assert(miner.attack==1 and miner.health==2 and miner.turn_castle_damage==1 and not miner.collectible)
 assert(caller.entry_summary().contains("Orc Mineiro 1/2") and miner.ability_entries().any(func(e):return e.get("badge","")=="Mining"))
 assert(Store.accepts_base(CardData.Faction.RUIN,["orc_mine_caller"]) and not Store.accepts_base(CardData.Faction.RUIN,["orc_miner"]))
 for side in [0,1]:
  var m=fixture();m.turn=side;m.players[side].hand=["orc_mine_caller"]
  assert(m.play(side,0) and m.players[side].board.size()==2)
  var token=m.players[side].board[1]
  assert(token.key=="orc_miner" and not token.ready and m.players[0].hp==20 and m.players[1].hp==20)
  assert(m.end_turn(side) and m.players[0].hp==20 and m.players[1].hp==20)
  assert(m.end_turn(1-side) and m.players[0].hp==19 and m.players[1].hp==19 and token.ready and m.last_action.turn_castle_hits.size()==2)
  m=fixture();m.turn=side
  for i in range(5):m.spawn_unit(side,"farmer")
  m.players[side].hand=["orc_mine_caller"];assert(m.play(side,0) and m.players[side].board.size()==6)
  assert(not m.players[side].board.any(func(u):return u.key=="orc_miner"))
  m=fixture();m.turn=side;m.spawn_unit(side,"orc_miner");m.spawn_unit(side,"orc_miner")
  m.players[side].armor=1;m.begin_turn()
  assert(m.players[side].hp==20 and m.players[1-side].hp==18 and m.last_action.turn_castle_hits.size()==4)
  m=fixture();m.turn=side;m.spawn_unit(side,"orc_miner");m.players[0].hp=1;m.players[1].hp=1;m.begin_turn()
  assert(m.winner==2 and m.players[0].hp==0 and m.players[1].hp==0)
  m=fixture();m.turn=side;m.spawn_unit(side,"orc_miner");m.players[side].hp=1;m.begin_turn()
  assert(m.winner==1-side)
 var familiar_game=fixture();familiar_game.turn=0;familiar_game.players[0].hand=["aether_summoner"]
 assert(familiar_game.play(0,0) and familiar_game.players[0].board[1].key=="runic_familiar")
 var m=fixture();m.turn=1;m.players[1].hand=["orc_mine_caller"]
 assert(m.ai_step() and m.players[1].board.size()==2 and m.players[1].board[1].key=="orc_miner")
 print("OK: invocação, ambos os turnos, Armadura, campo cheio, dano múltiplo, vitórias, empate e IA.")
 quit()
