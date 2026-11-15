class_name DuelMatch
extends RefCounted

const MAX_HAND_SIZE := 7

static var CARD_DATA = {
 "gallant_farmer": preload("res://cards/gallant_farmer.tres"),
 "ruin_worg": preload("res://cards/ruin_worg.tres"),
 "wastes_anubite_stalker": preload("res://cards/wastes_anubite_stalker.tres"),
 "wastes_caravan_guide": preload("res://cards/wastes_caravan_guide.tres"),
 "wastes_camel": preload("res://cards/wastes_camel.tres"),
 "wastes_jackal_leader": preload("res://cards/wastes_jackal_leader.tres"),
 "wastes_ancient_worm": preload("res://cards/wastes_ancient_worm.tres"),
 "wastes_spitter": preload("res://cards/wastes_spitter.tres"),
 "orc_mine_caller": preload("res://cards/orc_mine_caller.tres"),
 "orc_miner": preload("res://cards/orc_miner.tres"),
 "orc_mine_overseer": preload("res://cards/orc_mine_overseer.tres"),
 "necropolis_ghost": preload("res://cards/necropolis_ghost.tres"),
 "luminary_healer": preload("res://cards/luminary_healer.tres"),
 "wastes_sandstorm": preload("res://cards/wastes_sandstorm.tres"),
 "wastes_bat": preload("res://cards/wastes_bat.tres"),
 "scarred_troll": preload("res://cards/scarred_troll.tres"),
 "rotting_guardian": preload("res://cards/rotting_guardian.tres"),
 "dwarf_smith": preload("res://cards/dwarf_smith.tres"),
 "sepulchral_tide": preload("res://cards/sepulchral_tide.tres"),
 "defiled_crypt": preload("res://cards/defiled_crypt.tres"),
 "restless_skeleton": preload("res://cards/restless_skeleton.tres"),
 "crypt_zombie": preload("res://cards/crypt_zombie.tres"),
 "wastes_hyena": preload("res://cards/wastes_hyena.tres"),
 "hungry_ghoul": preload("res://cards/hungry_ghoul.tres"),
 "wandering_ogre": preload("res://cards/wandering_ogre.tres"),
 "ash_necromancer": preload("res://cards/ash_necromancer.tres"),
 "crypt_sentinel": preload("res://cards/crypt_sentinel.tres"),
 "battle_howl": preload("res://cards/battle_howl.tres"),
 "alley_ambush": preload("res://cards/alley_ambush.tres"),
 "valeria_implacavel": preload("res://cards/valeria_implacavel.tres"),
 "adventure_black_dragon": preload("res://cards/adventure_black_dragon.tres"),
 "adventure_mimic": preload("res://cards/adventure_mimic.tres"),
 "rift_champion": preload("res://cards/rift_champion.tres"),
 "wild_pack_spell": preload("res://cards/wild_pack_spell.tres"),
 "wild_stag": preload("res://cards/wild_stag.tres"),
 "wild_beast_druid": preload("res://cards/wild_beast_druid.tres"),
 "wild_swift_boar": preload("res://cards/wild_swift_boar.tres"),
 "wild_elf": preload("res://cards/wild_elf.tres"),
 "wild_badger": preload("res://cards/wild_badger.tres"),
 "wild_scout": preload("res://cards/wild_scout.tres"),
 "wild_archer": preload("res://cards/wild_archer.tres"),
 "wild_sprout_druid": preload("res://cards/wild_sprout_druid.tres"),
 "wild_roots_druid": preload("res://cards/wild_roots_druid.tres"),
 "wild_guardian": preload("res://cards/wild_guardian.tres"),
 "wild_wolf": preload("res://cards/wild_wolf.tres"),
 "wild_wasp": preload("res://cards/wild_wasp.tres"),
 "wild_roots": preload("res://cards/wild_roots.tres"),
 "wild_regeneration": preload("res://cards/wild_regeneration.tres"),

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
 "antimagic_guardian": preload("res://cards/antimagic_guardian.tres"),
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
var creature_boss_id := -1
var mimic_turns := 0
var adventure_rules: Dictionary = {}
var castle_traps: Array = [[],[]]
var adventure_opening_applied := false
var adventure_creatures_played := 0
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

const DECK_NAMES=["Baluarte das Cicatrizes", "Caçada das Brumas", "Círculo Arcano", "Aurora Vital", "União da Colheita", "Ruína dos Ermos", "Aliança da Floresta", "Ecos das Dunas"]
static func default_deck_name(style: int=0) -> String:
 return DECK_NAMES[clampi(style,0,DECK_NAMES.size()-1)]

static func default_deck(style: int = 0) -> Array[String]:
 if style==7:
  return ["wastes_bat","wastes_bat","wastes_spitter","wastes_spitter","wolf","wolf","zombie_helper","zombie_helper","wastes_hyena","wastes_hyena","hungry_ghoul","hungry_ghoul","wastes_jackal_leader","wastes_jackal_leader","wastes_caravan_guide","wastes_caravan_guide","wandering_ogre","wandering_ogre","wastes_anubite_stalker","wastes_anubite_stalker","wastes_sandstorm","wastes_ancient_worm"]
 if style==6:
  return ["wild_badger","wild_scout","wild_archer","wild_sprout_druid","wild_roots_druid","wild_guardian","wild_wolf","wild_wasp","wild_elf","wild_roots","wild_regeneration","wild_scout","wild_wolf","squire","squire","moon_herald","moon_herald","farmer","farmer","messenger_hawk","messenger_hawk","village_reconstruction"]
 var recipes := [
  ["squire", "squire", "sentinel", "sentinel", "wall_smith", "wall_smith", "warrior", "warrior", "wall_guard", "moon_herald", "iron_stance", "iron_stance", "wall_guard", "moon_herald", "bloodblade", "antimagic_guardian", "antimagic_guardian", "generous_peasant", "generous_peasant", "bloodblade"],
  ["dusk_scout", "dusk_scout", "raven", "raven", "lightning_rogue", "lightning_rogue", "mist_alchemist", "mist_alchemist", "moon_herald", "messenger_hawk", "shadow_step", "shadow_step", "moon_herald", "messenger_hawk", "secrets_dealer", "rooftop_leaper", "gate_watcher", "gate_watcher", "street_urchin", "street_urchin"],
  ["mage", "mage", "aether_summoner", "aether_summoner", "runic_familiar", "eclipse_channeler", "eclipse_channeler", "conductive_bolt", "conductive_bolt", "astral_flame", "squire", "squire", "runic_familiar", "astral_flame", "fire_mage", "fire_mage", "fireball", "magic_missiles", "magic_missiles", "wizard_apprentice"],
  ["cleric", "cleric", "dawn_warden", "dawn_warden", "dawn_oracle", "dawn_oracle", "farmer", "farmer", "moon_herald", "squire", "restoring_light", "vigor_vow", "moon_herald", "squire", "restoring_light", "vigor_vow", "life_pilgrim", "life_pilgrim", "generous_peasant", "generous_peasant"],
  ["moon_herald", "moon_herald", "generous_peasant", "generous_peasant", "farmer", "farmer", "wise_merchant", "wise_merchant", "harvest_ox", "harvest_ox", "peasant_uprising", "village_leader", "village_leader", "gate_watcher", "gate_watcher", "squire", "squire", "life_pilgrim", "life_pilgrim", "village_reconstruction"],
  ["horde_roar", "horde_roar", "zombie_helper", "zombie_helper", "moon_werewolf", "moon_werewolf", "marsh_troll", "minotaur_brute", "minotaur_brute", "marsh_troll", "wolf", "wolf", "goblin_raider", "goblin_raider", "orc_mine_overseer", "orc_mine_overseer", "brood_fungus", "brood_fungus", "scorpion_kobold", "scorpion_kobold"]
 ]
 var result: Array[String] = []
 result.assign(recipes[clampi(style,0,recipes.size()-1)])
 var additions := [["iron_recruit","iron_recruit"],["secrets_dealer","rooftop_leaper"],["wizard_apprentice","fireball"],["dawn_acolyte","dawn_acolyte"],["village_reconstruction","village_wall"],["battle_howl","battle_howl"]]
 # Some recipes already contain the maximum; select only legal additions.
 for key in additions[clampi(style,0,additions.size()-1)]:
  if result.count(key)<copy_limit(key):result.append(key)
 if result.size()<DECK_SIZE:
  for key in CARD_DATA:
   if result.size()>=DECK_SIZE:break
   if result.count(key)<copy_limit(key) and can_add_faction(result,key):result.append(key)
 return result

static func copy_limit(key: String) -> int:
 return CARD_DATA[key].copy_limit() if CARD_DATA.has(key) else 0

static func deck_faction(cards: Array) -> int:
 var faction: int=-1
 var support: int=-1
 for key in cards:
  if not CARD_DATA.has(key):return -2
  var value: int=CARD_DATA[key].faction
  if value in [CardData.Faction.VILLAGER,CardData.Faction.WASTES]:
   if support>=0 and support!=value:return -2
   support=value
   continue
  if faction>=0 and faction!=value:return -2
  faction=value
 return faction if faction>=0 else CardData.Faction.WASTES if support==CardData.Faction.WASTES else -1

static func can_add_faction(cards: Array,key: String) -> bool:
 if not CARD_DATA.has(key) or not CARD_DATA[key].collectible:return false
 var candidate: Array=cards.duplicate()
 candidate.append(key)
 return deck_faction(candidate)!=-2 and restrictions_met(candidate)

static func neutral_monster_forbidden(base: int,key: String) -> bool:
 if not CARD_DATA.has(key):return false
 var card: CardData=CARD_DATA[key]
 return base in [CardData.Faction.WARRIOR,CardData.Faction.MAGE,CardData.Faction.LADINO,CardData.Faction.CLERIC,CardData.Faction.WILD] and card.faction==CardData.Faction.VILLAGER and card.has_creature_type(CardData.CreatureType.MONSTER)

static func restrictions_met(cards: Array) -> bool:
 var base: int=deck_faction(cards)
 var only_neutral: bool=base==-1
 if base==-2:return false
 if only_neutral:base=CardData.Faction.VILLAGER
 for key in cards:
  if not CARD_DATA.has(key):return false
  if not faction_allowed(base,CARD_DATA[key].faction):return false
  if neutral_monster_forbidden(base,key):return false
  if CARD_DATA[key].neutral_deck_only and not only_neutral:return false
 return true

static func villagers_allowed(base: int) -> bool:
 return base in [CardData.Faction.VILLAGER,CardData.Faction.WARRIOR,CardData.Faction.MAGE,CardData.Faction.LADINO,CardData.Faction.CLERIC,CardData.Faction.WILD]

static func complement_for(base: int) -> int:
 if villagers_allowed(base):return CardData.Faction.VILLAGER
 if base in [CardData.Faction.RUIN,CardData.Faction.NECROPOLIS,CardData.Faction.WASTES]:return CardData.Faction.WASTES
 return -1

static func faction_allowed(base: int,card_faction: int) -> bool:
 return base>=0 and (card_faction==base or card_faction==complement_for(base))

static func expand_legacy_deck(cards: Array) -> Array:
 var result: Array=cards.duplicate()
 var faction: int=deck_faction(cards)
 var style: int={0:0,3:1,1:2,4:3,-1:4,5:5}.get(faction,4)
 var candidates: Array=default_deck(style)
 candidates.append_array(CARD_DATA.keys())
 for key in candidates:
  if result.size()>=DECK_SIZE:break
  if result.count(key)>=copy_limit(key):continue
  # Preserve old mixed lists for correction; fill them only with ordinary neutrals.
  var allowed: bool=can_add_faction(result,key) if faction!=-2 else CARD_DATA[key].collectible and CARD_DATA[key].faction==CardData.Faction.VILLAGER and not CARD_DATA[key].neutral_deck_only
  if allowed:result.append(key)
 return result

static func valid_deck(cards: Array,enforce_faction: bool=true,required_size: int=DECK_SIZE) -> bool:
 if cards.size() != required_size:
  return false
 var counts := {}
 for key in cards:
  if not key is String or not CARD_DATA.has(key) or not CARD_DATA[key].collectible:
   return false
  counts[key] = int(counts.get(key, 0)) + 1
  if counts[key] > copy_limit(key):
   return false
 return not enforce_faction or (deck_faction(cards)!=-2 and restrictions_met(cards))

func _init(player_deck: Array = [], ai_deck: Array = [], starting_side: int = 0, with_mulligan: bool = false, rules: Dictionary = {}) -> void:
 adventure_rules = rules.duplicate(true)
 first_player = clampi(starting_side,0,1)
 turn = first_player
 opening = with_mulligan
 mulligan_done = [not with_mulligan,not with_mulligan]
 mulligan_rounds.assign([0,0] if with_mulligan else [mulligan_limit(0),mulligan_limit(1)])
 for side in range(2):
  var deck: Array[String] = []
  var supplied: Array = player_deck if side == 0 else ai_deck
  var is_adventure_deck: bool = adventure_rules.get("enabled",false) and supplied.size() >= 15 and supplied.all(func(key):return CARD_DATA.has(key) and (side==1 or CARD_DATA[key].collectible or CARD_DATA[key].has_meta("adventure_items")))
  deck.assign(supplied if is_adventure_deck or valid_deck(supplied) else default_deck(side))
  deck.shuffle()
  players.append({"hp": 20, "mana": 0, "temporary_mana":0, "max_mana": 0, "deck": deck, "hand": [], "board": [], "fatigue": 0,"poison":0,"neutral_deck":deck_faction(deck)==-1})
  if side == 0 and adventure_rules.get("enabled",false):
   players[side].hp += int(adventure_rules.get("life_bonus",0)) + (5 if "starting_life" in adventure_rules.get("powers",[]) else 0)
  if side==1 and adventure_rules.get("enabled",false):
   players[side].hp=clampi(int(adventure_rules.get("enemy_castle_life",20)),1,20)
  players[side]["max_hp"] = players[side].hp
  players[side]["armor"]=1 if side==0 and has_adventure_power("castle_armor") else 0
  if side==0 and adventure_rules.get("enabled",false):players[side].hp=clampi(int(adventure_rules.get("current_life",players[side].hp)),1,players[side].max_hp)
  for i in range(3 if side==first_player else 4):
   draw(side)
 if is_creature_encounter():
  players[1].hand.clear();players[1].deck.clear()
  if not is_dragon_boss():players[1].hand.assign(["wild_roots","wild_roots","wild_roots","horde_roar","horde_roar"])
  var boss: Dictionary=spawn_unit(1,creature_boss_key())
  creature_boss_id=boss.id
  if not is_dragon_boss():boss["mimic_sleeping"]=true
 if not opening:
  draw_events.clear()
  begin_turn()
  apply_adventure_opening_powers()
 else:draw_events.clear()

func log_event(message: String, actor_side: int = -1) -> void:
 history.append(message)
 history_sides.append(turn if actor_side < 0 else actor_side)

func draw(side: int,resolve_result: bool=true) -> void:
 if side==1 and is_creature_encounter():return
 var p: Dictionary = players[side]
 if p.deck.is_empty():
  p.fatigue += 1
  p.hp -= p.fatigue
  log_event("%s sofre %d de fadiga." % [castle_name(side).capitalize(), p.fatigue], side)
 elif p.hand.size() < MAX_HAND_SIZE:
  p.hand.append(p.deck.pop_back())
  draw_events.append({"side":side,"key":p.hand.back()})
  if side == 0 and not opening and turn == 0 and "draw_attack" in adventure_rules.get("powers",[]):
   for unit in p.board:unit["turn_attack"] = int(unit.get("turn_attack",0)) + 1
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
 last_action.erase("turn_castle_hits")
 for unit in players[turn].board:
  var bonus: int=int(unit.get("resonance_bonus",0))
  if bonus<=0 or unit.health<=0:continue
  unit.attack-=bonus
  unit.max_health=maxi(1,int(unit.get("max_health",CARD_DATA[unit.key].health))-bonus)
  unit.health=clampi(int(unit.health)-bonus,1,int(unit.max_health))
  unit.resonance_bonus=0
  log_event("Ressonância de %s termina: −%d/−%d, vida mínima 1." % [unit.name,bonus,bonus],turn)
 refresh_auras()
 # Both players regain all Block charges at the start of every turn.
 for player in players:
  for unit in player.board:
   if unit.health>0:unit.block=block_capacity(unit)
 var p: Dictionary = players[turn]
 var second_first_turn: bool=turn!=first_player and p.max_mana==0 and not (turn==1 and creature_boss_id>=0)
 p.max_mana = mini(10, p.max_mana + 1)
 if turn==1 and creature_boss_id>=0:
  p.max_mana=mini(boss_mana_cap(),mimic_turns)
  mimic_turns+=1
 p.mana = p.max_mana
 p.temporary_mana = 0
 if turn == 0 and p.max_mana == 1 and "first_mana" in adventure_rules.get("powers",[]):
  p.mana += 1
  p.temporary_mana += 1
 log_event("Seu turno — %d mana." % p.mana if turn == 0 else "Turno da IA — %d mana." % p.mana)
 if second_first_turn:
  p.temporary_mana+=1
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
  unit["end_random_attack_used"]=false
  unit.exhausting_action_taken=false
  if turn==1 and unit.id==creature_boss_id and not is_dragon_boss():
   unit["mimic_sleeping"]=mimic_turns==1
   if unit.mimic_sleeping:
    unit.ready=false
    unit.summoned_this_turn=true
  var max_antimagic: int=antimagic_capacity(unit)
  unit.antimagic=mini(max_antimagic,int(unit.get("antimagic",0))+1)
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
  var mining: int=int(source.get("turn_castle_damage",0))
  if source.health<=0 or mining<=0:continue
  if not last_action.has("turn_castle_hits"):last_action["turn_castle_hits"]=[]
  for owner in range(2):
   var dealt: int=damage_castle(owner,mining)
   last_action.turn_castle_hits.append({"side":owner,"id":-1,"castle":true,"amount":dealt,"source":source.id})
   log_event("Escavação de %s causa %d de dano físico ao %s." % [source.name,dealt,castle_name(owner)],turn)
  check_winner()
  if winner!=-1:return
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
 # Run after readying existing units: new allies keep summoning exhaustion.
 for source in p.board.duplicate():
  var summon_key: String=String(source.get("turn_summon_key",""))
  if source.health<=0 or summon_key.is_empty():continue
  var companion: Dictionary=spawn_unit(turn,summon_key)
  if companion.is_empty():
   log_event("Reanimar de %s: sem espaço para invocar." % source.name,turn)
   continue
  if not last_action.has("turn_summons"):last_action["turn_summons"]=[]
  last_action.turn_summons.append({"side":turn,"id":companion.id,"key":summon_key,"source":source.id})
  log_event("Reanimar: %s invoca %s." % [source.name,companion.name],turn)
 refresh_auras()
 draw(turn)
 if winner!=-1:return
 if turn==0 and p.max_mana==1 and "extra_draw" in adventure_rules.get("powers",[]):draw(0)
 if winner!=-1:return
 for observer in p.board.duplicate():
  if observer.health<=0:continue
  for i in range(int(observer.get("turn_draw",0))):
   log_event("%s: compra adicional no início do turno." % observer.name,turn)
   draw(turn)
   if winner!=-1:return

func spend_mana(p: Dictionary, amount: int) -> void:
 var paid: int=maxi(0,amount)
 p.mana=maxi(0,int(p.mana)-paid)
 # Mana temporária é sempre consumida antes das gemas normais.
 p.temporary_mana=maxi(0,int(p.get("temporary_mana",0))-paid)

func perform_impulsive_attack(side: int) -> bool:
 if opening or winner!=-1 or side!=turn or side not in [0,1]:return false
 for index in range(players[side].board.size()):
  var unit: Dictionary=players[side].board[index]
  if unit.health<=0 or not (unit.get("impulsive",false) or unit.get("turn_impulsive",false)) or not unit.ready or unit.get("attacked_this_turn",false):continue
  var target: int=preferred_attack_target(side,index)
  if target==-2:continue
  var title: String=unit.name
  if act(side,index,target,false):
   last_action["impulsive"]=true
   log_event("Impulsivo: %s ataca antes de encerrar o turno." % title,side)
   return true
 return false

func automatic_hunt_targets(side: int,index: int) -> Array:
 var result: Array=[]
 if opening or winner!=-1 or side not in [0,1] or side!=turn or index<0 or index>=players[side].board.size():return result
 var attacker: Dictionary=players[side].board[index]
 if attacker.health<=0 or not attacker.get("end_random_attack",false) or attacker.get("end_random_attack_used",false) or attacker.get("rooted",false) or attacker.get("wall",false) or physical_attack(attacker)<=0:return result
 for owner in [side,1-side]:
  for i in range(players[owner].board.size()):
   var victim: Dictionary=players[owner].board[i]
   if victim.health<=0 or victim.get("stealth",false) or is_same(attacker,victim) or unit_faction(victim)==CardData.Faction.WASTES:continue
   result.append({"side":owner,"index":i})
 return result

func perform_automatic_hunt(side: int) -> bool:
 if side not in [0,1] or side!=turn or winner!=-1:return false
 for index in range(players[side].board.size()):
  var candidates:=automatic_hunt_targets(side,index)
  if candidates.is_empty():continue
  var chosen: Dictionary=candidates.pick_random()
  if act(side,index,int(chosen.index),false,int(chosen.side),true):
   last_action["automatic_hunt"]=true
   return true
 return false

func end_turn(side: int) -> bool:
 if opening or side != turn or winner != -1:
  return false
 # Forced attacks happen while turn bonuses and attack restrictions still apply.
 for i in range(MAX_BOARD):
  if not perform_impulsive_attack(side):break
  if winner!=-1:return true
 for i in range(MAX_BOARD):
  if not perform_automatic_hunt(side):break
  if winner!=-1:return true
 log_event("%s encerra o turno." % side_name(side))
 for player in players:
  for unit in player.board:
   unit["turn_attack"]=int(unit.get("turn_attack",0))-int(unit.get("pack_turn_attack",0))
   unit["pack_turn_attack"]=0
 for unit in players[side].board:
  unit["turn_attack"]=0
  unit["turn_flying"]=false
  unit["turn_swift"]=false
  unit["turn_impulsive"]=false
 for unit in players[side].board:unit["bleeding"]=0;unit["rooted"]=false
 resolve_poison(side)
 resolve_regeneration(side)
 if winner==-1:resolve_end_turn_attack(side)
 for unit in players[side].board:
  if int(unit.get("nature_regen_turns",0))>0:
   unit.nature_regen_turns-=1
   if unit.nature_regen_turns==0:unit.regeneration=maxi(0,int(unit.regeneration)-2)
 var p: Dictionary=players[side]
 if int(p.get("temporary_mana",0))>0:
  p.mana=maxi(0,int(p.mana)-int(p.temporary_mana))
  p.temporary_mana=0
 if winner != -1:
  return true
 turn = 1 - turn
 begin_turn()
 return true

func resolve_end_turn_attack(side: int) -> void:
 var buffs: Array=[]
 for source in players[side].board:
  var amount: int=int(source.get("end_turn_attack",0))
  if source.health<=0 or amount<=0:continue
  var candidates: Array=players[side].board.filter(func(ally):return ally.health>0 and ally.id!=source.id)
  if candidates.is_empty():continue
  var ally: Dictionary=candidates.pick_random()
  grant_stats(ally,amount,0)
  buffs.append({"side":side,"id":ally.id,"source":source.id,"castle":false,"amount":amount})
  log_event("Forjar: %s concede +%d de ataque a %s." % [source.name,amount,ally.name],side)
 if not buffs.is_empty():last_action["end_turn_buffs"]=buffs

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
 if side==0:apply_adventure_keyword(unit)
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
    log_event("Chamado: %s concede %s %d a %s." % [card.name,"Punga" if entry_choice=="loot" else "Envenenar",amount,ally.name])
  CardData.EntryEffect.WHIP_ALLY:
   if target>=0:
    var ally: Dictionary=p.board[target]
    grant_stats(ally,int(card.entry_attack),0)
    var dealt: int=damage(ally,int(card.entry_value))
    last_action["buff_target"]=ally.id
    last_action["buff_attack"]=int(card.entry_attack)
    last_action["entry_damage"]=[{"side":side,"id":ally.id,"castle":false,"amount":dealt}]
    log_event("Chamado: %s concede +%d de ataque e causa %d de dano físico a %s." % [card.name,card.entry_attack,dealt,ally.name],side)
    remove_dead()
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
  CardData.EntryEffect.DAMAGE_ENEMY:
   if target>=0:
    var victim: Dictionary=players[1-side].board[target]
    var dealt: int=damage(victim,int(card.entry_value))
    last_action["entry_damage"]=[{"side":1-side,"id":victim.id,"castle":false,"amount":dealt}]
    log_event("Chamado: %s causa %d de dano físico a %s." % [card.name,dealt,victim.name],side)
    remove_dead()
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
    log_event("Chamado de %s: sem espaço para invocar." % card.name)
  CardData.EntryEffect.HEAL_ALLIES:
   for ally in p.board:
    if ally.health<=0 or ally.get("wall",false):continue
    var undead: bool=is_undead(ally)
    var before: int=int(ally.health)
    apply_healing(side,ally,int(card.entry_value),side)
    if undead:
     if not last_action.has("entry_damage"):last_action["entry_damage"]=[]
     last_action.entry_damage.append({"side":side,"id":ally.id,"castle":false,"amount":maxi(0,before-int(ally.health))})
   log_event("Chamado: %s aplica Cura %d a todas as criaturas aliadas." % [card.name,card.entry_value],side)
   remove_dead()
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
 return kind==value

func record_death(owner: int,unit: Dictionary) -> void:
 var id: int=int(unit.get("id",-1))
 if recorded_deaths.has(id):return
 recorded_deaths[id]=true
 log_event("%s perde %s." % [side_name(owner),unit.name], owner)
 if int(unit.get("creature_type",-1))==CardData.CreatureType.HUMAN:human_deaths[owner]+=1
 for observer in players[owner].board:
  var amount: int=int(observer.get("soul_harvest",0))
  if observer.health<=0 or observer.id==id or amount<=0:continue
  grant_stats(observer,amount,amount)
  if not last_action.has("soul_harvest_buffs"):last_action["soul_harvest_buffs"]=[]
  last_action.soul_harvest_buffs.append({"side":owner,"id":observer.id,"amount":amount})
  log_event("Colher Almas: %s ganha +%d/+%d." % [observer.name,amount,amount],owner)
 # Scavengers feed on deaths from either side. Dead sources never recover.
 for side in range(players.size()):
  for observer in players[side].board:
   var amount: int=int(observer.get("carrion",0))
   if observer.health<=0 or observer.id==id or amount<=0:continue
   var restored: int=mini(amount,maxi(0,int(observer.get("max_health",CARD_DATA[observer.key].health))-int(observer.health)))
   if restored<=0:continue
   observer.health+=restored
   if not last_action.has("carrion_heals"):last_action["carrion_heals"]=[]
   last_action.carrion_heals.append({"side":side,"id":observer.id,"castle":false,"amount":restored})
   log_event("Carniceiro: %s recupera %d de vida." % [observer.name,restored],side)

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
  last_action["antimagic_blocked"]=dealt==0 and amount>0
  log_event("%s recebe %d de dano mágico por Cura." % [unit.name,dealt])
  if dealt>0:trigger_devotion(owner if source_side<0 else source_side)
  return 0
 var restored: int=mini(amount,int(unit.get("max_health",CARD_DATA[unit.key].health))-int(unit.health))
 unit.health+=restored
 record_heal(owner,unit,restored)
 if restored>0:log_event("%s recupera %d de vida por Cura." % [unit.name,restored])
 return restored

static func apply_poison(unit: Dictionary,amount: int) -> bool:
 if unit.get("wall",false) or unit.get("poison_immune",false):
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
 var result: Array[int]=[]
 if opening or winner!=-1 or turn!=side or side<0 or side>1:return result
 if index<0 or index>=players[side].board.size():return result
 var unit: Dictionary=players[side].board[index]
 if not unit.ready or unit.get("wall",false) or has_flying(unit) or physical_attack(unit)<=0:return result
 var guards:=blockers(1-side)
 if not guards.is_empty() and target not in guards:result.assign(guards)
 return result

static func damage(unit: Dictionary, amount: int, magical: bool = false) -> int:
 if magical and unit.get("spell_immune",false):return 0
 if magical and amount>0 and int(unit.get("antimagic",0))>0:
  unit.antimagic-=1
  return 0
 var dealt: int = amount if magical else maxi(0, amount - int(unit.armor))
 unit.health -= dealt
 return dealt

func apply_necrotic_damage(owner: int,unit: Dictionary,amount: int) -> int:
 if amount<=0 or unit.health<=0 or unit.get("spell_immune",false) or has_type(unit,CardData.CreatureType.ARTIFACT):return 0
 if is_undead(unit):
  var restored: int=mini(amount,maxi(0,int(unit.get("max_health",CARD_DATA[unit.key].health))-int(unit.health)))
  if restored>0:
   unit.health+=restored
   if not last_action.has("healed"):last_action["healed"]=[]
   last_action.healed.append({"side":owner,"id":unit.id,"castle":false,"amount":restored,"cleansed":0})
   log_event("Energia necrótica: %s recupera %d de vida." % [unit.name,restored],owner)
  return -restored
 var dealt: int=damage(unit,amount,true)
 log_event("%s recebe %d de dano necrótico." % [unit.name,dealt])
 return dealt

func can_necrotic_target(side: int,index: int,owner: int,target: int) -> bool:
 if opening or winner!=-1 or side!=turn or side not in [0,1] or owner not in [0,1]:return false
 if index<0 or index>=players[side].board.size():return false
 var actor: Dictionary=players[side].board[index]
 if actor.health<=0 or not actor.ready or int(actor.get("necrotic_damage",0))<=0 or players[side].mana<int(actor.get("magic_cost",1)):return false
 if target==-1:return owner==1-side and not (side==0 and creature_boss_id>=0)
 if target<0 or target>=players[owner].board.size():return false
 var victim: Dictionary=players[owner].board[target]
 return victim.health>0 and not victim.get("stealth",false) and not victim.get("spell_immune",false) and not has_type(victim,CardData.CreatureType.ARTIFACT) and (owner!=side or is_undead(victim))

func necrotic_shot(side: int,index: int,owner: int,target: int) -> bool:
 if not can_necrotic_target(side,index,owner,target):return false
 var actor: Dictionary=players[side].board[index]
 var amount: int=int(actor.necrotic_damage)+magic_bonus(side)
 last_action={"kind":"magic","side":side,"attacker":actor.id,"target_side":owner,"target":-1 if target<0 else players[owner].board[target].id,"castle":target<0,"damage_type":CardData.DamageType.NECROTIC,"dead":[]}
 actor.ready=false;actor.exhausting_action_taken=true;actor.actions_taken=int(actor.get("actions_taken",0))+1
 spend_mana(players[side],int(actor.get("magic_cost",1)))
 if target<0:
  resolve_castle_traps(owner,actor)
  if actor.health<=0:
   last_action["trap_stopped"]=true;last_action["amount"]=0
   remove_dead();refresh_auras();check_winner();return true
  players[owner].hp-=amount;last_action["amount"]=amount
  log_event("Disparo Necrótico causa %d de dano ao %s." % [amount,castle_name(owner)],side)
 else:
  var victim: Dictionary=players[owner].board[target]
  last_action["necrotic_healing"]=is_undead(victim)
  var result: int=apply_necrotic_damage(owner,victim,amount)
  last_action["amount"]=maxi(0,result)
  last_action["antimagic_blocked"]=result==0 and not is_undead(victim)
 trigger_resonance(side);trigger_bleeding(actor,side)
 remove_dead();refresh_auras();check_winner()
 return true

func necrotic_target_score(side: int,owner: int,victim: Dictionary,amount: int) -> int:
 if victim.health<=0 or victim.get("spell_immune",false) or has_type(victim,CardData.CreatureType.ARTIFACT):return 0
 if is_undead(victim):
  var recovered: int=mini(amount,maxi(0,int(victim.get("max_health",victim.health))-int(victim.health)))
  return recovered*3*(1 if owner==side else -1)
 return ai_magic_score(victim,amount) if owner!=side else 0

func ai_necrotic_target(side: int,index: int) -> Dictionary:
 var best: Dictionary={};var score: int=0
 var amount: int=int(players[side].board[index].get("necrotic_damage",0))+magic_bonus(side)
 for owner in range(2):
  for target in range(-1,players[owner].board.size()):
   if not can_necrotic_target(side,index,owner,target):continue
   var value: int=(100 if players[owner].hp<=amount else 2) if target<0 else necrotic_target_score(side,owner,players[owner].board[target],amount)
   if value>score:score=value;best={"side":owner,"index":target}
 return best

func blockers(side: int) -> Array[int]:
 var result: Array[int] = []
 for i in range(players[side].board.size()):
  if players[side].board[i].get("block", 0) > 0 and not players[side].board[i].get("stealth",false):
   result.append(i)
 return result

func can_target(side: int, index: int, target: int, magical: bool = false, target_side: int=-1) -> bool:
 if magical and side in [0,1] and index>=0 and index<players[side].board.size() and int(players[side].board[index].get("necrotic_damage",0))>0:
  return can_necrotic_target(side,index,1-side if target_side<0 else target_side,target)
 if target_side>=0 and target_side!=1-side:return false
 if side==0 and target==-1 and creature_boss_id>=0:return false
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
 if target>=0 and foe.board[target].get("stealth",false):return false
 if magical and unit.get("root_power",false):return target>=0 and p.mana>=1 and not foe.board[target].get("spell_immune",false)
 if magical:
  return unit.get("magic_damage", 0) > 0 and p.mana >= unit.get("magic_cost", 1) and (target>=0 or int(unit.get("magic_splash",0))==0)
 if unit.get("wall",false) or unit.get("rooted",false) or unit.get("end_random_attack",false) or physical_attack(unit) <= 0:
  return false
 if has_flying(unit):
  var reachers: Array=[]
  for j in range(foe.board.size()):
   if foe.board[j].get("reach",false) and not foe.board[j].get("stealth",false):reachers.append(j)
  return reachers.is_empty() or target in reachers
 var guards := blockers(1 - side)
 return guards.is_empty() or target in guards

func has_magic_target(side: int,index: int) -> bool:
 if side in [0,1] and index>=0 and index<players[side].board.size() and int(players[side].board[index].get("necrotic_damage",0))>0:
  for owner in range(2):
   for target in range(-1,players[owner].board.size()):
    if can_necrotic_target(side,index,owner,target):return true
  return false
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
  result.append({"index":at,"side":1-side,"id":victim.id,"castle":false,"power":power,"amount":0 if int(victim.get("antimagic",0))>0 else power})
 return result

func attack_forecast(side: int,index: int,target: int,magical: bool=false,target_side: int=-1) -> Dictionary:
 if not can_target(side,index,target,magical,target_side):return {}
 if magical and int(players[side].board[index].get("necrotic_damage",0))>0:
  var owner: int=1-side if target_side<0 else target_side
  var actor: Dictionary=players[side].board[index]
  var victim: Dictionary={} if target<0 else players[owner].board[target]
  var power: int=int(actor.necrotic_damage)+magic_bonus(side)
  var healing: bool=target>=0 and is_undead(victim)
  var warded: bool=not healing and target>=0 and int(victim.get("antimagic",0))>0
  var restored: int=mini(power,maxi(0,int(victim.get("max_health",victim.get("health",0)))-int(victim.get("health",0)))) if healing else 0
  var dealt: int=0 if healing or warded else power
  return {"damage":dealt,"healing":restored,"necrotic_healing":healing,"received":0,"absorbed":0,"flight_reduction":0,"counter_absorbed":0,"bleeding":int(actor.get("bleeding",0)),"warded":warded,"castle":target<0,"target_dies":not healing and dealt>=(players[owner].hp if target<0 else victim.health),"attacker_dies":int(actor.get("bleeding",0))>=actor.health,"damage_type":CardData.DamageType.NECROTIC}
 var attacker: Dictionary=players[side].board[index]
 var defender: Dictionary={} if target<0 else players[1-side].board[target]
 var power: int=int(attacker.get("magic_damage",0))+magic_bonus(side) if magical else physical_attack(attacker)+(1 if target>=0 and attacker.get("reach",false) and has_flying(defender) else 0)
 var armor: int=int(players[1-side].get("armor",0)) if target<0 else int(defender.get("armor",0))
 var absorbed: int=0 if magical else mini(power,maxi(0,armor))
 var flight_reduction: int=0 if magical or target<0 or not has_flying(defender) or attacker.get("reach",false) else mini(1,maxi(0,power-absorbed))
 var warded: bool=magical and target>=0 and (int(defender.get("antimagic",0))>0 or defender.get("spell_immune",false))
 var dealt: int=0 if warded else maxi(0,power-absorbed-flight_reduction)
 var castle_damage: int=maxi(0,dealt-int(defender.health)) if not magical and target>=0 and attacker.get("trample",false) else 0
 if castle_damage>0:dealt-=castle_damage
 castle_damage=maxi(0,castle_damage-int(players[1-side].get("armor",0)))
 var counter: int=0 if magical or target<0 else defense_attack(defender)+(1 if defender.get("reach",false) and has_flying(attacker) else 0)
 var counter_absorbed: int=mini(counter,maxi(0,int(attacker.get("armor",0))))
 var received: int=maxi(0,counter-counter_absorbed)
 var bleeding: int=int(attacker.get("bleeding",0))
 if not magical and target>=0 and counter>0 and not attacker.get("wall",false):bleeding+=int(defender.get("bleed",0))
 var target_health: int=int(players[1-side].hp) if target<0 else int(defender.health)
 return {"damage":dealt,"castle_damage":castle_damage,"received":received,"absorbed":absorbed,"flight_reduction":flight_reduction,"counter_absorbed":counter_absorbed,"bleeding":bleeding,"warded":warded,"splash_hits":magic_hit_plan(side,index,target) if magical and int(attacker.get("magic_splash",0))>0 else [],"castle":target<0,"target_dies":dealt>=target_health,"attacker_dies":received+bleeding>=int(attacker.health)+(int(attacker.get("resonance",0)) if magical else 0)}

func preferred_attack_target(side: int,index: int) -> int:
 if side==0 and creature_boss_id>=0:
  for i in range(players[1].board.size()):
   if players[1].board[i].id==creature_boss_id and can_target(side,index,i,false):return i
  return -2
 # -1 is the castle; -2 means no legal physical attack.
 if can_target(side,index,-1,false):return -1
 if side<0 or side>=players.size():return -2
 for target in range(players[1-side].board.size()):
  if can_target(side,index,target,false):return target
 return -2

func apply_bleeding(unit: Dictionary,amount: int,side: int) -> void:
 if amount<=0 or unit.get("wall",false) or unit.get("poison_immune",false):return
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
 if target==-1:return owner==side and p.hp>0 and p.hp<int(p.get("max_hp",20))
 var unit: Dictionary=players[owner].board[target]
 if unit.health<=0 or unit.get("stealth",false):return false
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
  var restored: int=mini(amount,int(p.get("max_hp",20))-int(p.hp))
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

func act(side: int, index: int, target: int, magical: bool = false, target_side: int=-1, automatic_hunt: bool=false) -> bool:
 if magical and side in [0,1] and index>=0 and index<players[side].board.size() and int(players[side].board[index].get("necrotic_damage",0))>0:
  return necrotic_shot(side,index,1-side if target_side<0 else target_side,target)
 if automatic_hunt:
  if magical or {"side":target_side,"index":target} not in automatic_hunt_targets(side,index):return false
 elif not can_target(side, index, target, magical):
  return false
 var p: Dictionary = players[side]
 var defender_side: int=target_side if automatic_hunt else 1-side
 var foe: Dictionary = players[defender_side]
 if index < 0 or index >= p.board.size() or target < -1 or target >= foe.board.size():
  return false
 var unit: Dictionary = p.board[index]
 var defender: Dictionary = {} if target<0 else foe.board[target]
 if not unit.ready and not automatic_hunt:
  return false
 if automatic_hunt:unit["end_random_attack_used"]=true
 if not magical and unit.get("stealth",false):
  unit["stealth"]=false
  log_event("%s perde Furtivo ao atacar." % unit.name,side)
 last_action = {"kind": "magic" if magical else "attack", "side": side, "attacker": unit.get("id", -1), "target": -1 if target == -1 else foe.board[target].get("id", -1), "castle": target == -1, "target_side": defender_side, "dead": []}
 unit.ready = false
 unit.actions_taken=int(unit.get("actions_taken",0))+1
 unit.exhausting_action_taken=true
 if not magical:unit.attacked_this_turn=true
 if target==-1:
  resolve_castle_traps(1-side,unit)
  if unit.health<=0:
   if magical:spend_mana(p,int(unit.get("magic_cost",1)))
   last_action["amount"]=0
   last_action["trap_stopped"]=true
   remove_dead();refresh_auras();check_winner()
   return true
 if magical:
  if unit.get("root_power",false):
   spend_mana(p,1)
   var victim: Dictionary=foe.board[target]
   if int(victim.get("antimagic",0))>0:
    victim.antimagic-=1
    last_action["antimagic_blocked"]=true
   else:victim.rooted=true
   last_action["amount"]=0
   log_event("%s usa Raízes Enredantes em %s." % [unit.name,victim.name])
  else:
   spend_mana(p,unit.magic_cost)
  if unit.get("root_power",false):pass
  elif int(unit.get("magic_splash",0))>0:
   last_action["fire_hits"]=[]
   for hit in magic_hit_plan(side,index,target):
    var victim: Dictionary=foe.board[hit.index]
    hit.amount=damage(victim,int(hit.power),true)
    hit["antimagic_blocked"]=hit.amount==0 and hit.power>0
    last_action.fire_hits.append(hit)
    if hit.index==target:
     last_action["amount"]=hit.amount
     last_action["antimagic_blocked"]=hit.antimagic_blocked
    log_event("Mãos Flamejantes de %s: %d de dano mágico em %s." % [unit.name,hit.amount,victim.name])
  else:
   var total_magic: int = unit.magic_damage + magic_bonus(side)
   var dealt: int=total_magic if target<0 else damage(foe.board[target],total_magic,true)
   if target<0:dealt=damage_castle(1-side,dealt,true)
   last_action["amount"]=dealt
   last_action["antimagic_blocked"]=target>=0 and dealt==0 and total_magic>0
   log_event("%s: Antimagia anula o dano mágico." % foe.board[target].name if last_action.antimagic_blocked else "%s causa %d de dano mágico em %s." % [unit.name,dealt,castle_name(1-side) if target<0 else foe.board[target].name])
  if not unit.get("root_power",false):trigger_resonance(side)
 elif target == -1:
  last_action["amount"]=damage_castle(1-side,physical_attack(unit))
  foe.poison=0
  log_event("%s ataca o %s e causa %d de dano." % [unit.name, castle_name(1-side), last_action.amount])
  var loot: int=int(unit.get("loot",0))
  if loot>0:
   log_event("%s ativa Punga %d." % [unit.name,loot],side)
   for i in range(loot):draw(side,false)
 else:
  if defender.get("block", 0) > 0:
   defender.block -= 1
   log_event("Bloqueio de %s consumido." % defender.name)
  var counter: int = defense_attack(defender)+(1 if defender.get("reach",false) and has_flying(unit) else 0)
  var physical: int=physical_attack(unit)+(1 if unit.get("reach",false) and has_flying(defender) else 0)
  var armor_absorbed: int=mini(physical,maxi(0,int(defender.get("armor",0))))
  var flight_reduction: int=mini(1,maxi(0,physical-armor_absorbed)) if has_flying(defender) and not unit.get("reach",false) else 0
  var counter_absorbed: int=mini(counter,maxi(0,int(unit.get("armor",0))))
  var castle_damage: int=maxi(0,physical-flight_reduction-armor_absorbed-int(defender.health)) if unit.get("trample",false) else 0
  var dealt := damage(defender, physical-flight_reduction-castle_damage)
  var received := damage(unit, counter)
  if castle_damage>0:
   castle_damage=damage_castle(1-side,castle_damage)
   log_event("Atropelar: %s causa %d de dano ao %s." % [unit.name,castle_damage,castle_name(1-side)],side)
  last_action["amount"]=dealt
  last_action["castle_damage"]=castle_damage
  last_action["received"]=received
  last_action["absorbed"]=armor_absorbed
  last_action["flight_reduction"]=flight_reduction
  last_action["counter_absorbed"]=counter_absorbed
  var attack_poison: int=int(unit.get("envenom",0))
  if attack_poison>0 and apply_poison(defender,attack_poison):
   record_poison(defender_side,defender,attack_poison)
  var counter_poison: int=int(defender.get("envenom",0))
  if counter>0 and counter_poison>0 and apply_poison(unit,counter_poison):
   record_poison(side,unit,counter_poison)
  apply_bleeding(defender,int(unit.get("bleed",0)),defender_side)
  if counter>0:apply_bleeding(unit,int(defender.get("bleed",0)),side)
  log_event("%s ataca %s: %d dano, %d recebido." % [unit.name, defender.name, dealt, received])
 if not magical:
  if unit.get("ephemeral",false):
   unit.health=0
   log_event("Efêmero: %s se dissipa após atacar." % unit.name,side)
  if target>=0 and defender.get("ephemeral",false):
   defender.health=0
   log_event("Efêmero: %s se dissipa após defender." % defender.name,defender_side)
 trigger_bleeding(unit,side)
 remove_dead()
 refresh_auras()
 check_winner()
 return true

func resolve_castle_traps(owner: int,attacker: Dictionary) -> void:
 var pending: Array=[]
 for trap in castle_traps[owner]:
  trap.remaining-=1
  if trap.remaining>0:
   pending.append(trap)
   continue
  var dealt: int=damage(attacker,int(trap.damage))
  if not last_action.has("trap_hits"):last_action["trap_hits"]=[]
  last_action.trap_hits.append({"side":1-owner,"id":attacker.id,"castle":false,"amount":dealt})
  log_event("Emboscada dos Becos dispara: %d de dano físico em %s." % [dealt,attacker.name],owner)
 castle_traps[owner]=pending

func disarm_castle_traps(owner: int) -> int:
 if owner not in [0,1]:return 0
 var removed: int=castle_traps[owner].size()
 castle_traps[owner].clear()
 if removed>0:
  last_action["disarmed_traps"]={"side":owner,"count":removed}
  log_event("%d armadilha(s) do %s foram desarmadas." % [removed,castle_name(owner)])
 return removed

func check_winner() -> void:
 if players.size() < 2:
  return
 if creature_boss_id>=0:
  if players[0].hp<=0:winner=1
  elif not players[1].board.any(func(u):return u.id==creature_boss_id and u.health>0):winner=0
  return
 if players[0].hp <= 0 and players[1].hp <= 0:
  winner = 2
 elif players[0].hp <= 0:
  winner = 1
 elif players[1].hp <= 0:
  winner = 0

# Scores reflect actual damage and remaining protection, not printed attack alone.
func ai_magic_score(victim: Dictionary,amount: int) -> int:
 if int(victim.get("antimagic",0))>0 or victim.get("spell_immune",false):return -3
 var damage_amount: int=maxi(0,amount)
 var threat: int=physical_attack(victim)+int(victim.get("magic_damage",0))*2+int(victim.get("heal_amount",0))+int(victim.get("envenom",0))
 return mini(damage_amount,int(victim.health))*3+threat+(12 if int(victim.health)<=damage_amount else 0)

func ai_best_magic_target(side: int,amount: int,excluded: Array = []) -> int:
 var best: int=-1
 var best_score: int=-999999
 for index in range(players[1-side].board.size()):
  if index in excluded or players[1-side].board[index].get("stealth",false):continue
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
  if not can_target(side,index,target,true):continue
  var score:=0
  for hit in magic_hit_plan(side,index,target):score+=ai_magic_score(players[1-side].board[hit.index],int(hit.power))
  if score>best_score:best=target;best_score=score
 return best if best_score>0 else -1

func ai_attack_score(attacker: Dictionary,defender: Dictionary) -> int:
 var dealt: int=maxi(0,physical_attack(attacker)+(1 if attacker.get("reach",false) and has_flying(defender) else 0)-int(defender.get("armor",0))-(1 if has_flying(defender) and not attacker.get("reach",false) else 0))
 var received: int=maxi(0,defense_attack(defender)+(1 if defender.get("reach",false) and has_flying(attacker) else 0)-int(attacker.get("armor",0)))
 var kills: bool=dealt>=int(defender.health) or defender.get("ephemeral",false)
 var dies: bool=received>=int(attacker.health) or attacker.get("ephemeral",false)
 var enemy_threat: int=physical_attack(defender)+int(defender.get("magic_damage",0))*2+int(defender.get("heal_amount",0))+int(defender.get("envenom",0))
 var own_value: int=physical_attack(attacker)+int(attacker.get("magic_damage",0))*2+int(attacker.get("heal_amount",0))
 var score: int=mini(dealt,int(defender.health))*2+enemy_threat+(12 if kills else 0)
 if attacker.get("trample",false):score+=maxi(0,dealt-int(defender.health))*3
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
 if is_dragon_boss():
  for i in range(p.board.size()):
   if p.board[i].id!=creature_boss_id:continue
   if enemy.hp<=6 and can_dragon_breath(1,i,"acid",-1):return dragon_breath(1,i,"acid",-1)
   var best_target: int=0;var best_score: int=-1
   for target in range(enemy.board.size()):
    if not can_dragon_breath(1,i,"acid",target):continue
    var score:=0
    for j in dragon_breath_targets(0,target):score+=maxi(1,physical_attack(enemy.board[j]))+mini(3,int(enemy.board[j].health))
    if score>best_score:best_score=score;best_target=target
   if enemy.board.size()>=2 and can_dragon_breath(1,i,"acid",best_target):return dragon_breath(1,i,"acid",best_target)
   if enemy.board.size()>0 and can_dragon_breath(1,i,"poison",best_target):return dragon_breath(1,i,"poison",best_target)
   if enemy.board.is_empty() and can_dragon_breath(1,i,"acid",-1):return dragon_breath(1,i,"acid",-1)
 # Immediate castle lethal takes precedence over setup and healing.
 for i in range(p.board.size()):
  if can_target(1,i,-1,false) and physical_attack(p.board[i])>=enemy.hp:return act(1,i,-1)
  if p.board[i].get("trample",false):
   for j in range(enemy.board.size()):
    var forecast:=attack_forecast(1,i,j,false)
    if not forecast.is_empty() and int(forecast.get("castle_damage",0))>=enemy.hp:return act(1,i,j,false)
 for i in range(p.board.size()):
  var caster: Dictionary=p.board[i]
  var amount: int=int(caster.get("magic_damage",0))+magic_bonus(1)
  if int(caster.get("magic_damage",0))>0 and amount>=enemy.hp and can_target(1,i,-1,true):return act(1,i,-1,true)
 # Prefer useful healing and magic, accounting for magical protection.
 for i in range(p.board.size()):
  if ai_quick_heal(i):return true
  var actor: Dictionary=p.board[i]
  if not actor.ready:continue
  if int(actor.get("necrotic_damage",0))>0:
   var choice: Dictionary=ai_necrotic_target(1,i)
   if not choice.is_empty():return necrotic_shot(1,i,choice.side,choice.index)
  if actor.get("root_power",false):
   for j in range(enemy.board.size()):
    if physical_attack(enemy.board[j])>0 and not enemy.board[j].get("rooted",false) and can_target(1,i,j,true):return act(1,i,j,true)
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
 if target >= 0 and (target_player.board[target].health <= 0 or target_player.board[target].get("spell_immune",false) or target_player.board[target].get("stealth",false)):
  return false
 match int(card.spell_effect):
  CardData.SpellEffect.SANDSTORM:
   return target_side==side and target==-1
  CardData.SpellEffect.SEPULCHRAL_TIDE:
   if target_side!=side or target!=-1:return false
   for owner in range(2):
    for creature in players[owner].board:
     if creature.health>0 and not creature.get("spell_immune",false) and not has_type(creature,CardData.CreatureType.ARTIFACT) and (owner!=side or is_undead(creature)):return true
   return false
  CardData.SpellEffect.CASTLE_TRAP:
   return target_side==side and target==-1
  CardData.SpellEffect.GRANT_PACK:
   return target_side==side and target==-1 and players.any(func(player):return player.board.any(func(creature):return creature.health>0 and not creature.get("spell_immune",false)))
  CardData.SpellEffect.ROOTS:
   return target_side==1-side and target>=0
  CardData.SpellEffect.NATURE_REGEN:
   return target_side==side and target>=0
  CardData.SpellEffect.MAGIC_MISSILES:
   return target_side==1-side and (target>=0 or target==-1) and players[1-side].board.size()>=1
  CardData.SpellEffect.RUIN_ROAR:
   return target_side==side and target==-1 and players[side].board.any(func(unit):return unit.health>0 and has_type(unit,CardData.CreatureType.MONSTER))
  CardData.SpellEffect.AREA_ARCANE:
   return target_side==1-side and target==-1 and not target_player.board.is_empty()
  CardData.SpellEffect.RECONSTRUCT:
   return target_side==side and (target==-1 or target_player.board[target].get("wall",false))
  CardData.SpellEffect.ARCANE:
   if side==0 and target_side==1 and target==-1 and creature_boss_id>=0:return false
   return target_side==1-side
  CardData.SpellEffect.CONDUCTIVE:
   return target_side == 1-side and target >= 0
  CardData.SpellEffect.VIGOR:
   return target_side==side and target>=0 and not target_player.board[target].get("vigor",false)
  CardData.SpellEffect.FORTIFY, CardData.SpellEffect.SHADOW_STEP, CardData.SpellEffect.WAR_PAINT:
   return target_side == side and target >= 0
  CardData.SpellEffect.RESTORE:
   if target==-1:return target_side==side and p.hp>0 and p.hp<int(p.get("max_hp",20))
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
  if unit.health>0 and unit_faction(unit)!=CardData.Faction.VILLAGER:return false
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

func cast(side: int, hand_index: int, target_side: int, target: int,trap_choice: int=0) -> bool:
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
 if card.spell_effect==CardData.SpellEffect.CASTLE_TRAP:
  if side==1 and trap_choice==0:trap_choice=randi_range(1,2)
  if trap_choice not in [1,2]:return false
 var unit: Dictionary = {} if target < 0 else players[target_side].board[target]
 last_action = {"kind":"spell","side":side,"attacker":-1,"target_side":target_side,"target":-1 if target<0 else unit.get("id",-1),"castle":target<0 and card.spell_effect not in [CardData.SpellEffect.AREA_ARCANE,CardData.SpellEffect.RUIN_ROAR,CardData.SpellEffect.GRANT_PACK,CardData.SpellEffect.SANDSTORM],"effect":card.spell_effect,"card":key,"dead":[]}
 spend_mana(p,card.cost)
 p.hand.remove_at(hand_index)
 match int(card.spell_effect):
  CardData.SpellEffect.SANDSTORM:
   var total: int=int(card.spell_value)+magic_bonus(side)
   last_action["castle"]=false;last_action["area_hits"]=[]
   for owner in range(2):
    var castle_hit: int=damage_castle(owner,total,true)
    last_action.area_hits.append({"side":owner,"id":-1,"castle":true,"amount":castle_hit})
    for victim in players[owner].board:
     if victim.health<=0 or unit_faction(victim)==CardData.Faction.WASTES or victim.get("spell_immune",false):continue
     var charges: int=int(victim.get("antimagic",0))
     var dealt: int=damage(victim,total,true)
     last_action.area_hits.append({"side":owner,"id":victim.id,"castle":false,"amount":dealt,"antimagic_blocked":charges>0})
  CardData.SpellEffect.SEPULCHRAL_TIDE:
   var amount: int=int(card.spell_value)+magic_bonus(side)
   last_action["damage_type"]=CardData.DamageType.NECROTIC
   last_action["castle"]=false;last_action["area_hits"]=[]
   for owner in range(2):
    for creature in players[owner].board:
     if creature.health<=0 or creature.get("spell_immune",false) or has_type(creature,CardData.CreatureType.ARTIFACT) or (owner==side and not is_undead(creature)):continue
     var result: int=apply_necrotic_damage(owner,creature,amount)
     if not is_undead(creature):last_action.area_hits.append({"side":owner,"id":creature.id,"castle":false,"amount":maxi(0,result),"antimagic_blocked":result==0})
  CardData.SpellEffect.CASTLE_TRAP:
   castle_traps[side].append({"remaining":trap_choice,"damage":int(card.spell_value)})
  CardData.SpellEffect.GRANT_PACK:
   last_action["buffs"]=[]
   for owner in range(players.size()):
    for creature in players[owner].board:
     if creature.health<=0 or creature.get("spell_immune",false):continue
     creature.pack=int(creature.get("pack",0))+1
     last_action.buffs.append({"side":owner,"id":creature.id,"castle":false,"amount":1})
  CardData.SpellEffect.ROOTS:
   if int(unit.get("antimagic",0))>0:
    unit.antimagic-=1
    last_action["antimagic_blocked"]=true
   else:unit.rooted=true
  CardData.SpellEffect.NATURE_REGEN:
   if int(unit.get("nature_regen_turns",0))<=0:unit.regeneration=int(unit.get("regeneration",0))+2
   unit.nature_regen_turns=5
  CardData.SpellEffect.RUIN_ROAR:
   last_action["buffs"]=[]
   for ally in p.board:
    if ally.health>0 and not ally.get("spell_immune",false) and has_type(ally,CardData.CreatureType.MONSTER):
     ally["turn_attack"]=int(ally.get("turn_attack",0))+int(card.spell_value)
     if int(card.get("spell_secondary",0))>0:ally["turn_impulsive"]=true
     last_action.buffs.append({"side":side,"id":ally.id,"castle":false,"amount":card.spell_value})
  CardData.SpellEffect.AREA_ARCANE:
   var total: int=int(card.spell_value)+magic_bonus(side)
   last_action["area_hits"]=[]
   for victim in players[1-side].board:
    if victim.get("spell_immune",false):continue
    var dealt: int=damage(victim,total,true)
    last_action.area_hits.append({"side":1-side,"id":victim.id,"castle":false,"amount":dealt,"antimagic_blocked":dealt==0 and total>0})
    if dealt==0 and total>0:log_event("%s: Antimagia anula a magia." % victim.name)
  CardData.SpellEffect.RECONSTRUCT:
   if target<0:
    var restored: int=mini(card.spell_secondary,int(p.get("max_hp",20))-int(p.hp))
    p.hp+=restored
    record_heal(side,{},restored,true)
   else:
    apply_healing(target_side,unit,int(card.spell_secondary),side)
   if neutral_field(side):draw(side,false)
  CardData.SpellEffect.WAR_PAINT:
   grant_stats(unit,int(card.spell_value),0)
   unit["granted_impulsive"]=true
   unit["impulsive"]=true
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
   last_action["antimagic_blocked"]=dealt==0 and total>0
   log_event("%s causa %d de dano mágico em %s." % [card.name,dealt,castle_name(target_side) if target<0 else unit.name])
   if last_action.antimagic_blocked:log_event("%s: Antimagia anula a magia." % unit.name)
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
    var restored: int=mini(card.spell_value,int(p.get("max_hp",20))-int(p.hp))
    p.hp+=restored
    record_heal(side,{},restored,true)
   else:
    apply_healing(target_side,unit,int(card.spell_value),side)
 trigger_resonance(side)
 remove_dead()
 refresh_auras()
 if card.spell_effect==CardData.SpellEffect.SANDSTORM:
  log_event("%s conjura %s: %d de dano mágico a ambos os castelos e às criaturas fora dos Ermos." % [side_name(side),card.name,int(card.spell_value)+magic_bonus(side)],side)
 elif card.spell_effect==CardData.SpellEffect.SEPULCHRAL_TIDE:
  log_event("%s conjura %s: energia necrótica atinge os inimigos e restaura Mortos-vivos dos dois lados." % [side_name(side),card.name],side)
 elif card.spell_effect==CardData.SpellEffect.GRANT_PACK:
  log_event("%s concede Matilha 1 às criaturas de ambos os lados." % side_name(side),side)
 elif card.spell_effect==CardData.SpellEffect.RUIN_ROAR:
  log_event("%s conjura %s: Monstros aliados ganham +%d de ataque%s até o fim do turno." % [side_name(side),card.name,card.spell_value," e Impulsivo" if int(card.get("spell_secondary",0))>0 else ""])
 elif card.spell_effect==CardData.SpellEffect.AREA_ARCANE:
  log_event("%s conjura %s: %d de dano mágico a todas as criaturas inimigas." % [side_name(side),card.name,card.spell_value+magic_bonus(side)])
 else:log_event("%s conjura %s em %s." % [side_name(side),card.name,castle_name(target_side) if target<0 else unit.name])
 check_winner()
 return true

func ai_spell_target(hand_index: int) -> Dictionary:
 var p: Dictionary = players[1]
 var card: Dictionary = CARDS[p.hand[hand_index]]
 if card.spell_effect==CardData.SpellEffect.SANDSTORM:
  if not can_cast(1,hand_index,1,-1):return {}
  var amount: int=int(card.spell_value)+magic_bonus(1)
  var score: int=0
  for owner in range(2):
   for creature in players[owner].board:
    if unit_faction(creature)==CardData.Faction.WASTES:continue
    var value: int=maxi(0,ai_magic_score(creature,amount))
    score+=value if owner==0 else -value
  if players[0].hp<=amount:score+=100
  if players[1].hp<=amount:score-=200
  return {"side":1,"index":-1} if score>0 else {}
 if card.spell_effect==CardData.SpellEffect.SEPULCHRAL_TIDE:
  if not can_cast(1,hand_index,1,-1):return {}
  var score: int=0
  var amount: int=int(card.spell_value)+magic_bonus(1)
  for owner in range(2):
   for creature in players[owner].board:score+=necrotic_target_score(1,owner,creature,amount)
  return {"side":1,"index":-1} if score>0 else {}
 var owner := 0 if card.spell_effect in [CardData.SpellEffect.ARCANE,CardData.SpellEffect.CONDUCTIVE,CardData.SpellEffect.AREA_ARCANE,CardData.SpellEffect.MAGIC_MISSILES,CardData.SpellEffect.ROOTS] else 1
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
   CardData.SpellEffect.CASTLE_TRAP:
    score=4+players[0].board.size()*2
   CardData.SpellEffect.ROOTS:
    score=physical_attack(unit)*3 if not unit.get("rooted",false) else 0
   CardData.SpellEffect.NATURE_REGEN:
    score=maxi(0,int(unit.get("max_health",unit.health))-int(unit.health))*2+2
   CardData.SpellEffect.GRANT_PACK:
    var friendly_beasts: int=p.board.filter(func(v):return has_type(v,CardData.CreatureType.BEAST)).size()
    var enemy_beasts: int=players[0].board.filter(func(v):return has_type(v,CardData.CreatureType.BEAST)).size()
    score=maxi(0,(friendly_beasts-enemy_beasts)*3+p.board.size()-players[0].board.size())
   CardData.SpellEffect.RUIN_ROAR:
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
   CardData.SpellEffect.WAR_PAINT:
    if unit.get("wall",false):continue
    score=int(card.spell_value)*3+physical_attack(unit)+(4 if unit.ready else 0)+(0 if unit.get("impulsive",false) else 2)
   CardData.SpellEffect.FORTIFY:
    score = unit.attack+unit.health+(4 if unit.get("block",0)>0 else 0)
   CardData.SpellEffect.SHADOW_STEP:
    if unit.get("wall",false) or (not unit.ready and (not unit.get("summoned_this_turn",false) or unit.get("exhausting_action_taken",false))):
     continue
    score = (physical_attack(unit)+int(card.spell_value))*3
   CardData.SpellEffect.RECONSTRUCT:
    score=(3 if neutral_field(1) else 0)+mini(card.spell_secondary,int(p.get("max_hp",20))-int(p.hp) if target<0 else int(unit.get("max_health",CARD_DATA[unit.key].health))-int(unit.health))
    if score<=0:continue
   CardData.SpellEffect.RESTORE:
    if target>=0 and is_undead(unit):continue
    score = int(p.get("max_hp",20))-p.hp if target<0 else int(unit.get("max_health",CARD_DATA[unit.key].health))-unit.health+int(unit.get("poison",0))*2
    if score<2:
     continue
  if score>best_score:
   best_score=score
   best={"side":owner,"index":target}
 return best
static func attack_value(unit: Dictionary) -> int:
 return int(unit.attack)+int(unit.get("aura_attack",0))+int(unit.get("turn_attack",0))+int(unit.get("mount_attack_bonus",0))

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
  apply_adventure_opening_powers()
 return true

func resolve_poison(side: int) -> void:
 var p: Dictionary=players[side]
 var ticks: Array=[]
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
 # Damage resolves together: death triggers cannot save another poisoned victim.
 last_action={"kind":"poison" if not ticks.is_empty() else "turn_end","side":side,"ticks":ticks,"dead":[]}
 remove_dead()
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
  CardData.EntryEffect.BUFF_ALLY,CardData.EntryEffect.ARMOR_ALLY,CardData.EntryEffect.BUFF_MONSTER_UNDEAD,CardData.EntryEffect.GRANT_ROGUE_CHOICE,CardData.EntryEffect.WHIP_ALLY:return side
  CardData.EntryEffect.POISON_ENEMY,CardData.EntryEffect.DAMAGE_ENEMY:return 1-side
 return -1

func entry_valid_targets(side: int,card: Dictionary) -> Array:
 var owner:=entry_target_side(side,card)
 var result:=[]
 if owner<0:return result
 for i in range(players[owner].board.size()):
  var target: Dictionary=players[owner].board[i]
  if target.health<=0 or target.get("stealth",false):continue
  if int(card.get("entry_effect",0))==CardData.EntryEffect.BUFF_ALLY and card.get("entry_human_only",false) and not has_type(target,CardData.CreatureType.HUMAN):continue
  if int(card.get("entry_effect",0))==CardData.EntryEffect.BUFF_MONSTER_UNDEAD and not (has_type(target,CardData.CreatureType.MONSTER) or has_type(target,CardData.CreatureType.UNDEAD)):continue
  result.append(i)
 return result

func spawn_unit(side: int,key: String) -> Dictionary:
 if not CARDS.has(key) or players[side].board.size()>=MAX_BOARD:return {}
 var card: Dictionary=CARDS[key]
 if card.get("card_type",0)!=CardData.CardType.CREATURE:return {}
 var unit: Dictionary=card.duplicate(true)
 unit.merge({"key":key,"id":next_id,"ready":card.get("swift",false),"max_health":card.health,"poison":0,"summoned_this_turn":true,"actions_taken":0,"exhausting_action_taken":false})
 if side==0 and adventure_rules.get("enabled",false):
  if has_adventure_power("all_trample"):unit.trample=true;unit["adventure_flag_trample"]=true
  var bonus: int=adventure_rules.get("equipment",[]).count(key)
  unit.health+=bonus
  unit.max_health+=bonus
 if side==0 and adventure_rules.get("farm_blessing",false):
  unit.health+=1;unit.max_health+=1;unit["farm_blessing"]=true;unit["farm_blessing_persistent"]=adventure_rules.get("farm_blessing_persistent",false)
 next_id+=1
 if has_type(unit,CardData.CreatureType.BEAST):
  for observer in players[side].board:
   var bonus: int=int(observer.get("pack",0))
   if observer.health<=0 or bonus<=0:continue
   observer["turn_attack"]=int(observer.get("turn_attack",0))+bonus
   observer["pack_turn_attack"]=int(observer.get("pack_turn_attack",0))+bonus
   log_event("Matilha: %s recebe +%d de ataque até o fim do turno." % [observer.name,bonus],side)
 players[side].board.append(unit)
 refresh_auras()
 unit.ready=unit.get("swift",false)
 if unit.get("wounded_entry",false):
  unit.health=1
  log_event("Ferido: %s é invocado com 1/%d de vida." % [unit.name,unit.max_health],side)
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
   CardData.EntryEffect.DAMAGE_ENEMY:
    var dealt: int=maxi(0,int(card.entry_value)-int(ally.get("armor",0)))
    value=dealt*3+physical_attack(ally)+(12 if dealt>=int(ally.health) else 0)
   CardData.EntryEffect.POISON_ENEMY:
    var poison: int=int(ally.get("poison",0))+int(card.entry_value)
    value=physical_attack(ally)*2+ally.armor+(12 if ally.health<=poison else 0)
   CardData.EntryEffect.GRANT_ROGUE_CHOICE:
    value=ally.health+(5 if ally.ready else 0)+(5 if has_flying(ally) else 0)-(8 if ally.get("wall",false) else 0)
   CardData.EntryEffect.WHIP_ALLY:
    var dealt: int=maxi(0,int(card.entry_value)-int(ally.get("armor",0)))
    value=int(card.entry_attack)*4+physical_attack(ally)+(3 if ally.ready else 0)-dealt*3-(100 if dealt>=int(ally.health) else 0)
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

static func unit_faction(unit: Dictionary) -> int:
 if unit.has("faction"):return int(unit.faction)
 var key: String=String(unit.get("key",""))
 return int(CARD_DATA[key].faction) if CARD_DATA.has(key) else -1

static func grant_stats(unit: Dictionary,attack_bonus: int,health_bonus: int) -> void:
 unit.attack+=attack_bonus
 unit.health+=health_bonus
 unit.max_health=int(unit.get("max_health",CARD_DATA[unit.key].health))+health_bonus

func block_capacity(unit: Dictionary) -> int:
 return int(unit.get("block_capacity",CARD_DATA[unit.key].block))

func antimagic_capacity(unit: Dictionary) -> int:
 return int(unit.get("antimagic_capacity",CARD_DATA[unit.key].antimagic))

func card_for_unit(unit: Dictionary) -> CardData:
 var view: CardData=Collective.display_card(self,unit)
 if view.block!=block_capacity(unit) or view.loot!=int(unit.get("loot",0)) or view.envenom!=int(unit.get("envenom",0)) or view.regeneration!=int(unit.get("regeneration",0)) or view.pack!=int(unit.get("pack",0)):
  view=view.duplicate()
  view.block=block_capacity(unit)
  view.loot=int(unit.get("loot",0))
  view.envenom=int(unit.get("envenom",0))
  view.regeneration=int(unit.get("regeneration",0))
  view.pack=int(unit.get("pack",0))
 var dynamic: Dictionary={"antimagic":antimagic_capacity(unit),"flying":unit.get("flying",false),"trample":unit.get("trample",false),"swift":unit.get("swift",false),"reach":unit.get("reach",false),"stealth":unit.get("stealth",false)}
 var copied:=false
 for field in dynamic:
  if view.get(field)!=dynamic[field]:
   if not copied:view=view.duplicate();copied=true
   view.set(field,dynamic[field])
 return view

func refresh_auras() -> void:
 # A source leaving can reduce a damaged collective's life to zero. Settle those deaths.
 for iteration in range(11):
  Collective.refresh(self)
  for player in players:
   for unit in player.board:unit["aura_attack"]=0
   for index in range(player.board.size()):
    var mount: Dictionary=player.board[index]
    var has_neighbor: bool=(index>0 and player.board[index-1].health>0) or (index+1<player.board.size() and player.board[index+1].health>0)
    mount["mount_attack_bonus"]=int(mount.get("mount_attack",0)) if mount.health>0 and has_neighbor else 0
   for source in player.board:
    if source.health<=0:continue
    var auras: Array=source.get("inherited_auras",[]).duplicate()
    if int(source.get("aura_effect",0))!=CardData.AuraEffect.NONE:auras.append(source)
    for aura in auras:
     for target in player.board:
      if target.health<=0:continue
      if is_same(source,target) and not aura.get("aura_includes_self",true):continue
      if int(aura.get("aura_targets",0))==CardData.AuraTargets.ALLIED_VILLAGERS and unit_faction(target)!=CardData.Faction.VILLAGER:continue
      if int(aura.get("aura_targets",0))==CardData.AuraTargets.ALLIED_BEASTS and not has_type(target,CardData.CreatureType.BEAST):continue
      if int(aura.get("aura_targets",0))==CardData.AuraTargets.ALLIED_WASTES and unit_faction(target)!=CardData.Faction.WASTES:continue
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







func is_dragon_boss() -> bool:
 return adventure_rules.get("encounter","")=="black_dragon"

func is_creature_encounter() -> bool:
 return adventure_rules.get("encounter","") in ["mimic","black_dragon"]

func boss_mana_cap() -> int:
 return 4 if is_dragon_boss() else 3

func creature_boss_key() -> String:
 return "adventure_black_dragon" if is_dragon_boss() else "adventure_mimic"

func creature_boss_name() -> String:
 return CARD_DATA[creature_boss_key()].title

func dragon_breath_targets(owner: int,target: int) -> Array[int]:
 var result: Array[int]=[]
 var count: int=players[owner].board.size()
 if count==0 or target<0 or target>=count:return result
 var first: int=clampi(target-1,0,maxi(0,count-3))
 for i in range(first,mini(first+3,count)):result.append(i)
 return result

func can_dragon_breath(side: int,index: int,kind: String,target: int) -> bool:
 if opening or winner!=-1 or turn!=side or side not in [0,1] or index<0 or index>=players[side].board.size():return false
 if kind not in ["poison","acid"]:return false
 var actor: Dictionary=players[side].board[index]
 if not actor.get("dragon_breaths",false) or not actor.ready or actor.get("attacked_this_turn",false):return false
 if players[side].mana<(3 if kind=="poison" else 4):return false
 if target==-1:return kind=="acid" and not (side==0 and creature_boss_id>=0)
 return target>=0 and target<players[1-side].board.size() and not players[1-side].board[target].get("stealth",false)

func dragon_breath(side: int,index: int,kind: String,target: int) -> bool:
 if not can_dragon_breath(side,index,kind,target):return false
 var actor: Dictionary=players[side].board[index]
 var owner: int=1-side
 spend_mana(players[side],3 if kind=="poison" else 4)
 actor.ready=false;actor.exhausting_action_taken=true;actor.actions_taken=int(actor.get("actions_taken",0))+1
 last_action={"kind":"spell","side":side,"attacker":actor.id,"target_side":owner,"target":-1 if target<0 else players[owner].board[target].id,"castle":target<0,"effect":CardData.SpellEffect.DRAGON_POISON if kind=="poison" else CardData.SpellEffect.DRAGON_ACID,"card":"adventure_black_dragon","dead":[],"area_hits":[]}
 if target<0:
  last_action["cone_targets"]=[{"side":owner,"id":-1,"castle":true}]
  players[owner].hp-=6
  last_action.area_hits.append({"side":owner,"id":-1,"castle":true,"amount":6})
  log_event("Sopro Ácido: 6 de dano ao castelo.",side)
 else:
  last_action["cone_targets"]=[]
  for at in dragon_breath_targets(owner,target):
   var victim: Dictionary=players[owner].board[at]
   last_action.cone_targets.append({"side":owner,"id":victim.id,"castle":false})
   if kind=="poison":
    if victim.get("spell_immune",false) or victim.get("wall",false) or victim.get("poison_immune",false):continue
    if int(victim.get("antimagic",0))>0:victim.antimagic-=1;continue
    if apply_poison(victim,2):record_poison(owner,victim,2)
   else:
    var amount: int=damage(victim,3,true)
    last_action.area_hits.append({"side":owner,"id":victim.id,"castle":false,"amount":amount})
  log_event("%s: %s em até três criaturas consecutivas." % ["Sopro Venenoso" if kind=="poison" else "Sopro Ácido","Veneno 2" if kind=="poison" else "3 de dano mágico"],side)
 trigger_resonance(side)
 trigger_bleeding(actor,side)
 remove_dead();refresh_auras();check_winner()
 return true






func has_adventure_power(key: String) -> bool:
 return adventure_rules.get("enabled",false) and key in adventure_rules.get("powers",[])

func apply_adventure_opening_powers() -> void:
 if adventure_opening_applied or not adventure_rules.get("enabled",false):return
 adventure_opening_applied=true
 if has_adventure_power("bonus_spell"):
  var spells: Array=[]
  for key in CARD_DATA:
   var card: CardData=CARD_DATA[key]
   if card.collectible and card.card_type==CardData.CardType.SPELL and (not card.neutral_deck_only or players[0].neutral_deck):spells.append(key)
  if not spells.is_empty():
   var key: String=spells.pick_random();players[0].hand.append(key)
   log_event("Truque na manga: %s foi adicionada à sua mão apenas neste combate." % CARD_DATA[key].title,0)
 if has_adventure_power("starting_allies"):
  var creatures: Array=[]
  for key in CARD_DATA:
   var card: CardData=CARD_DATA[key]
   if card.collectible and card.card_type==CardData.CardType.CREATURE and card.cost==1:creatures.append(key)
  if not creatures.is_empty():
   for i in range(2):
    var unit: Dictionary=spawn_unit(0,creatures.pick_random())
    if not unit.is_empty():log_event("Companhia inesperada invoca %s gratuitamente." % unit.name,0)

func apply_adventure_keyword(unit: Dictionary) -> void:
 if not has_adventure_power("first_three_keywords") or adventure_creatures_played>=3:return
 adventure_creatures_played+=1
 var keywords: Array=["envenom","antimagic"]
 for key in ["flying","swift","trample","reach"]:
  if not unit.get(key,false):keywords.append(key)
 var chosen: String=keywords.pick_random()
 if chosen=="antimagic":
  unit["antimagic_capacity"]=antimagic_capacity(unit)+1
  unit.antimagic+=1
  unit["adventure_antimagic_bonus"]=int(unit.get("adventure_antimagic_bonus",0))+1
 elif chosen=="envenom":unit.envenom=int(unit.get("envenom",0))+1
 else:
  unit[chosen]=true
  unit["adventure_flag_"+chosen]=true
  if chosen=="swift":unit.ready=true
 unit["adventure_keyword"]=chosen
 var title: String={"envenom":"Envenenar 1","antimagic":"Antimagia 1","flying":"Voo","swift":"Disparada","trample":"Atropelar","reach":"Alcance"}[chosen]
 log_event("Dons do destino: %s recebe %s neste combate (%d/3)." % [unit.name,title,adventure_creatures_played],0)

func damage_castle(side: int,amount: int,magical: bool=false) -> int:
 var armor: int=0 if magical else int(players[side].get("armor",0))
 var dealt: int=maxi(0,amount-armor)
 players[side].hp-=dealt
 return dealt
