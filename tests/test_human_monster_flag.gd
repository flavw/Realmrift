extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _initialize() -> void:
 var necro: CardData=Match.CARD_DATA.necromancer_summoner
 assert(necro.human_and_monster and necro.is_human())
 assert(necro.has_creature_type(CardData.CreatureType.MONSTER))
 assert(necro.creature_type_name()=="Humano / Monstro")
 assert(necro.ability_entries().any(func(e):return e.name=="Pacto Sombrio"))
 assert(Store.accepts_base(5,["necromancer_summoner","zombie_helper"]))
 assert(not Store.accepts_base(5,["necromancer_summoner","farmer"]))
 var m=Match.new()
 var u=m.spawn_unit(0,"necromancer_summoner")
 assert(u.human_and_monster and Match.has_type(u,CardData.CreatureType.HUMAN) and Match.has_type(u,CardData.CreatureType.MONSTER))
 assert(not Match.has_type(m.spawn_unit(0,"farmer"),CardData.CreatureType.MONSTER))
 print("OK: Pacto Sombrio, tipos e restrições de deck preservados.")
 quit()
