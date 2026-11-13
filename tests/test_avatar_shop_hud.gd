extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
const Match=preload("res://scripts/match.gd")
const Identity=preload("res://scripts/player_identity.gd")
const Profile=preload("res://scripts/adventure_profile.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 Identity.storage_path="res://.local/test_player_identity.json";Identity.loaded=true;Identity.selected="warrior"
 var menu=load("res://start_menu.tscn").instantiate();root.add_child(menu)
 assert(menu.find_child("PlayerAvatarSelector",true,false)!=null)
 menu.show_avatar_selector()
 assert(menu.find_child("AvatarChoices",true,false).get_child_count()==10)
 await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("res://.local/avatar-selector.png")
 menu.select_avatar("mage");assert(Identity.avatar()=="mage")
 Identity.loaded=false;Identity.selected="warrior";assert(Identity.avatar()=="mage")
 menu.queue_free();await process_frame;await process_frame
 var profile=Profile.new("res://.local/test_hud_profile.json",false);profile.xp=2
 var run=State.new(profile);run.faction=0;run.deck=Match.default_deck(0).slice(0,15)+["mage"];run.gold=12;run.current_life=17;run.step=6;run.generate_shop();State.current=run
 var candidates: Array=Match.CARD_DATA.keys().filter(func(key):return Match.CARD_DATA[key].collectible and not Match.CARD_DATA[key].neutral_deck_only and Match.CARD_DATA[key].card_type==CardData.CardType.CREATURE)
 for roll in [0.0,0.399,0.4,0.799,0.8,0.899,0.9,0.999]:
  var pool: Array=run.premium_pool_for_roll(candidates,roll)
  assert(not pool.is_empty())
  if roll<0.4:assert(pool.all(func(key):return Match.CARD_DATA[key].faction==0))
  elif roll<0.8:assert(pool.all(func(key):return Match.CARD_DATA[key].faction==1))
  elif roll<0.9:assert(pool.all(func(key):return Match.CARD_DATA[key].faction not in [0,1,2]))
  else:assert(pool.all(func(key):return Match.CARD_DATA[key].faction==2))
 var view=load("res://adventure.tscn").instantiate();root.add_child(view)
 await process_frame;await process_frame
 assert(not view.deck_open and view.find_child("AdventureDeckSidebar",true,false)==null)
 assert(view.find_child("AdventureCompactHUD",true,false)!=null)
 var avatar=view.find_child("AdventureXPProgress",true,false)
 assert(avatar.avatar_key=="mage" and is_equal_approx(avatar.xp_progress,0.4))
 assert(view.find_child("HUDVida",true,false).get_node("Value").text=="17/20")
 assert(view.find_child("HUDOuro",true,false).get_node("Value").text=="12")
 assert(view.find_child("HUDDados",true,false).get_node("Value").text=="—")
 assert(not view.find_children("*","Label",true,false).any(func(label):return label.text=="Da Vila à Fenda"))
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("res://.local/shop-compact-hud.png")
 view.toggle_deck();await create_timer(0.35).timeout
 var panel=view.find_child("AdventureDeckSidebar",true,false)
 assert(view.deck_open and panel.visible and is_equal_approx(panel.offset_right,-30))
 view.toggle_deck();await create_timer(0.35).timeout
 assert(not view.deck_open and not panel.visible and is_equal_approx(view.find_child("AdventureContentScroll",true,false).offset_right,-40))
 # New offer fallback remains valid before recruiting extra factions and after all factions.
 run.deck=Match.default_deck(0).slice(0,15);run.step=9;run.generate_shop();assert(not run.shop_premium_key.is_empty())
 view.queue_free();await process_frame;await process_frame;State.current=null
 DirAccess.remove_absolute(ProjectSettings.globalize_path(Identity.storage_path))
 Identity.storage_path="user://player_identity.json";Identity.loaded=false
 print("OK: dez avatares persistentes, HUD com vida/ouro/dados e XP circular, loja sem título/deck, animação lateral e pesos 40/40/10/10")
 quit()
