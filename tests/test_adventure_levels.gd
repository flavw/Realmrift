extends SceneTree
const Profile=preload("res://scripts/adventure_profile.gd")
const State=preload("res://scripts/adventure_state.gd")
const Match=preload("res://scripts/match.gd")
const TEST_PATH="res://.local/tests-adventure-profile.json"
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 preload("res://scripts/adventure_save.gd").path="res://.local/tests-level-expedition.save"
 var profile=Profile.new(TEST_PATH,false)
 assert(profile.level()==1 and Profile.xp_cost(1)==5 and Profile.xp_cost(2)==8 and Profile.xp_cost(3)==12)
 profile.persist()
 var run=State.new(profile);run.deck=Match.default_deck(0).slice(0,15)
 assert(run.gold==1 and run.max_life()==20 and run.retries_left==0)
 for at in range(5):run.step=at;run.finish_combat(true,10)
 assert(profile.xp==0 and profile.level()==1 and run.pending_xp==5 and run.last_xp_gained==1)
 run.finish_combat(false,0)
 assert(run.phase=="defeat" and profile.xp==5)
 var reloaded=Profile.new(TEST_PATH)
 assert(reloaded.xp==5 and reloaded.level()==2)
 var choice: Dictionary=reloaded.pending_choice()
 assert(choice.level==2 and choice.options.size()==2 and choice.options[0]!=choice.options[1])
 assert(Profile.new(TEST_PATH).pending_choice()==choice)
 assert(not reloaded.choose_bonus("not-a-perk"))
 var selected: String=choice.options[0]
 assert(reloaded.choose_bonus(selected))
 assert(not reloaded.choose_bonus(selected))
 var next_profile=Profile.new(TEST_PATH)
 assert(next_profile.pending_choice().is_empty() and next_profile.totals()[selected]==1)
 var next_run=State.new(next_profile)
 if selected=="life":assert(next_run.max_life()==21 and next_run.current_life==21)
 if selected=="gold":assert(next_run.gold==2)
 # Boss grants three XP total, not four.
 next_run.deck=Match.default_deck(0).slice(0,15);next_run.step=State.STAGES.size()-1
 next_run.finish_combat(true,15)
 assert(next_profile.xp==5 and next_run.pending_xp==3 and next_run.last_xp_gained==3)
 next_run.finish_combat(true,15)
 assert(next_profile.xp==5 and next_run.last_xp_gained==0)
 next_run.advance();assert(next_profile.xp==8)
 # With deferred XP, level 3 unlocks attempts for the following expeditions.
 next_profile.gain_xp(4)
 assert(next_profile.level()==2 and next_profile.xp==12)
 var crossing=State.new(next_profile);crossing.deck=Match.default_deck(0).slice(0,15)
 crossing.finish_combat(true,11)
 assert(next_profile.xp==12 and crossing.pending_xp==1 and crossing.retries_left==0)
 crossing.finish_combat(false,0)
 assert(next_profile.xp==13 and next_profile.level()==3)
 crossing=State.new(next_profile);crossing.deck=Match.default_deck(0).slice(0,15)
 crossing.encounter="mimic";crossing.enemy=Match.default_deck(0);crossing.current_life=9
 var prior_xp: int=next_profile.xp
 crossing.finish_combat(false,0)
 assert(crossing.phase=="retry" and crossing.current_life==9 and next_profile.xp==prior_xp)
 assert(crossing.use_extra_life() and crossing.retries_left==0 and crossing.in_combat and crossing.encounter=="mimic")
 assert(not crossing.use_extra_life())
 crossing.finish_combat(false,0)
 assert(crossing.phase=="defeat" and next_profile.xp==prior_xp)
 var future=State.new(Profile.new(TEST_PATH));assert(future.retries_left==1)
 # Isolate each bonus, including per-copy random training applied once per run.
 for perk in Profile.BONUSES:
  var isolated=Profile.new("user://tests-adventure-bonus.json",false);isolated.xp=5;isolated.claimed={"2":perk}
  var boosted=State.new(isolated);boosted.deck=Match.default_deck(0).slice(0,15)
  boosted.rng.seed=77
  boosted.apply_account_creature_bonuses()
  var after: Array=boosted.deck.duplicate()
  boosted.apply_account_creature_bonuses()
  assert(boosted.deck==after)
  if perk in ["creature_life","creature_attack"]:
   var altered: Array=boosted.deck.filter(func(key):return key.begins_with("adventure_item_"))
   assert(altered.size()==1)
   var data=Match.CARD_DATA[altered[0]]
   var original=Match.CARD_DATA[State.Items.base_key(altered[0])]
   assert(data.health==original.health+(1 if perk=="creature_life" else 0))
   assert(data.attack==original.attack+(1 if perk=="creature_attack" else 0))
 assert(next_profile.pending_choice().is_empty())
 next_profile.gain_xp(12) # Level 4 has a normal choice; level 3 does not.
 State.current=crossing
 var view=load("res://adventure.tscn").instantiate();root.add_child(view)
 await process_frame
 assert(view.body.get_children().any(func(n):return n is Button and n.text.begins_with("Vitalidade") or n is Button and n.text.begins_with("Economias") or n is Button and n.text.begins_with("Treino")))
 await process_frame
 if DisplayServer.get_name()!="headless":get_root().get_texture().get_image().save_png("res://.local/adventure-level-choice.png")
 view.choose_level_bonus(next_profile.pending_choice().options[0])
 assert(next_profile.pending_choice().is_empty())
 crossing.phase="retry";crossing.retries_left=1;view.render()
 assert(view.body.get_children().any(func(n):return n is Button and n.text=="Usar vida extra e tentar novamente"))
 await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":get_root().get_texture().get_image().save_png("res://.local/adventure-extra-life.png")
 view.queue_free();await process_frame;await process_frame
 var paused=State.new(next_profile)
 paused.deck=Match.default_deck(0).slice(0,15);paused.enemy=Match.default_deck(1)
 paused.step=State.STAGES.size()-1;paused.in_combat=true
 var saved=Match.new(paused.deck,paused.enemy,0,false,paused.rules())
 saved.players[0].hp=6;saved.players[1].hp=12
 paused.saved_duel=saved;State.current=paused
 var main=load("res://main.tscn").instantiate();root.add_child(main)
 assert(is_same(main.duel,saved) and main.duel.players[0].hp==6 and main.duel.players[1].hp==12)
 main.queue_free();await process_frame;await process_frame
 State.current=null
 print("OK: XP salvo nas derrotas, curva de nível, escolha de dois bônus, bônus por expedição e vida extra no nível 3")
 quit()



