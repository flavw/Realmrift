extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
const Match=preload("res://scripts/match.gd")
const Music=preload("res://scripts/game_music.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var run=State.new();State.current=run
 var view=load("res://adventure.tscn").instantiate();root.add_child(view)
 assert(run.phase=="intro")
 view.advance_intro()
 assert(run.phase=="faction")
 run.deck=Match.default_deck(0).slice(0,15);run.phase="map";run.step=4;run.ensure_routes();view.render()
 assert(run.route_rows[4][1].kind=="farm")
 view.choose_route(1);assert(run.phase=="farm")
 if DisplayServer.get_name()!="headless":
  await process_frame;await process_frame
  get_root().get_texture().get_image().save_png("res://.local/adventure-farm.png")
 run.gold=1
 assert(not run.gift_farmer() and run.gold==1)
 run.visit_farm_recruits();assert(run.phase=="farm_recruit" and run.options.size()==3)
 for key in run.options:
  assert(Match.CARD_DATA[key].faction==CardData.Faction.VILLAGER and Match.CARD_DATA[key].card_type==CardData.CardType.CREATURE)
 var count: int=run.deck.size()
 assert(run.recruit_from_farm(run.options[0]) and run.deck.size()==count+1 and run.step==5)
 assert(not run.gift_farmer())
 run.phase="farm";run.gold=2
 assert(run.gift_farmer() and run.gold==0 and run.farm_blessing_pending)
 assert(not run.gift_farmer())
 run.advance()
 var duel=Match.new(run.deck,[],0,false,run.rules())
 var ally: Dictionary=duel.spawn_unit(0,"warrior")
 assert(ally.health==Match.CARD_DATA.warrior.health+1 and ally.max_health==Match.CARD_DATA.warrior.health+1)
 var enemy: Dictionary=duel.spawn_unit(1,"warrior")
 assert(enemy.health==Match.CARD_DATA.warrior.health)
 var extra: Dictionary=duel.spawn_unit(0,"summoned_ghoul")
 assert(extra.health==Match.CARD_DATA.summoned_ghoul.health+1)
 run.retries_left=1;run.finish_combat(false,0)
 assert(run.farm_blessing_pending and run.phase=="retry")
 run.finish_combat(true,9)
 assert(not run.farm_blessing_pending and run.victory_sound_pending)
 var next=Match.new(run.deck,[],0,false,run.rules())
 assert(next.spawn_unit(0,"warrior").health==Match.CARD_DATA.warrior.health)
 var chest=State.new();chest.phase="chest"
 var rng_state=chest.rng.state
 assert(chest.leave_closed_chest() and chest.step==1 and chest.gold==1 and chest.chest_result.is_empty() and chest.rng.state==rng_state)
 assert(not chest.leave_closed_chest())
 view.queue_free();await process_frame
 var music=Music.ensure(self)
 await process_frame
 music.muted=false;music.effects_volume=1.0
 State.current=run
 var rewards=load("res://adventure.tscn").instantiate();root.add_child(rewards)
 await process_frame;await process_frame
 assert(not run.victory_sound_pending)
 var sound=music.find_child("AdventureVictorySound",true,false)
 if DisplayServer.get_name()=="headless":assert(sound==null)
 else:assert(sound!=null and sound.stream.resource_path=="res://assets/audio/victory.ogg" and sound.playing)
 rewards.render();assert(not run.victory_sound_pending)
 rewards.queue_free();await process_frame
 if is_instance_valid(sound):sound.stop();sound.stream=null;sound.queue_free()
 await create_timer(0.1).timeout
 State.current=null
 print("OK: introdução, fazenda aldeã, presente só no próximo combate, saída do baú sem sorteio e som de vitória")
 quit()



