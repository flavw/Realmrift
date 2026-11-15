extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
const Match=preload("res://scripts/match.gd")
const Save=preload("res://scripts/adventure_save.gd")
func _initialize():call_deferred("verify")
func verify():
 assert(State.POWERS.bonus_spell.description=="No início de cada combate, receba na mão uma magia aleatória de qualquer facção.")
 Save.path="res://work/test_reroll_offers.save"
 var run=State.new();run.faction=0;run.dice=10
 for phase in ["power","midpower"]:
  run.phase=phase;run.options=run.power_options();var old=run.options.duplicate();var count=run.dice
  assert(run.reroll_offer() and run.dice==count-1 and run.options.size()==3)
  for key in run.options:assert(key not in old and key not in run.powers)
  assert(run.save_checkpoint());var restored=Save.load_run();assert(restored.dice==run.dice and restored.options==run.options and restored.phase==phase)
 run.phase="midpower";run.preparation_active=true;run.options=run.power_options()
 for i in range(8):
  run.dice=1;assert(run.reroll_offer() and "combat_gold" not in run.options)
 run.phase="reward";run.enemy_faction=5;run.options=run.reward_options(5);run.dice=1
 var old=run.options.duplicate();assert(run.reroll_offer() and run.dice==0 and run.options.size()==3)
 assert(run.options.any(func(k):return Match.CARD_DATA[k].faction==5))
 for key in run.options:assert(key not in old)
 assert(not run.reroll_offer() and run.dice==0)
 run=State.new();run.deck.assign(Match.default_deck(0).slice(0,15));run.prepare_item();run.dice=2
 var item=run.pending_item;var choices=run.options.duplicate();var return_phase=run.item_return_phase
 assert(run.reroll_offer() and run.pending_item!=item and run.options==choices and run.dice==1 and run.item_return_phase==return_phase)
 assert(run.save_checkpoint());var saved=Save.load_run();assert(saved.pending_item==run.pending_item and saved.options==choices and saved.dice==1)
 assert(run.apply_item(choices[0]) and run.equipment.size()==1)
 run=State.new();run.deck=["astral_flame"];run.prepare_item();run.dice=2
 assert(run.pending_item=="charm" and not run.can_reroll_offer() and not run.reroll_offer() and run.dice==2)
 Save.enabled=false
 for phase in ["power","midpower","reward","item"]:
  var state=State.new();state.faction=0;state.deck.assign(Match.default_deck(0).slice(0,15));state.phase=phase
  if phase=="item":state.prepare_item()
  if phase=="reward":state.options=state.reward_options(0)
  State.current=state
  var view=load("res://adventure.tscn").instantiate();root.add_child(view);await process_frame
  var button_name: String={"power":"PowerReroll","midpower":"PowerReroll","reward":"RewardReroll","item":"ItemReroll"}[phase]
  var button=view.find_child(button_name,true,false);assert(button!=null and not button.disabled and button.icon!=null)
  button.pressed.emit();assert(state.dice==1)
  view.queue_free();await process_frame
 Save.enabled=true;DirAccess.remove_absolute(ProjectSettings.globalize_path(Save.path))
 print("OK: poderes, recompensas, itens, limites, dados, interface e persistência.")
 quit()
