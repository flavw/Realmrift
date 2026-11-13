extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _initialize() -> void:
 var data=CardData.new()
 var exported: Array=[]
 for property in data.get_property_list():
  if (property.usage&PROPERTY_USAGE_SCRIPT_VARIABLE)!=0 and (property.usage&PROPERTY_USAGE_EDITOR)!=0:exported.append(property.name)
 assert(exported.slice(0,3)==["cost","attack","health"])
 var rest=exported.slice(3);var ordered=rest.duplicate();ordered.sort()
 assert(rest==ordered and not exported.has("human_and_monster"))
 var necro:CardData=Match.CARD_DATA.necromancer_summoner
 assert(necro.is_human() and necro.creature_type_name()=="Humano" and not necro.has_creature_type(CardData.CreatureType.MONSTER))
 assert(not necro.combat_data().has("human_and_monster"))
 assert(not necro.ability_entries().any(func(entry):return entry.name=="Pacto Sombrio"))
 assert(Store.accepts_base(7,["necromancer_summoner","zombie_helper"]))
 assert(not Store.accepts_base(5,["necromancer_summoner","zombie_helper"]))
 var m=Match.new()
 for player in m.players:player.board.clear();player.hand.clear();player.mana=10
 var human=m.spawn_unit(0,"necromancer_summoner")
 var monster=m.spawn_unit(0,"wandering_ogre")
 m.spawn_unit(0,"zombie_helper")
 assert(Match.has_type(human,CardData.CreatureType.HUMAN) and not Match.has_type(human,CardData.CreatureType.MONSTER))
 m.players[0].hand=["zombie_helper","horde_roar"]
 assert(not m.can_play(0,0,0) and m.can_play(0,0,1) and m.can_play(0,0,2))
 assert(m.play(0,0,1) and monster.attack==5 and human.attack==2)
 assert(m.cast(0,0,0,-1) and Match.attack_value(monster)==7 and Match.attack_value(human)==2)
 var fungus=m.spawn_unit(0,"brood_fungus")
 m.begin_turn()
 assert(monster.max_health==6 and human.max_health==4 and fungus.max_health==3)
 print("OK: atributos ordenados, cost/attack/health primeiro; tipo único, Necromante Humana, alvos do Zumbi, Clamor e Esporos.")
 quit()
