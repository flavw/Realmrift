extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
const Names=preload("res://scripts/faction_names.gd")
const CardTheme=preload("res://scripts/card_skin.gd")

func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 assert(CardData.Faction.WASTES==8 and Names.PT[8]=="Ermos" and CardTheme.faction_symbol(8)!=null)
 assert(Match.CARD_DATA.wolf.faction==8 and Match.CARD_DATA.zombie_helper.faction==8)
 assert(Match.CARD_DATA.necromancer_summoner.faction==7)
 for main in ["goblin_raider","ash_necromancer","necromancer_summoner"]:
  for support in ["wolf","zombie_helper"]:
   assert(Match.can_add_faction([main],support) and Match.can_add_faction([support],main))
 for main in ["mage","warrior","lightning_rogue","cleric","wild_elf","farmer"]:
  assert(not Match.can_add_faction([main],"wolf") and not Match.can_add_faction(["wolf"],main))
 assert(not Match.can_add_faction(["goblin_raider"],"necromancer_summoner"))
 assert(Match.deck_faction(["wolf","zombie_helper"])==8)
 assert(Match.deck_faction(["wolf","ash_necromancer"])==7)
 assert(Match.deck_faction(["zombie_helper","goblin_raider"])==5)
 assert(Store.accepts_base(8,["wolf","zombie_helper"]) and not Store.accepts_base(8,["goblin_raider"]))
 # A few human Ermos can support Horde without being mistaken for forbidden Village.
 var human=Match.CARD_DATA.farmer.duplicate();human.faction=CardData.Faction.WASTES
 Match.CARD_DATA["test_wastes_human"]=human
 assert(Store.accepts_base(5,["test_wastes_human"]))
 assert(Match.can_add_faction(["goblin_raider"],"test_wastes_human"))
 Match.CARD_DATA.erase("test_wastes_human")
 # Version 12 migration keeps every deck legal, with and without saved base metadata.
 var path="res://work/wastes-test-decks.json"
 for include_base in [true,false]:
  var store=Store.new(path,false)
  var legacy=store.slots.duplicate(true)
  for slot in legacy:
   if slot.base_faction==5:
    for i in range(slot.cards.size()):
     if slot.cards[i]=="wolf":slot.cards[i]="necromancer_summoner"
    slot.cover="necromancer_summoner"
   if slot.base_faction in [3,6]:
    var substitutes: Array=["secrets_dealer","rooftop_leaper"] if slot.base_faction==3 else ["wild_scout","wild_wolf"]
    for key in substitutes:slot.cards[slot.cards.find(key)]="wolf"
    slot.cover="wolf"
   if not include_base:slot.erase("base_faction")
  var file=FileAccess.open(path,FileAccess.WRITE)
  file.store_string(JSON.stringify({"version":12,"active":4,"slots":legacy}));file.close()
  var migrated=Store.new(path)
  assert(migrated.active==4)
  for i in range(Store.SLOT_COUNT):
   assert(migrated.slots[i].name==legacy[i].name and migrated.slots[i].cards.size()==legacy[i].cards.size())
   if not migrated.slots[i].cards.is_empty():
    assert(Match.valid_deck(migrated.slots[i].cards) and Store.accepts_base(migrated.base_for(i),migrated.slots[i].cards))
    assert(migrated.slots[i].cover=="" or migrated.slots[i].cover in migrated.slots[i].cards)
  assert(Store.new(path).slots==migrated.slots,"Migration is idempotent")
 var editor=load("res://deck_editor.tscn").instantiate()
 editor.configure(Store.new(path,false));root.add_child(editor)
 editor.choose_slot(9);await process_frame
 assert(editor.find_child("BaseFactionChoices",true,false).get_child_count()==9)
 editor.select_base_faction(8);await process_frame
 assert(editor.collection_keys().all(func(key):return Match.CARD_DATA[key].faction==8) and editor.composition_rule(8)=="Somente Ermos")
 editor.begin_faction_choice();editor.select_base_faction(5);await process_frame
 assert(editor.collection_keys().has("wolf") and editor.collection_keys().has("zombie_helper"))
 assert(not editor.collection_keys().has("necromancer_summoner") and editor.composition_rule(5)=="Horda + Ermos")
 editor.begin_faction_choice();editor.select_base_faction(7);await process_frame
 assert(editor.collection_keys().has("necromancer_summoner") and editor.collection_keys().has("wolf"))
 editor.queue_free();await process_frame
 DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
 print("OK: Ermos, transferências, complementos em ambas as ordens, humanos, nove facções na UI e migração v12 com/sem base.")
 quit()
