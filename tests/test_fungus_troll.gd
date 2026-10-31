extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _initialize() -> void:call_deferred("verify")
func fresh():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10
 return m
func verify() -> void:
 var goblin: CardData=Match.CARD_DATA.goblin_raider
 assert(goblin.cost==1 and goblin.attack==1 and goblin.health==1 and goblin.swift)
 assert(Match.CARD_DATA.brood_fungus.card_class==2 and Match.CARD_DATA.brood_fungus.creature_type==3)
 for base in [0,1,3,4]:
  assert(not Store.accepts_base(base,["brood_fungus"]))
 for key in ["warrior","mage","lightning_rogue","cleric"]:
  assert(not Match.can_add_class([key],"brood_fungus"))
  assert(not Match.can_add_class(["brood_fungus"],key))
 assert(Store.accepts_base(5,["brood_fungus"]) and Store.accepts_base(2,["brood_fungus"]))
 assert(Match.can_add_class(["goblin_raider"],"brood_fungus"))
 assert(Match.can_add_class(["farmer"],"brood_fungus")) # Pure neutral remains allowed.
 for style in range(Match.DECK_NAMES.size()):assert(Match.valid_deck(Match.default_deck(style)))
 var invalid=Match.default_deck(0);invalid[0]="brood_fungus"
 assert(not Match.valid_deck(invalid))
 var store=Store.new("user://test_fungus_troll.json",false)
 assert(not store.save_slot(0,"Inválido",invalid,0))
 var neutral=Match.default_deck(4);neutral[0]="brood_fungus"
 assert(Match.valid_deck(neutral) and store.save_slot(5,"Neutros",neutral,2))
 # Start-of-owner-turn growth affects all allied Monsters, excluding the source.
 var m=fresh()
 var fungus=m.spawn_unit(0,"brood_fungus")
 var troll=m.spawn_unit(0,"marsh_troll")
 var small=m.spawn_unit(0,"goblin_raider");small.poison=1
 var human=m.spawn_unit(0,"necromancer_summoner")
 var zombie=m.spawn_unit(0,"zombie_helper")
 var ox=m.spawn_unit(0,"harvest_ox")
 var enemy=m.spawn_unit(1,"minotaur_brute")
 var devotee=m.spawn_unit(1,"dawn_devotee")
 m.begin_turn()
 assert(fungus.health==3 and fungus.max_health==3 and troll.health==6 and troll.max_health==6)
 assert(small.health==2 and small.max_health==2 and small.poison==1)
 assert(human.health==4 and zombie.health==3 and ox.health==3 and ox.attack==2)
 assert(enemy.health==5 and devotee.attack==1 and devotee.health==4)
 m.turn=1;m.begin_turn();assert(fungus.health==3)
 # Multiple Esporos sources stack; no healing or Cultivo trigger is involved.
 m=fresh();fungus=m.spawn_unit(0,"brood_fungus");var fungus2=m.spawn_unit(0,"brood_fungus")
 m.begin_turn();assert(fungus.health==4 and fungus2.health==4)
 # A neutral collective copies Esporos, with its original Monster-only targets.
 var crowd=m.spawn_unit(0,"peasant_uprising")
 assert(crowd.spores==2)
 var crowd_life=int(crowd.health)
 m.begin_turn()
 assert(fungus.health==7 and fungus2.health==7 and crowd.health==crowd_life)
 # Regeneration is owner-end only, works exhausted and caps at maximum health.
 m=fresh();troll=m.spawn_unit(0,"marsh_troll");troll.health=2;troll.ready=false
 enemy=m.spawn_unit(1,"marsh_troll");enemy.health=2
 assert(m.end_turn(0) and troll.health==3 and enemy.health==2)
 assert(m.last_action.healed.size()==1)
 assert(m.end_turn(1) and troll.health==3 and enemy.health==3)
 m=fresh();troll=m.spawn_unit(0,"marsh_troll");troll.health=4
 devotee=m.spawn_unit(1,"dawn_devotee")
 assert(m.end_turn(0) and troll.health==5 and troll.max_health==5 and devotee.attack==2)
 assert(m.end_turn(1) and m.end_turn(0) and troll.health==5 and devotee.attack==2)
 # Poison resolves first; a lethal tick cannot be undone by regeneration.
 m=fresh();troll=m.spawn_unit(0,"marsh_troll");troll.health=2;troll.poison=1
 assert(m.end_turn(0) and troll.health==2 and troll.poison==0)
 assert(m.last_action.ticks.size()==1 and m.last_action.healed.size()==1)
 m=fresh();troll=m.spawn_unit(0,"marsh_troll");troll.health=2;troll.poison=2
 assert(m.end_turn(0) and m.players[0].board.is_empty() and not m.last_action.has("healed"))
 # Regeneration follows healing rules for future undead and walls as well.
 m=fresh();troll=m.spawn_unit(0,"marsh_troll");troll.creature_type=CardData.CreatureType.UNDEAD
 assert(m.end_turn(0) and troll.health==4 and m.last_action.regeneration_damage.size()==1)
 m=fresh();troll=m.spawn_unit(0,"marsh_troll");troll.wall=true;troll.health=2
 assert(m.end_turn(0) and troll.health==2)
 var editor=load("res://deck_editor.tscn").instantiate();editor.configure(store);root.add_child(editor)
 editor.choose_slot(0)
 assert(not editor.collection_keys().has("brood_fungus"))
 editor.choose_slot(6);editor.select_base_class(5)
 assert(editor.collection_keys().has("brood_fungus") and editor.collection_keys().has("marsh_troll"))
 editor.choose_slot(5);assert(editor.collection_keys().has("brood_fungus"))
 editor.queue_free();await process_frame;await create_timer(0.35).timeout
 print("OK: Goblin 1 mana 1/1 Arrancada, restrição de Monstros neutros, Esporos/acúmulo/Multidão, Regeneração/Devoção/Veneno/Mortos-vivos/Muralha, filtros e salvamento.")
 quit()
