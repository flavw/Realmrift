class_name DeckStore
extends RefCounted

const Match = preload("res://scripts/match.gd")
const SLOT_COUNT := 9
const DECKSET_VERSION := 10
var slots: Array = []
var active := 0
var path: String
var error_message := ""

func _init(storage_path: String = "user://decks.json", read_saved: bool = true) -> void:
 path = storage_path
 reset_defaults()
 if read_saved:
  load_saved()

func load_saved() -> void:
 if not FileAccess.file_exists(path):
  persist()
  return
 var file := FileAccess.open(path, FileAccess.READ)
 if not file:
  return
 var parser := JSON.new()
 var content:=file.get_as_text()
 file.close()
 if parser.parse(content) != OK:
  return
 var data = parser.data
 if not data is Dictionary or not data.get("slots") is Array or data.slots.size() not in [3,6,SLOT_COUNT]:
  return
 var saved_version: int=int(data.get("version",0))
 if saved_version<2:
  reset_saved_decks()
  return
 for i in range(data.slots.size()):
  var slot = data.slots[i]
  # Rename the legacy key before validation, preserving saved deck composition.
  if slot is Dictionary and slot.get("cards") is Array:
   for j in range(slot.cards.size()):
    if slot.cards[j]=="solar_storm":slot.cards[j]="fireball"
    if slot.cards[j]=="rogue":slot.cards[j]="lightning_rogue"
   if slot.get("cover","")=="solar_storm":slot.cover="fireball"
   if slot.get("cover","")=="rogue":slot.cover="lightning_rogue"
  # Expand old 12-card decks without removing cards, names or covers.
  if slot is Dictionary and slot.get("cards") is Array and saved_version<6 and Match.valid_deck(slot.cards,false,12):
   slot.cards=Match.expand_legacy_deck(slot.cards)
  # Preserve saved 20-card decks and complete them once under the new limit.
  if slot is Dictionary and slot.get("cards") is Array and saved_version<10 and Match.valid_deck(slot.cards,false,20):
   slot.cards=expand_saved_deck(slot.cards,int(slot.get("base_class",infer_base(slot.cards))))
  # Keep legacy mixed lists editable; class/restriction validation gates play.
  if slot is Dictionary and slot.get("name") is String and slot.get("cards") is Array and slot.cards.size()<=Match.DECK_SIZE and (slot.cards.is_empty() or Match.valid_deck(slot.cards,false,slot.cards.size())):
   var cover: String=String(slot.get("cover",""))
   if cover!="" and (not Match.CARD_DATA.has(cover) or cover not in slot.cards):cover=""
   var base: int=int(slot.get("base_class",infer_base(slot.cards)))
   if base not in [-2,-1,0,1,2,3,4,5] or (not slot.cards.is_empty() and not accepts_base(base,slot.cards)):base=infer_base(slot.cards)
   slots[i] = {"name": clean_name(slot.name, i), "cards": slot.cards.duplicate(),"cover":cover,"base_class":base}
 var saved_active = data.get("active", 0)
 if (saved_active is int or saved_active is float) and saved_active >= 0 and saved_active < SLOT_COUNT:
  active = int(saved_active)
 ensure_nonempty_active()
 if saved_version<DECKSET_VERSION or data.slots.size()!=SLOT_COUNT:
  persist()

static func expand_saved_deck(cards: Array,base: int) -> Array:
 var result:=cards.duplicate()
 var style: int={0:0,3:1,1:2,4:3,2:4,5:5}.get(base,4)
 var candidates:=Match.default_deck(style)
 candidates.append_array(Match.CARD_DATA.keys())
 for key in candidates:
  if result.size()>=Match.DECK_SIZE:break
  if result.count(key)>=Match.copy_limit(key):continue
  var next:=result.duplicate()
  next.append(key)
  if accepts_base(base,next) and Match.can_add_class(result,key):result.append(key)
 return result

static func infer_base(cards: Array) -> int:
 if cards.is_empty():return -1
 var faction: int=Match.deck_class(cards)
 return CardData.CardClass.NEUTRAL if faction==-1 else faction

static func accepts_base(base: int,cards: Array) -> bool:
 if base<0:return cards.is_empty()
 for key in cards:
  if not Match.CARD_DATA.has(key) or not Match.CARD_DATA[key].collectible:return false
  if Match.neutral_monster_forbidden(base,key):return false
  if base==CardData.CardClass.HORDE and Match.CARD_DATA[key].is_human() and not Match.CARD_DATA[key].has_creature_type(CardData.CreatureType.MONSTER):return false
  var faction: int=Match.CARD_DATA[key].card_class
  if faction!=CardData.CardClass.NEUTRAL and faction!=base:return false
 return true

func base_for(index: int) -> int:
 return int(slots[index].get("base_class",infer_base(slots[index].cards)))

func clean_name(value: String, slot: int) -> String:
 var trimmed := value.strip_edges().left(24)
 return "Deck %d" % (slot + 1) if trimmed.is_empty() else trimmed

func persist() -> bool:
 var file := FileAccess.open(path, FileAccess.WRITE)
 if not file:
  error_message = "Não foi possível salvar os decks no computador."
  return false
 file.store_string(JSON.stringify({"version": DECKSET_VERSION, "active": active, "slots": slots}, "  "))
 file.flush()
 if file.get_error() != OK:
  error_message = "Ocorreu um erro ao salvar os decks."
  return false
 error_message = ""
 return true

func save_slot(slot: int, name: String, cards: Array,base_class: int=-3, cover_override: Variant=null) -> bool:
 if slot<0 or slot>=SLOT_COUNT:return false
 var base: int=base_class
 if base==-3:
  base=infer_base(cards)
  var previous_base: int=base_for(slot)
  if (cards.is_empty() or Match.deck_class(cards)==-1) and previous_base>=0:base=previous_base
 if base not in [-1,0,1,2,3,4,5] or not accepts_base(base,cards) or (not cards.is_empty() and not Match.valid_deck(cards)):
  if cards.any(func(key):return Match.neutral_monster_forbidden(base,key)):
   error_message="Monstros neutros só podem entrar na Horda ou em decks só de neutros."
   return false
  error_message = "Humanos precisam de Pacto Sombrio para entrar na Horda." if base==CardData.CardClass.HORDE and cards.any(func(key):return Match.CARD_DATA.has(key) and Match.CARD_DATA[key].is_human() and not Match.CARD_DATA[key].human_and_monster) else "Use 22 cartas, até 2 cópias (lendárias: 1), de uma única classe + neutros ou somente neutros. Respeite as cartas exclusivas de decks neutros."
  return false
 var previous_active:=active
 var previous: Dictionary = slots[slot].duplicate(true)
 var cover: String=String(previous.get("cover","")) if cover_override==null else String(cover_override)
 if cover not in cards:cover=""
 slots[slot] = {"name": clean_name(name, slot), "cards": cards.duplicate(),"cover":cover,"base_class":base}
 ensure_nonempty_active()
 if not persist():
  slots[slot] = previous
  active=previous_active
  return false
 return true

func activate(slot: int) -> bool:
 if slot < 0 or slot >= SLOT_COUNT or not Match.valid_deck(slots[slot].cards) or not accepts_base(base_for(slot),slots[slot].cards):
  error_message="Complete um deck de 22 cartas antes de jogar."
  return false
 var previous := active
 active = slot
 if not persist():
  active = previous
  return false
 return true

func active_cards() -> Array:
 return slots[active].cards.duplicate()

func reset_defaults() -> void:
 slots.clear()
 active=0
 var styles: Array[int]=[0,1,2,3,5,4]
 for i in range(SLOT_COUNT):
  if i<styles.size():
   var cards:=Match.default_deck(styles[i])
   slots.append({"name":Match.default_deck_name(styles[i]),"cards":cards,"cover":"bloodblade" if i==0 else "","base_class":infer_base(cards)})
  else:
   slots.append({"name":"Novo deck %d" % (i+1),"cards":[],"cover":"","base_class":-1})

func reset_saved_decks() -> bool:
 reset_defaults()
 return persist()

func ensure_nonempty_active() -> void:
 if not slots[active].cards.is_empty():return
 for i in range(SLOT_COUNT):
  if Match.valid_deck(slots[i].cards):
   active=i
   return
 active=0

static func automatic_cover(cards: Array) -> String:
 if cards.is_empty():return ""
 var preferred: String={-1:"village_leader",0:"wall_smith",1:"aether_summoner",3:"mist_alchemist",4:"dawn_oracle"}.get(Match.deck_class(cards),"")
 if preferred in cards:return preferred
 for key in cards:
  if Match.CARD_DATA.has(key) and Match.CARD_DATA[key].card_class!=CardData.CardClass.NEUTRAL:return String(key)
 return String(cards[0])

func cover_for(index: int) -> String:
 if index<0 or index>=SLOT_COUNT:return ""
 var chosen: String=String(slots[index].get("cover",""))
 return chosen if chosen!="" and chosen in slots[index].cards else automatic_cover(slots[index].cards)

func save_metadata(index: int,name: String,cover: String) -> bool:
 if index<0 or index>=SLOT_COUNT:return false
 if cover!="" and (not Match.CARD_DATA.has(cover) or cover not in slots[index].cards):
  error_message="Escolha uma carta que faça parte deste deck para a capa."
  return false
 var previous: Dictionary=slots[index].duplicate(true)
 slots[index].name=clean_name(name,index)
 slots[index]["cover"]=cover
 if not persist():
  slots[index]=previous
  return false
 return true
