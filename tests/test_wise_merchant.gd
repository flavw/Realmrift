extends SceneTree

const Match=preload("res://scripts/match.gd")
const CardDataType=preload("res://scripts/card_data.gd")

func fresh():
 var m=Match.new()
 for p in m.players:
  p.board.clear()
  p.hand.clear()
 return m

func _initialize() -> void:
 call_deferred("verify")

func verify() -> void:
 var card: CardData=Match.CARD_DATA.wise_merchant
 assert(card.title=="Comerciante Astuta" and card.faction==CardDataType.Faction.VILLAGER)
 assert(card.creature_type==CardDataType.CreatureType.HUMAN and card.cost==2 and card.attack==1 and card.health==3 and card.commerce==1)
 assert(Match.can_add_faction(["warrior"],"wise_merchant"))
 assert(not Match.can_add_faction(["goblin_raider"],"wise_merchant"))
 var m=fresh()
 var merchant=m.spawn_unit(0,"wise_merchant")
 var farmer=m.spawn_unit(0,"farmer")
 m.begin_turn()
 assert(m.players[0].mana==3 and m.players[0].temporary_mana==1)
 assert(farmer.health==4 and merchant.get("commerce",0)==1)
 # Each individual Cultivo activates Comércio, including multiple sources.
 var farmer_two=m.spawn_unit(0,"farmer")
 m.begin_turn()
 assert(m.players[0].temporary_mana==2 and m.players[0].mana==5)
 assert(farmer_two.health==4)
 # Temporary mana pays first and unspent temporary mana expires at end of turn.
 m.spend_mana(m.players[0],1)
 assert(m.players[0].mana==4 and m.players[0].temporary_mana==1)
 assert(m.end_turn(0) and m.players[0].temporary_mana==0 and m.players[0].mana==3)
 print("OK: Comerciante Astuta transforma cada Cultivo aliado em mana temporária, gasta antes e expira no fim do turno.")
 quit()
