extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
const Save=preload("res://scripts/adventure_save.gd")
const Profile=preload("res://scripts/adventure_profile.gd")
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 Save.path="res://.local/test-adventure-ui-save.save"
 var profile=Profile.new("res://.local/test-adventure-ui-profile.json",false);profile.xp=15;profile.claimed["2"]="life"
 var run=State.new(profile);run.phase="map";run.deck=Match.default_deck(0).slice(0,15);run.powers=["all_trample","first_mana","castle_armor"];run.pending_xp=7;State.current=run
 var menu=load("res://start_menu.tscn").instantiate();root.add_child(menu);menu.show_avatar_selector()
 await process_frame;await process_frame
 for key in preload("res://scripts/player_identity.gd").AVATARS:
  var portrait=menu.find_child("AvatarChoice_"+key,true,false).find_child("AvatarPortrait",true,false)
  assert(portrait.material.get_shader_parameter("crop")==Vector2(0.48,0.36))
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("res://.local/avatar-close-faces.png")
 menu.queue_free();await process_frame;await process_frame
 var view=load("res://adventure.tscn").instantiate();root.add_child(view)
 var avatar=view.find_child("AdventureXPProgress",true,false)
 assert(avatar.custom_minimum_size==Vector2(128,128))
 var click:=InputEventMouseButton.new();click.button_index=MOUSE_BUTTON_LEFT;click.pressed=true;avatar.gui_input.emit(click)
 await process_frame;await process_frame
 var dialog=view.find_child("AdventureProgressDialog",true,false)
 assert(dialog!=null and dialog.find_child("ProgressLevel",true,false).text=="NÍVEL 3")
 assert(dialog.find_child("ProgressLevel",true,false).size.x>500)
 assert(dialog.find_child("ExpeditionPendingXP",true,false).text.contains("7"))
 for key in run.powers:assert(dialog.find_child("PowerDetail_"+key,true,false)!=null)
 assert(not view.body.get_children().any(func(node):return node is Label and node.text.contains("Dourado:")))
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("res://.local/avatar-level-powers.png")
 view.queue_free();await process_frame;await process_frame
 assert(run.save_checkpoint())
 var selector=load("res://adventure_select.tscn").instantiate();root.add_child(selector)
 await process_frame;await process_frame
 assert(selector.find_child("AdventureSelectionArtwork",true,false)!=null)
 assert(selector.find_child("ContinueExpedition",true,false)!=null and selector.find_child("AbandonExpedition",true,false)!=null)
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("res://.local/adventure-selector-save.png")
 selector.confirm_abandon()
 assert(selector.find_child("ConfirmAbandon",true,false)!=null and run.phase=="map")
 selector.queue_free();await process_frame;await process_frame
 # Persisted receipts and the animation crossing a level boundary.
 profile.xp=3;run.phase="abandoned";run.xp_settled=false
 assert(run.settle_xp("abandoned") and profile.xp==10)
 var payout=load("res://scripts/adventure_xp_payout.gd").new();payout.configure(run);root.add_child(payout);payout.popup_centered()
 payout.xp_tween.pause();payout.display_xp(4.2)
 await process_frame;await process_frame
 assert(payout.xp_bar.value>4 and payout.avatar.level==1)
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("res://.local/adventure-xp-payout.png")
 payout.display_xp(6.0);assert(payout.avatar.level==2 and payout.xp_bar.value==1)
 payout.queue_free();await process_frame;await process_frame;State.current=null
 print("OK: avatares maiores com rosto em destaque, menu de nível/poderes ao clicar, seletor de aventuras com continuar/abandonar e barra de XP cruzando nível")
 quit()
