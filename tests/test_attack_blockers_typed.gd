extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var game=Match.new()
 for player in game.players:player.board.clear()
 var unit=game.spawn_unit(0,"warrior");unit.ready=true
 var mimic=game.spawn_unit(1,"adventure_mimic");mimic.block=0
 var result: Array[int]=game.attack_blockers(0,0,0)
 assert(result.is_typed() and result.is_empty())
 result=game.attack_blockers(0,-1,0);assert(result.is_typed() and result.is_empty())
 mimic.block=1
 result=game.attack_blockers(0,0,-1);assert(result==[0] and result.is_typed())
 result=game.attack_blockers(0,0,0);assert(result.is_empty() and result.is_typed())
 unit.flying=true;result=game.attack_blockers(0,0,-1);assert(result.is_empty() and result.is_typed())
 unit.flying=false;unit.ready=false;result=game.attack_blockers(0,0,-1);assert(result.is_empty() and result.is_typed())
 var Save=load("res://scripts/adventure_save.gd");Save.enabled=false
 var run=load("res://scripts/adventure_state.gd").new();run.deck=Match.default_deck(0).slice(0,15);run.in_combat=true;run.encounter="mimic";run.phase="combat"
 run.saved_duel=game;load("res://scripts/adventure_state.gd").current=run
 var main=load("res://main.tscn").instantiate();root.add_child(main)
 unit.ready=true;unit.rooted=true;main.selected=0;main.redraw()
 main.notify_blocked_attack(0)
 assert(main.vfx_layer.find_child("FloatingResult",true,false)!=null and not main.busy)
 unit.rooted=false;mimic.block=0
 main.notify_blocked_attack(0)
 assert(not main.busy)
 for player in main.sounds.values():player.stop();player.stream=null
 main.queue_free();await process_frame;await process_frame
 print("OK: retorno Array[int] em todos os caminhos, clique no mímico sem pausa do depurador e aviso de Raízes")
 quit()
