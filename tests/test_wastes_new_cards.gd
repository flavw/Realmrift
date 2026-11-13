extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
const Items=preload("res://scripts/adventure_items.gd")
func fixture():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10
 return m
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var ghoul:CardData=Match.CARD_DATA.hungry_ghoul
 var ogre:CardData=Match.CARD_DATA.wandering_ogre
 assert(ghoul.collectible and ghoul.faction==8 and ghoul.cost==3 and ghoul.attack==3 and ghoul.health==3)
 assert(ghoul.creature_type==CardData.CreatureType.UNDEAD and ghoul.combat_data().carrion==1)
 assert(ghoul.ability_entries().any(func(entry):return entry.name=="Carniceiro 1"))
 assert(ogre.collectible and ogre.faction==8 and ogre.cost==4 and ogre.attack==4 and ogre.health==4 and ogre.trample)
 assert(ogre.creature_type==CardData.CreatureType.MONSTER)
 for base in [5,7,8]:assert(Store.accepts_base(base,["hungry_ghoul","wandering_ogre"]))
 for base in [0,1,2,3,4,6]:assert(not Store.accepts_base(base,["hungry_ghoul","wandering_ogre"]))
 # Both sides can play the cards. The trigger restores current life, never maximum life.
 for side in [0,1]:
  var m=fixture();m.turn=side;m.players[side].hand=["hungry_ghoul","wandering_ogre"]
  assert(m.play(side,0) and m.play(side,0) and m.players[side].mana==3)
  var g:Dictionary=m.players[side].board[0];g.health=1;g.poison=2;g.bleeding=1
  var devotee=m.spawn_unit(side,"dawn_devotee")
  var ally=m.spawn_unit(side,"farmer");ally.health=0
  m.remove_dead();assert(g.health==2 and g.max_health==3 and g.poison==2 and g.bleeding==1)
  assert(devotee.attack==1 and not m.last_action.has("healed") and not m.last_action.has("devotion_buffs"))
  var enemy=m.spawn_unit(1-side,"farmer");enemy.health=0
  m.remove_dead();assert(g.health==3 and m.last_action.carrion_heals.size()==2)
  m.remove_dead();assert(g.health==3 and m.last_action.carrion_heals.size()==2)
  ally=m.spawn_unit(side,"farmer");ally.health=0
  m.remove_dead();assert(g.health==3 and g.max_health==3 and m.last_action.carrion_heals.size()==2)
  # A dead ghoul stays dead, even when another victim is processed before it.
  ally=m.spawn_unit(side,"farmer");ally.health=0
  m.players[side].board.erase(g);m.players[side].board.append(g);g.health=0
  m.remove_dead();assert(g not in m.players[side].board and g.health==0)
 # Lethal poison is simultaneous: another victim cannot rescue a dying scavenger.
 var m=fixture();var victim=m.spawn_unit(0,"farmer");victim.health=1;victim.poison=1
 var g=m.spawn_unit(0,"hungry_ghoul");g.health=1;g.poison=1
 m.resolve_poison(0);assert(m.players[0].board.is_empty())
 # Multiple sources and an enemy source each receive their own single restoration.
 m=fixture();g=m.spawn_unit(0,"hungry_ghoul");g.health=1
 var g2=m.spawn_unit(0,"hungry_ghoul");g2.health=1
 var other=m.spawn_unit(1,"hungry_ghoul");other.health=1
 victim=m.spawn_unit(0,"farmer");victim.health=0
 m.remove_dead();assert(g.health==2 and g2.health==2 and other.health==2 and m.last_action.carrion_heals.size()==3)
 # Ogre's existing Trample and Horde spell interactions are fully functional.
 m=fixture();var o=m.spawn_unit(0,"wandering_ogre");o.ready=true
 victim=m.spawn_unit(1,"crypt_sentinel");victim.health=1
 assert(m.act(0,0,0) and m.players[1].hp==17)
 m=fixture();o=m.spawn_unit(0,"wandering_ogre");g=m.spawn_unit(0,"hungry_ghoul")
 m.players[0].hand=["battle_howl"]
 assert(m.cast(0,0,0,-1) and Match.attack_value(o)==5 and Match.attack_value(g)==3)
 # Adventure equipment duplicates the new exported ability together with the card.
 var enhanced=Items.enhance("hungry_ghoul","heart")
 assert(Match.CARDS[enhanced].carrion==1 and Match.CARDS[enhanced].health==5)
 var editor=load("res://deck_editor.tscn").instantiate()
 editor.configure(Store.new("res://work/new-wastes-cards-unused.json",false));root.add_child(editor)
 editor.choose_slot(9);editor.select_base_faction(8);await process_frame
 assert(editor.collection_keys().has("hungry_ghoul") and editor.collection_keys().has("wandering_ogre"))
 var field=load("res://field_card.tscn").instantiate();field.card_data=ghoul;root.add_child(field);await process_frame
 assert(field.find_child("Carrion",true,false)!=null)
 field.queue_free();editor.queue_free();await process_frame
 print("OK: dois cards Ermos, Carniceiro aliado/inimigo, limites, mortes simultâneas, Atropelar, Clamor, equipamentos e ícone de campo.")
 quit()
