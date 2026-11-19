extends SceneTree
const Match=preload("res://scripts/match.gd")
const State=preload("res://scripts/adventure_state.gd")
const Profile=preload("res://scripts/adventure_profile.gd")
const Save=preload("res://scripts/adventure_save.gd")
func _initialize() -> void:call_deferred("verify")
func labels(node: Node) -> String:
 var result: String=node.text if node is Label else ""
 for child in node.get_children():result+="\n"+labels(child)
 return result
func verify() -> void:
 Save.enabled=false
 for side in [0,1]:
  for blocker in [false,true]:
   var game=Match.new();game.turn=side;game.players[side].board.clear();game.players[1-side].board.clear();game.players[side].mana=10;game.players[side].hand=["iron_stance"]
   var ally=game.spawn_unit(side,"squire" if blocker else "farmer")
   var attack: int=ally.attack;var armor: int=ally.armor;var capacity: int=game.block_capacity(ally)
   ally.block=0
   assert(game.cast(side,0,side,0))
   assert(ally.attack==attack+1 and ally.armor==armor+1 and ally.block==0 and game.block_capacity(ally)==capacity)
 for entry in Match.CARD_DATA.iron_stance.ability_entries():assert(not entry.name.contains("Bloqueio") and not entry.description.contains("Bloqueio"))
 var run=State.new();run.ensure_routes()
 assert(run.route_rows[2].size()==2)
 for node in run.route_rows[2]:assert(node.kind in ["bridge","river"])
 for branch in range(run.route_rows[1].size()):assert(run.linked(1,branch,0) and run.linked(1,branch,1))
 assert(State.STAGES.count("fortune")==1 and State.STAGES.count("shop")==2 and State.STAGES.count("combat")==6)
 var outcomes: Dictionary={}
 var ambush
 for i in range(120):
  var visit=State.new();visit.deck=Match.default_deck(0);visit.phase="fortune";visit.current_life=10;visit.gold=4;visit.dice=2;visit.rng.seed=i
  assert(visit.resolve_fortune() and visit.phase=="event_result")
  outcomes[visit.fortune_outcome]=true
  var before: Array=[visit.gold,visit.current_life,visit.dice,visit.rng.state]
  assert(not visit.resolve_fortune() and before==[visit.gold,visit.current_life,visit.dice,visit.rng.state])
  assert(visit.current_life>=1)
  if visit.fortune_outcome=="luck":assert(visit.gold>4 or visit.current_life>10 or visit.dice>2 or visit.extra_item_reward)
  else:assert(visit.gold==3)
  if visit.fortune_outcome=="ambush":ambush=visit
 assert(outcomes.size()==3)
 var temp_profile=Profile.new("res://work/fortune-check-profile.json",false)
 Save.path="res://work/fortune-check.save"
 Save.enabled=true
 assert(ambush.save_checkpoint())
 var restored=Save.load_run(temp_profile)
 assert(restored.fortune_outcome=="ambush" and restored.gold==3)
 assert(not restored.resolve_fortune() and not restored.leave_fortune())
 assert(restored.start_fortune_ambush() and restored.save_checkpoint())
 restored=Save.load_run(temp_profile)
 assert(restored.encounter=="fortune_ambush" and restored.in_combat)
 DirAccess.remove_absolute(ProjectSettings.globalize_path(Save.path))
 Save.enabled=false
 assert(ambush!=null and ambush.start_fortune_ambush())
 assert(ambush.in_combat and ambush.phase=="combat" and ambush.enemy.size()==16 and ambush.gold==3)
 var duel=Match.new(ambush.deck,ambush.enemy,0,false,ambush.rules())
 assert(duel.players[1].hp==16 and duel.adventure_rules.encounter=="fortune_ambush")
 ambush.finish_combat(true,7)
 assert(ambush.phase=="reward" and ambush.gold==4 and ambush.pending_xp==1)
 assert(ambush.options.any(func(key):return Match.CARD_DATA[key].faction==CardData.Faction.NECROPOLIS))
 run.phase="fortune";run.step=State.STAGES.find("fortune");var previous: int=run.rng.state
 assert(run.route_rows[run.step].any(func(node):return node.kind=="treasure"))
 run.gold=0
 assert(not run.resolve_fortune() and run.rng.state==previous and not run.event_claimed)
 assert(run.leave_fortune() and run.rng.state==previous and run.step==State.STAGES.find("fortune")+1)
 assert(State.merchant_at(State.STAGES.find("shop")).art!=State.merchant_at(State.STAGES.rfind("shop")).art)
 var profile=Profile.new("res://work/second-polish-profile.json",false);profile.xp=42;profile.ensure_offers()
 assert(profile.level()==5 and profile.rewards_since(4).size()==4)
 assert(profile.reward_for_level(3).description.contains("vida extra"))
 assert(profile.reward_for_level(4).description.contains("dado"))
 assert(profile.reward_for_level(5).description.contains("item"))
 run=State.new(profile);run.xp_before_settlement=4;run.pending_xp=38
 var payout=preload("res://scripts/adventure_xp_payout.gd").new();payout.configure(run);root.add_child(payout);payout.popup_centered();payout.xp_tween.kill()
 payout.display_xp(42.0);payout.finish_animation()
 for level in [2,3,4,5]:assert(payout.find_child("LevelReward_%d" % level,true,false)!=null)
 assert(payout.revealed_levels.size()==4 and not payout.get_ok_button().disabled)
 assert(payout.get_ok_button().text=="Escolher melhoria")
 var details:=labels(payout)
 assert(details.contains("vida extra") and details.contains("dado inicial") and details.contains("item aleatório"))
 payout.queue_free();await process_frame;await process_frame
 var menu=load("res://start_menu.tscn").instantiate();root.add_child(menu)
 await process_frame;await process_frame
 var ai: Button=menu.find_child("PlayAI",true,false);var online: Button=menu.find_child("PlayMultiplayer",true,false)
 assert(ai.get_parent()==online.get_parent() and ai.get_parent() is HBoxContainer)
 assert(ai.text=="vs IA" and online.text=="Multiplayer" and ai.get_theme_font_size("font_size")==19)
 assert(menu.find_child("PlayAdventure",true,false).icon!=null)
 menu.queue_free();await process_frame;await process_frame
 print("OK: Postura sem Bloqueio, travessia obrigatória, sorte/revés sem duplicação, recompensas por nível e menu compacto.")
 quit()
