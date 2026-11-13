extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _initialize() -> void:call_deferred("verify")
func fresh():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10
 return m
func verify() -> void:
 assert(CardData.Faction.HORDE==5)
 assert(Match.CARD_DATA.horde_roar.cost==3 and Match.CARD_DATA.horde_roar.spell_value==2)
 assert(Store.accepts_base(5,["necromancer_summoner","horde_roar"]))
 assert(not Store.accepts_base(5,["farmer","horde_roar"]))
 var m=fresh();m.players[0].hand=["horde_roar"]
 assert(not m.has_spell_target(0,0))
 for key in ["necromancer_summoner","zombie_helper","wolf","village_wall"]:m.spawn_unit(0,key)
 assert(not m.has_spell_target(0,0)) # Faction membership is not creature type.
 m=fresh()
 var goblin=m.spawn_unit(0,"goblin_raider")
 var werewolf=m.spawn_unit(0,"moon_werewolf")
 var necro=m.spawn_unit(0,"necromancer_summoner")
 var undead=m.spawn_unit(0,"zombie_helper")
 var beast=m.spawn_unit(0,"wolf")
 var enemy=m.spawn_unit(1,"minotaur_brute")
 m.players[0].hand=["horde_roar","horde_roar"]
 assert(not m.can_cast(0,0,1,-1) and not m.can_cast(0,0,0,0))
 assert(m.cast(0,0,0,-1) and m.players[0].mana==7)
 assert(Match.attack_value(goblin)==3 and Match.attack_value(werewolf)==5)
 assert(goblin.attack==1 and werewolf.attack==3 and not werewolf.ready)
 assert(Match.attack_value(necro)==2 and Match.attack_value(undead)==1 and Match.attack_value(beast)==2 and Match.attack_value(enemy)==5)
 assert(m.last_action.buffs.size()==2 and not m.last_action.castle)
 assert(m.cast(0,0,0,-1) and Match.attack_value(goblin)==5)
 # New arrivals do not gain the previously cast spell's bonus.
 var late=m.spawn_unit(0,"minotaur_brute")
 assert(Match.attack_value(late)==5)
 # Permanent Fury and stat gains survive temporary-bonus expiry.
 assert(m.fury(0,1))
 Match.grant_stats(goblin,1,0)
 assert(Match.attack_value(werewolf)==8 and Match.attack_value(goblin)==6)
 assert(not m.end_turn(1) and Match.attack_value(goblin)==6)
 assert(m.end_turn(0))
 assert(Match.attack_value(goblin)==2 and Match.attack_value(werewolf)==4)
 assert(goblin.turn_attack==0 and werewolf.turn_attack==0)
 assert(m.end_turn(1) and Match.attack_value(goblin)==2)
 # AI casts only when a monster can use the bonus during this turn.
 m=fresh();m.turn=1;m.players[1].hand=["horde_roar"]
 var ready_monster=m.spawn_unit(1,"goblin_raider")
 assert(m.ai_spell_target(0)=={"side":1,"index":-1})
 ready_monster.ready=false
 assert(m.ai_spell_target(0).is_empty())
 # Exhaustion is not removed by casting.
 assert(m.cast(1,0,1,-1) and not ready_monster.ready)
 var store=Store.new("user://test_horde_roar.json",false)
 assert(store.save_slot(5,"Horda",Match.default_deck(5),5))
 assert(Store.new(store.path).base_for(5)==5)
 var main=load("res://main.tscn").instantiate();main.enable_opening=false;main.muted=true;root.add_child(main)
 main.enemy_deck_style=5
 assert(main.opponent_label()=="IA — Horda")
 assert(Match.default_deck(5).count("horde_roar")==2)
 var view=load("res://card_model.tscn").instantiate();view.card_data=Match.CARD_DATA.goblin_raider
 view.ability_context={"turn_attack":2};root.add_child(view)
 assert(view.view_entries().any(func(e):return e.name=="Clamor da Horda" and e.runtime))
 view.queue_free();main.queue_free();await process_frame;await create_timer(0.35).timeout
 print("OK: Horda preserva ID/salvamento; Clamor por 3 mana, apenas Monstros aliados, +2 temporário acumulável, expiração, bônus permanentes, novos invocados, UI e IA.")
 quit()
