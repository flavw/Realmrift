extends SceneTree
const Match=preload("res://scripts/match.gd")
const Items=preload("res://scripts/adventure_items.gd")
func fixture():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.deck=Match.default_deck(0);p.mana=10;p.max_mana=5
 return m
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var data:CardData=Match.CARD_DATA.restless_skeleton
 assert(data.impulsive and data.swift and data.ability_entries().any(func(entry):return entry.name=="Impulsivo"))
 for side in [0,1]:
  var m=fixture();m.turn=side;m.players[side].hand=["restless_skeleton"]
  assert(m.play(side,0))
  var skeleton:Dictionary=m.players[side].board[0]
  assert(m.end_turn(side) and m.players[1-side].hp==19 and not skeleton.ready)
  assert(m.end_turn(1-side) and m.end_turn(side) and m.players[1-side].hp==18)
  # A manual attack, exhaustion, roots, zero attack or an already-used attack prevents an extra attack.
  m=fixture();m.turn=side;skeleton=m.spawn_unit(side,"restless_skeleton")
  assert(m.act(side,0,-1) and m.end_turn(side) and m.players[1-side].hp==19)
  for condition in ["exhausted","rooted","zero_attack","wall","already_attacked"]:
   m=fixture();m.turn=side;skeleton=m.spawn_unit(side,"restless_skeleton")
   if condition=="exhausted":skeleton.ready=false
   if condition=="rooted":skeleton.rooted=true
   if condition=="zero_attack":skeleton.attack=0
   if condition=="wall":skeleton.wall=true
   if condition=="already_attacked":skeleton.attacked_this_turn=true
   assert(m.end_turn(side) and m.players[1-side].hp==20,condition)
  # Multiple sources re-evaluate blockers after deaths and consumed charges.
  m=fixture();m.turn=side;m.spawn_unit(side,"restless_skeleton");m.spawn_unit(side,"restless_skeleton")
  var guard=m.spawn_unit(1-side,"squire");guard.health=3
  assert(m.end_turn(side) and guard.health==2 and m.players[1-side].hp==19 and m.players[side].board.size()==1)
  # Turn bonuses and temporary flying still apply before end-turn cleanup.
  m=fixture();m.turn=side;skeleton=m.spawn_unit(side,"restless_skeleton")
  skeleton.turn_attack=2;skeleton.turn_flying=true;m.spawn_unit(1-side,"squire")
  assert(m.end_turn(side) and m.players[1-side].hp==17 and skeleton.turn_attack==0 and not skeleton.turn_flying)
  # Bleeding triggers on the attack; poison resolves afterwards.
  for status in ["bleeding","poison"]:
   m=fixture();m.turn=side;skeleton=m.spawn_unit(side,"restless_skeleton");skeleton[status]=1
   assert(m.end_turn(side) and m.players[1-side].hp==19 and m.players[side].board.is_empty())
  m=fixture();m.turn=side;m.spawn_unit(side,"restless_skeleton")
  m.castle_traps[1-side]=[{"remaining":1,"damage":5}]
  assert(m.end_turn(side) and m.players[1-side].hp==20 and m.players[side].board.is_empty())
  m=fixture();m.turn=side;m.spawn_unit(side,"restless_skeleton");m.players[1-side].hp=1
  assert(m.end_turn(side) and m.winner==side and m.turn==side)
 # Creature bosses remain the automatic target in encounters without a castle.
 var m=fixture();m.spawn_unit(0,"restless_skeleton")
 var boss=m.spawn_unit(1,"adventure_mimic");var life:int=boss.health
 m.creature_boss_id=boss.id;m.adventure_rules={"enabled":true,"encounter":"mimic"}
 assert(m.end_turn(0) and boss.health==life-1 and m.players[1].hp==20)
 var enhanced=Items.enhance("restless_skeleton","heart")
 assert(Match.CARDS[enhanced].impulsive)
 # One actual UI attack confirms that lethal interrupts passing the turn.
 var main=load("res://main.tscn").instantiate();main.enable_opening=false;main.muted=true
 root.add_child(main);await process_frame
 main.duel=fixture();main.duel.spawn_unit(0,"restless_skeleton");main.duel.players[1].hp=1
 main.redraw();await process_frame;main.end_turn()
 assert(main.duel.winner==0 and main.busy)
 await create_timer(0.8).timeout
 assert(not main.busy and main.duel.turn==0 and main.result_shown)
 main.queue_free();await process_frame;await process_frame
 print("OK: Impulsivo nos dois lados, sem ataque extra, impedimentos, Bloqueio, bônus, mortes, armadilhas, chefes e vitória animada na UI.")
 quit()
