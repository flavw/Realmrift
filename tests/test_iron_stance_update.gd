extends SceneTree
const Match=preload("res://scripts/match.gd")
func _init() -> void:
 var m=Match.new()
 m.players[0].board=[];m.players[0].hand=["iron_stance"];m.players[0].mana=10
 var u=m.spawn_unit(0,"farmer")
 var attack: int=u.attack
 assert(m.cast(0,0,0,0))
 assert(u.attack==attack+1 and u.armor==1 and u.block==1 and m.block_capacity(u)==1)
 u.block=0;m.begin_turn()
 assert(u.block==1)
 m.players[0].board=[];m.players[0].hand=["iron_stance"];m.players[0].mana=10
 u=m.spawn_unit(0,"peasant_uprising")
 assert(m.cast(0,0,0,0))
 m.refresh_auras()
 assert(u.block==1 and m.block_capacity(u)==1)
 print("OK: Postura, recuperação e Multidão")
 quit()
