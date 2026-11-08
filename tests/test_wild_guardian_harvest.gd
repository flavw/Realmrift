extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize():
 var card=Match.CARD_DATA.wild_guardian
 assert(card.title=="Guardiã do Bosque" and card.harvest==1 and card.block==1 and card.attack==3 and card.health==5)
 assert(card.artwork.get_width()==1024 and card.artwork.get_height()==1536 and card.field_artwork_focus==Vector2(0.5,0.35))
 assert(card.ability_entries().any(func(e):return e.name=="Colheita 1"))
 var game=Match.new()
 for p in game.players:p.board.clear();p.deck=["wolf","squire"];p.hand.clear()
 var guardian=game.spawn_unit(0,"wild_guardian")
 game.spawn_unit(0,"farmer")
 game.spawn_unit(0,"wild_sprout_druid")
 game.turn=0;game.begin_turn()
 assert(guardian.attack==5 and guardian.health==7 and guardian.max_health==7)
 game.begin_turn()
 assert(guardian.attack==7 and guardian.health==9 and guardian.max_health==9)
 print("OK: Colheita 1, duas ativações de Cultivo e atributos preservados.")
 quit()
