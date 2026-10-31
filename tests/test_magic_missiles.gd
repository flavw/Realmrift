extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=3
 m.players[0].hand=["magic_missiles"]
 var a=m.spawn_unit(1,"warrior");a.armor=10;a.abascanto=1
 assert(m.has_spell_target(0,0), "Uma criatura e o castelo são dois alvos válidos")
 var b=m.spawn_unit(1,"farmer")
 assert(m.has_spell_target(0,0))
 var first={"side":1,"index":0};var second={"side":1,"index":1}
 assert(not m.cast_multiple(0,0,[first,first]) and m.players[0].mana==3)
 m.spawn_unit(0,"runic_familiar")
 assert(m.cast_multiple(0,0,[first,second]))
 assert(a.health==1 and a.abascanto==0 and b.health==0 and m.players[0].mana==0 and m.players[0].hand.is_empty())
 assert(Match.CARD_DATA.generous_peasant.attack==0 and Match.CARD_DATA.generous_peasant.health==3)
 print("OK: dois alvos distintos, seleção atômica, Armadura, Abascanto, Amplificar e custo.")
 quit()
