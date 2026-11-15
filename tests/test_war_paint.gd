extends SceneTree
const Match=preload("res://scripts/match.gd")
func fixture():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10;p.hp=20;p.deck=Match.default_deck(0)
 return m
func _initialize():call_deferred("verify")
func verify():
 var card:CardData=Match.CARD_DATA.battle_howl
 assert(card.title=="Pintura de Guerra" and card.cost==2 and card.spell_value==2 and card.spell_effect==CardData.SpellEffect.WAR_PAINT)
 assert(card.ability_entries()[0].name.contains("Impulsivo"))
 for side in [0,1]:
  var m=fixture();m.turn=side
  var ally=m.spawn_unit(side,"farmer");ally.ready=false
  var second=m.spawn_unit(side,"squire");second.ready=false
  var enemy=m.spawn_unit(1-side,"farmer");enemy.ready=false
  m.players[side].hand=["battle_howl"]
  assert(not m.can_cast(side,0,side,-1) and not m.can_cast(side,0,1-side,0) and m.can_cast(side,0,side,0))
  assert(m.cast(side,0,side,0) and ally.attack==3 and ally.impulsive and not ally.ready and second.attack==1 and not second.impulsive and m.players[side].mana==8)
  assert(m.end_turn(side) and m.end_turn(1-side) and ally.attack==3 and ally.impulsive and ally.ready)
  assert(m.end_turn(side) and m.players[1-side].hp==17 and ally.attack==3 and ally.impulsive)
  m=fixture();m.turn=side;ally=m.spawn_unit(side,"farmer");ally.ready=false
  m.players[side].hand=["battle_howl","battle_howl"]
  assert(m.cast(side,0,side,0) and m.cast(side,0,side,0) and ally.attack==5 and ally.impulsive)
  m=fixture();m.turn=side;ally=m.spawn_unit(side,"peasant_uprising")
  m.players[side].hand=["battle_howl"];assert(m.cast(side,0,side,0) and ally.impulsive)
  m.refresh_auras();assert(ally.impulsive and ally.granted_impulsive)
  m=fixture();m.turn=side;ally=m.spawn_unit(side,"goblin_raider");ally.ready=true
  m.players[side].hand=["horde_roar"];assert(m.cast(side,0,side,-1) and not ally.get("granted_impulsive",false) and ally.turn_attack==2)
 var ai=fixture();ai.turn=1;var target=ai.spawn_unit(1,"goblin_raider");target.ready=true;ai.players[1].hand=["battle_howl"]
 assert(ai.ai_spell_target(0)=={"side":1,"index":0} and ai.cast(1,0,1,0) and target.impulsive)
 var field=load("res://field_card.tscn").instantiate();field.card_data=Match.CARD_DATA.farmer
 field.set_meta("ability_context",{"granted_impulsive":true});root.add_child(field);await process_frame
 field.refresh_ability_icons(3,1);assert(field.find_child("Impulsive",true,false)!=null)
 var view=load("res://card_model.tscn").instantiate();view.card_data=Match.CARD_DATA.farmer;view.ability_context={"granted_impulsive":true};root.add_child(view);await process_frame
 assert(view.view_entries().any(func(e):return e.name=="Impulsivo"))
 field.queue_free();view.queue_free();await process_frame
 print("OK: Pintura de Guerra permanente, alvo, custo, repetição, Multidão, UI e IA.")
 quit()
