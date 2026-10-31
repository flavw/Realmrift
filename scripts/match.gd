class_name DuelMatch
extends RefCounted

const MAX_HAND_SIZE := 7

const CARD_DATA = {
 "warrior": preload("res://cards/warrior.tres"),
 "mage": preload("res://cards/mage.tres"),
 "wizard_apprentice": preload("res://cards/wizard_apprentice.tres"),
 "scorpion_kobold": preload("res://cards/scorpion_kobold.tres"),
 "squire": preload("res://cards/squire.tres"),
 "wolf": preload("res://cards/wolf.tres"),
 "lightning_rogue": preload("res://cards/lightning_rogue.tres"),
 "venom_rooftop": preload("res://cards/venom_rooftop.tres"),
 "street_urchin": preload("res://cards/street_urchin.tres"),
 "raven": preload("res://cards/raven.tres"),
 "rooftop_leaper": preload("res://cards/rooftop_leaper.tres"),
 "sentinel": preload("res://cards/sentinel.tres"),
 "iron_recruit": preload("res://cards/iron_recruit.tres"),
 "fire_mage": preload("res://cards/fire_mage.tres"),
 "farmer": preload("res://cards/farmer.tres"),
 "cleric": preload("res://cards/cleric.tres"),
 "dawn_acolyte": preload("res://cards/dawn_acolyte.tres"),
 "dawn_paladin": preload("res://cards/dawn_paladin.tres"),
 "wall_guard": preload("res://cards/wall_guard.tres"),
 "gate_watcher": preload("res://cards/gate_watcher.tres"),
 "eclipse_channeler": preload("res://cards/eclipse_channeler.tres"),
 "runic_familiar": preload("res://cards/runic_familiar.tres"),
 "dusk_scout": preload("res://cards/dusk_scout.tres"),
 "messenger_hawk": preload("res://cards/messenger_hawk.tres"),
 "dawn_warden": preload("res://cards/dawn_warden.tres"),
 "life_pilgrim": preload("res://cards/life_pilgrim.tres"),
 "iron_stance": preload("res://cards/iron_stance.tres"),
 "astral_flame": preload("res://cards/astral_flame.tres"),
 "shadow_step": preload("res://cards/shadow_step.tres"),
 "restoring_light": preload("res://cards/restoring_light.tres"),
 "vigor_vow": preload("res://cards/vigor_vow.tres"),
 "conductive_bolt": preload("res://cards/conductive_bolt.tres"),
 "moon_herald": preload("res://cards/moon_herald.tres"),
 "wall_smith": preload("res://cards/wall_smith.tres"),
 "aether_summoner": preload("res://cards/aether_summoner.tres"),
 "mist_alchemist": preload("res://cards/mist_alchemist.tres"),
 "secrets_dealer": preload("res://cards/secrets_dealer.tres"),
 "dawn_oracle": preload("res://cards/dawn_oracle.tres"),
 "village_leader": preload("res://cards/village_leader.tres"),
 "generous_peasant": preload("res://cards/generous_peasant.tres"),
 "village_reconstruction": preload("res://cards/village_reconstruction.tres"),
 "village_wall": preload("res://cards/village_wall.tres"),
 "fireball": preload("res://cards/fireball.tres"),
 "abascanto_guardian": preload("res://cards/abascanto_guardian.tres"),
 "peasant_uprising": preload("res://cards/peasant_uprising.tres"),
 "harvest_ox": preload("res://cards/harvest_ox.tres"),
 "dawn_devotee": preload("res://cards/dawn_devotee.tres"),
 "goblin_raider": preload("res://cards/goblin_raider.tres"),
 "minotaur_brute": preload("res://cards/minotaur_brute.tres"),
 "moon_werewolf": preload("res://cards/moon_werewolf.tres"),
 "zombie_helper": preload("res://cards/zombie_helper.tres"),
 "necromancer_summoner": preload("res://cards/necromancer_summoner.tres"),
 "summoned_ghoul": preload("res://cards/summoned_ghoul.tres"),
 "horde_roar": preload("res://cards/horde_roar.tres"),
 "brood_fungus": preload("res://cards/brood_fungus.tres"),
 "marsh_troll": preload("res://cards/marsh_troll.tres"),
 "bloodblade": preload("res://cards/bloodblade.tres"),
 "vanguard_bastion": preload("res://cards/vanguard_bastion.tres"),
 "magic_missiles": preload("res://cards/magic_missiles.tres"),
 "wise_merchant": preload("res://cards/wise_merchant.tres")
}
const Collective=preload("res://scripts/collective_rules.gd")
const MAX_BOARD := 6
const DECK_SIZE := 22
const MAX_COPIES := 2
static var CARDS: Dictionary = build_cards()

static func build_cards() -> Dictionary:
 var result := {}
 for key in CARD_DATA:
  result[key] = CARD_DATA[key].combat_data()
 return result
var players: Array = []
var turn := 0
var winner := -1
var next_id := 0
var human_deaths: Array[int]=[0,0]
var recorded_deaths: Dictionary={}
var history: Array[String] = []
var history_sides: Array[int] = []
var last_action: Dictionary = {}
var draw_events: Array = []
var first_player := 0
var opening := false
var mulligan_done: Array[bool] = [true,true]
var mulligan_rounds: Array[int]=[0,0]

const DECK_NAMES=["Baluarte das Cicatrizes", "Caçada das Brumas", "Círculo Arcano", "Aurora Vital", "União da Colheita", "Horda dos Ermos"]
static func default_deck_name(style: int=0) -> String:
 return DECK_NAMES[clampi(style,0,DECK_NAMES.size()-1)]

static func default_deck(style: int = 0) -> Array[String]:
 var recipes := [
  ["squire", "squire", "sentinel", "sentinel", "wall_smith", "wall_smith", "warrior", "warrior", "wall_guard", "moon_herald", "iron_stance", "iron_stance", "wall_guard", "moon_herald", "bloodblade", "abascanto_guardian", "abascanto_guardian", "generous_peasant", "generous_peasant", "bloodblade"],
  ["dusk_scout", "dusk_scout", "raven", "raven", "lightning_rogue", "lightning_rogue", "mist_alchemist", "mist_alchemist", "moon_herald", "messenger_hawk", "shadow_step", "shadow_step", "moon_herald", "messenger_hawk", "wolf", "wolf", "gate_watcher", "gate_watcher", "street_urchin", "street_urchin"],
  ["mage", "mage", "aether_summoner", "aether_summoner", "runic_familiar", "eclipse_channeler", "eclipse_channeler", "conductive_bolt", "conductive_bolt", "astral_flame", "squire", "squire", "runic_familiar", "astral_flame", "fire_mage", "fire_mage", "fireball", "magic_missiles", "magic_missiles", "wizard_apprentice"],
  ["cleric", "cleric", "dawn_warden", "dawn_warden", "dawn_oracle", "dawn_oracle", "farmer", "farmer", "moon_herald", "squire", "restoring_light", "vigor_vow", "moon_herald", "squire", "restoring_light", "vigor_vow", "life_pilgrim", "life_pilgrim", "generous_peasant", "generous_peasant"],
  ["moon_herald", "moon_herald", "generous_peasant", "generous_peasant", "farmer", "farmer", "wise_merchant", "wise_merchant", "harvest_ox", "harvest_ox", "peasant_uprising", "village_leader", "village_leader", "gate_watcher", "gate_watcher", "squire", "squire", "life_pilgrim", "life_pilgrim", "village_reconstruction"],
  ["horde_roar", "horde_roar", "zombie_helper", "zombie_helper", "moon_werewolf", "moon_werewolf", "marsh_troll", "minotaur_brute", "minotaur_brute", "marsh_troll", "necromancer_summoner", "necromancer_summoner", "goblin_raider", "goblin_raider", "wolf", "wolf", "brood_fungus", "brood_fungus", "scorpion_kobold", "scorpion_kobold"]
 ]
 var result: Array[String] = []
 result.assign(recipes[clampi(style,0,recipes.size()-1)])
 var additions := [["iron_recruit","iron_recruit"],["secrets_dealer","rooftop_leaper"],["wizard_apprentice","fireball"],["dawn_acolyte","dawn_acolyte"],["village_reconstruction","village_wall"],["village_reconstruction","village_reconstruction"]]
 # Some recipes already contain the maximum; select only legal additions.
 for key in additions[clampi(style,0,additions.size()-1)]:
  if result.count(key)<copy_limit(key):result.append(key)
 if result.size()<DECK_SIZE:
  for key in CARD_DATA:
   if result.size()>=DECK_SIZE:break
   if result.count(key)<copy_limit(key) and can_add_class(result,key):result.append(key)
 return result

static func copy_limit(key: String) -> int:
 return CARD_DATA[key].copy_limit() if CARD_DATA.has(key) else 0

static func deck_class(cards: Array) -> int:
 var faction: int=-1
 for key in cards:
  if not CARD_DATA.has(key):return -2
  var value: int=CARD_DATA[key].card_class
  if value==CardData.CardClass.NEUTRAL:continue
  if faction>=0 and faction!=value:return -2
  faction=value
 return faction

static func can_add_class(cards: Array,key: String) -> bool:
 if not CARD_DATA.has(key) or not CARD_DATA[key].collectible:return false
 var candidate: Array=cards.duplicate()
 candidate.append(key)
 return deck_class(candidate)!=-2 and restrictions_met(candidate)

static func neutral_monster_forbidden(base: int,key: String) -> bool:
 if not CARD_DATA.has(key):return false
 var card: CardData=CARD_DATA[key]
 return base in [CardData.CardClass.WARRIOR,CardData.CardClass.MAGE,CardData.CardClass.LADINO,CardData.CardClass.CLERIC] and card.card_class==CardData.CardClass.NEUTRAL and card.has_creature_type(CardData.CreatureType.MONSTER)

static func restrictions_met(cards: Array) -> bool:
 var only_neutral: bool=deck_class(cards)==-1
 var horde: bool=deck_class(cards)==CardData.CardClass.HORDE
 for key in cards:
  if not CARD_DATA.has(key):return false
  if neutral_monster_forbidden(deck_class(cards),key):return false
  if horde and CARD_DATA[key].is_human() and not CARD_DATA[key].has_creature_type(CardData.CreatureType.MONSTER):return false
  if CARD_DATA[key].neutral_deck_only and not only_neutral:return false
 return true

static func expand_legacy_deck(cards: Array) -> Array:
 var result: Array=cards.duplicate()
 var faction: int=deck_class(cards)
 var style: int={0:0,3:1,1:2,4:3,-1:4,5:5}.get(faction,4)
 var candidates: Array=default_deck(style)
 candidates.append_array(CARD_DATA.keys())
 for key in candidates:
  if result.size()>=DECK_SIZE:break
  if result.count(key)>=copy_limit(key):continue
  # Preserve old mixed lists for correction; fill them only with ordinary neutrals.
  var allowed: bool=can_add_class(result,key) if faction!=-2 else CARD_DATA[key].collectible and CARD_DATA[key].card_class==CardData.CardClass.NEUTRAL and not CARD_DATA[key].neutral_deck_only
  if allowed:result.append(key)
 return result

static func valid_deck(cards: Array,enforce_class: bool=true,required_size: int=DECK_SIZE) -> bool:
 if cards.size() != required_size:
  return false
 var counts := {}
 for key in cards:
  if not key is String or not CARD_DATA.has(key) or not CARD_DATA[key].collectible:
   return false
  counts[key] = int(counts.get(key, 0)) + 1
  if counts[key] > copy_limit(key):
   return false
 return not enforce_class or (deck_class(cards)!=-2 and restrictions_met(cards))

func _init(player_deck: Array = [], ai_deck: Array = [], starting_side: int = 0, with_mulligan: bool = false) -> void:
 first_player = clampi(starting_side,0,1)
 turn = first_player
 opening = with_mulligan
 mulligan_done = [not with_mulligan,not with_mulligan]
 mulligan_rounds.assign([0,0] if with_mulligan else [mulligan_limit(0),mulligan_limit(1)])
 for side in range(2):
  var deck: Array[String] = []
  var supplied: Array = player_deck if side == 0 else ai_deck
  deck.assign(supplied if valid_deck(supplied) else default_deck(side))
  deck.shuffle()
  players.append({"hp": 20, "mana": 0, "temporary_mana":0, "max_mana": 0, "deck": deck, "hand": [], "board": [], "fatigue": 0,"poison":0,"neutral_deck":deck_class(deck)==-1})
  for i in range(3 if side==first_player else 4):
   draw(side)
 if not opening:
  draw_events.clear()
  begin_turn()
 else:draw_events.clear()

func log_event(message: String, actor_side: int = -1) -> void:
 history.append(message)
 history_sides.append(turn if actor_side < 0 else actor_side)

func draw(side: int,resolve_result: bool=true) -> void:
 var p: Dictionary = players[side]
 if p.deck.is_empty():
  p.fatigue += 1
  p.hp -= p.fatigue
  log_event("%s sofre %d de fadiga." % [castle_name(side).capitalize(), p.fatigue], side)
 elif p.hand.size() < MAX_HAND_SIZE:
  p.hand.append(p.deck.pop_back())
  draw_events.append({"side":side,"key":p.hand.back()})
  log_event("%s compra %s." % [side_name(side),CARDS[p.hand.back()].name if side==0 else "uma carta"], side)
 else:
  var key: String=p.deck.pop_back()
  draw_events.append({"side":side,"key":key,"destroyed":true})
  log_event("%s: mão cheia, %s destruída." % [side_name(side),CARDS[key].name if side==0 else "carta"], side)
 if resolve_result:check_winner()

func side_name(side: int) -> String:
 return "Você" if side == 0 else "IA"

func castle_name(side: int) -> String:
 return "castelo aliado" if side == 0 else "castelo inimigo"

func begin_turn() -> void:
 if opening:
  return
 for unit in players[turn].board:
  var bonus: int=int(unit.get("resonance_bonus",0))
  if bonus<=0 or unit.health<=0:continue
  unit.attack-=bonus
  unit.max_health=maxi(1,int(unit.get("max_health",CARD_DATA[unit.key].health))-bonus)
  unit.health=clampi(int(unit.health)-bonus,1,int(unit.max_health))
  unit.resonance_bonus=0
  log_event("Ressonância de %s termina: −%d/−%d, vida mínima 1." % [unit.name,bonus,bonus],turn)
 refresh_auras()
 var p: Dictionary = players[turn]
 var second_first_turn: bool=turn!=first_player and p.max_mana==0
 p.max_mana = mini(10, p.max_mana + 1)
 p.mana = p.max_mana
 p.temporary_mana = 0
 log_event("Seu turno — %d mana." % p.mana if turn == 0 else "Turno da IA — %d mana." % p.mana)
 if second_first_turn:
  p.temporary_mana=1
  p.mana+=1
  log_event("%s recebe 1 mana temporária por jogar em segundo." % side_name(turn))
 var cultivation_events: Array=[]
 for unit in p.board:
  unit.ready = true
  unit.fury_used = false
  unit.quick_heal_used = false
  unit.summoned_this_turn=false
  unit.actions_taken=0
  unit.attacked_this_turn=false
  unit.exhausting_action_taken=false
  var max_abascanto: int=abascanto_capacity(unit)
  unit.abascanto=mini(max_abascanto,int(unit.get("abascanto",0))+1)
  var max_block: int = block_capacity(unit)
  unit.block = mini(max_block, int(unit.get("block", 0)) + 1)
  if int(unit.get("rural_pride",0))>0 and neutral_field(turn):
   var pride: int=int(unit.rural_pride)
   unit.attack+=pride
   log_event("Brio: %s ganha +%d de ataque." % [unit.name,pride])
  if unit.get("growth", 0) > 0:
   var gain: int = unit.growth
   unit.max_health = int(unit.get("max_health", CARD_DATA[unit.key].health)) + gain
   unit.health += gain
   cultivation_events.append(unit.id)
   log_event("%s ganha +%d de vida: %d/%d." % [unit.name, gain, unit.health, unit.max_health])
 for source in p.board.duplicate():
  var amount: int=int(source.get("spores",0))
  if source.health<=0 or amount<=0:continue
  for ally in p.board:
   if not is_same(ally,source) and ally.health>0 and (has_type(ally,CardData.CreatureType.MONSTER) or has_type(ally,CardData.CreatureType.BEAST)):
    grant_stats(ally,0,amount)
    log_event("Esporos de %s: %s ganha +%d de vida." % [source.name,ally.name,amount])
 for source_id in cultivation_events:
  for listener in p.board:
   var bonus: int=int(listener.get("harvest",0))
   if bonus>0 and listener.health>0:
    grant_stats(listener,bonus,bonus)
    log_event("Colheita: %s ganha +%d/+%d por ativação de Cultivo." % [listener.name,bonus,bonus])
  for listener in p.board:
   var commerce: int=int(listener.get("commerce",0))
   if commerce>0 and listener.health>0:
    p.mana+=commerce
    p.temporary_mana+=commerce
    log_event("Comércio: %s recebe +%d mana temporária por Cultivo." % [listener.name,commerce])
 refresh_auras()
 draw(turn)

func spend_mana(p: Dictionary, amount: int) -> void:
 var paid: int=maxi(0,amount)
 p.mana=maxi(0,int(p.mana)-paid)
 # Mana temporária é sempre consumida antes das gemas normais.
 p.temporary_mana=maxi(0,int(p.get("temporary_mana",0))-paid)

func end_turn(side: int) -> bool:
 if opening or side != turn or winner != -1:
  return false
 log_event("%s encerra o turno." % side_name(side))
 for unit in players[side].board:
  unit["turn_attack"]=0
  unit["turn_flying"]=false
  unit["turn_swift"]=false
 for unit in players[side].board:unit["bleeding"]=0
 resolve_poison(side)
 resolve_regeneration(side)
 var p: Dictionary=players[side]
 if int(p.get("temporary_mana",0))>0:
  p.mana=maxi(0,int(p.mana)-int(p.temporary_mana))
  p.temporary_mana=0
 if winner != -1:
  return true
 turn = 1 - turn
 begin_turn()
 return true

func can_play(side: int,hand_index: int,target: int=-1) -> bool:
 if opening or winner!=-1 or side!=turn or side<0 or side>1:return false
 var p: Dictionary=players[side]
 if hand_index<0 or hand_index>=p.hand.size() or p.board.size()>=MAX_BOARD:return false
 var card: Dictionary=CARDS[p.hand[hand_index]]
 if card.get("card_type",0)==CardData.CardType.SPELL or p.mana<card.cost:return false
 var owner:=entry_target_side(side,card)
 if owner>=0:
  var targets:=entry_valid_targets(side,card)
  return target in targets if not targets.is_empty() else target==-1
 return target==-1

func play(side: int, hand_index: int,target: int=-1,entry_choice: String="") -> bool:
 if not can_play(side,hand_index,target):return false
 var p: Dictionary=players[side]
 var key: String=p.hand[hand_index]
 var card: Dictionary=CARDS[key]
 if int(card.get("entry_effect",0))==CardData.EntryEffect.GRANT_ROGUE_CHOICE and target>=0 and entry_choice not in ["loot","envenom"]:return false
 spend_mana(p,card.cost)
 p.hand.remove_at(hand_index)
 var unit: Dictionary=spawn_unit(side,key)
 last_action = {"kind": "summon", "side": side, "attacker": unit.id, "dead": []}
 match int(card.get("entry_effect",0)):
  CardData.EntryEffect.BUFF_ALLY,CardData.EntryEffect.BUFF_MONSTER_UNDEAD:
   if target>=0:
    var ally: Dictionary=p.board[target]
    var attack_bonus: int=card.get("entry_attack",0)
    var health_bonus: int=card.get("entry_health",0)
    grant_stats(ally,attack_bonus,health_bonus)
    last_action["buff_target"]=ally.id
    last_action["buff_attack"]=attack_bonus
    last_action["buff_health"]=health_bonus
    log_event("Chamado: %s concede +%d/+%d a %s." % [card.name,attack_bonus,health_bonus,ally.name])
  CardData.EntryEffect.GRANT_ROGUE_CHOICE:
   if target>=0:
    var ally: Dictionary=p.board[target]
    var amount: int=int(card.entry_value) if entry_choice=="loot" else int(card.entry_secondary)
    ally[entry_choice]=int(ally.get(entry_choice,0))+amount
    last_action["buff_target"]=ally.id
    last_action["granted_ability"]=entry_choice
    last_action["granted_amount"]=amount
    log_event("Chamado: %s concede %s %d a %s." % [card.name,"Saquear" if entry_choice=="loot" else "Envenenar",amount,ally.name])
  CardData.EntryEffect.ARMOR_ALLY:
   if target>=0:
    var ally: Dictionary=p.board[target]
    ally.armor+=int(card.entry_value)
    last_action["buff_target"]=ally.id
    last_action["buff_armor"]=card.entry_value
    log_event("Chamado: %s concede +%d de Armadura a %s." % [card.name,card.entry_value,ally.name])
  CardData.EntryEffect.POISON_ALL_ENEMIES:
   var affected:=0
   for victim in players[1-side].board:
    if victim.health>0 and int(card.entry_value)>0 and apply_poison(victim,int(card.entry_value)):
     record_poison(1-side,victim,int(card.entry_value))
     affected+=1
   log_event("Chamado: %s aplica Veneno %d a %d criatura(s) inimiga(s)." % [card.name,card.entry_value,affected])
  CardData.EntryEffect.POISON_ENEMY:
   if target>=0:
    var victim: Dictionary=players[1-side].board[target]
    if apply_poison(victim,int(card.entry_value)):
     last_action["poison_target"]=victim.id
     record_poison(1-side,victim,int(card.entry_value))
     log_event("Chamado: %s aplica Veneno %d a %s." % [card.name,card.entry_value,victim.name])
    else:log_event("%s é imune a Veneno." % victim.name)
  CardData.EntryEffect.SUMMON_AFTER_ENEMY_HUMAN_DEATH:
   if human_deaths[1-side]>0:
    var companion: Dictionary=spawn_unit(side,String(card.entry_summon_key))
    if not companion.is_empty():
     last_action["spawned"]=[{"side":side,"id":companion.id,"key":companion.key}]
     log_event("Chamado: %s invoca um Carniçal após a morte de um Humano inimigo." % card.name)
    else:log_event("Chamado de %s: sem espaço para o Carniçal." % card.name)
   else:log_event("Chamado de %s: nenhum Humano inimigo morreu nesta partida." % card.name)
  CardData.EntryEffect.SUMMON:
   var companion: Dictionary=spawn_unit(side,String(card.entry_summon_key))
   if not companion.is_empty():
    last_action["spawned"]=[{"side":side,"id":companion.id,"key":companion.key}]
    log_event("Chamado: %s invoca %s." % [card.name,companion.name])
   else:
    log_event("Chamado de %s: sem espaço para o Familiar." % card.name)
  CardData.EntryEffect.BUFF_OTHER_ALLIES:
   var recipients: Array=[]
   for ally in p.board:
    if ally.health>0 and not is_same(ally,unit):
     grant_stats(ally,int(card.entry_attack),int(card.entry_health))
     recipients.append(ally.id)
   last_action["buff_targets"]=recipients
   last_action["buff_attack"]=card.entry_attack
   last_action["buff_health"]=card.entry_health
   log_event("Chamado: %s concede +%d/+%d a %d outros aliados." % [card.name,card.entry_attack,card.entry_health,recipients.size()])
 log_event("%s invoca %s." % [side_name(side), card.name])
 refresh_auras()
 return true

static func is_undead(unit: Dictionary) -> bool:
 return int(unit.get("creature_type",-1))==CardData.CreatureType.UNDEAD

static func has_type(unit: Dictionary,value: int) -> bool:
 var kind:int=int(unit.get("creature_type",-1))
 return kind==value or (value==CardData.CreatureType.MONSTER and kind==CardData.CreatureType.HUMAN and unit.get("human_and_monster",false))

func record_death(owner: int,unit: Dictionary) -> void:
 var id: int=int(unit.get("id",-1))
 if recorded_deaths.has(id):return
 recorded_deaths[id]=true
 log_event("%s perde %s." % [side_name(owner),unit.name], owner)
 if int(unit.get("creature_type",-1))==CardData.CreatureType.HUMAN:human_deaths[owner]+=1

func remove_dead() -> void:
 for owner in range(players.size()):
  for unit in players[owner].board:
   if unit.health<=0:
    record_death(owner,unit)
    if not last_action.has("dead"):last_action["dead"]=[]
    if not last_action.dead.any(func(v):return v.side==owner and v.id==unit.id):last_action.dead.append({"side":owner,"id":unit.id})
  players[owner].board=players[owner].board.filter(func(u):return u.health>0)

func apply_healing(owner: int,unit: Dictionary,amount: int,source_side: int=-1) -> int:
 if is_undead(unit):
  var dealt: int=damage(unit,amount,true)
  last_action["undead_damage"]=true
  last_action["amount"]=dealt
  last_action["abascanto_blocked"]=dealt==0 and amount>0
  log_event("%s recebe %d de dano mágico por Cura." % [unit.name,dealt])
  if dealt>0:trigger_devotion(owner if source_side<0 else source_side)
  return 0
 var restored: int=mini(amount,int(unit.get("max_health",CARD_DATA[unit.key].health))-int(unit.health))
 unit.health+=restored
 record_heal(owner,unit,restored)
 if restored>0:log_event("%s recupera %d de vida por Cura." % [unit.name,restored])
 return restored

static func apply_poison(unit: Dictionary,amount: int) -> bool:
 if unit.get("wall",false):
  unit.poison=0
  return false
 unit.poison=int(unit.get("poison",0))+amount
 return true

func record_poison(side: int,unit: Dictionary,amount: int,castle: bool=false) -> void:
 if castle or amount<=0 or unit.get("wall",false):return
 if not last_action.has("poisoned"):last_action["poisoned"]=[]
 last_action.poisoned.append({"side":side,"id":-1 if castle else unit.id,"castle":castle,"amount":amount})
 log_event("%s recebe Veneno %d." % [unit.name,amount])

func record_heal(side: int,unit: Dictionary,amount: int,castle: bool=false) -> void:
 var cleansed: int=0 if castle else int(unit.get("poison",0))+int(unit.get("bleeding",0))
 if not castle:unit.poison=0;unit.bleeding=0
 if amount<=0 and cleansed<=0:return
 if not last_action.has("healed"):last_action["healed"]=[]
 last_action.healed.append({"side":side,"id":-1 if castle else unit.id,"castle":castle,"amount":amount,"cleansed":cleansed})
 if cleansed>0:log_event("Cura remove efeitos nocivos de %s." % unit.name)
 if amount<=0:return
 trigger_devotion(side)

func trigger_devotion(side: int) -> void:
 for observer in players[side].board:
  var bonus: int=int(observer.get("devotion",0))
  if observer.health<=0 or bonus<=0:continue
  grant_stats(observer,bonus,bonus)
  if not last_action.has("devotion_buffs"):last_action["devotion_buffs"]=[]
  last_action.devotion_buffs.append({"side":side,"id":observer.id,"amount":bonus})
  log_event("Devoção: %s ganha +%d/+%d após uma Cura aliada." % [observer.name,bonus,bonus],side)

func attack_blockers(side: int,index: int,target: int) -> Array[int]:
 if opening or winner!=-1 or turn!=side or side<0 or side>1:return []
 if index<0 or index>=players[side].board.size():return []
 var unit: Dictionary=players[side].board[index]
 if not unit.ready or unit.get("wall",false) or has_flying(unit) or physical_attack(unit)<=0:return []
 var guards:=blockers(1-side)
 return guards if not guards.is_empty() and target not in guards else []

static func damage(unit: Dictionary, amount: int, magical: bool = false) -> int:
 if magical and amount>0 and int(unit.get("abascanto",0))>0:
  unit.abascanto-=1
  return 0
 var dealt: int = amount if magical else maxi(0, amount - int(unit.armor))
 unit.health -= dealt
 return dealt

func blockers(side: int) -> Array[int]:
 var result: Array[int] = []
 for i in range(players[side].board.size()):
  if players[side].board[i].get("block", 0) > 0:
   result.append(i)
 return result

func can_target(side: int, index: int, target: int, magical: bool = false) -> bool:
 refresh_auras()
 if opening or winner != -1 or side != turn:
  return false
 var p: Dictionary = players[side]
 var foe: Dictionary = players[1 - side]
 if index < 0 or index >= p.board.size() or target < -1 or target >= foe.board.size():
  return false
 var unit: Dictionary = p.board[index]
 if not unit.ready:
  return false
 if magical:
  return unit.get("magic_damage", 0) > 0 and p.mana >= unit.get("magic_cost", 1) and (target>=0 or int(unit.get("magic_splash",0))==0)
 if unit.get("wall",false) or physical_attack(unit) <= 0:
  return false
 var guards := blockers(1 - side)
 return has_flying(unit) or guards.is_empty() or target in guards

func has_magic_target(side: int,index: int) -> bool:
 if can_target(side,index,-1,true):return true
 for target in range(players[1-side].board.size()):
  if can_target(side,index,target,true):return true
 return false

func magic_hit_plan(side: int,index: int,target: int) -> Array:
 var result: Array=[]
 if target<0:return result
 var unit: Dictionary=players[side].board[index]
 var board: Array=players[1-side].board
 var splash: int=int(unit.get("magic_splash",0))
 var targets: Array=[target]
 if splash>0:
  if target>0:targets.append(target-1)
  if target+1<board.size():targets.append(target+1)
 var bonus: int=magic_bonus(side)
 for at in targets:
  var victim: Dictionary=board[at]
  var power: int=(int(unit.magic_damage) if at==target else splash)+bonus
  result.append({"index":at,"side":1-side,"id":victim.id,"castle":false,"power":power,"amount":0 if int(victim.get("abascanto",0))>0 else power})
 return result

func attack_forecast(side: int,index: int,target: int,magical: bool=false) -> Dictionary:
 if not can_target(side,index,target,magical):return {}
 var attacker: Dictionary=players[side].board[index]
 var defender: Dictionary={} if target<0 else players[1-side].board[target]
 var power: int=int(attacker.get("magic_damage",0))+magic_bonus(side) if magical else physical_attack(attacker)
 var absorbed: int=0 if magical or target<0 else mini(power,maxi(0,int(defender.get("armor",0))))
 var flight_reduction: int=0 if magical or target<0 or not has_flying(defender) else mini(1,maxi(0,power-absorbed))
 var warded: bool=magical and target>=0 and int(defender.get("abascanto",0))>0
 var dealt: int=0 if warded else maxi(0,power-absorbed-flight_reduction)
 var counter: int=0 if magical or target<0 else defense_attack(defender)
 var counter_absorbed: int=mini(counter,maxi(0,int(attacker.get("armor",0))))
 var received: int=maxi(0,counter-counter_absorbed)
 var bleeding: int=int(attacker.get("bleeding",0))
 if not magical and target>=0 and counter>0 and not attacker.get("wall",false):bleeding+=int(defender.get("bleed",0))
 var target_health: int=int(players[1-side].hp) if target<0 else int(defender.health)
 return {"damage":dealt,"received":received,"absorbed":absorbed,"flight_reduction":flight_reduction,"counter_absorbed":counter_absorbed,"bleeding":bleeding,"warded":warded,"splash_hits":magic_hit_plan(side,index,target) if magical and int(attacker.get("magic_splash",0))>0 else [],"castle":target<0,"target_dies":dealt>=target_health,"attacker_dies":received+bleeding>=int(attacker.health)+(int(attacker.get("resonance",0)) if magical else 0)}

func preferred_attack_target(side: int,index: int) -> int:
 # -1 is the castle; -2 means no legal physical attack.
 if can_target(side,index,-1,false):return -1
 if side<0 or side>=players.size():return -2
 for target in range(players[1-side].board.size()):
  if can_target(side,index,target,false):return target
 return -2

func apply_bleeding(unit: Dictionary,amount: int,side: int) -> void:
 if amount<=0 or unit.get("wall",false):return
 unit.bleeding=int(unit.get("bleeding",0))+amount
 if not last_action.has("bleeding_applied"):last_action["bleeding_applied"]=[]
 last_action.bleeding_applied.append({"side":side,"id":unit.id,"castle":false,"amount":amount})
 log_event("%s recebe Sangramento %d." % [unit.name,amount])

func trigger_bleeding(unit: Dictionary,side: int) -> void:
 var amount:int=int(unit.get("bleeding",0))
 if amount<=0 or unit.health<=0:return
 unit.health-=amount
 last_action["bleeding_damage"]=[{"side":side,"id":unit.id,"castle":false,"amount":amount}]
 log_event("%s sofre %d de Sangramento após agir." % [unit.name,amount])

func fury(side: int, index: int) -> bool:
 if opening or winner != -1 or side != turn or index < 0 or index >= players[side].board.size():
  return false
 var p: Dictionary = players[side]
 var unit: Dictionary = p.board[index]
 if unit.get("fury", 0) <= 0 or unit.get("fury_used",false) or p.mana < 1:
  return false
 spend_mana(p,1)
 unit.fury_used=true
 unit.actions_taken=int(unit.get("actions_taken",0))+1
 unit.attack += unit.fury
 last_action = {"kind": "fury", "side": side, "attacker": unit.get("id", -1), "dead": []}
 trigger_bleeding(unit,side)
 remove_dead();refresh_auras();check_winner()
 log_event("%s usa Fúria %d: ataque agora %d, sem esgotar." % [unit.name, unit.fury, physical_attack(unit)])
 return true

func can_heal(side: int, index: int, target: int, target_side: int=-1, quick: bool=false) -> bool:
 if opening or winner!=-1 or side!=turn or side<0 or side>=players.size():return false
 var owner: int=side if target_side<0 else target_side
 if owner<0 or owner>=players.size():return false
 var p: Dictionary=players[side]
 if index<0 or index>=p.board.size() or target < -1 or target>=players[owner].board.size():return false
 var caster: Dictionary=p.board[index]
 if quick:
  if caster.get("quick_heal_amount",0)<=0 or caster.get("quick_heal_used",false) or p.mana<caster.get("quick_heal_cost",1):return false
 else:
  if not caster.ready or caster.get("heal_amount",0)<=0 or p.mana<caster.get("heal_cost",1):return false
 if quick and target==-1:return false
 if target==-1:return owner==side and p.hp>0 and p.hp<20
 var unit: Dictionary=players[owner].board[target]
 if unit.health<=0:return false
 if is_undead(unit):return true
 return owner==side and not unit.get("wall",false) and (unit.health<int(unit.get("max_health",CARD_DATA[unit.key].health)) or int(unit.get("poison",0))>0 or int(unit.get("bleeding",0))>0)

func heal(side: int, index: int, target: int, target_side: int=-1, quick: bool=false) -> bool:
 if not can_heal(side,index,target,target_side,quick):return false
 var owner: int=side if target_side<0 else target_side
 var p: Dictionary=players[side]
 var caster: Dictionary=p.board[index]
 var unit: Dictionary={} if target<0 else players[owner].board[target]
 last_action={"kind":"heal","side":side,"attacker":caster.id,"target_side":owner,"target":-1 if target<0 else unit.id,"castle":target<0,"dead":[]}
 var amount: int=int(caster.get("quick_heal_amount",0)) if quick else int(caster.heal_amount)
 spend_mana(p,int(caster.get("quick_heal_cost",1)) if quick else int(caster.heal_cost))
 if quick:caster.quick_heal_used=true
 else:caster.ready=false
 caster.actions_taken=int(caster.get("actions_taken",0))+1
 if not quick:caster.exhausting_action_taken=true
 if target<0:
  var restored: int=mini(amount,20-int(p.hp))
  p.hp+=restored
  record_heal(side,{},restored,true)
  log_event("%s cura %d de vida do %s." % [caster.name,restored,castle_name(side)])
 else:
  apply_healing(owner,unit,amount,side)
  if is_undead(unit):last_action.kind="magic"
 if quick:log_event("%s usa Cura Célere %d." % [caster.name,amount],side)
 trigger_bleeding(caster,side)
 remove_dead()
 refresh_auras()
 check_winner()
 return true

func act(side: int, index: int, target: int, magical: bool = false) -> bool:
 if not can_target(side, index, target, magical):
  return false
 var p: Dictionary = players[side]
 var foe: Dictionary = players[1 - side]
 if index < 0 or index >= p.board.size() or target < -1 or target >= foe.board.size():
  return false
 var unit: Dictionary = p.board[index]
 if not unit.ready:
  return false
 last_action = {"kind": "magic" if magical else "attack", "side": side, "attacker": unit.get("id", -1), "target": -1 if target == -1 else foe.board[target].get("id", -1), "castle": target == -1, "dead": []}
 unit.ready = false
 unit.actions_taken=int(unit.get("actions_taken",0))+1
 unit.exhausting_action_taken=true
 if not magical:unit.attacked_this_turn=true
 if magical:
  spend_mana(p,unit.magic_cost)
  if int(unit.get("magic_splash",0))>0:
   last_action["fire_hits"]=[]
   for hit in magic_hit_plan(side,index,target):
    var victim: Dictionary=foe.board[hit.index]
    hit.amount=damage(victim,int(hit.power),true)
    hit["abascanto_blocked"]=hit.amount==0 and hit.power>0
    last_action.fire_hits.append(hit)
    if hit.index==target:
     last_action["amount"]=hit.amount
     last_action["abascanto_blocked"]=hit.abascanto_blocked
    log_event("Mãos Flamejantes de %s: %d de dano mágico em %s." % [unit.name,hit.amount,victim.name])
  else:
   var total_magic: int = unit.magic_damage + magic_bonus(side)
   var dealt: int=total_magic if target<0 else damage(foe.board[target],total_magic,true)
   if target<0:foe.hp-=dealt
   last_action["amount"]=dealt
   last_action["abascanto_blocked"]=target>=0 and dealt==0 and total_magic>0
   log_event("%s: Guarda Arcana anula o dano mágico." % foe.board[target].name if last_action.abascanto_blocked else "%s causa %d de dano mágico em %s." % [unit.name,dealt,castle_name(1-side) if target<0 else foe.board[target].name])
  trigger_resonance(side)
 elif target == -1:
  last_action["amount"]=physical_attack(unit)
  foe.hp -= physical_attack(unit)
  foe.poison=0
  log_event("%s ataca o %s e causa %d de dano." % [unit.name, castle_name(1-side), physical_attack(unit)])
  var loot: int=int(unit.get("loot",0))
  if loot>0:
   log_event("%s ativa Saquear %d." % [unit.name,loot],side)
   for i in range(loot):draw(side,false)
 else:
  var defender: Dictionary = foe.board[target]
  if defender.get("block", 0) > 0:
   defender.block -= 1
   log_event("Bloqueio de %s consumido." % defender.name)
  var counter: int = defense_attack(defender)
  var physical: int=physical_attack(unit)
  var armor_absorbed: int=mini(physical,maxi(0,int(defender.get("armor",0))))
  var flight_reduction: int=mini(1,maxi(0,physical-armor_absorbed)) if has_flying(defender) else 0
  var counter_absorbed: int=mini(counter,maxi(0,int(unit.get("armor",0))))
  var dealt := damage(defender, physical-flight_reduction)
  var received := damage(unit, counter)
  last_action["amount"]=dealt
  last_action["received"]=received
  last_action["absorbed"]=armor_absorbed
  last_action["flight_reduction"]=flight_reduction
  last_action["counter_absorbed"]=counter_absorbed
  var attack_poison: int=int(unit.get("envenom",0))
  if attack_poison>0 and apply_poison(defender,attack_poison):
   record_poison(1-side,defender,attack_poison)
  var counter_poison: int=int(defender.get("envenom",0))
  if counter>0 and counter_poison>0 and apply_poison(unit,counter_poison):
   record_poison(side,unit,counter_poison)
  apply_bleeding(defender,int(unit.get("bleed",0)),1-side)
  if counter>0:apply_bleeding(unit,int(defender.get("bleed",0)),side)
  log_event("%s ataca %s: %d dano, %d recebido." % [unit.name, defender.name, dealt, received])
 trigger_bleeding(unit,side)
 remove_dead()
 refresh_auras()
 check_winner()
 return true

func check_winner() -> void:
 if players.size() < 2:
  return
 if players[0].hp <= 0 and players[1].hp <= 0:
  winner = 2
 elif players[0].hp <= 0:
  winner = 1
 elif players[1].hp <= 0:
  winner = 0

# Scores reflect actual damage and remaining protection, not printed attack alone.
func ai_magic_score(victim: Dictionary,amount: int) -> int:
 if int(victim.get("abascanto",0))>0:return -3
 var damage_amount: int=maxi(0,amount)
 var threat: int=physical_attack(victim)+int(victim.get("magic_damage",0))*2+int(victim.get("heal_amount",0))+int(victim.get("envenom",0))
 return mini(damage_amount,int(victim.health))*3+threat+(12 if int(victim.health)<=damage_amount else 0)

func ai_best_magic_target(side: int,amount: int,excluded: Array = []) -> int:
 var best: int=-1
 var best_score: int=-999999
 for index in range(players[1-side].board.size()):
  if index in excluded:continue
  var score: int=ai_magic_score(players[1-side].board[index],amount)
  if score>best_score:
   best_score=score
   best=index
 return best

func ai_magic_target(side: int,index: int) -> int:
 var unit: Dictionary=players[side].board[index]
 if int(unit.get("magic_splash",0))==0:return ai_best_magic_target(side,int(unit.magic_damage)+magic_bonus(side))
 var best: int=-1
 var best_score: int=-999999
 for target in range(players[1-side].board.size()):
  var score:=0
  for hit in magic_hit_plan(side,index,target):score+=ai_magic_score(players[1-side].board[hit.index],int(hit.power))
  if score>best_score:best=target;best_score=score
 return best if best_score>0 else -1

func ai_attack_score(attacker: Dictionary,defender: Dictionary) -> int:
 var dealt: int=maxi(0,physical_attack(attacker)-int(defender.get("armor",0))-(1 if has_flying(defender) else 0))
 var received: int=maxi(0,defense_attack(defender)-int(attacker.get("armor",0)))
 var kills: bool=dealt>=int(defender.health)
 var dies: bool=received>=int(attacker.health)
 var enemy_threat: int=physical_attack(defender)+int(defender.get("magic_damage",0))*2+int(defender.get("heal_amount",0))+int(defender.get("envenom",0))
 var own_value: int=physical_attack(attacker)+int(attacker.get("magic_damage",0))*2+int(attacker.get("heal_amount",0))
 var score: int=mini(dealt,int(defender.health))*2+enemy_threat+(12 if kills else 0)
 score-=mini(received,int(attacker.health))*2+(12+own_value if dies else 0)
 if int(attacker.get("envenom",0))>0 and not defender.get("wall",false):score+=3
 if int(defender.get("envenom",0))>0 and not attacker.get("wall",false):score-=3
 return score

func ai_quick_heal(index: int) -> bool:
 var actor: Dictionary=players[1].board[index]
 var amount: int=int(actor.get("quick_heal_amount",0))
 if amount<=0 or actor.get("quick_heal_used",false):return false
 var best_side: int=-1
 var best_index: int=-1
 var best_score: int=0
 for side in [0,1]:
  for j in range(players[side].board.size()):
   if not can_heal(1,index,j,side,true):continue
   var target: Dictionary=players[side].board[j]
   if side==0:
    var score: int=ai_magic_score(target,amount)
    if score>best_score:best_score=score;best_side=side;best_index=j
   elif not is_undead(target):
    var missing: int=int(target.get("max_health",target.health))-int(target.health)
    var score: int=mini(amount,missing)*2+int(target.get("poison",0))*3+int(target.get("bleeding",0))*3
    if int(target.health)<=2 and missing>0:score+=2
    if score>best_score:best_score=score;best_side=side;best_index=j
 return best_index>=0 and best_score>0 and heal(1,index,best_index,best_side,true)

func ai_step() -> bool:
 refresh_auras()
 if opening or turn != 1 or winner != -1:return false
 var p: Dictionary=players[1]
 var enemy: Dictionary=players[0]
 # Immediate castle lethal takes precedence over setup and healing.
 for i in range(p.board.size()):
  if can_target(1,i,-1,false) and physical_attack(p.board[i])>=enemy.hp:return act(1,i,-1)
 for i in range(p.board.size()):
  var caster: Dictionary=p.board[i]
  var amount: int=int(caster.get("magic_damage",0))+magic_bonus(1)
  if int(caster.get("magic_damage",0))>0 and amount>=enemy.hp and can_target(1,i,-1,true):return act(1,i,-1,true)
 # Prefer useful healing and magic, accounting for magical protection.
 for i in range(p.board.size()):
  if ai_quick_heal(i):return true
  var actor: Dictionary=p.board[i]
  if not actor.ready:continue
  var heal_amount: int=int(actor.get("heal_amount",0))
  if heal_amount>0:
   var best_undead: int=-1
   var best_undead_score: int=0
   for j in range(enemy.board.size()):
    if not is_undead(enemy.board[j]) or not can_heal(1,i,j,0):continue
    var score: int=ai_magic_score(enemy.board[j],heal_amount)
    if score>best_undead_score:best_undead_score=score;best_undead=j
   if best_undead>=0:return heal(1,i,best_undead,0)
   var best_heal: int=-1
   var best_heal_score: int=0
   for j in range(p.board.size()):
    var target: Dictionary=p.board[j]
    if is_undead(target) or not can_heal(1,i,j):continue
    var missing: int=int(target.get("max_health",target.health))-int(target.health)
    var score: int=mini(heal_amount,missing)*2+int(target.get("poison",0))*3+int(target.get("bleeding",0))*3
    if target.get("vigor",false):score+=mini(heal_amount,missing)*2
    if int(target.health)<=2 and missing>0:score+=2
    if score>best_heal_score:best_heal_score=score;best_heal=j
   if best_heal>=0 and best_heal_score>=2:return heal(1,i,best_heal)
   if p.hp<=12 and can_heal(1,i,-1):return heal(1,i,-1)
  var magic_damage: int=int(actor.get("magic_damage",0))+magic_bonus(1)
  if int(actor.get("magic_damage",0))>0 and p.mana>=int(actor.get("magic_cost",1)):
   var j:=ai_magic_target(1,i)
   if j<0 and can_target(1,i,-1,true):return act(1,i,-1,true)
   if j>=0 and can_target(1,i,j,true) and (int(actor.get("magic_splash",0))>0 or ai_magic_score(enemy.board[j],magic_damage)>0):
    if int(actor.get("magic_splash",0))>0 or int(enemy.board[j].health)<=magic_damage or int(enemy.board[j].get("armor",0))>0 or physical_attack(actor)==0:
     return act(1,i,j,true)
 # Play affordable cards before spending leftover mana on permanent Fury.
 for i in range(p.hand.size()):
  var card: Dictionary=CARDS[p.hand[i]]
  if p.mana<card.cost:continue
  if card.get("card_type",0)==CardData.CardType.SPELL:
   var choice:=ai_spell_target(i)
   if not choice.is_empty():return cast(1,i,choice.side,choice.index)
  elif p.board.size()<MAX_BOARD:
   var target: int=entry_target(1,card) if entry_target_side(1,card)>=0 else -1
   if can_play(1,i,target):return play(1,i,target,ai_rogue_choice(1,target) if int(card.get("entry_effect",0))==CardData.EntryEffect.GRANT_ROGUE_CHOICE and target>=0 else "")
 # Fury is permanent and does not exhaust; do not sacrifice its user to bleeding.
 for i in range(p.board.size()):
  var unit: Dictionary=p.board[i]
  if int(unit.get("fury",0))>0 and not unit.get("fury_used",false) and p.mana>=1 and int(unit.health)>int(unit.get("bleeding",0)):
   return fury(1,i)
 # Favor a safe, valuable trade; otherwise attack the castle when legal.
 for i in range(p.board.size()):
  var unit: Dictionary=p.board[i]
  if not unit.ready or unit.get("wall",false) or physical_attack(unit)<=0:continue
  var best: int=-1
  var best_score: int=-999999
  for j in range(enemy.board.size()):
   if not can_target(1,i,j):continue
   var score: int=ai_attack_score(unit,enemy.board[j])
   if score>best_score:best_score=score;best=j
  if best>=0 and best_score>=12:return act(1,i,best)
  if can_target(1,i,-1):return act(1,i,-1)
  if best>=0:return act(1,i,best)
 return false
func trigger_resonance(side: int) -> void:
 for unit in players[side].board:
  var bonus: int=int(unit.get("resonance",0))
  if bonus<=0 or unit.health<=0:continue
  grant_stats(unit,bonus,bonus)
  unit.resonance_bonus=int(unit.get("resonance_bonus",0))+bonus
  if not last_action.has("resonance_buffs"):last_action["resonance_buffs"]=[]
  last_action.resonance_buffs.append({"side":side,"id":unit.id,"amount":bonus})
  log_event("Ressonância: %s ganha +%d/+%d até seu próximo turno." % [unit.name,bonus,bonus],side)

func magic_bonus(side: int) -> int:
 var total := 0
 for unit in players[side].board:
  if unit.health > 0:
   total += int(unit.get("magic_power",0))
 return total

func can_cast(side: int, hand_index: int, target_side: int, target: int) -> bool:
 if opening or winner != -1 or side != turn or side < 0 or side > 1:
  return false
 var p: Dictionary = players[side]
 if hand_index < 0 or hand_index >= p.hand.size() or target_side < 0 or target_side > 1:
  return false
 var card: Dictionary = CARDS[p.hand[hand_index]]
 if card.get("card_type",0) != CardData.CardType.SPELL or p.mana < card.cost:
  return false
 if card.get("neutral_deck_only",false) and not p.get("neutral_deck",false):return false
 var target_player: Dictionary = players[target_side]
 if target < -1 or target >= target_player.board.size():
  return false
 if target >= 0 and target_player.board[target].health <= 0:
  return false
 match int(card.spell_effect):
  CardData.SpellEffect.MAGIC_MISSILES:
   return target_side==1-side and (target>=0 or target==-1) and players[1-side].board.size()>=1
  CardData.SpellEffect.HORDE_ROAR:
   return target_side==side and target==-1 and players[side].board.any(func(unit):return unit.health>0 and has_type(unit,CardData.CreatureType.MONSTER))
  CardData.SpellEffect.AREA_ARCANE:
   return target_side==1-side and target==-1 and not target_player.board.is_empty()
  CardData.SpellEffect.RECONSTRUCT:
   return target_side==side and (target==-1 or target_player.board[target].get("wall",false))
  CardData.SpellEffect.ARCANE:
   return target_side==1-side
  CardData.SpellEffect.CONDUCTIVE:
   return target_side == 1-side and target >= 0
  CardData.SpellEffect.VIGOR:
   return target_side==side and target>=0 and not target_player.board[target].get("vigor",false)
  CardData.SpellEffect.FORTIFY, CardData.SpellEffect.SHADOW_STEP:
   return target_side == side and target >= 0
  CardData.SpellEffect.RESTORE:
   if target==-1:return target_side==side and p.hp>0 and p.hp<20
   var unit: Dictionary=target_player.board[target]
   if is_undead(unit):return true
   return target_side==side and not unit.get("wall",false) and (unit.health<int(unit.get("max_health",CARD_DATA[unit.key].health)) or int(unit.get("poison",0))>0 or int(unit.get("bleeding",0))>0)
 return false

func has_spell_target(side: int, hand_index: int) -> bool:
 for owner in range(2):
  for target in range(-1,players[owner].board.size()):
   if can_cast(side,hand_index,owner,target):
    return true
 return false

func neutral_field(side: int) -> bool:
 for unit in players[side].board:
  if unit.health>0 and unit_class(unit)!=CardData.CardClass.NEUTRAL:return false
 return true

func spell_target_count(side: int,hand_index: int) -> int:
 if hand_index<0 or hand_index>=players[side].hand.size():return 0
 return 2 if int(CARDS[players[side].hand[hand_index]].get("spell_effect",0))==CardData.SpellEffect.MAGIC_MISSILES else 1

func cast_multiple(side: int,hand_index: int,targets: Array) -> bool:
 if spell_target_count(side,hand_index)!=2 or targets.size()!=2:return false
 if targets[0]==targets[1]:return false
 for target in targets:
  if not target is Dictionary or not target.has("side") or not target.has("index") or not can_cast(side,hand_index,target.side,target.index):return false
 if targets[0].side==targets[1].side and targets[0].index==targets[1].index:return false
 var p:Dictionary=players[side]
 var key:String=p.hand[hand_index]
 var card:Dictionary=CARDS[key]
 if int(card.spell_effect)!=CardData.SpellEffect.MAGIC_MISSILES:return false
 var amount:int=int(card.spell_value)+magic_bonus(side)
 last_action={"kind":"spell","side":side,"attacker":-1,"target_side":1-side,"target":-1,"castle":false,"effect":card.spell_effect,"card":key,"dead":[],"missile_hits":[]}
 spend_mana(p,card.cost);p.hand.remove_at(hand_index)
 for target in targets:
  var is_castle: bool=target.index<0
  var victim: Dictionary={} if is_castle else players[target.side].board[target.index]
  var dealt: int=amount if is_castle else damage(victim,amount,true)
  if is_castle:players[target.side].hp-=dealt
  last_action.missile_hits.append({"side":target.side,"id":-1 if is_castle else victim.id,"castle":is_castle,"amount":dealt})
  log_event("Míssil atinge %s: %d de dano mágico." % [castle_name(target.side) if is_castle else victim.name,dealt])
 trigger_resonance(side)
 remove_dead();refresh_auras();check_winner()
 log_event("%s conjura Mísseis Mágicos em dois alvos." % side_name(side))
 return true

func cast(side: int, hand_index: int, target_side: int, target: int) -> bool:
 if side>=0 and side<players.size() and spell_target_count(side,hand_index)==2:
  if side!=1:return false
  if players[1-side].board.is_empty():return false
  var amount: int=int(CARDS[players[side].hand[hand_index]].spell_value)+magic_bonus(side)
  var first:=ai_best_magic_target(side,amount)
  if first<0:return false
  var second:=ai_best_magic_target(side,amount,[first])
  var castle_score: int=100 if players[1-side].hp<=amount else 3
  if second<0 or castle_score>ai_magic_score(players[1-side].board[second],amount):second=-1
  return cast_multiple(side,hand_index,[{"side":1-side,"index":first},{"side":1-side,"index":second}])
 if not can_cast(side,hand_index,target_side,target):
  return false
 var p: Dictionary = players[side]
 var key: String = p.hand[hand_index]
 var card: Dictionary = CARDS[key]
 var unit: Dictionary = {} if target < 0 else players[target_side].board[target]
 last_action = {"kind":"spell","side":side,"attacker":-1,"target_side":target_side,"target":-1 if target<0 else unit.get("id",-1),"castle":target<0 and card.spell_effect not in [CardData.SpellEffect.AREA_ARCANE,CardData.SpellEffect.HORDE_ROAR],"effect":card.spell_effect,"card":key,"dead":[]}
 spend_mana(p,card.cost)
 p.hand.remove_at(hand_index)
 match int(card.spell_effect):
  CardData.SpellEffect.HORDE_ROAR:
   last_action["buffs"]=[]
   for ally in p.board:
    if ally.health>0 and has_type(ally,CardData.CreatureType.MONSTER):
     ally["turn_attack"]=int(ally.get("turn_attack",0))+int(card.spell_value)
     last_action.buffs.append({"side":side,"id":ally.id,"castle":false,"amount":card.spell_value})
  CardData.SpellEffect.AREA_ARCANE:
   var total: int=int(card.spell_value)+magic_bonus(side)
   last_action["area_hits"]=[]
   for victim in players[1-side].board:
    var dealt: int=damage(victim,total,true)
    last_action.area_hits.append({"side":1-side,"id":victim.id,"castle":false,"amount":dealt,"abascanto_blocked":dealt==0 and total>0})
    if dealt==0 and total>0:log_event("%s: Guarda Arcana anula a magia." % victim.name)
  CardData.SpellEffect.RECONSTRUCT:
   if target<0:
    var restored: int=mini(card.spell_secondary,20-int(p.hp))
    p.hp+=restored
    record_heal(side,{},restored,true)
   else:
    apply_healing(target_side,unit,int(card.spell_secondary),side)
   if neutral_field(side):draw(side,false)
  CardData.SpellEffect.FORTIFY:
   unit.attack += card.spell_value
   unit.armor += card.spell_secondary
   if unit.get("collective",false):unit.granted_block=int(unit.get("granted_block",0))+1
   unit.block_capacity = block_capacity(unit) + 1
   unit.block = int(unit.get("block",0)) + 1
   last_action["armor_gain"]=int(card.spell_secondary)
  CardData.SpellEffect.ARCANE, CardData.SpellEffect.CONDUCTIVE:
   var total: int=spell_damage(side,card,unit)
   var dealt: int=total if target<0 else damage(unit,total,true)
   if target<0:players[target_side].hp-=dealt
   last_action["amount"]=dealt
   last_action["abascanto_blocked"]=dealt==0 and total>0
   log_event("%s causa %d de dano mágico em %s." % [card.name,dealt,castle_name(target_side) if target<0 else unit.name])
   if last_action.abascanto_blocked:log_event("%s: Guarda Arcana anula a magia." % unit.name)
  CardData.SpellEffect.VIGOR:
   unit.vigor = true
   unit.granted_vigor=true
  CardData.SpellEffect.SHADOW_STEP:
   unit["turn_attack"]=int(unit.get("turn_attack",0))+int(card.spell_value)
   unit["turn_flying"]=true
   unit["turn_swift"]=true
   if unit.get("summoned_this_turn",false) and not unit.get("exhausting_action_taken",false) and not unit.get("wall",false):unit.ready=true
  CardData.SpellEffect.RESTORE:
   if target < 0:
    var restored: int=mini(card.spell_value,20-int(p.hp))
    p.hp+=restored
    record_heal(side,{},restored,true)
   else:
    apply_healing(target_side,unit,int(card.spell_value),side)
 trigger_resonance(side)
 remove_dead()
 refresh_auras()
 if card.spell_effect==CardData.SpellEffect.HORDE_ROAR:
  log_event("%s conjura %s: Monstros aliados ganham +%d de ataque até o fim do turno." % [side_name(side),card.name,card.spell_value])
 elif card.spell_effect==CardData.SpellEffect.AREA_ARCANE:
  log_event("%s conjura %s: %d de dano mágico a todas as criaturas inimigas." % [side_name(side),card.name,card.spell_value+magic_bonus(side)])
 else:log_event("%s conjura %s em %s." % [side_name(side),card.name,castle_name(target_side) if target<0 else unit.name])
 check_winner()
 return true

func ai_spell_target(hand_index: int) -> Dictionary:
 var p: Dictionary = players[1]
 var card: Dictionary = CARDS[p.hand[hand_index]]
 var owner := 0 if card.spell_effect in [CardData.SpellEffect.ARCANE,CardData.SpellEffect.CONDUCTIVE,CardData.SpellEffect.AREA_ARCANE,CardData.SpellEffect.MAGIC_MISSILES] else 1
 if card.spell_effect==CardData.SpellEffect.RESTORE:
  for target in range(players[0].board.size()):
   if can_cast(1,hand_index,0,target) and ai_magic_score(players[0].board[target],int(card.spell_value))>0:return {"side":0,"index":target}
 var best := {}
 var best_score := -1
 for target in range(-1,players[owner].board.size()):
  if not can_cast(1,hand_index,owner,target):
   continue
  var score := 0
  var unit: Dictionary = {} if target < 0 else players[owner].board[target]
  match int(card.spell_effect):
   CardData.SpellEffect.HORDE_ROAR:
    for ally in p.board:
     if ally.health>0 and ally.ready and not ally.get("wall",false) and has_type(ally,CardData.CreatureType.MONSTER):score+=int(card.spell_value)*3
    if score==0:continue
   CardData.SpellEffect.AREA_ARCANE:
    for victim in players[0].board:
     var hit: int=spell_damage(1,card,victim)
     score+=mini(hit,int(victim.health))+(5 if victim.health<=hit else 0)
   CardData.SpellEffect.ARCANE, CardData.SpellEffect.CONDUCTIVE:
    score = (100 if players[owner].hp<=spell_damage(1,card,{}) else 3) if target<0 else ai_magic_score(unit,spell_damage(1,card,unit))
    if score<0:continue
   CardData.SpellEffect.VIGOR:
    score = maxi(0,unit.health-unit.attack)*2+unit.get("growth",0)*2
    if score<=0:continue
   CardData.SpellEffect.FORTIFY:
    score = unit.attack+unit.health+(4 if unit.get("block",0)>0 else 0)
   CardData.SpellEffect.SHADOW_STEP:
    if unit.get("wall",false) or (not unit.ready and (not unit.get("summoned_this_turn",false) or unit.get("exhausting_action_taken",false))):
     continue
    score = (physical_attack(unit)+int(card.spell_value))*3
   CardData.SpellEffect.RECONSTRUCT:
    score=(3 if neutral_field(1) else 0)+mini(card.spell_secondary,20-int(p.hp) if target<0 else int(unit.get("max_health",CARD_DATA[unit.key].health))-int(unit.health))
    if score<=0:continue
   CardData.SpellEffect.RESTORE:
    if target>=0 and is_undead(unit):continue
    score = 20-p.hp if target<0 else int(unit.get("max_health",CARD_DATA[unit.key].health))-unit.health+int(unit.get("poison",0))*2
    if score<2:
     continue
  if score>best_score:
   best_score=score
   best={"side":owner,"index":target}
 return best
static func attack_value(unit: Dictionary) -> int:
 return int(unit.attack)+int(unit.get("aura_attack",0))+int(unit.get("turn_attack",0))

static func has_flying(unit: Dictionary) -> bool:
 return bool(unit.get("flying",false)) or bool(unit.get("turn_flying",false))

static func physical_attack(unit: Dictionary) -> int:
 var attack:=attack_value(unit)
 return maxi(attack,int(unit.health)) if unit.get("vigor",false) else attack

static func defense_attack(unit: Dictionary) -> int:
 return physical_attack(unit)

func spell_damage(side: int, card: Dictionary, target: Dictionary) -> int:
 var value: int = int(card.spell_value)+magic_bonus(side)
 if int(card.spell_effect)==CardData.SpellEffect.CONDUCTIVE and int(target.get("armor",0))>0:
  value *= 2
 return value

func mulligan_limit(side: int) -> int:
 return 1

func mulligan_max_cards(side: int) -> int:
 return players[side].hand.size()

func mulligan(side: int, indices: Array) -> bool:
 if not opening or side<0 or side>1 or mulligan_done[side]:
  return false
 var p: Dictionary=players[side]
 var seen: Dictionary={}
 for index in indices:
  if not index is int or index<0 or index>=p.hand.size() or seen.has(index):
   return false
  seen[index]=true
 if indices.size()>p.deck.size() or indices.size()>mulligan_max_cards(side):
  return false
 var returned: Array=[]
 for index in indices:
  returned.append(p.hand[index])
  p.hand[index]=p.deck.pop_back()
 p.deck.append_array(returned)
 p.deck.shuffle()
 mulligan_rounds[side]+=1
 mulligan_done[side]=mulligan_rounds[side]>=mulligan_limit(side)
 log_event("%s troca %d carta(s) no mulligan." % [side_name(side),indices.size()], side)
 if mulligan_done[0] and mulligan_done[1]:
  opening=false
  turn=first_player
  begin_turn()
 return true

func resolve_poison(side: int) -> void:
 var p: Dictionary=players[side]
 var ticks: Array=[]
 var dead: Array=[]
 p.poison=0 # Castles are immune; discard any legacy status.
 var charges:=0
 for unit in p.board:
  if unit.get("wall",false):
   unit.poison=0
  charges=int(unit.get("poison",0))
  if charges>0:
   unit.health-=charges
   unit.poison=0
   ticks.append({"side":side,"id":unit.get("id",-1),"castle":false,"amount":charges})
   log_event("%s perde %d de vida por Veneno. Efeito encerrado." % [unit.name,charges])
  if unit.health<=0:
   record_death(side,unit)
   dead.append({"side":side,"id":unit.get("id",-1)})
 p.board=p.board.filter(func(u: Dictionary)->bool:return u.health>0)
 last_action={"kind":"poison" if not ticks.is_empty() else "turn_end","side":side,"ticks":ticks,"dead":dead}
 refresh_auras()
 check_winner()

func resolve_regeneration(side: int) -> void:
 for unit in players[side].board.duplicate():
  var amount: int=int(unit.get("regeneration",0))
  if unit.health<=0 or amount<=0:continue
  var restored: int=mini(amount,maxi(0,int(unit.get("max_health",CARD_DATA[unit.key].health))-int(unit.health)))
  if restored<=0:continue
  unit.health+=restored
  if not last_action.has("regenerated"):last_action["regenerated"]=[]
  last_action.regenerated.append({"side":side,"id":unit.id,"castle":false,"amount":restored})
  log_event("Regeneração: %s recupera %d de vida." % [unit.name,restored],side)
 remove_dead()
 refresh_auras()
 check_winner()

static func entry_target_side(side: int,card: Dictionary) -> int:
 match int(card.get("entry_effect",0)):
  CardData.EntryEffect.BUFF_ALLY,CardData.EntryEffect.ARMOR_ALLY,CardData.EntryEffect.BUFF_MONSTER_UNDEAD,CardData.EntryEffect.GRANT_ROGUE_CHOICE:return side
  CardData.EntryEffect.POISON_ENEMY:return 1-side
 return -1

func entry_valid_targets(side: int,card: Dictionary) -> Array:
 var owner:=entry_target_side(side,card)
 var result:=[]
 if owner<0:return result
 for i in range(players[owner].board.size()):
  var target: Dictionary=players[owner].board[i]
  if target.health<=0:continue
  if int(card.get("entry_effect",0))==CardData.EntryEffect.BUFF_MONSTER_UNDEAD and not (has_type(target,CardData.CreatureType.MONSTER) or has_type(target,CardData.CreatureType.UNDEAD)):continue
  result.append(i)
 return result

func spawn_unit(side: int,key: String) -> Dictionary:
 if not CARDS.has(key) or players[side].board.size()>=MAX_BOARD:return {}
 var card: Dictionary=CARDS[key]
 if card.get("card_type",0)!=CardData.CardType.CREATURE:return {}
 var unit: Dictionary=card.duplicate(true)
 unit.merge({"key":key,"id":next_id,"ready":card.get("swift",false),"max_health":card.health,"poison":0,"summoned_this_turn":true,"actions_taken":0,"exhausting_action_taken":false})
 next_id+=1
 players[side].board.append(unit)
 refresh_auras()
 unit.ready=unit.get("swift",false)
 return unit

func ai_rogue_choice(side: int,target: int) -> String:
 var ally: Dictionary=players[side].board[target]
 if ally.get("wall",false):return "envenom"
 if players[side].hand.size()<MAX_HAND_SIZE and not players[side].deck.is_empty() and (has_flying(ally) or blockers(1-side).is_empty()):return "loot"
 return "envenom"

func entry_target(side: int,card: Dictionary) -> int:
 refresh_auras()
 var owner:=entry_target_side(side,card)
 if owner<0:return -1
 var best: int=-1
 var score: int=-99999
 for i in range(players[owner].board.size()):
  if i not in entry_valid_targets(side,card):continue
  var ally: Dictionary=players[owner].board[i]
  var value: int=0
  match int(card.entry_effect):
   CardData.EntryEffect.POISON_ENEMY:
    var poison: int=int(ally.get("poison",0))+int(card.entry_value)
    value=physical_attack(ally)*2+ally.armor+(12 if ally.health<=poison else 0)
   CardData.EntryEffect.GRANT_ROGUE_CHOICE:
    value=ally.health+(5 if ally.ready else 0)+(5 if has_flying(ally) else 0)-(8 if ally.get("wall",false) else 0)
   CardData.EntryEffect.ARMOR_ALLY:
    value=ally.health+physical_attack(ally)+(5 if ally.get("block",0)>0 else 0)+(3 if ally.ready else 0)
   _:
    var boosted: Dictionary=ally.duplicate()
    boosted.attack+=int(card.get("entry_attack",0))
    boosted.health+=int(card.get("entry_health",0))
    value=(physical_attack(boosted)-physical_attack(ally))*5+ally.health+(3 if ally.ready else 0)+(2 if ally.get("flying",false) else 0)
  if value>score:
   score=value
   best=i
 return best

static func unit_class(unit: Dictionary) -> int:
 if unit.has("card_class"):return int(unit.card_class)
 var key: String=String(unit.get("key",""))
 return int(CARD_DATA[key].card_class) if CARD_DATA.has(key) else -1

static func grant_stats(unit: Dictionary,attack_bonus: int,health_bonus: int) -> void:
 unit.attack+=attack_bonus
 unit.health+=health_bonus
 unit.max_health=int(unit.get("max_health",CARD_DATA[unit.key].health))+health_bonus

func block_capacity(unit: Dictionary) -> int:
 return int(unit.get("block_capacity",CARD_DATA[unit.key].block))

func abascanto_capacity(unit: Dictionary) -> int:
 return int(unit.get("abascanto_capacity",CARD_DATA[unit.key].abascanto))

func card_for_unit(unit: Dictionary) -> CardData:
 var view: CardData=Collective.display_card(self,unit)
 if view.block!=block_capacity(unit) or view.loot!=int(unit.get("loot",0)) or view.envenom!=int(unit.get("envenom",0)):
  view=view.duplicate()
  view.block=block_capacity(unit)
  view.loot=int(unit.get("loot",0))
  view.envenom=int(unit.get("envenom",0))
 return view

func refresh_auras() -> void:
 # A source leaving can reduce a damaged collective's life to zero. Settle those deaths.
 for iteration in range(11):
  Collective.refresh(self)
  for player in players:
   for unit in player.board:unit["aura_attack"]=0
   for source in player.board:
    if source.health<=0:continue
    var auras: Array=source.get("inherited_auras",[]).duplicate()
    if int(source.get("aura_effect",0))!=CardData.AuraEffect.NONE:auras.append(source)
    for aura in auras:
     for target in player.board:
      if target.health<=0:continue
      if is_same(source,target) and not aura.get("aura_includes_self",true):continue
      if int(aura.get("aura_targets",0))==CardData.AuraTargets.ALLIED_NEUTRALS and unit_class(target)!=CardData.CardClass.NEUTRAL:continue
      if int(aura.aura_effect)==CardData.AuraEffect.ATTACK:target.aura_attack+=int(aura.aura_value)
  var departed:=false
  for owner in range(players.size()):
   for unit in players[owner].board.duplicate():
    if unit.get("collective",false) and unit.health<=0:
     record_death(owner,unit)
     if not last_action.has("dead"):last_action["dead"]=[]
     if not last_action.dead.any(func(v):return v.side==owner and v.id==unit.id):last_action.dead.append({"side":owner,"id":unit.id})
     players[owner].board.erase(unit)
     departed=true
  if not departed:return
