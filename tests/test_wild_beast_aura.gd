extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _initialize():call_deferred("verify")
func verify():
 var data=Match.CARD_DATA.wild_beast_druid
 var boar_data=Match.CARD_DATA.wild_swift_boar
 assert(data.cost==3 and data.attack==1 and data.health==3 and data.aura_targets==CardData.AuraTargets.ALLIED_BEASTS)
 assert(data.aura_summary()=="Feras: ataque +1" and data.ability_entries().any(func(e):return e.name=="Aura"))
 assert(boar_data.cost==3 and boar_data.attack==3 and boar_data.health==2 and boar_data.creature_type==CardData.CreatureType.BEAST and boar_data.swift)
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10
 var wolf=m.spawn_unit(0,"wolf")
 var farmer=m.spawn_unit(0,"farmer")
 var enemy_wolf=m.spawn_unit(1,"wolf")
 var source=m.spawn_unit(0,"wild_beast_druid")
 assert(Match.attack_value(wolf)==Match.CARD_DATA.wolf.attack+1)
 assert(Match.attack_value(farmer)==Match.CARD_DATA.farmer.attack and Match.attack_value(source)==1 and Match.attack_value(enemy_wolf)==Match.CARD_DATA.wolf.attack)
 var second=m.spawn_unit(0,"wild_beast_druid")
 assert(Match.attack_value(wolf)==Match.CARD_DATA.wolf.attack+2)
 source.health=0;m.remove_dead();m.refresh_auras()
 assert(Match.attack_value(wolf)==Match.CARD_DATA.wolf.attack+1)
 second.health=0;m.remove_dead();m.refresh_auras()
 assert(Match.attack_value(wolf)==Match.CARD_DATA.wolf.attack)
 m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10
 m.players[0].hand=["wild_swift_boar"]
 assert(m.play(0,0) and m.players[0].board[0].ready)
 assert(m.can_target(0,0,-1,false) and m.act(0,0,-1) and m.players[1].hp==17)
 assert(Store.accepts_base(CardData.Faction.WILD,["wild_beast_druid","wild_swift_boar","messenger_hawk"]))
 var editor=load("res://deck_editor.tscn").instantiate();editor.configure(Store.new("user://beast_test.json",false));root.add_child(editor);await process_frame
 editor.choose_slot(6);assert(editor.collection_keys().has("wild_beast_druid") and editor.collection_keys().has("wild_swift_boar"))
 editor.queue_free();await process_frame
 print("OK: Aura apenas em Feras aliadas, acúmulo e saída; Disparada, coleção e composição.")
 quit()
