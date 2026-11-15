extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize(): call_deferred("verify")
func verify():
 var card: CardData=Match.CARD_DATA.luminary_healer
 assert(card.cost==3 and card.attack==2 and card.health==2 and card.heal_amount==0 and card.devotion==1)
 assert(card.entry_effect==CardData.EntryEffect.HEAL_ALLIES and card.entry_value==1 and not card.entry_needs_target())
 for side in [0,1]:
  var m=Match.new();m.turn=side
  for p in m.players:p.board.clear();p.hand.clear();p.mana=10
  var a=m.spawn_unit(side,"farmer");a.health=1;a.poison=1;a.bleeding=1
  var b=m.spawn_unit(side,"squire");b.health=1
  var wall=m.spawn_unit(side,"village_wall");wall.health=1
  var undead=m.spawn_unit(side,"zombie_helper");undead.health=1;undead.antimagic=0
  var enemy=m.spawn_unit(1-side,"farmer");enemy.health=1
  m.players[side].hand=["luminary_healer"]
  assert(m.play(side,0))
  var guardian=m.players[side].board.back()
  assert(a.health==2 and a.poison==0 and a.bleeding==0 and b.health==2)
  assert(wall.health==1 and enemy.health==1 and not m.players[side].board.has(undead))
  assert(guardian.attack==5 and guardian.health==5 and guardian.max_health==5)
  assert(m.last_action.healed.size()==2 and m.last_action.entry_damage.size()==1 and m.last_action.devotion_buffs.size()==3)
 print("OK: Chamado de cura, ambos os lados, Devoção, Morto-vivo, Muralha e efeitos removidos.")
 quit()
