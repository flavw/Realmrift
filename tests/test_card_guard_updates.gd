extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void: call_deferred("verify")
func verify() -> void:
 var raven=Match.CARD_DATA.raven
 var alchemist=Match.CARD_DATA.mist_alchemist
 var mage=Match.CARD_DATA.mage
 assert(raven.attack==1 and raven.health==3 and raven.flying and raven.envenom==0 and raven.antimagic==1)
 assert(alchemist.antimagic==1 and mage.attack==1 and mage.health==2)
 for key in ["raven", "mist_alchemist"]:
  var m=Match.new()
  m.players[0].board.clear()
  var unit=m.spawn_unit(0,key)
  var health: int=unit.health
  assert(Match.damage(unit,1,true)==0 and unit.health==health and unit.antimagic==0)
  assert(Match.damage(unit,1,true)==1 and unit.health==health-1)
  m.turn=0
  m.begin_turn()
  assert(unit.antimagic==1)
  assert(Match.damage(unit,1,false)==1 and unit.antimagic==1)
 var editor=load("res://deck_editor.tscn").instantiate()
 var badge=editor.mana_badge(5,true)
 assert(not badge.get_child(0).visible and badge.get_child(1).get_child(0).outlined)
 badge.free()
 editor.free()
 print("OK: cards, Antimagia e gema azul no editor.")
 quit()
