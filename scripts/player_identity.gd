extends RefCounted

const AVATARS=["warrior","valeria_implacavel","mage","lightning_rogue","dawn_paladin","necromancer_summoner","wild_archer","generous_peasant","village_leader","moon_werewolf"]
const FACE_FOCUS={"warrior":Vector2(0.5,0.29),"valeria_implacavel":Vector2(0.5,0.23),"mage":Vector2(0.5,0.22),"lightning_rogue":Vector2(0.5,0.22),"dawn_paladin":Vector2(0.5,0.17),"necromancer_summoner":Vector2(0.5,0.24),"wild_archer":Vector2(0.48,0.22),"generous_peasant":Vector2(0.5,0.22),"village_leader":Vector2(0.5,0.25),"moon_werewolf":Vector2(0.60,0.23)}
static var selected := "warrior"
static var loaded := false
static var storage_path := "user://player_identity.json"
static var last_error := ""

static func avatar() -> String:
 if not loaded:
  loaded=true
  if FileAccess.file_exists(storage_path):
   var data=JSON.parse_string(FileAccess.get_file_as_string(storage_path))
   if data is Dictionary and data.get("avatar","") in AVATARS:selected=data.avatar
 return selected

static func choose(key: String) -> bool:
 if key not in AVATARS:return false
 selected=key;loaded=true;last_error=""
 var file:=FileAccess.open(storage_path,FileAccess.WRITE)
 if file==null:last_error="Não foi possível salvar seu avatar.";return false
 file.store_string(JSON.stringify({"version":1,"avatar":selected}))
 return true
