extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var card: CardData=Match.CARD_DATA.dawn_paladin
 assert(card.cost==5 and card.attack==2 and card.health==5 and card.legendary)
 assert(card.regeneration==0 and card.quick_heal_amount==1 and card.quick_heal_cost==1 and card.devotion==2 and card.card_class==CardData.CardClass.CLERIC)
 assert(card.artwork!=null and Match.copy_limit("dawn_paladin")==1)
 var guard: CardData=Match.CARD_DATA.abascanto_guardian
 assert(guard.title=="Guardião Arcano")
 assert(guard.ability_entries().any(func(e):return e.name=="Guarda Arcana 1"))
 var m=Match.new()
 m.players[0].board.clear();m.players[1].board.clear();m.players[0].mana=10
 var paladin=m.spawn_unit(0,"dawn_paladin")
 paladin.health=3
 m.resolve_regeneration(0)
 assert(paladin.health==3 and paladin.attack==2)
 assert(m.heal(0,0,0,0,true) and paladin.health==6 and paladin.attack==4)
 print("OK: Guarda Arcana e Paladino com Cura Célere e Devoção.")
 quit()
