extends SceneTree
const Profile=preload("res://scripts/adventure_profile.gd")
const State=preload("res://scripts/adventure_state.gd")
const Save=preload("res://scripts/adventure_save.gd")
func _initialize():call_deferred("verify")
func verify():
 var p=Profile.new("res://work/test_dice_levels_profile.json",false)
 for row in [[0,1,2],[24,3,2],[25,4,3],[132,7,3],[133,8,4]]:
  p.xp=row[0]
  assert(p.level()==row[1] and State.new(p).dice==row[2])
  assert(p.initial_dice_bonus()==row[2]-2)
 assert(Profile.is_milestone(4) and Profile.is_milestone(8))
 p.xp=133;p.claimed={"2":"life","6":"gold","7":"creature_attack"};p.offers={"4":["life","gold"],"8":["life","gold"]};p.ensure_offers()
 assert(p.pending_choice().is_empty() and not p.offers.has("4") and not p.offers.has("8"))
 # Existing earned choices remain valid when milestones change.
 p.claimed["4"]="life";p.claimed["8"]="gold";assert(p.persist())
 var reopened=Profile.new(p.path);assert(reopened.claimed.has("4") and reopened.claimed.has("8") and reopened.totals().life==2 and reopened.totals().gold==2)
 Save.path="res://work/test_dice_levels_run.save"
 var run=State.new(reopened);run.dice=1;run.phase="draft";run.faction=0;run.options=run.draft_options()
 assert(run.save_checkpoint());var saved=Save.load_run(reopened);assert(saved.dice==1 and saved.options==run.options)
 Save.enabled=false;State.current=State.new(reopened);State.current.phase="draft";State.current.faction=0
 var dialog=load("res://scripts/adventure_progress_dialog.gd").new();dialog.configure(State.current);root.add_child(dialog);await process_frame
 assert(dialog.find_child("Milestone4",true,false).text.contains("+1 dado") and dialog.find_child("Milestone8",true,false).text.contains("+1 dado"))
 dialog.queue_free();Save.enabled=true
 DirAccess.remove_absolute(ProjectSettings.globalize_path(p.path));DirAccess.remove_absolute(ProjectSettings.globalize_path(Save.path))
 print("OK: dados iniciais, marcos 4 e 8, escolhas, progresso e salvamento.")
 quit()
