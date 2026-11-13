extends SceneTree
const Match=preload("res://scripts/match.gd")
func fixture():
 var m=Match.new()
 for p in m.players:
  p.board.clear();p.hand.clear();p.deck=Match.default_deck(0)
 return m
func _initialize() -> void:
 var data: CardData=Match.CARD_DATA.dwarf_smith
 assert(data.cost==3 and data.attack==0 and data.health==4)
 assert(data.faction==CardData.Faction.WARRIOR and data.creature_type==CardData.CreatureType.DWARF)
 assert(data.creature_type_name()=="Anão" and data.ability_entries().any(func(e):return e.badge=="Forge"))
 for side in [0,1]:
  var m=fixture();m.turn=side
  var smith=m.spawn_unit(side,"dwarf_smith")
  assert(m.end_turn(side) and smith.attack==0)
  m.turn=side
  var ally=m.spawn_unit(side,"crypt_zombie")
  var enemy=m.spawn_unit(1-side,"crypt_zombie")
  assert(m.end_turn(side) and ally.attack==3 and ally.health==2 and enemy.attack==2 and smith.attack==0)
  assert(m.last_action.end_turn_buffs.size()==1)
  assert(not m.last_action.end_turn_buffs[0].castle and m.last_action.end_turn_buffs[0].amount==1)
  assert(m.end_turn(1-side) and ally.attack==3)
  assert(m.end_turn(side) and ally.attack==4)
  # One recipient among multiple candidates; every copy triggers independently.
  m=fixture();m.turn=side;m.spawn_unit(side,"dwarf_smith")
  var a=m.spawn_unit(side,"crypt_zombie");var b=m.spawn_unit(side,"crypt_zombie")
  assert(m.end_turn(side) and a.attack+b.attack==5)
  m=fixture();m.turn=side
  a=m.spawn_unit(side,"dwarf_smith");b=m.spawn_unit(side,"dwarf_smith")
  assert(m.end_turn(side) and a.attack==1 and b.attack==1)
  # A smith killed by end-turn poison cannot forge afterwards.
  m=fixture();m.turn=side;smith=m.spawn_unit(side,"dwarf_smith");smith.health=1;smith.poison=1
  ally=m.spawn_unit(side,"crypt_zombie")
  assert(m.end_turn(side) and ally.attack==2)
 print("OK: Ferreiro Anão, Forjar em ambos os lados, alvos, permanência, múltiplas cópias e morte.")
 quit()
