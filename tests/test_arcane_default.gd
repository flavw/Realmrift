extends SceneTree
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var main=load("res://main.tscn").instantiate();main.enable_opening=false
 root.add_child(main)
 for p in main.duel.players:p.board=[]
 var mage=main.duel.spawn_unit(0,"mage");mage.ready=true;mage.magic_cost=1
 main.duel.players[0].mana=1
 main.select(0)
 assert(main.magic and main.duel.players[0].mana==1 and mage.ready)
 var physical: Button
 for node in main.find_children("*","Button",true,false):
  if node.text=="Ataque físico":physical=node;break
 assert(physical!=null)
 physical.pressed.emit()
 assert(not main.magic)
 main.duel.players[0].mana=0;main.select(0)
 assert(not main.magic)
 mage.magic_cost=0;main.select(0)
 assert(main.magic)
 mage.ready=false;main.select(0)
 assert(not main.magic)
 var texture=load("res://assets/ui/tap-icon.svg")
 assert(texture.get_width()==256 and texture.get_height()==256)
 main.queue_free();await process_frame;await process_frame
 print("OK: Disparo padrão com mana, custo zero, sem mana, esgotamento, alternância física e ampulheta 256px")
 quit()
