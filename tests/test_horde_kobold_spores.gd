extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 assert(Match.CARD_DATA.marsh_troll.block==1 and Match.CARD_DATA.minotaur_brute.block==3)
 var kobold:CardData=Match.CARD_DATA.scorpion_kobold
 assert(kobold.cost==2 and kobold.attack==2 and kobold.health==1 and kobold.block==1 and kobold.envenom==1 and kobold.card_class==CardData.CardClass.HORDE)
 var game=Match.new()
 for p in game.players:p.board.clear();p.hand.clear();p.mana=10
 var fungus=game.spawn_unit(0,"brood_fungus")
 var beast=game.spawn_unit(0,"wolf")
 var human=game.spawn_unit(0,"farmer")
 var undead=game.spawn_unit(0,"zombie_helper")
 var enemy=game.spawn_unit(1,"wolf")
 game.begin_turn()
 assert(fungus.health==3 and beast.health==3 and beast.max_health==3)
 assert(human.health==4 and human.max_health==4 and undead.health==1 and enemy.health==2)
 game=fresh_combat()
 var attacker:Dictionary=game.players[0].board[0]
 var defender:Dictionary=game.players[1].board[0]
 assert(game.act(0,0,0) and defender.poison==1 and attacker.health==1)
 assert(game.end_turn(0) and game.end_turn(1) and game.players[1].board.is_empty())
 print("OK: bloqueios, Kobold, Veneno e Esporos em Feras e Monstros aliados.")
 quit()
func fresh_combat():
 var game=Match.new()
 for p in game.players:p.board.clear();p.hand.clear();p.mana=10
 var kobold=game.spawn_unit(0,"scorpion_kobold");kobold.ready=true
 var target=game.spawn_unit(1,"farmer");target.attack=0;target.growth=0
 return game
