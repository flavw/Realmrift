extends SceneTree
const Match=preload("res://scripts/match.gd")
func _init() -> void:
 var guard: CardData=Match.CARD_DATA.dawn_warden
 var acolyte: CardData=Match.CARD_DATA.dawn_acolyte
 assert(guard.cost==4 and guard.attack==2 and guard.health==5 and guard.vigor and guard.block==3 and guard.heal_amount==0)
 assert(acolyte.cost==1 and acolyte.attack==0 and acolyte.health==2 and acolyte.heal_amount==1 and acolyte.heal_cost==0)
 assert(acolyte.card_class==CardData.CardClass.CLERIC and acolyte.artwork!=null)
 var m=Match.new()
 m.players[0].board.clear();m.players[1].board.clear()
 var unit=m.spawn_unit(0,"dawn_warden")
 unit.block=1
 m.begin_turn()
 assert(unit.block==2)
 unit.block=3
 m.begin_turn()
 assert(unit.block==3)
 m.players[0].board.clear()
 var healer=m.spawn_unit(0,"dawn_acolyte")
 var target=m.spawn_unit(0,"farmer")
 healer.ready=true;target.health=2;target.poison=1;m.players[0].mana=0
 assert(m.heal(0,0,1))
 assert(target.health==3 and target.poison==0 and not healer.ready and m.players[0].mana==0)
 assert(not m.can_heal(0,0,1))
 print("OK: Guardião Bloqueio 3 e recarga; Acólita, cura gratuita e esgotamento.")
 quit()
