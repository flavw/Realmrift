extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var run=State.new();State.current=run
 var view=load("res://adventure.tscn").instantiate();root.add_child(view)
 await process_frame;await process_frame
 assert(view.find_child("ContinuousStory",true,false).text==State.INTRO_TEXT)
 assert(view.find_child("StoryArtwork",true,false).texture.resource_path=="res://assets/ui/adventure-opening.png")
 assert(not view.deck_open and view.find_child("AdventureDeckSidebar",true,false)==null)
 assert(view.find_child("ContinuousStory",true,false).visible_characters<State.INTRO_TEXT.length())
 view.intro_continue()
 assert(run.phase=="intro" and view.find_child("ContinuousStory",true,false).visible_characters==State.INTRO_TEXT.length())
 await process_frame;await process_frame
 assert(view.find_child("StoryArtwork",true,false).size.x>1700)
 assert(view.find_child("StoryArtwork",true,false).stretch_mode==TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
 assert(view.find_child("AdventureHeader",true,false)==null)
 assert(view.find_child("OpeningDialogue",true,false).get_global_rect().intersects(view.find_child("StoryArtwork",true,false).get_global_rect()))
 if DisplayServer.get_name()!="headless":get_root().get_texture().get_image().save_png("res://.local/adventure-opening-story.png")
 view.intro_fade.set_speed_scale(1000.0)
 await create_timer(0.15).timeout
 assert(view.intro_hidden and not view.intro_overlay.visible and run.phase=="intro")
 if DisplayServer.get_name()!="headless":get_root().get_texture().get_image().save_png("res://.local/adventure-opening-art-only.png")
 view.intro_continue();assert(run.phase=="faction")
 view.choose_faction(0)
 assert(view.deck_open and view.find_child("AdventureDeckSidebar",true,false)!=null)
 run.deck=Match.default_deck(0).slice(0,15);run.phase="farm";run.gold=3;view.render()
 var choices: Array=view.body.get_children().filter(func(n):return n is Button and n.text.contains("presente"))
 assert(choices.size()==2 and choices.all(func(b):return not b.text.contains("+1") and not b.text.contains("vida") and not b.text.contains("combate")))
 assert(view.find_child("StoryArtwork",true,false)==null)
 assert(not run.gift_farmer(true) and run.gold==3 and not run.farm_blessing_all_run)
 run.gold=4;view.farm_gift(true)
 assert(run.gold==0 and run.phase=="event_result" and run.farm_blessing_all_run and not run.farm_blessing_pending)
 assert(view.find_child("StoryArtwork",true,false).texture.resource_path=="res://assets/ui/adventure-farm-banquet.png")
 assert(not run.gift_farmer(true))
 await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":get_root().get_texture().get_image().save_png("res://.local/adventure-banquet-result.png")
 run.advance()
 for fight in range(2):
  var m=Match.new(run.deck,[],0,false,run.rules())
  var unit: Dictionary=m.spawn_unit(0,"warrior")
  assert(unit.health==Match.CARD_DATA.warrior.health+1 and unit.farm_blessing_persistent)
  assert(m.spawn_unit(1,"warrior").health==Match.CARD_DATA.warrior.health)
  run.finish_combat(true,10)
  assert(run.farm_blessing_all_run and run.rules().farm_blessing)
  run.advance()
 assert(not State.new().farm_blessing_all_run)
 run.victory_sound_pending=false;run.ensure_routes();run.phase="map";run.step=0;view.render()
 await process_frame;await process_frame;await process_frame
 var map=view.find_child("AdventureMapBackdrop",true,false)
 assert(not view.deck_open and view.find_child("AdventureDeckSidebar",true,false)==null)
 assert(view.find_child("AdventureMapScroll",true,false).size.x>1700)
 assert(map.get_parent().find_child("Route_0_0",true,false).size==Vector2(100,100))
 view.toggle_deck();assert(view.find_child("AdventureDeckSidebar",true,false)!=null)
 view.toggle_deck()
 await process_frame;await process_frame;await process_frame
 map=view.find_child("AdventureMapBackdrop",true,false)
 var start: float=map.material.get_shader_parameter("revealed_until")
 assert(start>0.0 and start<0.2 and map.show_behind_parent)
 if DisplayServer.get_name()!="headless":get_root().get_texture().get_image().save_png("res://.local/adventure-reveal-start.png")
 run.step=State.STAGES.size()-1;view.render()
 await process_frame;await process_frame;await process_frame
 map=view.find_child("AdventureMapBackdrop",true,false)
 assert(is_equal_approx(float(map.material.get_shader_parameter("revealed_until")),1.0))
 if DisplayServer.get_name()!="headless":get_root().get_texture().get_image().save_png("res://.local/adventure-reveal-final.png")
 view.queue_free();await process_frame;await process_frame
 var music=preload("res://scripts/game_music.gd").ensure(self)
 for child in music.get_children():
  if child is AudioStreamPlayer:child.stop();child.stream=null
 await create_timer(0.1).timeout
 State.current=null
 print("OK: história contínua, arte inicial, resultados ocultos, presente de 4 ouro até o fim e revelação do mapa")
 quit()

