extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func fresh():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10;p.hp=20
 return m
func verify() -> void:
 var data: CardData=Match.CARD_DATA.dawn_paladin
 assert(data.regeneration==0 and data.quick_heal_amount==1 and data.quick_heal_cost==1)
 assert(data.ability_entries().any(func(e):return e.name=="Cura Célere 1"))
 for side in [0,1]:
  var m=fresh();m.turn=side
  var pal=m.spawn_unit(side,"dawn_paladin");pal.health=3;pal.poison=2;pal.bleeding=1
  pal.ready=false
  assert(not m.can_heal(side,0,-1,side,true))
  assert(m.can_heal(side,0,0,side,true))
  assert(m.heal(side,0,0,side,true))
  assert(pal.health==6 and pal.max_health==7 and pal.attack==4 and pal.poison==0 and pal.bleeding==0)
  assert(not pal.ready and pal.quick_heal_used and m.players[side].mana==9)
  assert(not m.heal(side,0,0,side,true))
  m.begin_turn();assert(not pal.quick_heal_used and pal.ready)
  pal.health-=1
  assert(m.heal(side,0,0,side,true) and pal.ready and not pal.exhausting_action_taken)
  var foe=m.spawn_unit(1-side,"wolf");foe.health=10
  assert(m.act(side,0,0,false),"Cura Célere não impede atacar")
  m=fresh();m.turn=side
  pal=m.spawn_unit(side,"dawn_paladin");pal.ready=false
  var enemy=m.spawn_unit(1-side,"zombie_helper");enemy.health=3;enemy.abascanto=1
  assert(m.heal(side,0,0,1-side,true) and enemy.health==3 and pal.attack==2)
  m.begin_turn();assert(m.heal(side,0,0,1-side,true) and enemy.health==2 and pal.attack==4)
  m=fresh();m.turn=side;pal=m.spawn_unit(side,"dawn_paladin");pal.health-=1;m.players[side].mana=0
  assert(not m.can_heal(side,0,0,side,true))
 var ai=fresh();ai.turn=1
 var healer=ai.spawn_unit(1,"dawn_paladin");healer.ready=false;healer.health-=1
 assert(ai.ai_step() and healer.quick_heal_used and not healer.ready and healer.attack==4)
 var main=load("res://main.tscn").instantiate();main.enable_opening=false;main.muted=true
 root.add_child(main);await process_frame
 for p in main.duel.players:p.board.clear();p.mana=10
 main.duel.turn=0
 var unit=main.duel.spawn_unit(0,"dawn_paladin");unit.health-=1;unit.ready=false
 main.redraw();main.select(0);await process_frame
 assert(main.context_for(unit,0).quick_heal_target)
 var button=main.find_child("Ability_heal-icon",true,false)
 assert(button!=null and not button.disabled)
 main.select_heal(true);assert(main.healing and main.quick_healing)
 assert(not main.duel.can_heal(0,0,-1,0,true))
 main.queue_free();await process_frame
 print("OK: Cura Célere, limite, alvo, Devoção, mortos-vivos, interface e IA.")
 quit()
