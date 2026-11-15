extends RefCounted

# Account progression, isolated from decks and duel-vs-AI saves.
const BONUSES={
 "life":{"name":"Vitalidade","description":"+1 de vida máxima no início de cada nova expedição."},
 "gold":{"name":"Economias","description":"+1 ouro inicial em cada nova expedição."},
 "creature_life":{"name":"Treino de resistência","description":"Uma criatura aleatória do deck inicial ganha +1 de vida naquela expedição."},
 "creature_attack":{"name":"Treino de força","description":"Uma criatura aleatória do deck inicial ganha +1 de ataque naquela expedição."}
}
var path: String
var xp := 0
var claimed: Dictionary={}
var offers: Dictionary={}
var credited_expeditions: Dictionary={}
var last_error := ""

func _init(storage_path: String="user://adventure_profile.json",read_saved: bool=true) -> void:
 path=storage_path
 if read_saved:load_saved()
 ensure_offers()

static func xp_cost(current_level: int) -> int:
 var n: int=maxi(0,current_level-1)
 return 5+3*n+int(n*(n-1)/2.0)

func level() -> int:
 var result:=1
 var remaining:=xp
 while remaining>=xp_cost(result):
  remaining-=xp_cost(result)
  result+=1
 return result

func xp_in_level() -> int:
 var remaining:=xp
 for value in range(1,level()):remaining-=xp_cost(value)
 return remaining

func extra_lives() -> int:
 return 1 if level()>=3 else 0

func initial_items() -> int:
 return 1 if level()>=5 else 0

func initial_dice_bonus() -> int:
 return int(level()>=4)+int(level()>=8)

static func is_milestone(value: int) -> bool:
 return value in [3,4,5,8]

func ensure_offers() -> void:
 # Fixed milestones replace minor bonuses, including previous-version choices.
 for value in [3,5]:
  claimed.erase(str(value))
  offers.erase(str(value))
 for value in [4,8]:offers.erase(str(value))
 for value in range(2,level()+1):
  var key:=str(value)
  if claimed.has(key) or is_milestone(value):continue
  if offers.has(key) and offers[key] is Array and offers[key].size()==2 and offers[key][0]!=offers[key][1] and offers[key].all(func(b):return BONUSES.has(b)):continue
  var keys: Array=BONUSES.keys()
  var rng:=RandomNumberGenerator.new()
  rng.seed=24681357+value*97
  for i in range(keys.size()-1,0,-1):
   var j:=rng.randi_range(0,i)
   var temporary=keys[i];keys[i]=keys[j];keys[j]=temporary
  offers[key]=keys.slice(0,2)

func pending_choice() -> Dictionary:
 ensure_offers()
 for value in range(2,level()+1):
  if not is_milestone(value) and not claimed.has(str(value)):return {"level":value,"options":offers[str(value)].duplicate()}
 return {}

func choose_bonus(key: String) -> bool:
 var choice:=pending_choice()
 if choice.is_empty() or key not in choice.options:return false
 var value:=str(choice.level)
 claimed[value]=key
 offers.erase(value)
 persist()
 return true

func gain_xp(amount: int) -> void:
 xp+=maxi(0,amount)
 ensure_offers()
 persist()

func credit_expedition(id: String,amount: int) -> bool:
 if credited_expeditions.has(id):return true
 var before:=xp
 xp+=maxi(0,amount);credited_expeditions[id]=true
 if persist():return true
 xp=before;credited_expeditions.erase(id)
 return false

func totals() -> Dictionary:
 var result: Dictionary={"life":0,"gold":0,"creature_life":0,"creature_attack":0}
 for value in claimed.values():
  if result.has(value):result[value]+=1
 return result

func load_saved() -> void:
 if not FileAccess.file_exists(path):return
 var file:=FileAccess.open(path,FileAccess.READ)
 if file==null:last_error="Não foi possível ler o progresso da aventura.";return
 var data=JSON.parse_string(file.get_as_text())
 if not data is Dictionary:
  last_error="O arquivo de progresso da aventura é inválido.";return
 if not (data.get("xp",null) is float or data.get("xp",null) is int):
  last_error="O arquivo de progresso da aventura é inválido.";return
 xp=clampi(int(data.xp),0,1000000)
 if data.get("claimed") is Dictionary:
  for key in data.claimed:
   if String(key).is_valid_int() and int(key)>=2 and int(key)<=level() and int(key) not in [3,5] and BONUSES.has(data.claimed[key]):claimed[String(key)]=data.claimed[key]
 if data.get("offers") is Dictionary:offers=data.offers.duplicate(true)
 if data.get("credited_expeditions") is Dictionary:credited_expeditions=data.credited_expeditions.duplicate()

func persist() -> bool:
 ensure_offers()
 last_error=""
 var temporary: String=path+".tmp"
 var file:=FileAccess.open(temporary,FileAccess.WRITE)
 if file==null:last_error="Não foi possível salvar o progresso da aventura.";return false
 file.store_string(JSON.stringify({"version":3,"xp":xp,"claimed":claimed,"offers":offers,"credited_expeditions":credited_expeditions},"  "))
 file.flush()
 if file.get_error()!=OK:last_error="Não foi possível gravar o progresso da aventura.";return false
 file.close()
 if DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary),ProjectSettings.globalize_path(path))!=OK:last_error="Não foi possível concluir o salvamento do progresso.";return false
 return true



