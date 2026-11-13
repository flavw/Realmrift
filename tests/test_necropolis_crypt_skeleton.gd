extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
const State=preload("res://scripts/adventure_state.gd")
const Items=preload("res://scripts/adventure_items.gd")
func fixture():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10;p.max_mana=5;p.deck=Match.default_deck(0)
 return m
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var crypt:CardData=Match.CARD_DATA.defiled_crypt
 var skeleton:CardData=Match.CARD_DATA.restless_skeleton
 assert(crypt.faction==7 and crypt.attack==0 and crypt.health==5 and crypt.wall and crypt.cost==4)
 assert(crypt.ability_entries().any(func(entry):return entry.get("badge","")=="TurnSummon"))
 assert(skeleton.faction==7 and skeleton.attack==1 and skeleton.health==1 and skeleton.cost==1 and skeleton.swift)
 assert(skeleton.ability_entries().any(func(entry):return entry.name=="Disparada"))
 assert(not Match.CARD_DATA.crypt_zombie.collectible and not Store.accepts_base(7,["crypt_zombie"]))
 for side in [0,1]:
  var m=fixture();m.turn=side;m.players[side].hand=["defiled_crypt"]
  assert(m.play(side,0) and m.players[side].board.size()==1 and m.players[side].mana==6)
  var wall:Dictionary=m.players[side].board[0]
  wall.ready=true;wall.attack=1
  assert(not m.can_target(side,0,-1) and not Match.apply_poison(wall,2))
  wall.attack=0
  assert(m.end_turn(side) and m.players[side].board.size()==1)
  assert(m.end_turn(1-side) and m.players[side].board.size()==2)
  var zombie:Dictionary=m.players[side].board[1]
  assert(zombie.key=="crypt_zombie" and zombie.attack==2 and zombie.health==2 and not zombie.ready and zombie.summoned_this_turn)
  assert(m.players[side].mana==m.players[side].max_mana and m.last_action.turn_summons.size()==1)
  assert(m.end_turn(side) and m.end_turn(1-side))
  assert(m.players[side].board.size()==3 and zombie.ready and not m.players[side].board[2].ready)
  for i in range(5):assert(m.end_turn(side) and m.end_turn(1-side))
  assert(m.players[side].board.size()==Match.MAX_BOARD)
  assert(m.history.any(func(message):return message.contains("sem espaço para invocar")))
  m=fixture();m.turn=side;m.players[side].hand=["restless_skeleton"]
  assert(m.play(side,0) and m.players[side].board[0].ready)
  assert(m.act(side,0,-1) and m.players[1-side].hp==19)
 # Multiple sources share remaining spaces; newly summoned units stay exhausted.
 var m=fixture();m.spawn_unit(0,"defiled_crypt");m.spawn_unit(0,"defiled_crypt")
 for i in range(3):m.spawn_unit(0,"crypt_zombie")
 m.begin_turn();assert(m.players[0].board.size()==6 and m.last_action.turn_summons.size()==1)
 assert(not m.players[0].board[5].ready)
 # No trigger while mulligan is open or when its source is dead.
 m=fixture();var source=m.spawn_unit(0,"defiled_crypt");m.opening=true;m.begin_turn()
 assert(m.players[0].board.size()==1)
 m.opening=false;source.health=0;m.begin_turn();assert(m.players[0].board.size()==1)
 # An upgraded crypt keeps its passive; the token does not inherit its equipment.
 var key=Items.enhance("defiled_crypt","heart")
 assert(Match.CARDS[key].turn_summon_key=="crypt_zombie")
 m=fixture();m.spawn_unit(0,key);m.begin_turn()
 assert(m.players[0].board[0].health==7 and m.players[0].board[1].health==2)
 # The AI can play the passive normally; no new action or target selection is required.
 m=fixture();m.turn=1;m.players[1].hand=["defiled_crypt"]
 assert(m.ai_step() and m.players[1].board[0].key=="defiled_crypt")
 for i in range(8):
  var run=State.new();assert("crypt_zombie" not in run.reward_options(7))
 var editor=load("res://deck_editor.tscn").instantiate()
 editor.configure(Store.new("res://work/crypt_unused.json",false));root.add_child(editor)
 editor.choose_slot(9);editor.select_base_faction(7);await process_frame
 assert(editor.collection_keys().has("defiled_crypt") and editor.collection_keys().has("restless_skeleton") and not editor.collection_keys().has("crypt_zombie"))
 editor.queue_free();await process_frame
 print("OK: Cripta, ambos os lados, turno do dono, esgotamento, campo cheio, múltiplas fontes, Disparada, equipamentos, IA e coleção.")
 quit()
