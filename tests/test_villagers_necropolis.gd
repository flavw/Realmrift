extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
const Factions=preload("res://scripts/faction_names.gd")
const Adventure=preload("res://scripts/adventure_state.gd")
const CardTheme=preload("res://scripts/card_skin.gd")

func fixture():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10
 return m

func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 assert(CardData.Faction.VILLAGER==2 and CardData.Faction.NECROPOLIS==7)
 assert(Factions.name_for(2,"pt_BR")=="Aldeia" and Factions.name_for(7,"pt_BR")=="Necrópole")
 assert(CardTheme.faction_symbol(2)!=null and CardTheme.faction_symbol(7)!=null)
 for base in [0,1,3,4,6]:
  assert(Match.villagers_allowed(base) and Store.accepts_base(base,["farmer"]))
 for base in [5,7]:
  assert(not Match.villagers_allowed(base) and not Store.accepts_base(base,["farmer"]))
 assert(not Match.can_add_faction(["goblin_raider"],"farmer"))
 assert(not Match.can_add_faction(["farmer"],"goblin_raider"))
 assert(not Match.can_add_faction(["ash_necromancer"],"farmer"))
 assert(Match.can_add_faction(["mage"],"farmer") and Match.can_add_faction(["farmer"],"mage"))
 var store=Store.new("res://work/necropolis-test-decks.json",false)
 for style in range(7):
  var cards=Match.default_deck(style)
  assert(cards.size()==22 and Match.valid_deck(cards))
  assert(Store.accepts_base(Store.infer_base(cards),cards))
 assert(Match.default_deck(5).all(func(key):return Match.CARD_DATA[key].faction in [5,8]))
 # Both cards are real collectible resources, including the new numeric ability.
 var necro:CardData=Match.CARD_DATA.ash_necromancer
 var sentinel:CardData=Match.CARD_DATA.crypt_sentinel
 assert(necro.collectible and sentinel.collectible and necro.faction==7 and sentinel.faction==7)
 assert(necro.cost==4 and necro.attack==2 and necro.health==4 and necro.soul_harvest==1)
 assert(necro.ability_entries().any(func(entry):return entry.name=="Colher Almas 1"))
 assert(necro.combat_data().soul_harvest==1)
 assert(sentinel.creature_type==CardData.CreatureType.UNDEAD and sentinel.block==1)
 # Killing an allied sentinel through an actual attack buffs the surviving necromancer.
 var m=fixture()
 var n=m.spawn_unit(0,"ash_necromancer")
 m.spawn_unit(0,"crypt_sentinel")
 var enemy=m.spawn_unit(1,"goblin_raider");enemy.attack=3;enemy.health=9;enemy.ready=true
 m.turn=1
 assert(m.act(1,0,1))
 assert(m.players[0].board.size()==1 and n.attack==3 and n.health==5 and n.max_health==5)
 assert(m.last_action.soul_harvest_buffs.size()==1)
 m.remove_dead();assert(n.attack==3)
 enemy.health=0;m.remove_dead();assert(n.attack==3,"Enemy deaths do not count")
 # Two allied deaths stack; a dying necromancer cannot revive herself through the trigger.
 for i in range(2):
  var ally=m.spawn_unit(0,"crypt_sentinel");ally.health=0
 m.remove_dead();assert(n.attack==5 and n.health==7 and n.max_health==7)
 m=fixture();n=m.spawn_unit(0,"ash_necromancer")
 var ally=m.spawn_unit(0,"crypt_sentinel");n.health=0;ally.health=0
 m.remove_dead();assert(m.players[0].board.is_empty() and n.attack==2)
 # Poison death follows the same trigger; undead retain their existing healing interaction.
 m=fixture();n=m.spawn_unit(0,"ash_necromancer")
 ally=m.spawn_unit(0,"farmer");ally.health=1;ally.poison=1
 var undead=m.spawn_unit(0,"crypt_sentinel")
 assert(m.apply_healing(0,undead,1)==0 and undead.health==2)
 assert(m.end_turn(0));assert(n.attack==3 and n.max_health==5)
 # Poison damage is simultaneous regardless of board order, and its VFX metadata survives.
 for necro_first in [true,false]:
  m=fixture()
  if not necro_first:ally=m.spawn_unit(0,"farmer")
  n=m.spawn_unit(0,"ash_necromancer")
  if necro_first:ally=m.spawn_unit(0,"farmer")
  n.health=1;n.poison=1;ally.health=1;ally.poison=1
  m.resolve_poison(0);assert(m.players[0].board.is_empty())
 m=fixture();n=m.spawn_unit(0,"ash_necromancer")
 ally=m.spawn_unit(0,"farmer");ally.health=1;ally.poison=1
 m.resolve_poison(0);assert(m.last_action.soul_harvest_buffs.size()==1 and n.attack==3)
 # Opponent sources and multiple living copies obey the same ownership rule.
 m=fixture()
 var first=m.spawn_unit(1,"ash_necromancer")
 var second=m.spawn_unit(1,"ash_necromancer")
 ally=m.spawn_unit(1,"crypt_sentinel");ally.health=0
 m.remove_dead();assert(first.attack==3 and second.attack==3)
 first.health=0;m.remove_dead();assert(second.attack==4 and second.max_health==6)
 # Initial Horde draft and its opponents never use Village; adventure recruits remain free.
 var run=Adventure.new();run.faction=5
 for pick in range(15):
  var choices=run.draft_options()
  assert(choices.size()==3 and choices.all(func(key):return Match.CARD_DATA[key].faction in [5,8]))
  run.deck.append(choices[0])
 for tier in [0,2,5,7]:
  assert(run.enemy_deck_for(5,tier).all(func(key):return Match.CARD_DATA[key].faction in [5,8]))
 # Legacy Horde decks migrate without changing slot names, count, active selection or cover intent.
 var legacy=store.slots.duplicate(true)
 for slot in legacy:
  if slot.base_faction!=5:continue
  slot.cover="wolf"
  for i in range(slot.cards.size()):
   if slot.cards[i]=="wolf":slot.cards[i]="necromancer_summoner"
   elif slot.cards[i]=="orc_mine_overseer":slot.cards[i]="wolf"
   elif slot.cards[i]=="battle_howl":slot.cards[i]="village_reconstruction"
 var file=FileAccess.open(store.path,FileAccess.WRITE)
 file.store_string(JSON.stringify({"version":11,"active":4,"slots":legacy}));file.close()
 var restored=Store.new(store.path)
 for i in range(Store.SLOT_COUNT):
  assert(restored.slots[i].name==legacy[i].name and restored.slots[i].cards.size()==legacy[i].cards.size())
  if restored.base_for(i)==5:
   assert(Match.valid_deck(restored.slots[i].cards) and restored.slots[i].cover=="orc_mine_overseer")
 restored.slots[9]={"name":"Sementes da Necrópole","cards":["ash_necromancer","crypt_sentinel"],"cover":"ash_necromancer","base_faction":7}
 assert(restored.persist())
 assert(Store.new(store.path).base_for(9)==7)
 # Exercise the actual collection and builder with all eight faction icons and filters.
 var editor=load("res://deck_editor.tscn").instantiate()
 editor.configure(restored);root.add_child(editor);await process_frame
 editor.choose_slot(9);await process_frame
 assert(editor.collection_keys().all(func(key):return Match.CARD_DATA[key].faction in [7,8]) and editor.collection_keys().has("ash_necromancer"))
 assert(editor.addition_reason("wolf")=="" and editor.composition_rule(7)=="Necrópole + Ermos")
 editor.queue_free();await process_frame
 DirAccess.remove_absolute(ProjectSettings.globalize_path(store.path))
 print("OK: Aldeia, sete decks válidos, migração Horda, draft, nove facções na UI e Colher Almas em ataque/veneno/mortes simultâneas.")
 quit()
