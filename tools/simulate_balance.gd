extends SceneTree
const Match=preload("res://scripts/match.gd")
const FACTIONS=["Guerreiro","Mago","Ladina","Clérigo"]
const IDS={"Guerreiro":0,"Mago":1,"Ladina":3,"Clérigo":4}
const SALTS={"Guerreiro":101,"Mago":211,"Ladina":307,"Clérigo":401}
var games: Array=[]
var policy := "production"
var candidate_actions := 0
var patch_name := "baseline"
var changes: Array=[]

func _initialize() -> void:
 call_deferred("run")

func deck(faction: String, cohort: String) -> Array:
 if cohort=="archetype":
  match faction:
   "Guerreiro": return Match.default_deck(0)
   "Mago": return Match.default_deck(2)
   "Ladina": return Match.default_deck(1)
   _: return Match.default_deck(3)
 var result: Array=["squire","squire","wolf","wolf","farmer","farmer"]
 var core: Array
 match faction:
  "Guerreiro": core=["warrior","wall_guard","iron_stance"]
  "Mago": core=["mage","eclipse_channeler","astral_flame"]
  "Ladina": core=["lightning_rogue","dusk_scout","shadow_step"]
  _: core=["cleric","dawn_warden","restoring_light"]
 for key in core:
  result.append(key)
  result.append(key)
 return result

func shuffled(cards: Array, value: int) -> Array:
 var rng:=RandomNumberGenerator.new()
 rng.seed=value
 var result:=cards.duplicate()
 for i in range(result.size()-1,0,-1):
  var j:=rng.randi_range(0,i)
  var swap=result[i]
  result[i]=result[j]
  result[j]=swap
 return result

func match_for(a: String,b: String,cohort: String,seed_value: int):
 var m=Match.new(deck(a,cohort),deck(b,cohort))
 m.winner=-1
 m.turn=0
 m.next_id=0
 m.history.clear()
 m.last_action={}
 for side in range(2):
  var faction: String=a if side==0 else b
  var p: Dictionary=m.players[side]
  p.hp=20
  p.mana=0
  p.max_mana=0
  p.board=[]
  p.hand=[]
  p.fatigue=0
  p.poison=0
  p.deck=shuffled(deck(faction,cohort),seed_value*1009+int(SALTS[faction]))
  for draw in range(3 if side==0 else 4):m.draw(side)
 m.begin_turn()
 return m

func production_step(m) -> bool:
 if m.turn==1:
  return m.ai_step()
 # Expose player zero through the same AI viewpoint. No alternative rules or policy.
 m.players.reverse()
 m.turn=1
 var moved: bool=m.ai_step()
 m.players.reverse()
 m.turn=0
 if m.winner in [0,1]:m.winner=1-m.winner
 if moved and not m.last_action.is_empty():
  m.last_action.side=0
  if m.last_action.has("target_side"):m.last_action.target_side=1-int(m.last_action.target_side)
  for victim in m.last_action.get("dead",[]):victim.side=1-int(victim.side)
 return moved

func clone_state(m):
 var copy=Match.new()
 copy.players=m.players.duplicate(true)
 copy.first_player=m.first_player
 copy.opening=m.opening
 copy.mulligan_done=m.mulligan_done.duplicate()
 copy.turn=m.turn
 copy.winner=m.winner
 copy.next_id=m.next_id
 copy.history.clear()
 copy.last_action={}
 return copy

func side_value(m,side: int) -> float:
 var p: Dictionary=m.players[side]
 var value: float=p.hp*2.2 - maxf(0,6-p.hp)*3.0 + p.hand.size()*0.8 + p.mana*0.1
 var enemy_magic:=false
 for enemy in m.players[1-side].board:
  if enemy.get("magic_damage",0)>0:enemy_magic=true
 for u in p.board:
  value+=6.0+u.attack*2.0+u.health*1.6+u.armor*(0.8 if enemy_magic else 1.8)
  value+=u.get("block",0)*0.7+u.get("magic_power",0)*2.0+u.get("growth",0)*2.0
  value+=u.get("magic_damage",0)*1.3+u.get("heal_amount",0)*0.8
  if u.get("flying",false):value+=1.2
  if u.ready:value+=u.attack*0.4+u.get("magic_damage",0)*0.4
 return value

func apply_action(m,action: Array) -> bool:
 var side: int=m.turn
 match action[0]:
  "play":return m.play(side,action[1],action[2] if action.size()>2 else -1)
  "cast":return m.cast(side,action[1],action[2],action[3])
  "attack":return m.act(side,action[1],action[2],false)
  "magic":return m.act(side,action[1],action[2],true)
  "heal":return m.heal(side,action[1],action[2])
  "fury":return m.fury(side,action[1])
 return false

func tactical_step(m) -> bool:
 var side: int=m.turn
 var p: Dictionary=m.players[side]
 var actions: Array=[]
 for i in range(p.hand.size()):
  var card: Dictionary=Match.CARDS[p.hand[i]]
  if card.cost>p.mana:continue
  if card.card_type==CardData.CardType.CREATURE:
   if Match.entry_target_side(side,card)>=0 and not m.players[Match.entry_target_side(side,card)].board.is_empty():
    for target in range(m.players[Match.entry_target_side(side,card)].board.size()):
     if m.can_play(side,i,target):actions.append(["play",i,target])
   elif m.can_play(side,i):actions.append(["play",i])
  else:
   for owner in range(2):
    for target in range(-1,m.players[owner].board.size()):
     if m.can_cast(side,i,owner,target):actions.append(["cast",i,owner,target])
 for i in range(p.board.size()):
  var u: Dictionary=p.board[i]
  if u.get("fury",0)>0 and p.mana>=1:actions.append(["fury",i])
  for target in range(-1,m.players[1-side].board.size()):
   if m.can_target(side,i,target,false):actions.append(["attack",i,target])
   if m.can_target(side,i,target,true):actions.append(["magic",i,target])
  for target in range(-1,p.board.size()):
   if m.can_heal(side,i,target):actions.append(["heal",i,target])
 var before:=side_value(m,side)-side_value(m,1-side)
 var best: Array=[]
 var best_gain:=0.001
 for action in actions:
  var sample=clone_state(m)
  assert(apply_action(sample,action))
  candidate_actions+=1
  var gain: float=1000000.0 if sample.winner==side else (side_value(sample,side)-side_value(sample,1-side)-before)
  if sample.winner==1-side:gain=-1000000.0
  if gain>best_gain:
   best_gain=gain
   best=action
 if best.is_empty():return false
 return apply_action(m,best)

func simulate(a: String,b: String,cohort: String,seed_value: int) -> Dictionary:
 var m=match_for(a,b,cohort,seed_value)
 var turns:=1
 var actions:=0
 var idle_mana: Array=[0,0]
 var supplied_mana: Array=[1,0]
 var cards_played: Array=[{},{}]
 var finish:="combat"
 while m.winner==-1 and turns<160 and actions<4000:
  var side: int=m.turn
  var hand: Array=m.players[side].hand.duplicate()
  var moved: bool=production_step(m) if policy=="production" else tactical_step(m)
  if moved:
   actions+=1
   if m.players[side].hand.size()<hand.size():
    for key in m.players[side].hand:hand.erase(key)
    for key in hand:cards_played[side][key]=int(cards_played[side].get(key,0))+1
  else:
   idle_mana[side]+=m.players[side].mana
   m.end_turn(side)
   turns+=1
   supplied_mana[m.turn]+=m.players[m.turn].max_mana
   if m.winner!=-1:finish="fatigue"
 assert(m.winner!=-1,"Partida não terminou dentro do limite")
 var winner: String="Empate" if m.winner==2 else (a if m.winner==0 else b)
 return {"cohort":cohort,"policy":policy,"seed":seed_value,"first":a,"second":b,"winner":winner,"turns":turns,"actions":actions,"hp":[m.players[0].hp,m.players[1].hp],"finish":finish,"unused_mana":idle_mana,"supplied_mana":supplied_mana,"cards_played":cards_played}

func summarize(cohort: String) -> Dictionary:
 var summary: Dictionary={"classes":{},"matchups":[],"first_wins":0,"draws":0,"games":0,"fatigue_finishes":0,"turns":0}
 for faction in FACTIONS:summary.classes[faction]={"games":0,"wins":0,"draws":0,"unused_mana":0,"supplied_mana":0}
 for game in games:
  if game.cohort!=cohort:continue
  summary.games+=1
  summary.turns+=game.turns
  if game.winner==game.first:summary.first_wins+=1
  if game.winner=="Empate":summary.draws+=1
  if game.finish=="fatigue":summary.fatigue_finishes+=1
  for side in range(2):
   var faction: String=game.first if side==0 else game.second
   summary.classes[faction].games+=1
   if game.winner==faction:summary.classes[faction].wins+=1
   if game.winner=="Empate":summary.classes[faction].draws+=1
   summary.classes[faction].unused_mana+=game.unused_mana[side]
   summary.classes[faction].supplied_mana+=game.supplied_mana[side]
 for i in range(FACTIONS.size()):
  for j in range(i+1,FACTIONS.size()):
   var row:={"a":FACTIONS[i],"b":FACTIONS[j],"a_wins":0,"b_wins":0,"draws":0}
   for game in games:
    if game.cohort!=cohort or not (game.first in [row.a,row.b] and game.second in [row.a,row.b]):continue
    if game.winner==row.a:row.a_wins+=1
    elif game.winner==row.b:row.b_wins+=1
    else:row.draws+=1
   summary.matchups.append(row)
 return summary

func apply_patch_variant() -> void:
 patch_name=OS.get_environment("BALANCE_PATCH")
 if patch_name.is_empty():patch_name="baseline"
 match patch_name:
  "posture": changes=[["iron_stance","spell_secondary",1]]
  "warrior": changes=[["warrior","armor",1]]
  "cleric": changes=[["dawn_warden","attack",3]]
  "mage": changes=[["astral_flame","cost",2]]
  "combined": changes=[["iron_stance","spell_secondary",1],["warrior","armor",1],["dawn_warden","attack",3],["astral_flame","cost",2]]
 for change in changes:
  Match.CARD_DATA[change[0]].set(change[1],change[2])
 Match.CARDS=Match.build_cards()

func run() -> void:
 apply_patch_variant()
 policy=OS.get_environment("BALANCE_POLICY")
 if policy.is_empty():policy="production"
 var rounds:=int(OS.get_environment("BALANCE_ROUNDS"))
 if rounds<=0:rounds=10
 var started:=Time.get_ticks_msec()
 for cohort in ["archetype","shared"]:
  for faction in FACTIONS:
   var cards:=deck(faction,cohort)
   assert(Match.valid_deck(cards))
   for key in cards:
    assert(Match.CARD_DATA[key].card_class in [IDS[faction],CardData.CardClass.NEUTRAL],"Deck deve usar só a classe + neutros")
  for i in range(FACTIONS.size()):
   for j in range(i+1,FACTIONS.size()):
    for seed_value in range(1,rounds+1):
     games.append(simulate(FACTIONS[i],FACTIONS[j],cohort,seed_value))
     games.append(simulate(FACTIONS[j],FACTIONS[i],cohort,seed_value))
  print(JSON.stringify({"policy":policy,"summary":summarize(cohort)}))
  await process_frame
 var decks: Dictionary={}
 for cohort in ["archetype","shared"]:
  decks[cohort]={}
  for faction in FACTIONS:decks[cohort][faction]=deck(faction,cohort)
 var output:={"patch":patch_name,"changes":changes,"policy":policy,"rounds":rounds,"games":games,"summaries":{"archetype":summarize("archetype"),"shared":summarize("shared")},"decks":decks,"candidate_actions":candidate_actions,"elapsed_ms":Time.get_ticks_msec()-started}
 var path:=OS.get_environment("BALANCE_OUTPUT")
 assert(not path.is_empty())
 var file:=FileAccess.open(path,FileAccess.WRITE)
 file.store_string(JSON.stringify(output," "))
 file.close()
 print("COMPLETE ",games.size()," games; ",output.elapsed_ms," ms; ",candidate_actions," evaluated actions")
 quit()
