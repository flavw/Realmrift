extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func unit(key: String,id: int) -> Dictionary:
 var u: Dictionary=Match.CARDS[key].duplicate(true)
 u.merge({"key":key,"id":id,"ready":true,"max_health":u.health,"poison":0})
 return u
func settle() -> void:
 for i in range(5):await process_frame
func geometry(main) -> void:
 var footer=main.find_child("BattleFooter",true,false)
 var life=main.find_child("CastleVitals",true,false)
 var mana=main.find_child("ManaReserves",true,false)
 var hand=main.find_child("PlayerHandPanel",true,false)
 assert(life.get_global_rect().end.x<=hand.get_global_rect().position.x)
 assert(hand.get_global_rect().end.x<=mana.get_global_rect().position.x)
 assert(footer.get_global_rect().end.x<=root.get_visible_rect().size.x and footer.get_global_rect().end.y<=root.get_visible_rect().size.y)
 for side in range(2):
  for field in main.field_nodes[side].values():
   var canvas=field.get_node("Canvas")
   assert(canvas.scale.x*200>=224,"Cartas em campo devem ser maiores que os antigos 176")
   assert(field.get_global_rect().end.y<footer.get_global_rect().position.y)
func verify() -> void:
 var main=load("res://main.tscn").instantiate();main.enable_opening=false;main.muted=true;root.add_child(main)
 main.duel.players[0].board=[unit("dawn_warden",1),unit("wolf",2),unit("village_leader",3),unit("squire",4),unit("moon_herald",5)]
 main.duel.players[1].board=[unit("lightning_rogue",11),unit("raven",12),unit("aether_summoner",13),unit("runic_familiar",14),unit("abascanto_guardian",15)]
 main.duel.players[0].hand=["squire","squire","mage","mage","wolf","wolf","fireball","fireball"]
 main.duel.players[0].mana=10;main.duel.players[0].max_mana=10;main.duel.players[0].hp=15
 main.redraw();await settle();geometry(main)
 var aura_source=main.field_nodes[0][3].get_node("Canvas/StatusIcons")
 assert(aura_source.has_node("Aura") and not aura_source.has_node("AuraBonus"))
 assert(not main.field_nodes[0][2].get_node("Canvas/StatusIcons").has_node("Aura"))
 assert(not main.field_nodes[0][5].get_node("Canvas/StatusIcons").has_node("Entry"))
 assert(not main.field_nodes[1][11].get_node("Canvas/StatusIcons").has_node("Swift"))
 main.select(0);await settle();geometry(main)
 assert(not main.find_child("EnemyCastle",true,false).disabled and main.find_child("PlayerCastle",true,false).disabled)
 main.select_heal();await settle();geometry(main)
 assert(not main.find_child("PlayerCastle",true,false).disabled and main.find_child("EnemyCastle",true,false).disabled)
 assert(main.find_child("PlayerMana",true,false).find_child("ManaCounter",true,false).text=="10 / 10")
 main.duel.players[0].poison=4;main.duel.players[1].poison=3;main.redraw();await settle();geometry(main)
 main.queue_free();await process_frame;await create_timer(0.35).timeout
 print("OK: rodapé vida/esquerda e mana/direita, mão de 8 cartas sem overflow, campo ampliado, ícones persistentes e alvos dos castelos.")
 quit()
