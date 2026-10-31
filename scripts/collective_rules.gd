extends RefCounted
# Recompute inherited ranks without reapplying buffs, healing damage or refilling charges.
const NUMERIC=["armor","fury","magic_damage","magic_splash","growth","resonance","rural_pride","heal_amount","quick_heal_amount","magic_power","envenom","loot","bleed","harvest","commerce","devotion","spores","regeneration"]
const FLAGS=["swift","flying","wall"]

static func refresh(m) -> void:
 for p in m.players:
  for unit in p.board:
   if unit.get("collective",false) and unit.health>0:update_unit(m,unit,p.board)

static func update_unit(m,unit: Dictionary,board: Array) -> void:
 var count:=0
 var sources: Array=[]
 for ally in board:
  if ally.health<=0:continue
  if m.unit_class(ally)==CardData.CardClass.NEUTRAL:count+=1
  # Copies of Multidão never feed each other; sources are the original allied abilities.
  if not is_same(ally,unit) and m.unit_class(ally)==CardData.CardClass.NEUTRAL and not ally.get("collective",false):sources.append(ally)
 var delta: int=count-int(unit.get("collective_count",1))
 unit.attack+=delta
 unit.health+=delta
 unit.max_health=int(unit.get("max_health",1))+delta
 unit.collective_count=count
 var old: Dictionary=unit.get("inherited_ranks",{})
 var ranks: Dictionary={}
 for field in NUMERIC:
  var total:=0
  for source in sources:total+=int(source.get(field,0))
  ranks[field]=total
  unit[field]=maxi(0,int(unit.get(field,0))+total-int(old.get(field,0)))
 for field in FLAGS:
  unit[field]=sources.any(func(source):return source.get(field,false))
 if unit.get("vigor",false) and not unit.get("inherited_vigor",false):unit.granted_vigor=true
 unit.inherited_vigor=sources.any(func(source):return source.get("vigor",false))
 unit.vigor=unit.get("granted_vigor",false) or unit.inherited_vigor
 for field in ["block","abascanto"]:
  var capacity: int=int(unit.get("granted_block",0)) if field=="block" else 0
  for source in sources:
   capacity+=m.block_capacity(source) if field=="block" else m.abascanto_capacity(source)
  var old_capacity: int=int(unit.get(field+"_capacity",0))
  unit[field]=clampi(int(unit.get(field,0))+capacity-old_capacity,0,capacity)
  unit[field+"_capacity"]=capacity
 for kind in ["magic","heal","quick_heal"]:
  var cost:=999
  var amount_key: String="magic_damage" if kind=="magic" else kind+"_amount"
  for source in sources:
   if int(source.get(amount_key,0))>0:cost=mini(cost,int(source.get(kind+"_cost",1)))
  unit[kind+"_cost"]=1 if cost==999 else cost
 var auras: Array=[]
 for source in sources:
  if int(source.get("aura_effect",0))!=CardData.AuraEffect.NONE:
   auras.append({"aura_effect":source.aura_effect,"aura_value":source.aura_value,"aura_targets":source.aura_targets,"aura_includes_self":source.aura_includes_self})
 unit.inherited_auras=auras
 unit.inherited_ranks=ranks
 if unit.wall:unit.poison=0;unit.bleeding=0

static func display_card(m,unit: Dictionary) -> CardData:
 var base: CardData=m.CARD_DATA[unit.key]
 if not unit.get("collective",false):return base
 var view: CardData=base.duplicate()
 view.attack=int(unit.get("collective_count",1));view.health=view.attack
 for field in NUMERIC+FLAGS+["vigor","magic_cost","heal_cost","quick_heal_cost"]:view.set(field,unit.get(field,view.get(field)))
 view.block=m.block_capacity(unit);view.abascanto=m.abascanto_capacity(unit)
 view.aura_value=0
 for aura in unit.get("inherited_auras",[]):
  view.aura_effect=aura.aura_effect
  view.aura_value+=int(aura.aura_value)
  view.aura_targets=aura.aura_targets
  view.aura_includes_self=aura.aura_includes_self
 return view
