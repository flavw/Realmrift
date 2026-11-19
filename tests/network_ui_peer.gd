extends "res://tests/network_peer_runner.gd"
var game: Control
func begin() -> void:
 timeout_ms=120000
 super.begin()
 session.match_started.connect(open_game)
func open_game() -> void:
 game=load("res://main.tscn").instantiate()
 root.add_child(game)
 assert(game.network_mode and not game.adventure_active())
 assert(not game.playtest_win())
func tick() -> void:
 if is_instance_valid(game) and (game.busy or game.network_animating):return
 super.tick()
func send(command: Dictionary) -> void:
 if not is_instance_valid(game) or game.busy:return
 actions+=1
 match command.kind:
  "mulligan":game.finish_mulligan(command.indices)
  "play":
   game.play(command.hand)
   if game.summoning>=0:
    var data: CardData=Match.CARD_DATA[game.duel.players[0].hand[game.summoning]]
    game.summon_target(Match.entry_target_side(0,data.combat_data()),int(command.get("target",-1)),String(command.get("choice","")))
  "act":game.selected=command.index;game.magic=command.get("magical",false);game.target(command.target)
  "cast":game.casting=command.hand;game.cast_target(command.target_side,command.target,int(command.get("trap_choice",0)))
  "end_turn":game.end_turn()

func finish() -> void:
 timer.stop()
 # Allow the result overlay's entrance coroutine to complete before freeing it.
 await create_timer(0.7).timeout
 if is_instance_valid(game):game.queue_free()
 await process_frame;await process_frame
 session.close();quit()
