extends SceneTree
const Match=preload("res://scripts/match.gd")
const CardSkinTest=preload("res://scripts/card_skin.gd")
func game():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10
 return m
func _initialize():
 var card:CardData=Match.CARD_DATA.mist_alchemist
 assert(card.stealth and card.antimagic==0 and card.ability_entries().any(func(e):return e.get("badge","")=="Stealth"))
 assert(CardSkinTest.texture("stealth-icon")!=null)
 for side in [0,1]:
  var m=game();m.turn=side
  var hero=m.spawn_unit(side,"warrior");hero.ready=true
  var hidden=m.spawn_unit(1-side,"mist_alchemist");hidden.health=8;hidden.max_health=8
  assert(not m.can_target(side,0,0) and not m.can_target(side,0,0,true))
  m.players[side].hand=["astral_flame","magic_missiles"]
  assert(not m.can_cast(side,0,1-side,0) and not m.can_cast(side,1,1-side,0))
  m.players[side].hand=["mist_alchemist"]
  assert(m.entry_valid_targets(side,Match.CARDS.mist_alchemist).is_empty() and m.play(side,0,-1))
  m=game();m.turn=side
  var priest=m.spawn_unit(side,"cleric");priest.ready=true
  var ally=m.spawn_unit(side,"mist_alchemist");ally.health=1
  assert(not m.can_heal(side,0,1,side))
  m.players[side].hand=["iron_stance"]
  assert(not m.can_cast(side,0,side,1))
  m=game();m.turn=side
  hidden=m.spawn_unit(1-side,"mist_alchemist");hidden.health=8;hidden.max_health=8
  m.players[side].hand=["fireball"]
  assert(m.cast(side,0,1-side,-1) and hidden.health<8 and hidden.stealth)
  m=game();m.turn=side
  hidden=m.spawn_unit(side,"mist_alchemist");hidden.ready=true
  assert(m.card_for_unit(hidden).stealth)
  assert(m.act(side,0,-1) and not hidden.stealth and not m.card_for_unit(hidden).stealth)
  m.end_turn(side);m.end_turn(1-side)
  assert(not hidden.stealth)
  m=game();m.turn=side
  hero=m.spawn_unit(side,"warrior");hero.ready=true
  hidden=m.spawn_unit(1-side,"mist_alchemist");hidden.block=1;hidden.reach=true
  assert(m.blockers(1-side).is_empty() and m.can_target(side,0,-1))
  m=game();m.turn=side
  var worm=m.spawn_unit(side,"wastes_ancient_worm")
  hidden=m.spawn_unit(1-side,"mist_alchemist")
  assert(m.automatic_hunt_targets(side,0).is_empty())
 var stalker: CardData=Match.CARD_DATA.wastes_anubite_stalker
 assert(stalker.cost==5 and stalker.attack==5 and stalker.health==3 and stalker.stealth and stalker.faction==CardData.Faction.WASTES and stalker.creature_type==CardData.CreatureType.MONSTER)
 var check=game();check.turn=0
 var unit=check.spawn_unit(0,"wastes_anubite_stalker");unit.ready=true
 check.spawn_unit(0,"wastes_jackal_leader")
 assert(Match.physical_attack(unit)==6 and check.card_for_unit(unit).stealth)
 assert(check.act(0,0,-1) and not unit.stealth and not check.card_for_unit(unit).stealth)
 assert(load("res://scripts/main.gd")!=null)
 print("OK: Furtivo, seleção, dano em área, ataque, Bloqueio, ícone, caçada e ambos os lados.")
 quit()

