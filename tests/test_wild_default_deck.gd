extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
const CardSkinTest=preload("res://scripts/card_skin.gd")
func _initialize():call_deferred("verify")
func verify():
 var deck=Match.default_deck(6)
 assert(deck.size()==22 and Match.valid_deck(deck) and Match.deck_faction(deck)==CardData.Faction.WILD)
 for key in ["wild_badger","wild_scout","wild_archer","wild_sprout_druid","wild_roots_druid","wild_guardian","wild_wolf","wild_wasp","wild_elf","wild_roots","wild_regeneration"]:assert(deck.has(key))
 assert(deck.count("wolf")==2 and Match.default_deck_name(6)=="Aliança da Floresta")
 var ability=Match.CARD_DATA.wild_elf.ability_entries().filter(func(e):return e.name=="Alcance")
 assert(ability.size()==1 and ability[0].icon=="reach-icon" and CardSkinTest.texture("reach-icon")!=null)
 var path="user://test_wild_deck_migration.json"
 for full in [false,true]:
  var slots=[]
  for i in range(9):
   var old=Match.default_deck(i%6)
   slots.append({"name":"Original %d" % i,"cards":old if full or i!=7 else [],"cover":old[0] if full or i!=7 else "","base_faction":Store.infer_base(old) if full or i!=7 else -1})
  var file=FileAccess.open(path,FileAccess.WRITE)
  file.store_string(JSON.stringify({"version":10,"active":2,"slots":slots}));file.close()
  var store=Store.new(path,true)
  assert(store.active==2 and store.slots.size()==10)
  var destination=9 if full else 7
  assert(store.slots[destination].cards==deck and store.slots[destination].cover=="wild_elf")
  for i in range(9):
   if not full and i==7:continue
   assert(store.slots[i].cards==slots[i].cards and store.slots[i].name==slots[i].name and store.slots[i].cover==slots[i].cover)
  var again=Store.new(path,true)
  assert(again.slots==store.slots and again.active==2)
 DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
 print("OK: deck Selvagem, ícone, migração e preservação dos decks existentes.")
 quit()

