extends RefCounted
const Match=preload("res://scripts/match.gd")
const Items=preload("res://scripts/adventure_items.gd")
static var path := "user://adventure_run.save"
static var enabled := true
static var last_error := ""

static func fields(object: Object,skip: Array=[]) -> Dictionary:
 var result: Dictionary={}
 for property in object.get_property_list():
  var key: String=property.name
  if (int(property.usage)&PROPERTY_USAGE_SCRIPT_VARIABLE)==0 or key in skip or key==key.to_upper():continue
  var value=object.get(key)
  if plain(value):result[key]=value
 return result

static func plain(value: Variant) -> bool:
 if value is Object:return false
 if value is Array:
  for part in value:
   if not plain(part):return false
 if value is Dictionary:
  for key in value:
   if not plain(key) or not plain(value[key]):return false
 return true

static func referenced(value: Variant,keys: Dictionary) -> void:
 if value is String and Match.CARD_DATA.has(value) and Match.CARD_DATA[value].has_meta("adventure_base"):keys[value]=true
 elif value is Array:
  for part in value:referenced(part,keys)
 elif value is Dictionary:
  for key in value:referenced(key,keys);referenced(value[key],keys)

static func save_run(run) -> bool:
 if not enabled:return true
 last_error=""
 var state:=fields(run,["profile","rng","saved_duel","current"])
 var duel: Dictionary=fields(run.saved_duel) if run.saved_duel!=null else {}
 var referenced_keys: Dictionary={};referenced(state,referenced_keys);referenced(duel,referenced_keys)
 var cards: Dictionary={}
 for key in referenced_keys:
  var card: CardData=Match.CARD_DATA[key]
  var metadata: Dictionary={}
  for meta in card.get_meta_list():
   if plain(card.get_meta(meta)):metadata[meta]=card.get_meta(meta)
  cards[key]={"base":Items.base_key(key),"fields":fields(card),"metadata":metadata}
 var snapshot: Dictionary={"version":1,"adventure":"village_to_rift","state":state,"duel":duel,"cards":cards,"rng_state":run.rng.state}
 var temporary: String=path+".tmp"
 var file:=FileAccess.open(temporary,FileAccess.WRITE)
 if file==null:last_error="Não foi possível salvar a expedição.";return false
 file.store_var(snapshot,false);file.flush()
 var status:=file.get_error();file.close()
 if status!=OK or DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary),ProjectSettings.globalize_path(path))!=OK:
  last_error="Não foi possível concluir o salvamento da expedição.";return false
 return true

static func restore_fields(object: Object,values: Dictionary) -> void:
 var allowed:=fields(object)
 for key in values:
  if not allowed.has(key) or not plain(values[key]):continue
  var existing=object.get(key)
  if existing is Array and values[key] is Array:existing.assign(values[key]);object.set(key,existing)
  else:object.set(key,values[key])

static func load_run(profile=null):
 last_error=""
 if not FileAccess.file_exists(path):return null
 var file:=FileAccess.open(path,FileAccess.READ)
 if file==null:last_error="Não foi possível ler a expedição salva.";return null
 var data=preload("res://scripts/save_schema.gd").normalize(file.get_var(false));file.close()
 if not data is Dictionary or data.get("version",0)!=1 or not data.get("state") is Dictionary:
  last_error="O salvamento da expedição é inválido.";return null
 for key in data.get("cards",{}):
  var record: Dictionary=data.cards[key]
  if not Match.CARD_DATA.has(record.base):last_error="Uma carta da expedição não está disponível.";return null
  var card: CardData=Match.CARD_DATA[record.base].duplicate()
  restore_fields(card,record.fields)
  for meta in record.metadata:card.set_meta(meta,record.metadata[meta])
  Match.CARD_DATA[key]=card;Match.CARDS[key]=card.combat_data()
  Items.serial=maxi(Items.serial,int(String(key).trim_prefix("adventure_item_")))
 if profile==null:profile=load("res://scripts/adventure_profile.gd").new()
 var run=load("res://scripts/adventure_state.gd").new(profile)
 restore_fields(run,data.state);run.rng.state=int(data.get("rng_state",run.rng.state))
 if data.get("duel",{}) is Dictionary and not data.duel.is_empty():
  var duel=Match.new(run.deck,run.enemy,0,false,run.rules())
  restore_fields(duel,data.duel)
  if duel.adventure_rules.get("encounter","")=="mimic":
   for unit in duel.players[1].board:
    if unit.id!=duel.creature_boss_id:continue
    unit.armor=0
    unit["mimic_sleeping"]=duel.mimic_turns<=1
    if unit.mimic_sleeping:unit.ready=false
  run.saved_duel=duel
 return run
