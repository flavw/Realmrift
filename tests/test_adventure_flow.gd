extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 preload("res://scripts/adventure_save.gd").enabled=false
 State.current=State.new()
 var view=load("res://adventure.tscn").instantiate()
 root.add_child(view)
 view.choose_faction(0)
 for i in range(15):view.pick_card(State.current.options[0])
 assert(State.current.phase=="power")
 view.pick_power(State.current.options[0])
 assert(State.current.phase=="map")
 State.current.enemy=DuelMatch.default_deck(0)
 State.current.enemy_faction=0
 State.current.in_combat=true
 var main=load("res://main.tscn").instantiate()
 root.add_child(main)
 assert(main.adventure_active())
 assert(main.duel.players[0].deck.size()+main.duel.players[0].hand.size()==15)
 assert(main.duel.opening)
 main.queue_free()
 State.current.in_combat=false
 var wins:=0
 while State.current.step<State.STAGES.size():
  var stage: String=State.STAGES[State.current.step]
  if stage in ["combat","boss"]:
   State.current.finish_combat(true)
   view.render()
   assert(State.current.options.size()==3)
   view.pick_card(State.current.options[0]);wins+=1
  elif stage=="power_event":
   view.open_midpower();view.pick_power(State.current.options[0]);view.upgrade_life()
  elif stage=="shop":
   view.open_shop()
   var count: int=State.current.deck.size()
   State.current.gold=maxi(State.current.gold,3)
   view.purchase(State.current.options[0])
   assert(State.current.deck.size()==count+1)
   view.finish_service_encounter()
  elif stage=="event":
   view.choose_route(0)
   view.bridge_choice("pay")
   view.finish_event()
  elif stage=="fortune":
   view.choose_route(0)
   view.leave_fortune()
  elif stage=="preparation":
   if State.current.step==State.STAGES.size()-3:
    view.choose_route(1)
    view.heal_at_node(false)
   else:
    view.choose_route(0)
    view.equip(State.current.options[0])
 assert(wins==7 and State.current.phase=="victory")
 assert(State.current.powers.size()==2 and State.current.equipment.size()==1)
 print("OK: montagem, entrada no duelo, 7 vitórias, eventos, loja, poderes e final")
 quit()



