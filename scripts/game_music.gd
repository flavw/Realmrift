extends Node

signal audio_settings_changed
var muted:=false
var music_volume: float=1.0
var effects_volume: float=1.0
const SETTINGS_PATH="user://audio_settings.cfg"
var player: AudioStreamPlayer
static var current: Node
const MENU_TRACK="res://assets/audio/aldeia_ao_amanhecer.ogg"
const COMBAT_TRACK="res://assets/audio/chariots_of_war.ogg"
var track: String=MENU_TRACK

static func ensure(tree: SceneTree) -> Node:
 var singleton=tree.root.get_node_or_null("GameMusic")
 if is_instance_valid(singleton):return singleton
 # Custom SceneTree test runners do not initialize project autoloads.
 if not is_instance_valid(current):
  current=load("res://scripts/game_music.gd").new()
  current.name="GameMusic"
  tree.root.add_child.call_deferred(current)
 return current

func _ready() -> void:
 if Engine.is_editor_hint():return
 load_settings()
 player=AudioStreamPlayer.new()
 player.name="BackgroundMusic"
 var stream: AudioStream=load(track)
 if stream is AudioStreamOggVorbis:
  (stream as AudioStreamOggVorbis).loop=true
 elif stream is AudioStreamMP3:
  (stream as AudioStreamMP3).loop=true
 player.stream=stream
 player.volume_db=volume_db(music_volume,-19.0)
 add_child(player)
 if not muted and DisplayServer.get_name()!="headless":player.play()
 player.stream_paused=muted

func set_track(value: String) -> void:
 if value==track and is_instance_valid(player) and player.stream!=null:
  return
 track=value
 if not is_instance_valid(player):
  return
 var was_playing: bool=player.playing
 player.stop()
 var stream: AudioStream=load(track)
 if stream is AudioStreamOggVorbis:
  (stream as AudioStreamOggVorbis).loop=true
 elif stream is AudioStreamMP3:
  (stream as AudioStreamMP3).loop=true
 player.stream=stream
 if was_playing and not muted and DisplayServer.get_name()!="headless":player.play()

func play_menu() -> void:
 set_track(MENU_TRACK)

func play_combat() -> void:
 set_track(COMBAT_TRACK)

func set_muted(value: bool) -> void:
 muted=value
 if is_instance_valid(player):
  if not value and not player.playing and DisplayServer.get_name()!="headless":player.play()
  player.stream_paused=value

static func volume_db(value: float, base: float) -> float:
 return -80.0 if value<=0.001 else base+linear_to_db(clampf(value,0.0,1.0))

func load_settings() -> void:
 var config:=ConfigFile.new()
 if config.load(SETTINGS_PATH)!=OK:return
 music_volume=clampf(float(config.get_value("audio","music",1.0)),0.0,1.0)
 effects_volume=clampf(float(config.get_value("audio","effects",1.0)),0.0,1.0)

func save_settings() -> void:
 var config:=ConfigFile.new()
 config.set_value("audio","music",music_volume)
 config.set_value("audio","effects",effects_volume)
 config.save(SETTINGS_PATH)

func set_music_volume(value: float) -> void:
 music_volume=clampf(value,0.0,1.0)
 if is_instance_valid(player):player.volume_db=volume_db(music_volume,-19.0)
 save_settings()
 audio_settings_changed.emit()

func set_effects_volume(value: float) -> void:
 effects_volume=clampf(value,0.0,1.0)
 save_settings()
 audio_settings_changed.emit()

func _exit_tree() -> void:
 if is_instance_valid(player):
  player.stream_paused=false
  player.stop()
  player.stream=null
 if current==self:current=null
