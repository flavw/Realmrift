extends RefCounted
# The host owns the only rules simulation. Views contain no draw order or enemy hand.
const Match=preload("res://scripts/match.gd")
const PROTOCOL=1
const FIELDS=["players","turn","winner","first_player","opening","mulligan_done","mulligan_rounds","history","history_sides","human_deaths","last_action","draw_events","castle_traps","next_id"]

static func fingerprint() -> String:
 var catalog: Dictionary={}
 for key in Match.CARD_DATA:
  var data: CardData=Match.CARD_DATA[key]
  if data.has_meta("adventure_base"):continue
  catalog[key]=data.combat_data()
 return (str(PROTOCOL)+JSON.stringify(catalog)).sha256_text()

static func map_side(value: int,viewer: int) -> int:
 return value ^ viewer if value in [0,1] else value

static func map_records(value: Variant,viewer: int) -> Variant:
 if value is Array:
  var result: Array=[]
  for item in value:result.append(map_records(item,viewer))
  return result
 if value is Dictionary:
  var result: Dictionary={}
  for key in value:
   var item=value[key]
   result[key]=map_side(item,viewer) if (key=="side" or String(key).ends_with("_side")) and item is int else map_records(item,viewer)
  return result
 return value

static func view(m,viewer: int) -> Dictionary:
 var state: Dictionary={}
 for key in FIELDS:state[key]=m.get(key).duplicate(true) if m.get(key) is Array or m.get(key) is Dictionary else m.get(key)
 state.players=[m.players[viewer].duplicate(true),m.players[1-viewer].duplicate(true)]
 for side in range(2):
  # Even the owner's draw pile remains secret: only its size is sent.
  state.players[side].deck.fill("")
  if side==1:state.players[side].hand.fill("")
 for key in ["turn","winner","first_player"]:state[key]=map_side(state[key],viewer)
 for key in ["mulligan_done","mulligan_rounds","human_deaths"]:
  state[key]=[state[key][viewer],state[key][1-viewer]]
 state.history_sides=[]
 for side in m.history_sides:state.history_sides.append(map_side(side,viewer))
 state.last_action=map_records(m.last_action,viewer)
 state.draw_events=[]
 for event in m.draw_events:
  var record: Dictionary=map_records(event,viewer)
  if record.side==1:record.key=""
  state.draw_events.append(record)
 state.castle_traps=[m.castle_traps[viewer].duplicate(true),[]]
 for _trap in m.castle_traps[1-viewer]:state.castle_traps[1].append({"remaining":0,"damage":0})
 return state

static func apply_view(m,state: Dictionary) -> void:
 for key in FIELDS:
  if not state.has(key):continue
  if m.get(key) is Array:m.get(key).assign(state[key].duplicate(true))
  else:m.set(key,state[key].duplicate(true) if state[key] is Dictionary else state[key])

static func valid_command(command: Dictionary) -> bool:
 if command.size()>10 or not command.get("kind") is String:return false
 if command.kind not in ["play","act","cast","cast_multiple","heal","fury","end_turn","attack_all","mulligan","surrender"]:return false
 for key in ["hand","index","target","target_side","trap_choice"]:
  if command.has(key) and (not command[key] is int or command[key]<-1 or command[key]>64):return false
 for key in ["magical","quick"]:
  if command.has(key) and not command[key] is bool:return false
 if command.has("choice") and command.choice not in ["","loot","envenom"]:return false
 if command.has("indices"):
  if not command.indices is Array or command.indices.size()>Match.MAX_HAND_SIZE:return false
  for index in command.indices:
   if not index is int or index<0 or index>=Match.MAX_HAND_SIZE:return false
 if command.has("targets"):
  if not command.targets is Array or command.targets.size()!=2:return false
  for target in command.targets:
   if not target is Dictionary or target.size()!=2:return false
   if not target.get("side") is int or target.side not in [0,1]:return false
   if not target.get("index") is int or target.index<-1 or target.index>=Match.MAX_BOARD:return false
 return true

static func execute(m,side: int,command: Dictionary) -> bool:
 if side not in [0,1] or not valid_command(command) or m.winner!=-1:return false
 var kind: String=command.kind
 if kind=="surrender":
  m.winner=1-side;m.opening=false
  m.last_action={"kind":"surrender","side":side,"dead":[]}
  m.log_event("%s desistiu do duelo." % m.side_name(side),side)
  return true
 if kind=="mulligan":return m.mulligan(side,command.get("indices",[]))
 if m.opening or m.turn!=side:return false
 var index: int=int(command.get("index",-1))
 var target: int=int(command.get("target",-1))
 var owner: int=int(command.get("target_side",1))
 if owner not in [-1,0,1]:return false
 if owner>=0:owner=map_side(owner,side)
 match kind:
  "play":return m.play(side,int(command.get("hand",-1)),target,String(command.get("choice","")))
  "act":return m.act(side,index,target,bool(command.get("magical",false)),owner)
  "cast":
   var hand: int=int(command.get("hand",-1))
   if hand<0 or hand>=m.players[side].hand.size():return false
   if m.spell_target_count(side,hand)>1:return false
   # A human must explicitly choose their secret; never use the AI's random choice.
   if Match.CARDS[m.players[side].hand[hand]].spell_effect==CardData.SpellEffect.CASTLE_TRAP and command.get("trap_choice",0) not in [1,2]:return false
   return m.cast(side,hand,owner,target,int(command.get("trap_choice",0)))
  "cast_multiple":
   var targets: Array=[]
   for choice in command.get("targets",[]):targets.append({"side":map_side(choice.side,side),"index":choice.index})
   return m.cast_multiple(side,int(command.get("hand",-1)),targets)
  "heal":return m.heal(side,index,target,owner,bool(command.get("quick",false)))
  "fury":return m.fury(side,index)
  "end_turn":return m.end_turn(side)
 return false
