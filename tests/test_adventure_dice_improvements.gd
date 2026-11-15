extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
const Match=preload("res://scripts/match.gd")
const Save=preload("res://scripts/adventure_save.gd")
func _initialize():call_deferred("verify")
func verify():
 Save.path="res://work/test_adventure_dice.save"
 var run=State.new();run.phase="draft";run.faction=0;run.options=run.draft_options()
 assert(run.dice==2 and run.options.size()==3)
 var previous=run.options.duplicate();assert(run.reroll_draft() and run.dice==1 and run.options.size()==3)
 for key in run.options:assert(key not in previous and Match.faction_allowed(run.faction,Match.CARD_DATA[key].faction))
 assert(run.save_checkpoint())
 var loaded=Save.load_run();assert(loaded.dice==1 and loaded.options==run.options)
 assert(run.reroll_draft() and not run.reroll_draft() and run.dice==0)
 var costs: Dictionary={}
 for faction in [0,1,3,4,5,6,7,8]:
  run.faction=faction
  for n in range(20):
   run.dice=1;assert(run.reroll_draft())
   for key in run.options:
    assert(Match.faction_allowed(faction,Match.CARD_DATA[key].faction))
    costs[Match.CARD_DATA[key].cost]=true
 assert(costs.size()>=5)
 for side in [0,1]:
  var m=Match.new();for p in m.players:p.board.clear();p.mana=10
  m.turn=side
  var a=m.spawn_unit(side,"wild_archer");a.ready=true;a.attack=3;a.health=8
  var d=m.spawn_unit(1-side,"raven");d.attack=0;d.health=8;d.armor=1
  var forecast=m.attack_forecast(side,0,0)
  assert(forecast.flight_reduction==0 and forecast.damage==3)
  assert(m.act(side,0,0) and d.health==5 and m.last_action.flight_reduction==0)
 assert(Match.CARD_DATA.marsh_troll.block==0)
 Save.enabled=false;State.current=State.new();State.current.phase="draft";State.current.faction=0
 var view=load("res://adventure.tscn").instantiate();root.add_child(view)
 await process_frame;await process_frame
 assert(view.find_child("DraftReroll",true,false)!=null and view.find_child("SaveAndLeaveExpedition",true,false)!=null and view.find_child("AbandonExpeditionIcon",true,false)!=null)
 var card=view.find_child("AdventureCardChoices",true,false).get_child(0).get_child(0)
 assert(card.custom_minimum_size.x>=320)
 view.reroll_draft();assert(State.current.dice==1)
 State.current.phase="power";State.current.options=["first_three_keywords"];view.render();await process_frame
 assert(view.find_child("AdventurePower_first_three_keywords",true,false).icon!=null)
 State.current.phase="map";State.current.options=[];view.render();await process_frame
 assert(view.find_child("AdventureMapTopSpace",true,false)!=null and view.find_child("AdventureMapScroll",true,false)!=null)
 view.queue_free();Save.enabled=true;DirAccess.remove_absolute(ProjectSettings.globalize_path(Save.path))
 print("OK: dados e persistência, seleção, botões, ícones, mapa, Alcance e Troll.")
 quit()
