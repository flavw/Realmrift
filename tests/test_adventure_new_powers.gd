extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
const Match=preload("res://scripts/match.gd")
func game(powers: Array,opening: bool=false,side: int=0) -> DuelMatch:
 return Match.new(Match.default_deck(0),Match.default_deck(1),side,opening,{"enabled":true,"powers":powers})
func clear(m: DuelMatch) -> void:
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 for key in ["all_trample","first_three_keywords","bonus_spell","starting_allies","castle_armor"]:assert(State.POWERS.has(key))
 for first_side in [0,1]:
  var m=game(["starting_allies","bonus_spell","all_trample","first_three_keywords"],true,first_side)
  assert(m.players[0].board.is_empty() and not m.adventure_opening_applied)
  while m.opening:
   for side in [0,1]:
    if not m.mulligan_done[side]:assert(m.mulligan(side,[]))
  assert(m.adventure_opening_applied and m.players[0].board.size()==2)
  assert(m.players[0].board.all(func(u):return Match.CARD_DATA[u.key].cost==1 and u.trample))
  assert(m.adventure_creatures_played==0 and m.players[1].board.is_empty())
  assert(m.players[0].hand.size()==5)
  var hand_size: int=m.players[0].hand.size()
  m.apply_adventure_opening_powers()
  assert(m.players[0].hand.size()==hand_size and m.players[0].board.size()==2)
  assert(m.players[0].hand.any(func(key):return Match.CARD_DATA[key].card_type==CardData.CardType.SPELL))
 var m=game(["all_trample","first_three_keywords"]);clear(m)
 var immediate=game(["starting_allies","bonus_spell"])
 assert(immediate.adventure_opening_applied and immediate.players[0].board.size()==2 and immediate.players[0].hand.size()==5)
 # Spawned companions don't consume the three cards played from hand.
 var token=m.spawn_unit(0,"farmer");assert(token.trample and m.adventure_creatures_played==0)
 for i in range(4):
  m.players[0].hand=["squire"];m.players[0].mana=10
  assert(m.play(0,0))
  var unit: Dictionary=m.players[0].board.back()
  assert(unit.trample)
  if i<3:
   assert(unit.has("adventure_keyword"))
   var keyword: String=unit.adventure_keyword
   var card: CardData=m.card_for_unit(unit)
   if keyword=="antimagic":
    assert(m.antimagic_capacity(unit)==1 and card.antimagic==1)
    unit.antimagic=0;m.begin_turn();assert(unit.antimagic==1)
   elif keyword=="envenom":assert(unit.envenom==1 and card.envenom==1)
   else:assert(unit[keyword] and card.get(keyword))
  else:assert(not unit.has("adventure_keyword"))
 assert(m.adventure_creatures_played==3)
 assert(not m.spawn_unit(1,"squire").trample and not Match.CARD_DATA.squire.trample)
 m=game(["all_trample"]);clear(m)
 var collective=m.spawn_unit(0,"peasant_uprising");m.refresh_auras();assert(collective.trample and m.card_for_unit(collective).trample)
 m=game(["castle_armor"]);clear(m)
 var attacker=m.spawn_unit(1,"warrior");attacker.ready=true;attacker.attack=3;m.turn=1
 assert(m.attack_forecast(1,0,-1).damage==2)
 assert(m.act(1,0,-1) and m.players[0].hp==18 and m.last_action.amount==2)
 attacker.ready=true;attacker.attack=1
 assert(m.act(1,0,-1) and m.players[0].hp==18 and m.last_action.amount==0)
 m.players[1].board.clear();attacker=m.spawn_unit(1,"mage");attacker.ready=true;attacker.magic_damage=2
 assert(m.act(1,0,-1,true) and m.players[0].hp==16)
 m.players[0].deck.clear();m.draw(0);assert(m.players[0].hp==15)
 m=game(["castle_armor"]);clear(m)
 attacker=m.spawn_unit(1,"warrior");attacker.ready=true;attacker.attack=6;attacker.trample=true
 var defender=m.spawn_unit(0,"farmer");defender.health=2;defender.armor=0;defender.block=0;m.turn=1
 assert(m.attack_forecast(1,0,0).castle_damage==3)
 assert(m.act(1,0,0) and m.players[0].hp==17 and m.last_action.castle_damage==3)
 var normal=Match.new([],[],0,false,{"powers":["starting_allies","bonus_spell","castle_armor","all_trample"]})
 assert(normal.players[0].armor==0 and normal.players[0].board.is_empty() and not normal.spawn_unit(0,"squire").trample)
 assert(Match.CARD_DATA.antimagic_guardian.ability_entries().any(func(e):return e.name.contains("Antimagia")))
 var run=State.new();run.phase="map";run.powers=["castle_armor"];State.current=run
 var view=load("res://adventure.tscn").instantiate();root.add_child(view)
 assert(view.find_child("AdventureGoldIcon",true,false)!=null)
 await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("res://.local/adventure-gold-map.png")
 view.queue_free();await process_frame;State.current=null
 var main=load("res://main.tscn").instantiate();main.enable_opening=false;main.starting_player=0;root.add_child(main)
 main.duel=game(["castle_armor","all_trample","starting_allies"]);main.redraw()
 assert(main.find_child("CastleArmor",true,false)!=null)
 await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("res://.local/adventure-opening-powers.png")
 for p in main.sounds.values():p.stop();p.stream=null
 main.queue_free();await process_frame;await process_frame
 print("OK: cinco poderes, abertura com/sem mulligan, três cartas da mão, bônus visíveis, Atropelar, armadura física/fadiga/magia, ícone de ouro e isolamento do duelo normal")
 quit()
