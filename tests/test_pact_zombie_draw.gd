extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var card: CardData=Match.CARD_DATA.necromancer_summoner
 assert(card.is_human() and card.has_creature_type(CardData.CreatureType.MONSTER))
 var m=Match.new()
 m.players[0].board.clear();m.players[0].hand=["zombie_helper"];m.players[0].mana=10
 var human=m.spawn_unit(0,"farmer")
 assert(m.can_play(0,0,-1) and not m.can_play(0,0,0))
 var witch=m.spawn_unit(0,"necromancer_summoner")
 var zombie=m.spawn_unit(0,"zombie_helper")
 assert(not m.can_play(0,0,0) and m.can_play(0,0,1) and m.can_play(0,0,2) and not m.can_play(0,0,-1))
 assert(m.play(0,0,1) and witch.attack==3 and witch.health==5 and human.attack==1 and zombie.attack==2 and zombie.health==1)
 m.players[0].hand=["horde_roar"];m.players[0].mana=10
 assert(m.cast(0,0,0,-1) and witch.turn_attack==2 and int(zombie.get("turn_attack",0))==0)
 var fungus=m.spawn_unit(0,"brood_fungus")
 m.begin_turn()
 assert(witch.max_health==6 and fungus.max_health==4)
 var before: int=m.draw_events.size()
 m.draw(0)
 assert(m.draw_events.size()==before+1)
 print("OK: Pacto Sombrio, alvos do Zumbi, Clamor, Esporos e compra.")
 quit()
