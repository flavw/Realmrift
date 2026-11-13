extends SceneTree
const Save=preload("res://scripts/adventure_save.gd")
const State=preload("res://scripts/adventure_state.gd")
const Profile=preload("res://scripts/adventure_profile.gd")
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 Save.path="res://.local/test_expedition.save"
 var profile=Profile.new("res://.local/test_expedition_profile.json",false)
 var run=State.new(profile);run.faction=0;run.deck=Match.default_deck(0).slice(0,15);run.phase="map";run.ensure_routes();run.gold=10
 run.grant_card_item("squire","heart");run.powers=["starting_allies","bonus_spell"];run.generate_shop()
 assert(run.save_checkpoint(),Save.last_error)
 run.gold=12;assert(run.save_checkpoint(),Save.last_error)
 var enhanced_health: int=Match.CARD_DATA[run.deck[0]].health
 for key in Match.CARD_DATA.keys():
  if Match.CARD_DATA[key].has_meta("adventure_base"):Match.CARD_DATA.erase(key);Match.CARDS.erase(key)
 var loaded=Save.load_run(profile)
 assert(loaded!=null,Save.last_error)
 assert(loaded.gold==12 and loaded.deck==run.deck and loaded.route_rows==run.route_rows and loaded.shop_groups==run.shop_groups)
 assert(loaded.expedition_id==run.expedition_id and loaded.rng.state==run.rng.state)
 assert(loaded.card_item_grants==run.card_item_grants)
 assert(Match.CARD_DATA[loaded.deck[0]].health==enhanced_health)
 run.phase="combat";run.in_combat=true;run.enemy=Match.default_deck(1)
 run.saved_duel=Match.new(run.deck,run.enemy,0,false,run.rules())
 run.saved_duel.players[0].hp=9;run.saved_duel.castle_traps[0]=[{"remaining":2,"damage":5}]
 assert(run.save_checkpoint())
 loaded=Save.load_run(profile)
 assert(loaded.saved_duel!=null and loaded.saved_duel.players==run.saved_duel.players and loaded.saved_duel.castle_traps==run.saved_duel.castle_traps)
 var xp_before: int=profile.xp
 loaded.finish_combat(true,9)
 assert(loaded.pending_xp==1 and profile.xp==xp_before)
 loaded.step=1;loaded.finish_combat(true,10)
 assert(loaded.pending_xp==2 and profile.xp==xp_before)
 assert(loaded.abandon() and profile.xp==xp_before+2 and loaded.xp_animation_pending)
 assert(loaded.abandon() and profile.xp==xp_before+2)
 assert(loaded.save_checkpoint())
 var reloaded_profile=Profile.new(profile.path)
 var ended=Save.load_run(reloaded_profile)
 assert(ended.phase=="abandoned" and ended.pending_xp==2 and ended.xp_settled and reloaded_profile.xp==2)
 assert(ended.settle_xp("abandoned") and reloaded_profile.xp==2)
 State.current=ended
 var view=load("res://adventure.tscn").instantiate();root.add_child(view)
 await process_frame;await process_frame
 assert(view.find_child("ExpeditionXPPayout",true,false)!=null)
 await create_timer(1.5).timeout
 var payout=view.find_child("ExpeditionXPPayout",true,false)
 assert(not payout.get_ok_button().disabled)
 payout.confirmed.emit();await process_frame
 assert(not ended.xp_animation_pending)
 view.queue_free();await process_frame;await process_frame;State.current=null
 var completed=State.new(reloaded_profile);completed.deck=Match.default_deck(0).slice(0,15);completed.step=11
 completed.finish_combat(true,10)
 assert(completed.pending_xp==3 and reloaded_profile.xp==2)
 completed.advance();assert(completed.phase=="victory" and reloaded_profile.xp==5 and completed.xp_animation_pending)
 var defeated=State.new(reloaded_profile);defeated.finish_combat(true,10);assert(reloaded_profile.xp==5)
 defeated.finish_combat(false,0);assert(defeated.phase=="defeat" and reloaded_profile.xp==6)
 print("OK: salvamento atômico, cartas aprimoradas, mapa/loja/RNG, retomada de combate, XP adiado e entrega única animada")
 quit()
