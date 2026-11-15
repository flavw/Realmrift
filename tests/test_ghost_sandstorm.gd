extends SceneTree
const Match=preload("res://scripts/match.gd")
func fixture():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10;p.hp=20
 return m
func _initialize():call_deferred("verify")
func verify():
 var ghost: CardData=Match.CARD_DATA.necropolis_ghost
 assert(ghost.ephemeral and ghost.flying and ghost.faction==CardData.Faction.NECROPOLIS and ghost.cost==3)
 assert(ghost.ability_entries().any(func(e):return e.name=="Efêmero"))
 assert(Match.CARD_DATA.luminary_healer.faction==CardData.Faction.CLERIC)
 var store=load("res://scripts/deck_store.gd")
 assert(store.accepts_base(CardData.Faction.NECROPOLIS,["necropolis_ghost","wastes_sandstorm"]))
 assert(store.accepts_base(CardData.Faction.CLERIC,["luminary_healer"]))
 assert(not store.accepts_base(CardData.Faction.CLERIC,["wastes_sandstorm"]))
 for side in [0,1]:
  var m=fixture();m.turn=side
  var unit=m.spawn_unit(side,"necropolis_ghost");unit.ready=true
  assert(m.act(side,0,-1) and m.players[side].board.is_empty() and m.players[1-side].hp==16)
  m=fixture();m.turn=side
  var attacker=m.spawn_unit(side,"farmer");attacker.ready=true;attacker.attack=1
  var defender=m.spawn_unit(1-side,"necropolis_ghost");defender.health=10
  assert(m.act(side,0,0) and m.players[1-side].board.is_empty())
  m=fixture();m.turn=side
  var mage=m.spawn_unit(side,"mage");mage.ready=true
  defender=m.spawn_unit(1-side,"necropolis_ghost");defender.health=5;defender.max_health=5
  assert(m.act(side,0,0,true) and defender.health==4 and m.players[1-side].board.has(defender))
  m=fixture();m.turn=side
  var ally=m.spawn_unit(side,"wolf");ally.health=5;ally.max_health=5
  var other=m.spawn_unit(side,"farmer");other.health=5;other.max_health=5;other.armor=9
  var enemy=m.spawn_unit(1-side,"squire");enemy.health=5;enemy.max_health=5;enemy.antimagic=1
  var enemy_wastes=m.spawn_unit(1-side,"wolf");enemy_wastes.health=5
  m.players[side].hand=["wastes_sandstorm"]
  assert(m.cast(side,0,side,-1))
  assert(m.players[0].hp==18 and m.players[1].hp==18)
  assert(ally.health==5 and enemy_wastes.health==5 and other.health==3 and enemy.health==5 and enemy.antimagic==0)
  assert(m.last_action.area_hits.size()==4)
 var immune_game=fixture();immune_game.turn=0
 var immune=immune_game.spawn_unit(1,"wild_badger");var hp: int=immune.health
 immune_game.players[0].hand=["wastes_sandstorm"]
 assert(immune_game.cast(0,0,0,-1) and immune.health==hp)
 var ai=fixture();ai.turn=1
 var enemy=ai.spawn_unit(0,"farmer");enemy.health=1
 ai.spawn_unit(1,"wolf")
 ai.players[1].hand=["wastes_sandstorm"]
 assert(ai.ai_spell_target(0)=={"side":1,"index":-1})
 print("OK: Efêmero no ataque e defesa; Tempestade nos dois lados, castelos, Armadura e Antimagia.")
 quit()
