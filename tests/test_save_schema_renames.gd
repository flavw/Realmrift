extends SceneTree
const Schema=preload("res://scripts/save_schema.gd")
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
const Save=preload("res://scripts/adventure_save.gd")
const State=preload("res://scripts/adventure_state.gd")
const Profile=preload("res://scripts/adventure_profile.gd")

# Deliberately writes legacy spellings; these fixtures must stay in the old schema.
static func legacy(value: Variant) -> Variant:
 if value is String:
  return "abascanto_guardian" if value=="antimagic_guardian" else "Abascanto" if value=="Antimagic" else value
 if value is Array:
  var result: Array=[]
  for part in value:result.append(legacy(part))
  return result
 if value is Dictionary:
  var reverse: Dictionary={}
  for key in Schema.LEGACY_KEYS:reverse[Schema.LEGACY_KEYS[key]]=key
  var result: Dictionary={}
  for key in value:result[reverse.get(key,key)]=legacy(value[key])
  return result
 return value

func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var mixed=Schema.normalize({"abascanto":2,"antimagic":0,"card_class":5,"faction":7})
 assert(mixed=={"antimagic":0,"faction":7})
 var path="res://work/test_legacy_factions.json"
 var store=Store.new(path,false)
 var slots=legacy(store.slots)
 slots[0].cover="abascanto_guardian";slots[0].name="Meu abascanto antigo"
 var file=FileAccess.open(path,FileAccess.WRITE)
 file.store_string(JSON.stringify({"version":13,"active":0,"slots":slots}));file.close()
 var migrated=Store.new(path)
 assert(migrated.slots[0].cards==store.slots[0].cards and migrated.slots[0].cover=="antimagic_guardian")
 assert(migrated.slots[0].name=="Meu abascanto antigo" and migrated.active==0)
 for i in range(Store.SLOT_COUNT):
  assert(migrated.base_for(i)==store.base_for(i))
  if not migrated.slots[i].cards.is_empty():assert(Match.valid_deck(migrated.slots[i].cards))
 assert(Store.new(path).slots==migrated.slots)
 file=FileAccess.open(path,FileAccess.READ);var modern=JSON.parse_string(file.get_as_text());file.close()
 assert(modern.version==14 and modern.slots[0].has("base_faction") and not modern.slots[0].has("base_class"))
 # A real upgraded card and active duel must restore charges, capacities, IDs and faction.
 Save.path="res://work/test_legacy_antimagic.save";Save.enabled=true
 var profile=Profile.new("res://work/test_legacy_unused_profile.json",false)
 var run=State.new(profile);run.faction=0;run.deck=Match.default_deck(0);run.enemy=Match.default_deck(1)
 run.grant_card_item("antimagic_guardian","heart")
 var enhanced: String=run.deck.filter(func(key):return key.begins_with("adventure_item_"))[0]
 run.in_combat=true;run.phase="combat"
 run.saved_duel=Match.new(run.deck,run.enemy,0,false,run.rules())
 for player in run.saved_duel.players:player.board.clear()
 var guardian=run.saved_duel.spawn_unit(0,enhanced)
 guardian.antimagic=0;guardian["antimagic_capacity"]=3;guardian["adventure_antimagic_bonus"]=2
 var id: int=guardian.id;var hp: int=guardian.health
 run.saved_duel.last_action={"kind":"magic","antimagic_blocked":true}
 assert(Save.save_run(run))
 file=FileAccess.open(Save.path,FileAccess.READ);var snapshot=file.get_var(false);file.close()
 snapshot=legacy(snapshot)
 # The run's initial faction already used this spelling before the refactor.
 snapshot.state.faction=snapshot.state.card_class;snapshot.state.erase("card_class")
 file=FileAccess.open(Save.path,FileAccess.WRITE);file.store_var(snapshot,false);file.close()
 Match.CARD_DATA.erase(enhanced);Match.CARDS.erase(enhanced)
 var loaded=Save.load_run(profile)
 assert(loaded!=null and loaded.faction==0 and loaded.deck==run.deck and loaded.phase=="combat")
 assert(Match.CARD_DATA[enhanced].antimagic==1 and Match.CARD_DATA[enhanced].faction==0)
 assert(Match.CARD_DATA[enhanced].get_meta("adventure_base")=="antimagic_guardian")
 var restored: Dictionary=loaded.saved_duel.players[0].board[0]
 assert(restored.id==id and restored.health==hp and restored.antimagic==0 and restored.antimagic_capacity==3)
 assert(restored.adventure_antimagic_bonus==2 and restored.faction==0 and not restored.has("abascanto"))
 assert(loaded.saved_duel.last_action.antimagic_blocked and loaded.card_item_grants.has("antimagic_guardian"))
 assert(Save.save_run(loaded))
 var again=Save.load_run(profile)
 assert(again.saved_duel.players==loaded.saved_duel.players and again.deck==loaded.deck)
 # The renamed resource and badge reach the field and collection without an alias card.
 assert(not Match.CARD_DATA.has("abascanto_guardian"))
 var field=load("res://field_card.tscn").instantiate();field.card_data=Match.CARD_DATA.antimagic_guardian
 root.add_child(field);await process_frame
 assert(field.find_child("Antimagic",true,false)!=null)
 field.queue_free();await process_frame
 DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(Save.path))
 print("OK: facções e Antimagia; migração real de decks, capas, itens e combate legado com cargas/vida preservadas; badge e gravação atual.")
 quit()
