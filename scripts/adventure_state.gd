extends RefCounted

# Progressão exclusiva da aventura.
const Match = preload("res://scripts/match.gd")
const POWERS = {
 "all_trample":{"name":"Avanço imparável","description":"Todas as suas criaturas têm Atropelar durante cada combate."},
 "first_three_keywords":{"name":"Dons do destino","description":"As três primeiras criaturas jogadas da mão em cada combate recebem uma palavra-chave bônus aleatória: Envenenar 1, Voo, Antimagia 1, Disparada, Atropelar ou Alcance."},
 "bonus_spell":{"name":"Truque na manga","description":"No início de cada combate, receba na mão uma magia aleatória de qualquer facção."},
 "starting_allies":{"name":"Companhia inesperada","description":"No início de cada combate, invoque gratuitamente duas criaturas aleatórias de custo 1, de qualquer facção."},
 "castle_armor":{"name":"Muralhas reforçadas","description":"Seu castelo tem Armadura 1: reduz em 1 cada ocorrência de dano físico. Não reduz dano mágico ou fadiga."},
 "battle_hardened":{"name":"Veterano","description":"+2 de vida máxima em cada duelo desta expedição."},
 "extra_draw":{"name":"Suprimentos","description":"Compre uma carta adicional no seu primeiro turno de cada duelo."},
 "first_mana": {"name":"Impulso inicial", "description":"+1 mana temporária no primeiro turno."},
 "draw_attack": {"name":"Inspiração", "description":"Ao comprar uma carta, suas criaturas recebem +1 de ataque até o fim do turno."},
 "starting_life": {"name":"Fortaleza", "description":"+5 de vida inicial em cada duelo."},
 "combat_gold": {"name":"Tesouro de guerra", "description":"+1 de ouro após cada vitória."},
}
const POWER_ICONS={"all_trample":"trample-icon","first_three_keywords":"aura-icon","bonus_spell":"necrotic-icon","starting_allies":"collective-icon","castle_armor":"armor-icon","battle_hardened":"vigor-icon","extra_draw":"draw-icon","first_mana":"ability-mana-diamond","draw_attack":"fury-icon","starting_life":"devotion-icon","combat_gold":"adventure-gold-icon"}
const Items=preload("res://scripts/adventure_items.gd")
const DECK_RULES="Você começa com 15 cartas. Durante a aventura, seu deck pode ultrapassar 22 cartas e ter mais de 2 cópias de cada carta. Você pode recrutar aliados de qualquer facção."
const INTRO_TEXT="Uma fenda se abriu além das montanhas, e uma sombra alada passou a cobrir as ruínas da velha estrada. Na Vila do Vale, as caravanas deixaram de chegar e os campos já não parecem tão seguros. Você possui um dom raro: consegue reunir aliados de qualquer facção, mesmo entre povos que normalmente jamais lutariam juntos. O povo da vila deposita suas esperanças nessa união. Ao amanhecer, você parte pelos caminhos entre fazendas, pontes e bosques, reunindo companheiros e recursos para uma jornada que os guardas da vila não podem enfrentar sozinhos. Nas ruínas além dos últimos refúgios, o Dragão Negro guarda a fenda. Derrotá-lo é a única maneira de devolver a paz ao vale — mas cada escolha na estrada poderá decidir quem chegará vivo até lá."
const CURVE = [1,1,2,2,2,2,3,3,3,3,4,4,4,5,5]
var draft_curve: Array = []
var profile
var farm_blessing_pending := false
var victory_sound_pending := false
var event_art := ""
var farm_blessing_all_run := false
var account_life := 0
var initial_item_available := false
var initial_item_consumed := false
var item_return_phase := ""
var preparation_active := false
var retries_left := 0
var extra_lives_granted := 0
var account_creatures_applied: Dictionary={"creature_life":0,"creature_attack":0}
var account_creature_bonuses: Dictionary={"creature_life":0,"creature_attack":0}
var xp_awarded_steps: Dictionary={}
var last_xp_gained := 0
var expedition_id := ""
var pending_xp := 0
var xp_settled := false
var xp_before_settlement := 0
var xp_animation_pending := false
var settlement_reason := ""
var saved_duel: DuelMatch
var faction := -1
var deck: Array = []
var powers: Array = []
var dice := 2
var gold := 1
var current_life := 20
var treasure_roll := 0
var encounter := ""
var event_message := ""
var pending_item := ""
var extra_item_reward := false
var reward_message := ""
var shop_premium_key := ""
var shop_premium_price := 3
var shop_premium_sold := false
var shop_step := -1
var shop_groups: Array = []
var chest_result := ""
var route_rows: Array = []
var chosen_routes: Dictionary = {}
var permanent_life := 0
var equipment: Array = []
var card_item_grants: Dictionary = {}
var item_variant_cache: Dictionary = {}
var item_grant_serial := 0
var map_scroll_position := 0.0
var rng := RandomNumberGenerator.new()

func _init(account=null) -> void:
 rng.randomize()
 expedition_id=str(Time.get_unix_time_from_system())+"_"+str(rng.randi())
 draft_curve=shuffled(CURVE)
 profile=account
 if profile!=null:
  dice+=profile.initial_dice_bonus()
  var bonuses: Dictionary=profile.totals()
  account_life=int(bonuses.life)
  current_life+=account_life
  gold+=int(bonuses.gold)
  account_creature_bonuses={"creature_life":int(bonuses.creature_life),"creature_attack":int(bonuses.creature_attack)}
  extra_lives_granted=profile.extra_lives()
  retries_left=extra_lives_granted
  initial_item_available=profile.initial_items()>0

func shuffled(values: Array) -> Array:
 var result := values.duplicate()
 for i in range(result.size()-1,0,-1):
  var j := rng.randi_range(0,i)
  var item = result[i]
  result[i] = result[j]
  result[j] = item
 return result

func draft_options() -> Array:
 if faction < 0 or deck.size() >= 15:return []
 var candidates := []
 for key in Match.CARD_DATA:
  var card = Match.CARD_DATA[key]
  if not card.collectible or not Match.faction_allowed(faction,card.faction):continue
  if card.neutral_deck_only:continue
  candidates.append(key)
 var target: int = draft_curve[deck.size()]
 candidates = shuffled(candidates)
 candidates.sort_custom(func(a,b): return absi(Match.CARD_DATA[a].cost-target) < absi(Match.CARD_DATA[b].cost-target))
 return shuffled(candidates.slice(0,3))

func reroll_draft() -> bool:
 if phase!="draft" or dice<=0 or faction<0 or deck.size()>=15:return false
 var candidates: Array=[]
 for key in Match.CARD_DATA:
  var card: CardData=Match.CARD_DATA[key]
  if not card.collectible or card.neutral_deck_only or not Match.faction_allowed(faction,card.faction):continue
  candidates.append(key)
 if candidates.size()<3:return false
 var fresh: Array=candidates.filter(func(key):return key not in options)
 if fresh.size()>=3:candidates=fresh
 options=shuffled(candidates).slice(0,3)
 dice-=1
 return true

func power_options() -> Array:
 var available := []
 for key in POWERS:
  if key not in powers and not (preparation_active and key=="combat_gold"):available.append(key)
 return shuffled(available).slice(0,3)

# Opções de recompensa são geradas por uma etapa e preservadas pelo chamador.
func reward_options(enemy_faction: int,excluded: Array = []) -> Array:
 var faction_cards := []
 var other_cards := []
 for key in Match.CARD_DATA:
  var card = Match.CARD_DATA[key]
  if not card.collectible or card.neutral_deck_only or key in excluded:continue
  if card.faction == enemy_faction:faction_cards.append(key)
  else:other_cards.append(key)
 # Keep the enemy-faction guarantee even if every such card was in the old offer.
 if faction_cards.is_empty() and not excluded.is_empty():
  for key in excluded:
   if not Match.CARD_DATA.has(key):continue
   var card: CardData=Match.CARD_DATA[key]
   if card.collectible and not card.neutral_deck_only and card.faction==enemy_faction:faction_cards.append(key)
 faction_cards = shuffled(faction_cards)
 other_cards = shuffled(other_cards)
 if faction_cards.is_empty():return other_cards.slice(0,3)
 var options := [faction_cards.pop_back()]
 other_cards.append_array(faction_cards)
 other_cards = shuffled(other_cards)
 options.append_array(other_cards.slice(0,2))
 return shuffled(options)

func rerollable_powers() -> Array:
 var result: Array=[]
 for key in POWERS:
  if key not in powers and not (preparation_active and key=="combat_gold"):result.append(key)
 return result

func item_creatures() -> Array:
 var result: Array=[]
 var bases: Array=[]
 for key in deck:
  if not Match.CARD_DATA.has(key):continue
  var base: String=Items.base_key(key)
  if Match.CARD_DATA[key].card_type==CardData.CardType.CREATURE and base not in bases:
   result.append(key);bases.append(base)
 return result

func can_reroll_offer() -> bool:
 if dice<=0:return false
 match phase:
  "draft":return faction>=0 and deck.size()<15
  "power","midpower":return rerollable_powers().any(func(key):return key not in options)
  "reward":
   for key in Match.CARD_DATA:
    var card: CardData=Match.CARD_DATA[key]
    if card.collectible and not card.neutral_deck_only and key not in options:return true
   return false
  "item":return not item_creatures().is_empty() and pending_item in ["charm","heart","sword","shield","boots"]
 return false

func reroll_offer() -> bool:
 if not can_reroll_offer():return false
 if phase=="draft":return reroll_draft()
 match phase:
  "power","midpower":
   var available:=rerollable_powers()
   var fresh: Array=shuffled(available.filter(func(key):return key not in options))
   var chosen: Array=fresh.slice(0,3)
   if chosen.size()<3:
    var remaining: Array=shuffled(available.filter(func(key):return key not in chosen))
    chosen.append_array(remaining.slice(0,3-chosen.size()))
   options=shuffled(chosen)
  "reward":
   var replacement:=reward_options(enemy_faction,options)
   if replacement.size()<3:replacement=reward_options(enemy_faction)
   if replacement.is_empty():return false
   options=replacement
  "item":
   var items: Array=["heart","sword","shield","boots"]
   items.erase(pending_item)
   if items.is_empty():return false
   pending_item=shuffled(items)[0]
   var creatures:=item_creatures()
   if options.any(func(key):return key not in creatures):options=shuffled(creatures).slice(0,3)
  _:return false
 dice-=1
 return true

func gain_victory_gold(base_amount: int = 1) -> void:
 gold += maxi(0,base_amount) + (1 if "combat_gold" in powers else 0)

func buy_card(key: String, price: int) -> bool:
 if price < 0 or gold < price or not Match.CARD_DATA.has(key):return false
 var card = Match.CARD_DATA[key]
 if not card.collectible or card.neutral_deck_only:return false
 gold -= price
 add_card_to_deck(key)
 return true

static var current
var phase := "intro"
var step := 0
var options: Array = []
var enemy: Array = []
var enemy_faction := 0
var in_combat := false
const STAGES = ["combat","combat","event","combat","power_event","combat","shop","combat","combat","preparation","preparation","boss"]

func rules() -> Dictionary:
 return {"enabled":true,"powers":powers,"enemy_castle_life":enemy_castle_life(),"life_bonus":permanent_life+account_life+(2 if "battle_hardened" in powers else 0),"equipment":equipment,"current_life":current_life,"encounter":encounter,"farm_blessing":farm_blessing_pending or farm_blessing_all_run,"farm_blessing_persistent":farm_blessing_all_run}

func enemy_castle_life() -> int:
 var duel_index:=0
 for at in range(mini(step,STAGES.size())):
  if STAGES[at]=="combat":duel_index+=1
 return [12,15,17,18,19,20][mini(duel_index,5)]

func finish_combat(won: bool, remaining_life: int = -1) -> void:
 in_combat=false
 saved_duel=null
 victory_sound_pending=won
 reward_message=""
 last_xp_gained=0
 if not won:
  phase="retry" if retries_left>0 else "defeat"
  if phase=="defeat":settle_xp("defeat")
  return
 if not xp_awarded_steps.has(step):
  last_xp_gained=3 if step==STAGES.size()-1 and encounter not in ["bandits","mimic"] else 1
  pending_xp+=last_xp_gained
  xp_awarded_steps[step]=true
 farm_blessing_pending=false
 if remaining_life >= 0:current_life=clampi(remaining_life,1,max_life())
 heal(ceili(max_life()*0.20))
 gain_victory_gold()
 if encounter=="mimic":
  gold+=3
  extra_item_reward=true
  reward_message="Tesouro do mímico: 4 ouro, uma carta e um item garantido para aprimorar uma carta do deck."+(" +1 ouro de Tesouro de Guerra." if "combat_gold" in powers else "")
 elif encounter=="bandits":
  gold+=2
  extra_item_reward=true
  reward_message="Bandidos vencidos: +2 ouro e um item extras, além da recompensa normal."
 encounter=""
 phase="reward"
 options=reward_options(enemy_faction)

func advance() -> void:
 encounter=""
 pending_item=""
 event_art=""
 preparation_active=false
 step+=1
 options.clear()
 phase="victory" if step>=STAGES.size() else "map"
 if phase=="victory":settle_xp("victory")

func max_life() -> int:
 return 20+permanent_life+account_life+(5 if "starting_life" in powers else 0)+(2 if "battle_hardened" in powers else 0)

func heal(amount: int) -> void:
 current_life=mini(max_life(),current_life+maxi(0,amount))

func healer_cost() -> int:
 return ceili(max_life()*0.10)

func visit_healer(full: bool) -> bool:
 if preparation_active:
  current_life=max_life()
  return true
 if full:
  if gold<healer_cost():return false
  gold-=healer_cost()
  current_life=max_life()
 else:heal(ceili(max_life()*0.25))
 return true

func grant_vitality() -> void:
 permanent_life+=1
 heal(1)

func enemy_deck_for(f: int, at: int) -> Array:
 var style: int={0:0,3:1,1:2,4:3,5:5,6:6}.get(f,0)
 var meta: Array=Match.default_deck(style)
 if at>=7:return meta
 # Early opponents have short, low-impact lists; later tiers gain meta synergies.
 var pool: Array=[]
 for key in Match.CARD_DATA:
  var c=Match.CARD_DATA[key]
  if not c.collectible or not Match.faction_allowed(f,c.faction) or c.neutral_deck_only:continue
  if c.card_type==CardData.CardType.CREATURE and c.cost<=3 and c.attack<=3 and c.health<=4:pool.append(key)
 pool=shuffled(pool)
 pool.sort_custom(func(a,b):return Match.CARD_DATA[a].cost<Match.CARD_DATA[b].cost)
 var result: Array=[]
 var target: int=15 if at<=1 else 18 if at<=3 else 20
 var meta_count: int=0 if at<=1 else 6 if at<=3 else 12
 for key in meta:
  if result.size()>=meta_count:break
  if result.count(key)<Match.copy_limit(key):result.append(key)
 for round_index in range(2):
  for key in pool:
   if result.size()>=target:break
   if result.count(key)<Match.copy_limit(key):result.append(key)
 for key in meta:
  if result.size()>=target:break
  if result.count(key)<Match.copy_limit(key):result.append(key)
 return result


func card_copies(key: String) -> int:
 var base: String=Items.base_key(key)
 var count:=0
 for k in deck:
  if Items.base_key(k)==base:count+=1
 return count

func prepare_item() -> void:
 var eligible: Array=[]
 var eligible_bases: Array=[]
 for key in deck:
  var base:=Items.base_key(key)
  if Match.CARD_DATA[key].card_type==CardData.CardType.CREATURE and base not in eligible_bases:eligible.append(key);eligible_bases.append(base)
 if eligible.size()<3:
  eligible=[]
  for key in deck:
   if key not in eligible:eligible.append(key)
  pending_item="charm"
 if pending_item.is_empty():pending_item=shuffled(["heart","sword","shield","boots"])[0]
 options=shuffled(eligible).slice(0,3)
 phase="item"

func apply_item(key: String) -> bool:
 if phase!="item" or key not in options or not Items.DEFINITIONS.has(pending_item):return false
 if key not in deck:return false
 grant_card_item(key,pending_item)
 if not item_return_phase.is_empty():
  phase=item_return_phase;item_return_phase="";pending_item="";options.clear()
  initial_item_consumed=true
 else:advance()
 return true

func resolve_bridge(choice: String) -> bool:
 if phase!="bridge":return false
 match choice:
  "pay":
   var paid: int=gold;gold=0;heal(ceili(max_life()*0.10))
   event_message="Você pagou %d ouro e recuperou 10%% da vida máxima." % paid
  "flee":
   var damage: int=ceili(max_life()*0.10) if rng.randf()<0.5 else 0
   current_life=maxi(1,current_life-damage)
   var bonus: String="nenhum bônus desta vez"
   if rng.randf()<0.5:
    if rng.randf()<0.5:gold+=1;bonus="+1 ouro"
    else:grant_vitality();bonus="+1 vida máxima"
   event_message="Fuga: %d de dano (não letal); %s." % [damage,bonus]
  "fight":
   encounter="bandits";enemy_faction=3
   enemy=enemy_deck_for(3,5);in_combat=true;phase="combat"
   return true
  _:return false
 phase="event_result"
 return true

func resolve_chest() -> String:
 if phase!="chest":return chest_result
 if rng.randf()<0.5:
  chest_result="mimic";encounter="mimic";enemy_faction=2
  enemy=Match.default_deck(0);in_combat=true;phase="combat"
 elif rng.randf()<0.5:
  chest_result="item";pending_item="";prepare_item()
 else:
  chest_result="gold";treasure_roll=rng.randi_range(1,6);gold+=treasure_roll
  event_message="O baú continha %d ouro." % treasure_roll;phase="event_result"
 return chest_result

func ensure_routes() -> void:
 if not route_rows.is_empty():return
 for at in range(STAGES.size()):
  var kind: String=STAGES[at]
  var row: Array=[]
  if kind=="boss":
   row=[{"kind":"boss","faction":5,"deck":Match.default_deck(5),"portrait":"adventure_black_dragon"}]
  elif kind=="preparation":
   row=[{"kind":"power_event","portrait":"","preparation":true},{"kind":"healer","portrait":"cleric","preparation":true},{"kind":"shop","portrait":"wise_merchant","preparation":true}] if at==9 else [{"kind":"item","portrait":"wall_smith","preparation":true},{"kind":"healer","portrait":"cleric","preparation":true}]
  elif kind=="combat":
   for f in shuffled([0,1,3,4,5,6]).slice(0,2):
    var cards: Array=enemy_deck_for(f,at)
    var portrait: String=""
    for key in cards:
     if portrait.is_empty() and Match.CARD_DATA[key].faction==f and Match.CARD_DATA[key].card_type==CardData.CardType.CREATURE:portrait=key
    if portrait.is_empty():portrait=cards[0]
    row.append({"kind":kind,"faction":f,"deck":cards,"portrait":portrait})
  elif kind=="power_event":row=[{"kind":"power_event","portrait":""},{"kind":"farm","portrait":"generous_peasant"}]
  elif kind=="shop":row=[{"kind":"shop","portrait":"wise_merchant"},{"kind":"healer","portrait":"cleric"}]
  else:row=[{"kind":"treasure","portrait":"generous_peasant"},{"kind":"healer","portrait":"cleric"}]
  # Wider branches in the first half, narrowing back to two paths near the end.

  if at==2:
   row.append({"kind":"item","portrait":"wall_smith"})
   row.append({"kind":"bridge","portrait":"lightning_rogue"})

  if at==4:
   row.append({"kind":"chest","portrait":""})
   row.append({"kind":"item","portrait":"wall_smith"})
  if at==6:row.append({"kind":"item","portrait":"wall_smith"})

  route_rows.append(row)

func linked(at: int, source: int, target: int) -> bool:
 var a: int=route_rows[at].size();var b: int=route_rows[at+1].size()
 # Each route has neighbours; expansion and convergence are actual connections.
 return target==clampi(roundi(float(source)*float(b-1)/maxi(1,a-1)),0,b-1) or absi(source-target)<=1

func route_available(index: int) -> bool:
 if step==0 or not chosen_routes.has(step-1):return true
 return linked(step-1,int(chosen_routes[step-1]),index)




func apply_account_creature_bonuses() -> void:
 # Called after the draft and after recruitment if the initial list had no creature.
 for perk in ["creature_life","creature_attack"]:
  while int(account_creatures_applied[perk])<int(account_creature_bonuses[perk]):
   var candidates: Array=[]
   for i in range(deck.size()):
    if Match.CARD_DATA[deck[i]].card_type==CardData.CardType.CREATURE:candidates.append(i)
   if candidates.is_empty():break
   var at: int=candidates[rng.randi_range(0,candidates.size()-1)]
   deck[at]=Items.enhance(deck[at],"training_health" if perk=="creature_life" else "training_attack")
   account_creatures_applied[perk]+=1

func use_extra_life() -> bool:
 if phase!="retry" or retries_left<=0:return false
 retries_left-=1
 saved_duel=null
 phase="combat"
 in_combat=true
 return true

func decline_retry() -> void:
 if phase=="retry":phase="defeat";settle_xp("defeat")



func begin_initial_item(next_phase: String="power") -> bool:
 if not initial_item_available or initial_item_consumed or deck.size()<15:return false
 item_return_phase=next_phase
 pending_item=""
 prepare_item()
 return true



func visit_farm_recruits() -> void:
 if phase!="farm":return
 var available: Array=[]
 for key in Match.CARD_DATA:
  var card=Match.CARD_DATA[key]
  if card.collectible and card.card_type==CardData.CardType.CREATURE and card.faction==CardData.Faction.VILLAGER and not card.neutral_deck_only:available.append(key)
 options=shuffled(available).slice(0,3)
 if options.is_empty():
  gold+=1;event_message="Não há recrutas disponíveis hoje. O fazendeiro oferece 1 ouro em agradecimento.";phase="event_result"
 else:phase="farm_recruit"

func recruit_from_farm(key: String) -> bool:
 if phase!="farm_recruit" or key not in options:return false
 add_card_to_deck(key)
 apply_account_creature_bonuses()
 advance()
 return true

func gift_farmer(large: bool=false) -> bool:
 var price: int=4 if large else 2
 if phase!="farm" or gold<price:return false
 gold-=price
 if large:
  farm_blessing_all_run=true
  farm_blessing_pending=false
  event_message="Seu grande presente de 4 ouro ajuda toda a família. Em agradecimento, a Camponesa Generosa prepara um banquete para seus aliados. Suas criaturas recebem +1 de vida atual e máxima em todos os combates restantes desta expedição."
 else:
  farm_blessing_pending=true
  event_message="Seu presente de 2 ouro é recebido com um sorriso. A Camponesa Generosa serve uma refeição farta aos viajantes. Suas criaturas recebem +1 de vida atual e máxima no próximo combate."
 event_art="banquet"
 phase="event_result"
 return true
func leave_closed_chest() -> bool:
 if phase!="chest":return false
 advance()
 return true


func generate_shop() -> void:
 if shop_step!=step:
  shop_step=step;shop_premium_sold=false;shop_premium_key=""
  var available: Array=Match.CARD_DATA.keys().filter(func(key):return Match.CARD_DATA[key].collectible and not Match.CARD_DATA[key].neutral_deck_only)
  generate_shop_groups(available)
  var premium: Array=available.filter(func(key):return Match.CARD_DATA[key].card_type==CardData.CardType.CREATURE)
  premium=premium_pool_for_roll(premium,rng.randf())
  if not premium.is_empty():
   shop_premium_key=Items.enhance(apply_card_items(shuffled(premium)[0]),shuffled(["heart","sword","shield","boots"])[0])
   shop_premium_price=market_price(shop_premium_key,true)
 phase="shop"

func premium_pool_for_roll(available: Array,roll: float) -> Array:
 var initial: int=int(shop_groups[0].factions[0]) if not shop_groups.is_empty() else faction
 var extras: Array=shop_groups[1].factions if shop_groups.size()>1 else []
 var pools: Dictionary={"initial":[],"extra":[],"new":[],"neutral":[]}
 for key in available:
  var origin: int=Match.CARD_DATA[key].faction
  var group: String="initial" if origin==initial else "extra" if origin in extras else "neutral" if origin in [CardData.Faction.VILLAGER,CardData.Faction.WASTES] else "new"
  pools[group].append(key)
 var choice: String="initial" if roll<0.4 else "extra" if roll<0.8 else "new" if roll<0.9 else "neutral"
 if not pools[choice].is_empty():return pools[choice]
 for fallback in ["initial","extra","new","neutral"]:
  if not pools[fallback].is_empty():return pools[fallback]
 return []

func generate_shop_groups(available: Array) -> void:
 var initial: int=faction
 if initial<0 or initial in [CardData.Faction.VILLAGER,CardData.Faction.WASTES]:
  initial=CardData.Faction.WARRIOR
  for key in deck:
   var origin: int=Match.CARD_DATA[key].faction
   if origin not in [CardData.Faction.VILLAGER,CardData.Faction.WASTES]:initial=origin;break
 var extras: Array=[]
 for key in deck:
  var origin: int=Match.CARD_DATA[key].faction
  if origin not in [initial,CardData.Faction.VILLAGER,CardData.Faction.WASTES] and origin not in extras:extras.append(origin)
 var initial_pool: Array=available.filter(func(key):return Match.CARD_DATA[key].faction==initial)
 var extra_pool: Array=available.filter(func(key):return Match.CARD_DATA[key].faction in extras)
 var other_pool: Array=available.filter(func(key):return Match.CARD_DATA[key].faction!=initial and Match.CARD_DATA[key].faction not in extras)
 var used: Array=[]
 shop_groups=[]
 for spec in [{"kind":"initial","factions":[initial],"pool":initial_pool,"novel":true},{"kind":"extra","factions":extras,"pool":extra_pool,"novel":true},{"kind":"other","factions":[],"pool":other_pool,"novel":false}]:
  var pool: Array=spec.pool
  var fallback: bool=pool.is_empty()
  if fallback:pool=other_pool.filter(func(key):return Match.CARD_DATA[key].faction not in [CardData.Faction.VILLAGER,CardData.Faction.WASTES]) if spec.kind=="extra" else available
  var cards:=shop_group_choices(pool,used,bool(spec.novel))
  if cards.size()<3:
   cards.append_array(shop_group_choices(available,used+cards,false,3-cards.size()))
  used.append_array(cards)
  shop_groups.append({"kind":spec.kind,"factions":spec.factions.duplicate(),"fallback":fallback,"cards":cards})
 options=used

func shop_group_choices(pool: Array,used: Array,novel: bool,count: int=3) -> Array:
 var candidates:=shuffled(pool.filter(func(key):return key not in used))
 var result: Array=[]
 if novel:
  var unseen: Array=candidates.filter(func(key):return card_copies(key)==0)
  if not unseen.is_empty():
   result.append(unseen[0]);candidates.erase(unseen[0])
 result.append_array(candidates.slice(0,maxi(0,count-result.size())))
 return shuffled(result)

func buy_premium_card(key: String) -> bool:
 if phase!="shop" or shop_premium_sold or key.is_empty() or key!=shop_premium_key or gold<shop_premium_price:return false
 gold-=shop_premium_price
 var base: String=Items.base_key(key)
 var item: String=Match.CARD_DATA[key].get_meta("adventure_items").back()
 if item=="boots_attack":item="boots"
 add_card_to_deck(base)
 grant_card_item(base,item)
 shop_premium_sold=true;shop_premium_key=""
 apply_account_creature_bonuses()
 return true



func market_price(key: String,with_item: bool=false) -> int:
 return mini(5,clampi(Match.CARD_DATA[key].cost,1,3)+(2 if with_item else 0))

func add_card_to_deck(key: String) -> String:
 var improved:=apply_card_items(key)
 deck.append(improved)
 return improved

func apply_card_items(key: String) -> String:
 var base:=Items.base_key(key)
 var applied: Array=Match.CARD_DATA[key].get_meta("adventure_run_item_grants",[]).duplicate()
 for grant in card_item_grants.get(base,[]):
  if grant.id in applied:continue
  var cache_key: String=key+":"+str(grant.id)
  if item_variant_cache.has(cache_key):key=item_variant_cache[cache_key]
  else:
   key=Items.enhance(key,grant.item)
   item_variant_cache[cache_key]=key
  applied.append(grant.id)
  Match.CARD_DATA[key].set_meta("adventure_run_item_grants",applied.duplicate())
 return key

func grant_card_item(key: String,item: String) -> void:
 var base:=Items.base_key(key)
 item_grant_serial+=1
 if not card_item_grants.has(base):card_item_grants[base]=[]
 card_item_grants[base].append({"id":item_grant_serial,"item":item})
 var representative: String=key
 for at in range(deck.size()):
  if Items.base_key(deck[at])==base:
   deck[at]=apply_card_items(deck[at])
   representative=deck[at]
 equipment.append({"card":representative,"item":item,"base":base})

func settle_xp(reason: String) -> bool:
 if xp_settled:return true
 xp_before_settlement=profile.xp if profile!=null else 0
 if profile!=null and not profile.credit_expedition(expedition_id,pending_xp):return false
 xp_settled=true;settlement_reason=reason;xp_animation_pending=pending_xp>0
 return true

func abandon() -> bool:
 if not settle_xp("abandoned"):return false
 in_combat=false;saved_duel=null;phase="abandoned"
 return true

func save_checkpoint() -> bool:
 return preload("res://scripts/adventure_save.gd").save_run(self)
