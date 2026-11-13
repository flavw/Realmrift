extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 assert(not Match.CARD_DATA["rift_champion"].collectible and not Match.CARD_DATA["adventure_mimic"].collectible)
 var run=State.new();run.deck=Match.default_deck(0);run.encounter="mimic";run.in_combat=true
 var m=Match.new(run.deck,[],1,true,run.rules())
 assert(m.players[1].mana==0 and m.players[1].hand.count("wild_roots")==3 and m.players[1].hand.count("horde_roar")==2)
 var boss: Dictionary=m.players[1].board[0]
 assert(boss.attack==1 and boss.fury==1 and boss.block==0 and m.block_capacity(boss)==0 and boss.regeneration==0)
 assert(m.mulligan(0,[]) and m.mulligan(1,[]))
 assert(m.players[1].mana==0 and m.players[1].temporary_mana==0)
 for expected in [1,2,3,3,3]:
  assert(m.end_turn(1) and m.end_turn(0))
  assert(m.players[1].mana==expected and m.players[1].max_mana==expected)
 assert(m.players[1].hand.size()==5 and m.players[1].deck.is_empty() and m.players[1].fatigue==0)
 m.turn=0;m.spawn_unit(0,"warrior").ready=true
 assert(m.preferred_attack_target(0,0)==0 and not m.can_target(0,0,-1))
 m.turn=1;m.players[1].mana=3
 assert(m.can_cast(1,0,0,0) and m.cast(1,0,0,0))
 assert(m.players[0].board[0].rooted and m.players[1].hand.count("wild_roots")==2)
 m.players[1].mana=3
 assert(m.cast(1,m.players[1].hand.find("horde_roar"),1,-1))
 assert(Match.physical_attack(boss)>1)
 m.players[1].mana=1
 assert(m.fury(1,0))
 assert(m.players[1].hand.size()==3)
 State.current=run
 var main=load("res://main.tscn").instantiate();main.starting_player=0;main.muted=true;root.add_child(main)
 await process_frame;await process_frame
 assert(main.find_child("EnemyCastle",true,false)==null)
 assert(main.find_child("CreatureBossObjective",true,false)!=null)
 assert(main.find_child("MimicManaReserve",true,false).find_child("ManaGems",true,false).get_child_count()==3)
 var art=main.field_nodes[1][main.duel.creature_boss_id]
 assert(art.get_global_rect().get_center().x>800 and art.get_global_rect().get_center().x<1100)
 assert(art.custom_minimum_size.x>224)
 main.finish_mulligan([])
 await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":get_root().get_texture().get_image().save_png("res://.local/mimic-central.png")
 main.queue_free();await process_frame;await process_frame
 State.current=null
 print("OK: mímico 1/Fúria 1, sem Bloqueio ou castelo, mão fixa, mana 0–3 e alvo automático central")
 quit()



