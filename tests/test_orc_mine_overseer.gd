extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func fresh():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10;p.deck=Match.default_deck(0)
 return m
func _initialize():call_deferred("verify")
func verify():
 var card:CardData=Match.CARD_DATA.orc_mine_overseer
 assert(card.cost==3 and card.attack==3 and card.health==3 and card.creature_type==CardData.CreatureType.MONSTER)
 assert(card.entry_needs_target() and Store.accepts_base(CardData.Faction.RUIN,["orc_mine_overseer"]))
 assert(card.ability_entries().any(func(e):return e.name=="Chamado" and e.description.contains("dano físico")))
 for side in [0,1]:
  var m=fresh();m.turn=side;m.players[side].hand=["orc_mine_overseer"]
  assert(m.play(side,0) and m.players[side].board.size()==1)
  m=fresh();m.turn=side
  var ally=m.spawn_unit(side,"farmer");ally.health=3;ally.armor=0
  m.spawn_unit(1-side,"farmer");m.players[side].hand=["orc_mine_overseer"]
  assert(not m.can_play(side,0,-1) and m.can_play(side,0,0) and m.play(side,0,0))
  assert(ally.attack==3 and ally.health==2 and m.last_action.entry_damage[0].amount==1)
  m=fresh();m.turn=side;ally=m.spawn_unit(side,"squire");ally.health=4;ally.armor=1
  m.players[side].hand=["orc_mine_overseer"];assert(m.play(side,0,0) and ally.health==4 and ally.attack==3)
  m=fresh();m.turn=side;ally=m.spawn_unit(side,"goblin_raider");ally.health=1
  m.players[side].hand=["orc_mine_overseer"];assert(m.play(side,0,0) and not m.players[side].board.has(ally) and m.last_action.dead.size()==1)
 var ai=fresh();ai.turn=1
 var weak=ai.spawn_unit(1,"goblin_raider");weak.health=1
 var strong=ai.spawn_unit(1,"farmer");strong.health=3
 ai.players[1].hand=["orc_mine_overseer"]
 assert(ai.entry_target(1,Match.CARDS.orc_mine_overseer)==1)
 assert(ai.ai_step() and strong.attack==3 and strong.health==2)
 print("OK: orc da Horda, seleção, dano, Armadura, morte, ausência de alvo e IA.")
 quit()
