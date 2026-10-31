extends SceneTree
const Match=preload("res://scripts/match.gd")
class FastCombat:
 extends "res://scripts/main.gd"
 var played_actions: Array=[]
 func animate_action(action: Dictionary,_snapshot: Array) -> void:
  played_actions.append(action.duplicate(true))
  await get_tree().process_frame

func _initialize() -> void:call_deferred("verify")
func unit(key: String,id: int,ready: bool=true) -> Dictionary:
 var u: Dictionary=Match.CARDS[key].duplicate(true)
 u.merge({"key":key,"id":id,"ready":ready,"max_health":u.health,"poison":0})
 return u
func fixture():
 var m=Match.new()
 for p in m.players:p.board=[];p.hand=[];p.deck=["squire","wolf"];p.mana=5;p.max_mana=5;p.hp=20
 return m
func verify() -> void:
 var m=fixture()
 m.players[0].board=[unit("squire",1),unit("raven",2),unit("mage",3),unit("village_wall",4),unit("wolf",5,false)]
 m.players[1].board=[unit("squire",11),unit("wolf",12)]
 assert(m.preferred_attack_target(0,0)==0 and m.preferred_attack_target(0,1)==-1)
 for index in [2,3,4]:assert(m.preferred_attack_target(0,index)==-2)
 m.players[1].board[0].block=0
 assert(m.preferred_attack_target(0,0)==-1)
 var main=load("res://main.tscn").instantiate();main.set_script(FastCombat);main.enable_opening=false;main.muted=true;root.add_child(main)
 main.duel=fixture();var guard=unit("squire",21);guard.attack=3
 main.duel.players[0].board=[unit("squire",1),unit("warrior",2),unit("raven",3),unit("wolf",4,false)]
 main.duel.players[1].board=[guard]
 main.casting=-1;main.selected=0;main.redraw()
 for i in range(4):await process_frame
 assert(not main.find_child("AttackAll",true,false).disabled)
 await main.attack_all()
 assert(main.played_actions.size()==3 and main.played_actions[0].target==21 and main.played_actions[1].castle and main.played_actions[2].castle)
 assert(main.duel.players[0].board.size()==3 and main.duel.players[1].hp==15 and guard.health==1 and guard.block==0)
 assert(main.duel.players[0].mana==5 and main.duel.turn==0 and not main.busy)
 assert(not main.duel.players[0].board[0].ready and not main.duel.players[0].board[1].ready and not main.duel.players[0].board[2].ready)
 # No automatic magical shot, Fury or second attack after a victory.
 main.duel=fixture();main.duel.players[0].board=[unit("mage",1)];main.redraw()
 assert(not main.can_attack_all() and main.find_child("AttackAll",true,false).disabled)
 main.duel.players[0].board=[unit("raven",1),unit("wolf",2)];main.duel.players[1].hp=2
 main.played_actions.clear();main.redraw();await main.attack_all()
 assert(main.duel.winner==0 and main.played_actions.size()==1 and main.duel.players[0].board[1].ready and main.duel.players[0].mana==5 and not main.busy)
 # One persistent soundtrack, compressed stream, looping and following the sound setting.
 var music=main.music.player
 assert(music!=null and music.stream is AudioStreamOggVorbis and music.stream.loop)
 assert(music.stream.resource_path=="res://assets/audio/chariots_of_war.ogg")
 assert(main.music.muted and (music.stream_paused or not music.playing))
 main.toggle_sound();assert(not main.music.muted and not music.stream_paused)
 main.restart();assert(main.music.player==music and main.music.get_child_count()==1)
 main.toggle_sound();assert(main.music.muted and (music.stream_paused or not music.playing))
 assert(main.find_child("PlayerCastle",true,false).get_node("CastleArtwork").texture.resource_path=="res://assets/art/castle_player_wide.webp")
 assert(main.find_child("EnemyCastle",true,false).get_node("CastleArtwork").texture.resource_path=="res://assets/art/castle_enemy_wide.webp")
 main.queue_free();await process_frame;await create_timer(0.35).timeout
 # One short real-animation check for the new sequence, rather than many animation runs.
 if OS.get_environment("VERIFY_ATTACK_ANIMATION")=="1":
  var live=load("res://main.tscn").instantiate();live.enable_opening=false;live.muted=true;root.add_child(live)
  live.duel=fixture();live.duel.players[0].board=[unit("warrior",31),unit("raven",32)];live.redraw()
  for i in range(4):await process_frame
  await live.attack_all()
  assert(live.duel.players[1].hp==15 and not live.busy and live.duel.turn==0)
  live.queue_free();await process_frame;await create_timer(0.35).timeout
 print("OK: ataque em grupo com prioridade/Block/Voo, mortes e índices, vitória, sem gastos extras; castelos e música de combate única em loop/mute.")
 quit()

