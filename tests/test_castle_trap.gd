extends SceneTree
const Match=preload("res://scripts/match.gd")
func fresh() -> DuelMatch:
 var m=Match.new()
 m.opening=false;m.turn=0
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10
 return m
func arm(m: DuelMatch,ordinal: int,side: int=0) -> void:
 m.turn=side;m.players[side].hand=["alley_ambush"];m.players[side].mana=10
 assert(m.cast(side,0,side,-1,ordinal))
 assert(m.players[side].mana==7 and m.players[side].hand.is_empty())
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var m=fresh()
 m.players[0].hand=["alley_ambush"]
 assert(m.has_spell_target(0,0) and not m.can_cast(0,0,1,-1))
 assert(not m.cast(0,0,0,-1,3) and not m.cast(0,0,0,-1))
 assert(m.players[0].mana==10 and m.players[0].hand.size()==1)
 arm(m,1)
 assert(not str(m.last_action).contains("remaining") and not " ".join(m.history).contains("1º"))
 var a=m.spawn_unit(1,"warrior");a.ready=true;a.health=4;a.armor=0
 m.turn=1
 assert(m.act(1,0,-1) and m.players[0].hp==20 and m.players[1].board.is_empty())
 assert(m.last_action.trap_stopped and m.last_action.trap_hits[0].amount==5 and m.castle_traps[0].is_empty())
 # Second attacker, armor, persistence, and no activation from attacks on creatures.
 m=fresh();arm(m,2)
 a=m.spawn_unit(1,"warrior");a.health=20;a.max_health=20;a.armor=2;a.ready=true
 var defender=m.spawn_unit(0,"farmer");defender.health=20;defender.armor=0;defender.block=0
 m.turn=1
 assert(m.act(1,0,0) and m.castle_traps[0][0].remaining==2)
 a.ready=true
 assert(m.act(1,0,-1) and m.castle_traps[0][0].remaining==1 and not m.last_action.has("trap_hits"))
 var before: int=a.health
 var castle_before: int=m.players[0].hp
 a.ready=true
 assert(m.act(1,0,-1) and a.health==before-3 and m.players[0].hp<castle_before)
 assert(m.last_action.trap_hits[0].amount==3 and m.castle_traps[0].is_empty())
 # A mage's shot counts and dies before hitting; mana is still spent.
 m=fresh();arm(m,1)
 a=m.spawn_unit(1,"mage");a.health=5;a.armor=0;a.ready=true;a.antimagic=3;a.spell_immune=true
 m.turn=1;m.players[1].mana=10
 assert(m.act(1,0,-1,true) and m.players[0].hp==20)
 assert(m.players[1].mana==10-a.magic_cost and a.antimagic==3 and m.last_action.trap_stopped)
 # Hand spells do not count; the second attack can be a mystic shot.
 m=fresh();arm(m,2)
 m.turn=1;m.players[1].hand=["astral_flame"]
 assert(m.cast(1,0,0,-1) and m.castle_traps[0][0].remaining==2)
 a=m.spawn_unit(1,"mage");a.health=10;a.armor=1;a.ready=true
 assert(m.act(1,0,-1,true) and m.castle_traps[0][0].remaining==1)
 a.ready=true
 assert(m.act(1,0,-1,true) and a.health==6 and m.castle_traps[0].is_empty())
 # IA can arm it, choice hidden from forecast/history, and traps don't share state.
 m=fresh();m.turn=1;m.players[1].hand=["alley_ambush"]
 var choice=m.ai_spell_target(0)
 assert(choice.side==1 and choice.index==-1 and m.cast(1,0,1,-1))
 assert(m.castle_traps[1][0].remaining in [1,2] and not str(m.last_action).contains("remaining"))
 var n=fresh();assert(n.castle_traps[0].is_empty() and n.castle_traps[1].is_empty())
 n.turn=0;arm(n,2)
 n.end_turn(0);n.end_turn(1)
 assert(n.castle_traps[0][0].remaining==2)
 arm(n,1,1)
 assert(n.disarm_castle_traps(0)==1 and n.castle_traps[0].is_empty() and n.castle_traps[1].size()==1)
 assert(n.disarm_castle_traps(0)==0 and n.disarm_castle_traps(-1)==0)
 # Real game UI: no mana spent before confirmation, secret options, and card rendering.
 var main=load("res://main.tscn").instantiate();main.starting_player=0;root.add_child(main)
 main.finish_mulligan([])
 main.duel=fresh();main.duel.players[0].hand=["alley_ambush"];main.redraw()
 main.play(0)
 var dialog=main.find_child("CastleTrapChoice",true,false)
 assert(dialog!=null and main.duel.players[0].mana==10 and main.duel.castle_traps[0].is_empty())
 var card=load("res://card_model.tscn").instantiate();card.set_card(Match.CARD_DATA.alley_ambush);main.add_child(card);card.position=Vector2(40,160);card.size=Vector2(360,480)
 await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("res://.local/alley-ambush-choice.png")
 dialog.find_child("CastleTrapChoice_2",true,false).pressed.emit()
 assert(main.duel.castle_traps[0][0].remaining==2 and main.duel.players[0].mana==7)
 await create_timer(0.5).timeout
 assert(main.find_child("CastleTrapMark",true,false)!=null)
 assert(main.find_child("CastleTrapMark",true,false).icon.resource_path=="res://assets/ui/trap-icon.svg")
 for player in main.sounds.values():player.stop();player.stream=null
 await create_timer(0.1).timeout
 main.queue_free();await process_frame;await process_frame
 print("OK: armadilha secreta, 1º/2º ataques, Armadura, morte antes do golpe, Disparo Místico, IA e escolha na interface")
 quit()
