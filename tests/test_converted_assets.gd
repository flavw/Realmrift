extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void: call_deferred("verify")
func verify() -> void:
 for key in Match.CARD_DATA:
  var card: CardData=Match.CARD_DATA[key]
  assert(card.artwork!=null,"Arte ausente: "+key)
  assert(card.artwork.resource_path.ends_with(".webp"),"Formato incorreto: "+key)
 var music=load("res://scripts/game_music.gd").new()
 root.add_child(music)
 music.set_muted(true)
 music.play_combat()
 assert(music.player.stream is AudioStreamOggVorbis)
 assert(music.player.stream.loop and music.player.stream.resource_path.ends_with("chariots_of_war.ogg"))
 for file in DirAccess.get_files_at("res://assets/ui"):
  if file.ends_with(".webp"):assert(load("res://assets/ui/"+file)!=null,"Imagem ausente: "+file)
 music.queue_free()
 print("OK: artes WebP da coleção e interface, música OGG em loop.")
 quit()
