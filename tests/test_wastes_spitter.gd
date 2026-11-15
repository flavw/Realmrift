extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func game():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10;p.deck=Match.default_deck(0)
 return m
func _initialize():call_deferred("verify")
func verify():
 var card:CardData=Match.CARD_DATA.wastes_spitter
 assert(card.cost==2 and card.attack==1 and card.health==2 and card.faction==CardData.Faction.WASTES and card.creature_type==CardData.CreatureType.BEAST)
 assert(card.entry_needs_target() and Match.entry_target_side(0,card.combat_data())==1)
 assert(Store.accepts_base(CardData.Faction.RUIN,["wastes_spitter"]) and Store.accepts_base(CardData.Faction.NECROPOLIS,["wastes_spitter"]))
 assert(not Store.accepts_base(CardData.Faction.WARRIOR,["wastes_spitter"]))
 for side in [0,1]:
  var m=game();m.turn=side;m.players[side].hand=["wastes_spitter"]
  assert(m.play(side,0) and m.players[side].board.size()==1)
  m=game();m.turn=side;var victim=m.spawn_unit(1-side,"farmer");victim.health=3;victim.block=1;victim.antimagic=1
  m.players[side].hand=["wastes_spitter"]
  assert(not m.can_play(side,0,-1) and m.can_play(side,0,0))
  assert(m.play(side,0,0) and victim.health==2 and victim.block==1 and victim.antimagic==1 and m.last_action.entry_damage[0].amount==1)
  m=game();m.turn=side;victim=m.spawn_unit(1-side,"farmer");victim.health=3;victim.armor=1
  m.players[side].hand=["wastes_spitter"];assert(m.play(side,0,0) and victim.health==3)
  m=game();m.turn=side;victim=m.spawn_unit(1-side,"farmer");victim.health=1
  m.players[side].hand=["wastes_spitter"];assert(m.play(side,0,0) and m.players[1-side].board.is_empty() and m.last_action.dead.size()==1)
 var m=game();m.turn=1
 var protected=m.spawn_unit(0,"squire");protected.armor=1;protected.health=3
 var weak=m.spawn_unit(0,"farmer");weak.health=1
 m.players[1].hand=["wastes_spitter"]
 assert(m.entry_target(1,Match.CARDS.wastes_spitter)==1 and m.ai_step() and not m.players[0].board.has(weak))
 print("OK: serpente, seleção e ausência de alvo, Armadura, Bloqueio, Antimagia, morte e IA.")
 quit()
