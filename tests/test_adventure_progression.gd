extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var run=State.new()
 assert(run.gold==1 and run.current_life==20)
 run.permanent_life=1;run.current_life=7
 run.finish_combat(true,7)
 assert(run.current_life==12 and run.gold==2) # ceil(21*.20)=5
 run.current_life=1
 assert(run.visit_healer(false) and run.current_life==7) # ceil(21*.25)=6
 assert(run.healer_cost()==3)
 assert(not run.visit_healer(true) and run.current_life==7 and run.gold==2)
 run.gold=3
 assert(run.visit_healer(true) and run.current_life==21 and run.gold==0)
 run.current_life=20;run.finish_combat(true,20)
 assert(run.current_life==21)
 run.powers.append("combat_gold");run.gold=0;run.gain_victory_gold();assert(run.gold==2)
 for f in State.PRIMARY_FACTIONS:
  var early: Array=run.enemy_deck_for(f,0)
  var late: Array=run.enemy_deck_for(f,State.STAGES.rfind("combat"))
  assert(early.size()==15 and late.size()==22)
  for key in early:assert(DuelMatch.CARD_DATA[key].cost<=3)
  assert(DuelMatch.valid_deck(late))
 var combat_steps: Array=[]
 for at in range(State.STAGES.size()):
  if State.STAGES[at]=="combat":combat_steps.append(at)
 var castle_lives: Array=[12,15,17,18,19,20]
 for i in range(combat_steps.size()):
  run.step=combat_steps[i]
  var duel=DuelMatch.new(DuelMatch.default_deck(0),DuelMatch.default_deck(1),0,false,run.rules())
  assert(duel.players[1].hp==castle_lives[i] and duel.players[1].max_hp==castle_lives[i])
 var normal=DuelMatch.new(DuelMatch.default_deck(0),DuelMatch.default_deck(1),0,false)
 assert(normal.players[1].hp==20 and normal.players[1].max_hp==20)
 run.step=0
 run.ensure_routes()
 assert(run.route_rows.size()==State.STAGES.size())
 for at in [3,State.STAGES.find("fortune"),State.STAGES.size()-3]:assert(run.route_rows[at].any(func(node):return node.kind=="healer"))
 for row in run.route_rows:
  assert(row.size()>=2 or row[0].kind=="boss")
  for node in row:
   if node.kind=="combat":assert(node.portrait in node.deck)
 State.current=run
 run.deck=DuelMatch.default_deck(0).slice(0,15);run.current_life=8;run.enemy=run.enemy_deck_for(0,0);run.in_combat=true
 var main=load("res://main.tscn").instantiate();root.add_child(main)
 assert(main.duel.players[0].hp==8 and main.duel.players[0].max_hp==21)
 main.queue_free();await process_frame
 run.in_combat=false;run.phase="map";run.step=0
 var view=load("res://adventure.tscn").instantiate();root.add_child(view)
 await process_frame
 await process_frame
 assert(view.find_child("Route_0_0",true,false)!=null)
 if DisplayServer.get_name()!="headless":get_root().get_texture().get_image().save_png("res://.local/adventure-route-map.png")
 run.step=2;view.render();await process_frame
 var before: int=run.gold
 view.choose_route(0)
 assert(run.phase=="bridge" and run.gold==before)
 var after: int=run.gold
 view.choose_route(0)
 assert(run.gold==after)
 run.phase="healer";run.step=2;run.current_life=1;run.gold=1;view.render()
 view.heal_at_node(true)
 assert(run.phase=="healer" and run.step==2 and run.current_life==1 and run.gold==1)
 var vitality: int=run.permanent_life
 var items: int=run.equipment.size()
 view.heal_at_node(false)
 assert(run.phase=="map" and run.step==3 and run.current_life==7 and run.gold==1)
 assert(run.permanent_life==vitality and run.equipment.size()==items)
 run.phase="healer";run.step=6;run.current_life=1;run.gold=3;view.render()
 view.heal_at_node(true)
 assert(run.phase=="map" and run.step==7 and run.current_life==21 and run.gold==0)
 run.phase="healer";run.step=9;run.preparation_active=true;run.current_life=1;view.render()
 view.heal_at_node(false)
 assert(run.phase=="map" and run.step==10 and run.current_life==21 and run.gold==0)
 assert(run.permanent_life==vitality and run.equipment.size()==items)
 view.queue_free();await process_frame;await process_frame
 State.current=null
 print("OK: vida persistente, arredondamentos, curandeira, economia, decks progressivos, mapa e tesouro")
 quit()


