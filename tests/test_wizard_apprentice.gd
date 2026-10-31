extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var apprentice:CardData=Match.CARD_DATA.wizard_apprentice
 assert(apprentice.cost==1 and apprentice.attack==0 and apprentice.health==2 and apprentice.magic_damage==1 and apprentice.magic_cost==1)
 assert(Match.CARD_DATA.mage.attack==1 and Match.CARD_DATA.mage.health==2 and Match.CARD_DATA.mage.magic_cost==0)
 assert(Match.CARD_DATA.fire_mage.attack==2 and Match.CARD_DATA.fire_mage.health==4)
 var game=Match.new()
 for p in game.players:p.board.clear();p.mana=2
 var a=game.spawn_unit(0,"wizard_apprentice");a.ready=true
 var foe=game.spawn_unit(1,"village_wall")
 assert(game.act(0,0,0,true) and foe.health==3 and game.players[0].mana==1 and not a.ready and a.attack==1 and a.health==3)
 print("OK: Aprendiz, Maga Arcana e Feiticeira das Brasas.")
 quit()

