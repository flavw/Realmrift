extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _initialize() -> void:call_deferred("verify")
func fixture():
 var m=Match.new()
 for p in m.players:p.board=[];p.hand=[];p.deck=["squire","wolf"];p.mana=10;p.max_mana=10;p.hp=20
 m.next_id=100
 return m
func settle() -> void:
 for i in range(5):await process_frame
func click(node: Control,double: bool=false) -> void:
 var event:=InputEventMouseButton.new();event.position=node.get_global_rect().get_center();event.button_index=MOUSE_BUTTON_LEFT;event.pressed=true;event.double_click=double
 root.push_input(event,true);event.pressed=false;root.push_input(event,true)
func verify() -> void:
 assert(Match.MAX_BOARD==6 and Match.CARD_DATA.dawn_warden.block==3)
 var m=fixture()
 for i in range(5):m.spawn_unit(0,"farmer")
 m.players[0].hand=["squire","wolf"]
 assert(m.can_play(0,0) and m.play(0,0) and m.players[0].board.size()==6)
 assert(not m.can_play(0,0) and m.spawn_unit(0,"wolf").is_empty())
 for initial_count in [4,5]:
  m=fixture()
  for i in range(initial_count):m.spawn_unit(0,"farmer")
  m.players[0].hand=["aether_summoner"];assert(m.play(0,0) and m.players[0].board.size()==6)
  assert(m.players[0].board.count(m.players[0].board[-1])==1)
 m=fixture();m.turn=1
 for i in range(5):m.spawn_unit(1,"farmer")
 m.players[1].hand=["wolf","wolf"]
 assert(m.ai_step() and m.players[1].board.size()==6 and m.players[1].hand.size()==1)
 assert(not m.ai_step())
 # Both sides observe every effective healing event, once regardless of amount.
 m=fixture();var a=m.spawn_unit(0,"dawn_devotee");var b=m.spawn_unit(0,"dawn_devotee")
 var healer=m.spawn_unit(0,"cleric");healer.ready=true;m.players[0].hp=16
 assert(m.heal(0,2,-1) and a.attack==2 and a.health==5 and b.attack==2)
 var enemy=m.spawn_unit(1,"dawn_devotee");m.turn=1;m.players[1].hp=15;m.players[1].hand=["restoring_light"]
 assert(m.cast(1,0,1,-1) and a.attack==3 and b.attack==3 and enemy.attack==2 and enemy.health==5)
 m.players[1].hp=20;m.players[1].hand=["village_reconstruction"]
 assert(m.cast(1,0,1,-1) and enemy.attack==2 and a.attack==3 and not m.last_action.has("devotion_buffs"))
 m=fixture();a=m.spawn_unit(0,"dawn_devotee");m.players[0].hand=["generous_peasant"];assert(m.play(0,0) and a.attack==1 and a.health==5)
 m.spawn_unit(0,"farmer");m.begin_turn();assert(a.attack==1 and a.health==5)
 var mob=m.spawn_unit(0,"peasant_uprising");assert(mob.devotion==0)
 var before: int=mob.attack;m.turn=1;m.players[1].hp=16;m.players[1].hand=["restoring_light"]
 assert(m.cast(1,0,1,-1) and mob.attack==before and a.attack==2)
 # Real editor clicks: first locate, second remove; a different row resets the choice.
 var editor=load("res://deck_editor.tscn").instantiate();editor.configure(Store.new("user://unused_six_field_editor.json",false));root.add_child(editor)
 editor.choose_slot(0);await settle();var before_count: int=editor.draft.count("squire")
 click(editor.find_child("DeckCard_squire",true,false));await settle()
 assert(editor.focused_card=="squire" and editor.draft.count("squire")==before_count)
 click(editor.find_child("DeckCard_squire",true,false));await settle();assert(editor.draft.count("squire")==before_count-1)
 click(editor.find_child("DeckCard_wolf",true,false));await settle()
 click(editor.find_child("DeckCard_squire",true,false));await settle();assert(editor.draft.count("squire")==before_count-1)
 editor.show_library();await settle();click(editor.find_child("DeckTile2",true,false));await settle()
 assert(editor.screen=="library" and editor.library_selected==1)
 click(editor.find_child("DeckTile2",true,false));await settle();assert(editor.screen=="edit" and editor.slot==1)
 editor.show_library();await settle();click(editor.find_child("DeckTile3",true,false),true);await settle();assert(editor.screen=="edit" and editor.slot==2)
 editor.show_library();await settle();click(editor.find_child("DeckTile9",true,false));await settle();click(editor.find_child("DeckTile9",true,false));await settle();assert(editor.screen=="choose_class" and editor.slot==8)
 editor.queue_free();await process_frame
 var main=load("res://main.tscn").instantiate();main.enable_opening=false;main.muted=true;root.add_child(main)
 main.duel=fixture()
 for side in range(2):
  for i in range(6):main.duel.spawn_unit(side,"farmer")
 main.duel.players[0].hand=["wolf","wolf","mage","mage","squire","squire","fireball","fireball"]
 main.redraw();await settle()
 for name in ["PlayerBattlefield","EnemyBattlefield"]:assert(main.find_child(name,true,false).get_child_count()==6)
 for name in ["PlayerCastle","EnemyCastle"]:
  var castle=main.find_child(name,true,false);var artwork=castle.get_node("CastleArtwork")
  assert(artwork.size.x>artwork.size.y*2 and castle.get_node("CastleLife").text=="20")
 assert(main.find_child("BattleFooter",true,false).get_global_rect().end.x<=root.get_visible_rect().size.x)
 main.queue_free();await process_frame;await create_timer(0.35).timeout
 print("OK: limite 6, invocação/IA, Aurora sem Bloqueio, Devoção global sem falsos gatilhos, herança, dois cliques e castelos largos.")
 quit()
