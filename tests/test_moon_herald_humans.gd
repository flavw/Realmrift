extends SceneTree
const Match=preload("res://scripts/match.gd")
func fresh():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10
 return m
func _initialize():call_deferred("verify")
func verify():
 var data=Match.CARD_DATA.moon_herald
 assert(data.entry_human_only and data.entry_summary()=="+1/+1 aliado humano" and "Humano" in data.entry_prompt())
 for side in [0,1]:
  var m=fresh();m.turn=side
  var wolf=m.spawn_unit(side,"wolf")
  var human=m.spawn_unit(side,"squire")
  var dual=m.spawn_unit(side,"necromancer_summoner")
  var elf=m.spawn_unit(side,"wild_elf")
  m.players[side].hand=["moon_herald"]
  assert(m.entry_valid_targets(side,Match.CARDS.moon_herald)==[1,2])
  assert(not m.play(side,0,0) and not m.play(side,0,3) and m.players[side].mana==10)
  assert(m.play(side,0,1) and human.attack==2 and human.health==3 and wolf.attack==Match.CARD_DATA.wolf.attack and elf.attack==Match.CARD_DATA.wild_elf.attack)
  assert(m.last_action.buff_target==human.id and Match.has_type(dual,CardData.CreatureType.HUMAN) and not Match.has_type(dual,CardData.CreatureType.MONSTER))
  m=fresh();m.turn=side
  m.spawn_unit(side,"wolf");m.players[side].hand=["moon_herald"]
  assert(m.play(side,0) and m.players[side].board.size()==2 and not m.last_action.has("buff_target"))
 var m=fresh();m.turn=1
 var beast=m.spawn_unit(1,"wolf")
 var ai_human=m.spawn_unit(1,"squire")
 m.players[1].hand=["moon_herald"];m.players[1].mana=2
 assert(m.ai_step() and ai_human.attack==2 and beast.attack==Match.CARD_DATA.wolf.attack)
 var main=load("res://main.tscn").instantiate();main.enable_opening=false;main.muted=true;root.add_child(main);await process_frame
 for player in main.duel.players:player.board.clear();player.hand.clear();player.mana=10
 main.duel.turn=0
 var w=main.duel.spawn_unit(0,"wolf")
 var h=main.duel.spawn_unit(0,"squire")
 main.duel.players[0].hand=["moon_herald"];main.redraw();await process_frame
 main.play(0)
 assert(main.summoning==0 and not main.field_nodes[0][w.id].available and main.field_nodes[0][h.id].available)
 main.queue_free();await process_frame
 print("OK: Humanos, alvos inválidos, sem alvo, IA e interface.")
 quit()
