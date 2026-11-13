extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
const Match=preload("res://scripts/match.gd")
const Names=preload("res://scripts/faction_names.gd")
var report: Array[String]=["# Simulação automática de aventura", "", "Duelos resolvidos pelo motor real, sem atribuir vitórias. Um agente heurístico joga pelo protagonista; o adversário usa a IA normal. Sem interface ou animações. Este resultado não demonstra equilíbrio de todas as campanhas.", ""]
func _initialize() -> void:call_deferred("simulate")
func value(key: String) -> float:
 var c=Match.CARD_DATA[key]
 if c.card_type==CardData.CardType.SPELL:
  return 4.0+c.spell_value+2.0*c.spell_secondary if c.spell_effect in [CardData.SpellEffect.ARCANE,CardData.SpellEffect.AREA_ARCANE,CardData.SpellEffect.MAGIC_MISSILES,CardData.SpellEffect.RESTORE] else 2.0+c.spell_value
 return c.attack+c.health*0.85+c.armor*2+c.block*0.6+c.magic_damage*2+c.growth*2+c.regeneration*2+(2 if c.flying else 0)+(2 if c.swift else 0)+c.entry_value+c.entry_attack+c.entry_health+c.aura_value*2
func best_card(keys: Array,run) -> String:
 var pool=keys.duplicate()
 var spells:=0
 for key in run.deck:
  if Match.CARD_DATA[key].card_type==CardData.CardType.SPELL:spells+=1
 pool.sort_custom(func(a,b):return value(a)-(5 if spells>=4 and Match.CARD_DATA[a].card_type==CardData.CardType.SPELL else 0)>value(b)-(5 if spells>=4 and Match.CARD_DATA[b].card_type==CardData.CardType.SPELL else 0))
 return pool[0]
func pick_power(run) -> void:
 var options: Array=run.power_options()
 for preferred in ["starting_life","first_mana","draw_attack","combat_gold"]:
  if preferred in options:
   var previous: int=run.max_life();run.powers.append(preferred);run.heal(run.max_life()-previous)
   report.append("Poder escolhido: **%s**." % State.POWERS[preferred].name)
   return
func player_step(m) -> bool:
 var p: Dictionary=m.players[0]
 for i in range(p.board.size()):
  if m.can_target(0,i,-1) and Match.physical_attack(p.board[i])>=m.players[1].hp:return m.act(0,i,-1)
 for i in range(p.board.size()):
  var unit: Dictionary=p.board[i]
  for quick in [true,false]:
   var amount: int=unit.get("quick_heal_amount",0) if quick else unit.get("heal_amount",0)
   if amount<=0:continue
   if p.hp<int(p.max_hp) and m.can_heal(0,i,-1,0,quick):return m.heal(0,i,-1,0,quick)
   for j in range(p.board.size()):
    var ally: Dictionary=p.board[j]
    if not Match.is_undead(ally) and ally.health<ally.max_health and m.can_heal(0,i,j,0,quick):return m.heal(0,i,j,0,quick)
  var target: int=-2;var score: int=-999
  for j in range(m.players[1].board.size()):
   if m.can_target(0,i,j,true):
    var s: int=m.ai_magic_score(m.players[1].board[j],int(unit.get("magic_damage",0))+m.magic_bonus(0))
    if unit.get("root_power",false):s=Match.physical_attack(m.players[1].board[j]) if not m.players[1].board[j].get("rooted",false) else -1
    if s>score:score=s;target=j
  if target>=0 and score>0:return m.act(0,i,target,true)
 # Use the existing AI spell evaluator on a mirrored snapshot; execute on the real match.
 var mirror=Match.new()
 mirror.players=[m.players[1].duplicate(true),m.players[0].duplicate(true)]
 mirror.turn=1;mirror.opening=false
 for i in range(p.hand.size()):
  var card: Dictionary=Match.CARDS[p.hand[i]]
  if card.card_type!=CardData.CardType.SPELL or p.mana<card.cost:continue
  if m.spell_target_count(0,i)>1:
   var targets: Array=[]
   for j in range(m.players[1].board.size()):
    if m.can_cast(0,i,1,j):targets.append({"side":1,"index":j})
   if m.can_cast(0,i,1,-1):targets.append({"side":1,"index":-1})
   if targets.size()>=2:return m.cast_multiple(0,i,targets.slice(0,2))
  else:
   var choice: Dictionary=mirror.ai_spell_target(i)
   if not choice.is_empty() and m.can_cast(0,i,1-int(choice.side),choice.index):return m.cast(0,i,1-int(choice.side),choice.index)
 var hand: Array=[]
 for i in range(p.hand.size()):hand.append(i)
 hand.sort_custom(func(a,b):return value(p.hand[a])>value(p.hand[b]))
 for i in hand:
  var card: Dictionary=Match.CARDS[p.hand[i]]
  if card.card_type==CardData.CardType.SPELL:continue
  var target: int=m.entry_target(0,card) if Match.entry_target_side(0,card)>=0 else -1
  if m.can_play(0,i,target):return m.play(0,i,target,m.ai_rogue_choice(0,target) if card.entry_effect==CardData.EntryEffect.GRANT_ROGUE_CHOICE and target>=0 else "")
 for i in range(p.board.size()):
  var u: Dictionary=p.board[i]
  if u.get("fury",0)>0 and not u.get("fury_used",false) and p.mana>=1:return m.fury(0,i)
 for i in range(p.board.size()):
  var best: int=-2;var score: int=-99999
  for j in range(m.players[1].board.size()):
   if m.can_target(0,i,j):
    var s: int=m.ai_attack_score(p.board[i],m.players[1].board[j])
    if s>score:score=s;best=j
  if best>=0 and score>=12:return m.act(0,i,best)
  if m.can_target(0,i,-1):return m.act(0,i,-1)
  if best>=0:return m.act(0,i,best)
 return false
func combat(run,node: Dictionary) -> bool:
 var start: int=run.current_life
 if node.kind=="boss":run.encounter="black_dragon"
 var m=Match.new(run.deck,node.deck,randi_range(0,1),true,run.rules())
 for side in [0,1]:
  var swaps: Array=[]
  for i in range(m.players[side].hand.size()):
   if Match.CARD_DATA[m.players[side].hand[i]].cost>=4:swaps.append(i)
  m.mulligan(side,swaps)
 var turns:=1;var actions:=0
 for action in range(2500):
  if m.winner!=-1:break
  var acted: bool=m.ai_step() if m.turn==1 else player_step(m)
  if not acted:m.end_turn(m.turn);turns+=1
  actions+=1
 report.append("- Duelo %s (%s, %d cartas): vida %d → %d; %d turnos, %d ações; **%s**." % [Names.PT[node.faction],node.kind,node.deck.size(),start,m.players[0].hp,turns,actions,"vitória" if m.winner==0 else "derrota" if m.winner==1 else "empate/limite"])
 if m.winner==-1:report.append("  Limite de segurança alcançado; não foi considerado vitória.")
 run.enemy_faction=node.faction
 run.finish_combat(m.winner==0,m.players[0].hp)
 if m.winner!=0:return false
 var key: String=best_card(run.options,run)
 run.deck.append(key);report.append("  Recruta: %s; vida após recuperação: %d/%d; ouro: %d." % [Match.CARD_DATA[key].title,run.current_life,run.max_life(),run.gold])
 if run.extra_item_reward:
  run.extra_item_reward=false;run.pending_item="";run.prepare_item();run.apply_item(best_card(run.options,run))
 else:run.advance()
 return true
func expedition(faction: int,seed_value: int) -> bool:
 seed(seed_value)
 var run=State.new();run.rng.seed=seed_value;run.faction=faction
 report.append("## Tentativa · %s · semente %d" % [Names.PT[faction],seed_value])
 for i in range(15):run.deck.append(best_card(run.draft_options(),run))
 report.append("Deck inicial: "+", ".join(run.deck.map(func(k):return Match.CARD_DATA[k].title))+".")
 pick_power(run);run.phase="map";run.ensure_routes()
 while run.step<State.STAGES.size():
  var candidates: Array=[]
  for index in range(run.route_rows[run.step].size()):
   if run.route_available(index):candidates.append(index)
  candidates.sort_custom(func(a,b):return route_score(run,run.route_rows[run.step][a])>route_score(run,run.route_rows[run.step][b]))
  var index: int=candidates[0]
  var node: Dictionary=run.route_rows[run.step][index]
  run.chosen_routes[run.step]=index
  run.preparation_active=bool(node.get("preparation",false))
  report.append("Etapa %d · caminho %d · %s" % [run.step+1,index+1,node.kind])
  match node.kind:
   "combat","boss":
    if not combat(run,node):return false
   "healer":
    var paid: bool=run.current_life<run.max_life()*0.45 and run.gold>=run.healer_cost()
    run.visit_healer(paid);run.grant_vitality();report.append("Cura %s; vida %d/%d, ouro %d." % ["total paga" if paid else "grátis",run.current_life,run.max_life(),run.gold]);run.advance()
   "power_event":pick_power(run);run.grant_vitality();run.advance()
   "item":
    run.prepare_item();var key: String=best_card(run.options,run);report.append("Item %s em %s." % [State.Items.DEFINITIONS[run.pending_item].name,Match.CARD_DATA[key].title]);run.apply_item(key)
   "shop":
    if run.preparation_active:run.gold+=3
    var offers: Array=run.shuffled(Match.CARD_DATA.keys().filter(func(k):return Match.CARD_DATA[k].collectible and not Match.CARD_DATA[k].neutral_deck_only)).slice(0,6)
    while run.gold>=3 and not offers.is_empty():
     var key: String=best_card(offers,run);offers.erase(key)
     if run.buy_card(key,3):report.append("Compra: "+Match.CARD_DATA[key].title)
    run.grant_vitality();run.advance()
   "treasure":
    var amount: int=run.rng.randi_range(1,6);run.gold+=amount;run.grant_vitality();report.append("Tesouro: +%d ouro." % amount);run.advance()
   "chest":
    run.phase="chest";var outcome: String=run.resolve_chest();report.append("Resultado do baú: "+outcome)
    if outcome=="mimic":
     if not combat(run,{"kind":"mimic","faction":2,"deck":run.enemy}):return false
    elif outcome=="item":run.apply_item(best_card(run.options,run))
    else:run.advance()
   "bridge":
    run.phase="bridge";run.resolve_bridge("pay");report.append(run.event_message);run.advance()
 report.append("**Aventura concluída. Vida %d/%d, ouro %d, deck com %d cartas.**" % [run.current_life,run.max_life(),run.gold,run.deck.size()])
 return true
func route_score(run,node: Dictionary) -> float:
 match node.kind:
  "healer":return 100 if run.current_life<run.max_life()*0.75 else 5
  "power_event":return 80
  "item":return 50
  "shop":return 55 if run.gold>=3 else 0
  "treasure":return 40
  "chest":return 30
  "bridge":return 10
 return 20
func simulate() -> void:
 var successes:=0;var attempts:=0
 for setup in [[0,4101],[1,4102],[4,4103],[6,4104],[3,4105],[5,4106]]:
  attempts+=1
  var won: bool=expedition(setup[0],setup[1])
  print("Tentativa %d: %s" % [attempts,"CONCLUÍDA" if won else "DERROTA"])
  if won:successes+=1;break
 report.append("")
 report.append("Resultado: %d conclusão(ões) em %d tentativa(s). As sementes não foram repetidas para mudar compras ou resultados." % [successes,attempts])
 var file=FileAccess.open("res://docs/SIMULACAO_AVENTURA.md",FileAccess.WRITE);file.store_string("\n\n".join(report));file.close()
 print("SIMULACAO: %d/%d concluídas. Relatório: docs/SIMULACAO_AVENTURA.md" % [successes,attempts])
 quit()

