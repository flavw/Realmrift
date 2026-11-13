extends SceneTree
const Match=preload("res://scripts/match.gd")
const Items=preload("res://scripts/adventure_items.gd")
func fixture():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.deck=Match.default_deck(0)
 return m
func _initialize() -> void:
 var data: CardData=Match.CARD_DATA.scarred_troll
 assert(data.faction==CardData.Faction.HORDE and data.cost==3 and data.wounded_entry)
 assert(data.attack==4 and data.health==5 and data.regeneration==1)
 assert(data.ability_entries().any(func(e):return e.badge=="WoundedEntry"))
 assert(not Match.faction_allowed(CardData.Faction.NECROPOLIS,data.faction))
 for side in [0,1]:
  var m=fixture();m.turn=side;m.players[side].mana=3;m.players[side].hand=["scarred_troll"]
  assert(m.play(side,0))
  var troll: Dictionary=m.players[side].board[0]
  assert(troll.health==1 and troll.max_health==5 and m.players[side].mana==0)
  assert(m.end_turn(side) and troll.health==2)
  assert(m.end_turn(1-side) and troll.health==2)
  assert(m.end_turn(side) and troll.health==3)
  for i in range(4):assert(m.end_turn(1-side) and m.end_turn(side))
  assert(troll.health==5 and troll.max_health==5)
  # Direct summons follow the same rule, while ordinary creatures keep full life.
  m=fixture();troll=m.spawn_unit(side,"scarred_troll")
  assert(troll.health==1 and troll.max_health==5)
  var ordinary=m.spawn_unit(side,"marsh_troll")
  assert(ordinary.health==5)
 # Equipment and farm bonuses increase maximum life, never entry life.
 var enhanced=Items.enhance("scarred_troll","heart")
 var m=fixture();m.adventure_rules={"enabled":true,"farm_blessing":true,"equipment":[enhanced]}
 var troll=m.spawn_unit(0,enhanced)
 assert(troll.health==1 and troll.max_health==9 and troll.wounded_entry)
 # Wounded entry is not damage: it neither spends protection nor affects health bonuses.
 Match.CARD_DATA[enhanced].antimagic=1;Match.CARDS[enhanced]=Match.CARD_DATA[enhanced].combat_data()
 troll=m.spawn_unit(0,enhanced)
 assert(troll.health==1 and troll.antimagic==1)
 print("OK: Ferido ao jogar/invocar, ambos os lados, Regeneração até o máximo e bônus da aventura.")
 quit()
