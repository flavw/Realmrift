extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var m=Match.new()
 m.players[0].hand=["astral_flame"];m.players[0].mana=3
 m.players[1].board.clear()
 m.spawn_unit(0,"runic_familiar")
 assert(m.can_cast(0,0,1,-1) and not m.can_cast(0,0,0,-1))
 assert(m.cast(0,0,1,-1) and m.players[1].hp==16 and m.players[0].mana==0 and m.last_action.castle)
 assert(m.history.has("Seu turno — 1 mana."))
 assert(m.history.any(func(entry): return "castelo inimigo" in entry))
 assert(m.history_sides.size()==m.history.size())
 var enemy=Match.new([],[],1)
 assert(enemy.history.has("Turno da IA — 1 mana."))
 assert(enemy.history_sides[enemy.history.find("Turno da IA — 1 mana.")]==1)
 enemy.players[0].board.clear()
 var attacker=enemy.spawn_unit(1,"wolf")
 attacker.ready=true
 assert(enemy.act(1,0,-1))
 assert(enemy.history.any(func(entry): return "ataca o castelo aliado" in entry))
 assert(enemy.history_sides.back()==1)
 for i in range(120):m.log_event("Evento %d" % i)
 assert(m.history.size()>120 and m.history.has("Evento 0"))
 var main=load("res://main.tscn").instantiate();main.enable_opening=false;main.muted=true
 root.add_child(main);await process_frame
 assert(main.find_child("MatchLogButton",true,false)!=null)
 main.show_match_log();await process_frame
 assert(main.log_dialog.visible and not main.can_act() and main.log_text.get_parsed_text().length()>0)
 main.log_dialog.hide();main.queue_free();await process_frame
 print("OK: Chama Astral no castelo com Amplificar e histórico completo consultável.")
 quit()
