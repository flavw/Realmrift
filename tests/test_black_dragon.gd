extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
const Profile=preload("res://scripts/adventure_profile.gd")
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func make_dragon():
 var run=State.new();run.deck=Match.default_deck(0);run.encounter="black_dragon"
 return Match.new(run.deck,[],1,true,run.rules())
func verify() -> void:
 var game=make_dragon()
 var boss: Dictionary=game.players[1].board[0]
 assert(game.creature_boss_id==boss.id and boss.health==24 and boss.armor==1 and boss.flying and boss.envenom==2 and boss.antimagic==1)
 assert(not Match.CARD_DATA["adventure_black_dragon"].collectible)
 assert(game.players[1].hand.is_empty() and game.players[1].deck.is_empty() and game.players[1].mana==0)
 assert(game.mulligan(0,[]) and game.mulligan(1,[]))
 assert(game.players[1].mana==0)
 for expected in [1,2,3,4,4]:
  assert(game.end_turn(1) and game.end_turn(0))
  assert(game.players[1].mana==expected)
 game.draw(1);assert(game.players[1].fatigue==0)
 for i in range(4):
  var unit: Dictionary=game.spawn_unit(0,"warrior")
  unit.health=10;unit.max_health=10;unit.armor=9
 game.players[0].board[1].antimagic=1
 game.players[1].mana=3;boss.ready=true;boss.attacked_this_turn=false
 assert(game.can_dragon_breath(1,0,"poison",0))
 assert(game.dragon_breath(1,0,"poison",0))
 assert(game.players[1].mana==0 and not boss.ready)
 assert(game.players[0].board[0].poison==2 and game.players[0].board[1].poison==0 and game.players[0].board[1].antimagic==0 and game.players[0].board[2].poison==2 and game.players[0].board[3].poison==0)
 assert(not game.can_target(1,0,-1) and not game.can_dragon_breath(1,0,"acid",0))
 boss.ready=true;boss.attacked_this_turn=true;game.players[1].mana=4
 assert(not game.can_dragon_breath(1,0,"poison",0) and not game.can_dragon_breath(1,0,"acid",-1))
 boss.attacked_this_turn=false
 assert(game.dragon_breath(1,0,"acid",3))
 assert(game.players[0].board[0].health==10)
 for i in [1,2,3]:assert(game.players[0].board[i].health==7)
 assert(game.players[1].mana==0 and not boss.ready)
 boss.ready=true;game.players[1].mana=4
 var hp: int=game.players[0].hp
 assert(game.dragon_breath(1,0,"acid",-1) and game.players[0].hp==hp-6)
 game.players[1].hp=0;game.check_winner();assert(game.winner==-1)
 boss.health=0;game.remove_dead();game.check_winner();assert(game.winner==0)
 assert(Match.CARD_DATA["antimagic_guardian"].ability_entries().any(func(e):return e.name=="Antimagia 1"))
 # Full sixth duel, then two safe reinforcement stages, then one final creature boss.
 var run=State.new();run.ensure_routes()
 var combats: Array=[]
 for row in run.route_rows:
  if row[0].kind=="combat":combats.append(row)
 assert(combats.size()==6)
 for node in combats[5]:assert(node.deck.size()==22)
 assert(run.route_rows.size()==12 and run.route_rows.back().size()==1 and run.route_rows.back()[0].kind=="boss")
 for at in [9,10]:
  for node in run.route_rows[at]:assert(node.get("preparation",false) and node.kind in ["healer","shop","power_event","item"])
 run.preparation_active=true;run.current_life=1
 assert(run.visit_healer(false) and run.current_life==run.max_life())
 # Fixed milestones do not have minor choices; migrate any old choices away.
 var account=Profile.new("user://tests-dragon-profile.json",false)
 account.xp=42;account.claimed={"2":"life","3":"gold","4":"life","5":"gold"};account.ensure_offers()
 assert(account.level()==5 and account.pending_choice().is_empty() and account.totals().gold==0)
 assert(account.extra_lives()==1 and account.initial_items()==1)
 var initial=State.new(account);initial.faction=0;initial.deck=Match.default_deck(0).slice(0,15)
 initial.apply_account_creature_bonuses()
 assert(initial.begin_initial_item() and initial.phase=="item" and initial.options.size()==3)
 assert(initial.apply_item(initial.options[0]) and initial.phase=="power" and initial.step==0 and initial.initial_item_consumed)
 assert(not initial.begin_initial_item())
 # Real UI integration for the larger dragon and level-5 draft flow.
 State.current=State.new(account)
 var view=load("res://adventure.tscn").instantiate();root.add_child(view)
 view.choose_faction(0)
 for i in range(15):view.pick_card(State.current.options[0])
 assert(State.current.phase=="item")
 view.equip(State.current.options[0]);assert(State.current.phase=="power" and State.current.step==0)
 view.pick_power(State.current.options[0]);assert(State.current.phase=="map")
 State.current.step=State.STAGES.size()-1;State.current.encounter="black_dragon";State.current.enemy=Match.default_deck(5);State.current.in_combat=true
 view.queue_free();await process_frame
 var main=load("res://main.tscn").instantiate();main.starting_player=0;main.muted=true;root.add_child(main)
 await process_frame;await process_frame
 assert(main.duel.is_dragon_boss() and main.find_child("EnemyCastle",true,false)==null)
 assert(main.find_child("DragonManaReserve",true,false).find_child("ManaGems",true,false).get_child_count()==4)
 var art=main.field_nodes[1][main.duel.creature_boss_id]
 assert(art.custom_minimum_size.x>298)
 main.finish_mulligan([])
 await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":get_root().get_texture().get_image().save_png("res://.local/black-dragon-boss.png")
 main.queue_free();await process_frame;await process_frame
 State.current=null
 print("OK: dragão, sopros adjacentes e exclusão de ataque, mana 0–4, resistência, 6º duelo completo, 2 reforços e marcos 3/5")
 quit()

