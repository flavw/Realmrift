extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize():
 var names=["adventure-mimic","adventure-black-dragon","alley_ambush","ash_necromancer","defiled_crypt","crypt_zombie","crypt_sentinel","dwarf_smith","hungry_ghoul","sepulchral_tide","wandering_ogre","rotting_guardian","scarred_troll","restless_skeleton","valeria_implacavel","wastes_bat","wastes_hyena"]
 for key in names:
  var texture=load("res://assets/art/"+key+".webp")
  assert(texture is Texture2D and texture.get_width()>0 and texture.get_height()>0,key)
 for key in ["adventure-items","adventure-farm-banquet","adventure-chest","adventure-power-sanctuary","adventure-opening","adventure-world-map"]:
  var texture=load("res://assets/ui/"+key+".webp")
  assert(texture is Texture2D and texture.get_width()>0 and texture.get_height()>0,key)
 for key in Match.CARD_DATA:
  var card: CardData=Match.CARD_DATA[key]
  assert(card.artwork!=null,"Card sem arte: "+key)
 assert(load("res://adventure.tscn")!=null and load("res://main.tscn")!=null)
 print("OK: 23 artes convertidas, todas as artes de cards e cenas principais carregam.")
 quit()
