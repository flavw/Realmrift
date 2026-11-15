extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func fixture():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10
 return m
func _initialize():
 var guide: CardData=Match.CARD_DATA.wastes_caravan_guide
 var camel: CardData=Match.CARD_DATA.wastes_camel
 assert(guide.cost==4 and guide.attack==3 and guide.health==2 and guide.faction==CardData.Faction.WASTES and guide.creature_type==CardData.CreatureType.HUMAN)
 assert(camel.attack==1 and camel.health==3 and camel.block==1 and camel.faction==CardData.Faction.WASTES and camel.creature_type==CardData.CreatureType.BEAST and not camel.collectible)
 assert(guide.entry_summary().contains("Camelo 1/3 com Bloqueio 1"))
 assert(Store.accepts_base(CardData.Faction.WASTES,["wastes_caravan_guide"]) and not Store.accepts_base(CardData.Faction.WASTES,["wastes_camel"]))
 for side in [0,1]:
  var m=fixture();m.turn=side;m.players[side].hand=["wastes_caravan_guide"]
  assert(m.play(side,0) and m.players[side].board.size()==2)
  var token=m.players[side].board[1]
  assert(token.key=="wastes_camel" and token.block==1 and not token.ready)
  assert(m.blockers(side)==[1] and m.last_action.spawned[0].id==token.id)
  token.block=0;m.turn=side;m.begin_turn();assert(token.block==1)
  m=fixture();m.turn=side
  for i in range(5):m.spawn_unit(side,"farmer")
  m.players[side].hand=["wastes_caravan_guide"]
  assert(m.play(side,0) and m.players[side].board.size()==6)
  assert(not m.players[side].board.any(func(u):return u.key=="wastes_camel"))
 var m=fixture();m.turn=1;m.players[1].hand=["wastes_caravan_guide"]
 assert(m.ai_step() and m.players[1].board.size()==2 and m.players[1].board[1].key=="wastes_camel")
 print("OK: guia, Chamado, Bloqueio, campo cheio, facção, deck e IA.")
 quit()
