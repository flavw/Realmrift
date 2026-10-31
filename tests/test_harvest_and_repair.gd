extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func fixture():
 var m=Match.new()
 for p in m.players:p.board=[];p.hand=[];p.deck=["squire","wolf","farmer"];p.mana=10;p.max_mana=10;p.hp=20;p.poison=0
 m.next_id=100
 return m
func spawn(m,key: String,side: int=0) -> Dictionary:return m.spawn_unit(side,key)
func verify() -> void:
 # Castles are immune in both directions; creature poison is unchanged.
 var m=fixture();var rogue=spawn(m,"lightning_rogue");rogue.ready=true
 assert(m.act(0,0,-1) and m.players[1].hp==17 and m.players[1].poison==0 and not m.last_action.has("poisoned"))
 m.players[1].poison=5;m.resolve_poison(1)
 assert(m.players[1].hp==17 and m.players[1].poison==0 and m.last_action.ticks.is_empty())
 m.turn=1;var enemy_rogue=spawn(m,"lightning_rogue",1);enemy_rogue.ready=true
 assert(m.act(1,0,-1) and m.players[0].hp==17 and m.players[0].poison==0)
 var victim=spawn(m,"farmer");assert(Match.apply_poison(victim,2));m.resolve_poison(0)
 assert(victim.health==1 and victim.poison==0 and m.players[0].hp==17)
 # Reconstruction repairs a friendly wall and retains the neutral-field draw condition.
 m=fixture();var wall=spawn(m,"village_wall");wall.health=1
 var wolf=spawn(m,"wolf");var enemy_wall=spawn(m,"village_wall",1)
 m.players[0].hand=["village_reconstruction"];m.players[0].hp=15;m.players[0].deck=["farmer"]
 assert(not m.can_cast(0,0,1,0) and not m.can_cast(0,0,0,1))
 assert(m.cast(0,0,0,0) and wall.health==3 and wall.max_health==4 and m.players[0].hp==15 and m.players[0].hand==["farmer"])
 assert(m.last_action.healed[0].id==wall.id and not m.last_action.healed[0].castle)
 m.players[0].hand=["restoring_light"]
 assert(not m.can_cast(0,0,0,0),"Cura comum continua proibida na Muralha")
 spawn(m,"cleric");m.players[0].hand=["village_reconstruction"]
 assert(m.cast(0,0,0,0) and wall.health==4 and m.players[0].hand.is_empty(),"Campo misto não compra")
 # The AI can select an injured wall when the castle needs no repair.
 m=fixture();m.turn=1;wall=spawn(m,"village_wall",1);wall.health=1
 m.players[1].hand=["village_reconstruction"]
 assert(m.ai_step() and wall.health==3 and m.players[1].hp==20)
 # Peasant supports all other allies; the source keeps its new base 1/3.
 m=fixture();var mage=spawn(m,"mage");wall=spawn(m,"village_wall")
 m.players[0].hand=["generous_peasant"];assert(m.play(0,0))
 var girl: Dictionary=m.players[0].board[-1]
 assert(girl.attack==1 and girl.health==3 and girl.max_health==3 and mage.health==3 and wall.health==5 and wall.max_health==5)
 m.players[0].hand=["village_leader"];assert(m.play(0,0))
 var leader: Dictionary=m.players[0].board[-1]
 assert(leader.attack==3 and leader.aura_attack==0 and mage.aura_attack==1 and girl.aura_attack==1 and wall.aura_attack==1)
 assert(not m.can_target(0,1,-1),"Aura não remove a restrição de Muralha")
 # Every cultivation activation triggers +1/+1, not one trigger per growth point.
 m=fixture();spawn(m,"farmer");spawn(m,"farmer");var ox=spawn(m,"harvest_ox")
 assert(ox.attack==2 and ox.health==3 and ox.harvest==1)
 m.begin_turn();assert(ox.attack==4 and ox.health==5 and ox.max_health==5)
 for i in range(6):m.refresh_auras()
 assert(ox.attack==4 and ox.health==5)
 m=fixture();spawn(m,"farmer",1);ox=spawn(m,"harvest_ox");m.turn=1;m.begin_turn()
 assert(ox.attack==2 and ox.health==3,"Cultivo inimigo não ativa Colheita")
 m=fixture();ox=spawn(m,"harvest_ox");ox.growth=2;m.begin_turn()
 assert(ox.attack==3 and ox.health==6,"Cultivo 2 ativa uma vez e inclui Colheita própria")
 m=fixture();spawn(m,"farmer");spawn(m,"farmer");ox=spawn(m,"harvest_ox");var mob=spawn(m,"peasant_uprising")
 assert(mob.growth==2 and mob.harvest==1)
 m.begin_turn();assert(ox.attack==5 and ox.health==6 and mob.attack==7 and mob.health==9)
 # UI enters targeting only for a friendly wall and leaves invalid choices unspent.
 var main=load("res://main.tscn").instantiate();main.enable_opening=false;main.muted=true;root.add_child(main)
 main.duel=fixture();wall=spawn(main.duel,"village_wall");wall.health=1;spawn(main.duel,"wolf")
 main.duel.players[0].hand=["village_reconstruction"];main.duel.players[0].deck=["farmer"];main.redraw()
 main.play(0);assert(main.casting==0 and main.duel.players[0].mana==10)
 assert(not main.find_child("PlayerCastle",true,false).disabled)
 assert(main.field_nodes[0][wall.id].available and not main.field_nodes[0][main.duel.players[0].board[1].id].available)
 await main.cast_target(0,1);assert(main.casting==0 and main.duel.players[0].mana==10)
 await main.cast_target(0,0);assert(wall.health==3 and main.casting==-1 and main.duel.players[0].mana==8)
 main.duel.players[0].board=[];spawn(main.duel,"village_wall",1);assert(not main.has_allied_wall())
 main.queue_free();await process_frame;await create_timer(0.35).timeout
 print("OK: castelo imune a Veneno, Reconstrução em Muralha/IA/seleção/compra, Camponesa/Líder outros aliados e Colheita por ativação, incluindo Multidão.")
 quit()
