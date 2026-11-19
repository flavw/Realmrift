extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func shortcut(ctrl: bool=true,shift: bool=true) -> InputEventKey:
 var event:=InputEventKey.new();event.keycode=KEY_F10;event.pressed=true;event.ctrl_pressed=ctrl;event.shift_pressed=shift
 return event
func cleanup_audio(main) -> void:
 for player in main.sounds.values():player.stop();player.stream=null
func verify() -> void:
 preload("res://scripts/adventure_save.gd").enabled=false
 var run=State.new();run.deck=Match.default_deck(0).slice(0,15);run.phase="map";run.step=6;State.current=run
 var view=load("res://adventure.tscn").instantiate();root.add_child(view)
 await process_frame;await process_frame;await process_frame
 var found: Dictionary={"shop":false,"healer":false}
 for at in range(run.route_rows.size()):
  for branch in range(run.route_rows[at].size()):
   var kind: String=run.route_rows[at][branch].kind
   if kind not in found:continue
   var art=view.find_child("Route_%d_%d" % [at,branch],true,false).get_child(0)
   assert(art.texture.resource_path==(State.merchant_at(at).art if kind=="shop" else "res://assets/ui/adventure-healer-icon.svg"))
   found[kind]=true
 assert(found.shop and found.healer)
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("res://.local/adventure-services-map.png")
 view.queue_free();await process_frame;State.current=null
 var main=load("res://main.tscn").instantiate();main.enable_opening=false;main.starting_player=0;root.add_child(main)
 main._input(shortcut(false,true));main._input(shortcut(true,false))
 assert(main.duel.winner==-1)
 main.set_busy(true);main._input(shortcut());assert(main.duel.winner==-1)
 main.set_busy(false);main._input(shortcut())
 assert(main.duel.winner==0 and main.duel.players[1].hp==0 and main.result_shown)
 assert(not main.playtest_win())
 cleanup_audio(main);main.queue_free();await process_frame;await process_frame
 for encounter in ["mimic","black_dragon"]:
  run=State.new();run.deck=Match.default_deck(0).slice(0,15);run.enemy=Match.default_deck(1);run.step=State.STAGES.size()-1 if encounter=="black_dragon" else State.STAGES.find("power_event");run.current_life=8;run.encounter=encounter;run.phase="combat";run.in_combat=true;State.current=run
  main=load("res://main.tscn").instantiate();main.starting_player=0;root.add_child(main)
  assert(main.duel.opening and main.mulligan_layer!=null)
  var boss: int=main.duel.creature_boss_id
  main._input(shortcut())
  assert(main.duel.winner==0 and not main.duel.opening and main.mulligan_layer==null)
  assert(not main.duel.players[1].board.any(func(unit):return unit.id==boss))
  assert(run.phase=="reward" and not run.in_combat and run.current_life==12 and run.options.size()==3)
  assert(run.gold==(5 if encounter=="mimic" else 2))
  var gold: int=run.gold
  main._input(shortcut());assert(run.gold==gold)
  cleanup_audio(main);main.queue_free();await process_frame;await process_frame
  if current_scene:
   current_scene.queue_free();await process_frame;await process_frame
  State.current=null
 print("OK: ícones de curandeira/mercador; Ctrl+Shift+F10 vence duelo, mímico e dragão e segue recompensas sem duplicar")
 quit()
