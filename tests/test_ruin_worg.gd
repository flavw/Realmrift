extends SceneTree
const Match=preload("res://scripts/match.gd")
const State=preload("res://scripts/adventure_state.gd")
const Profile=preload("res://scripts/adventure_profile.gd")
const SkinTest=preload("res://scripts/card_skin.gd")
func _initialize():
 var card:CardData=Match.CARD_DATA.ruin_worg
 assert(card.cost==3 and card.attack==2 and card.health==3 and card.faction==CardData.Faction.RUIN and card.creature_type==CardData.CreatureType.BEAST and card.mount_attack==1)
 assert(card.ability_entries().any(func(e):return e.get("badge","")=="Mount") and SkinTest.texture("mount-icon")!=null)
 assert(not State.POWERS.starting_allies.description.contains("Dons"))
 for side in [0,1]:
  var m=Match.new();for p in m.players:p.board.clear();p.mana=10
  m.turn=side
  var w=m.spawn_unit(side,"ruin_worg");w.ready=true
  m.spawn_unit(1-side,"farmer")
  assert(Match.attack_value(w)==2)
  var right=m.spawn_unit(side,"farmer");assert(Match.attack_value(w)==3)
  var other=m.spawn_unit(side,"farmer");assert(Match.attack_value(w)==3)
  m.players[side].board.erase(right);m.refresh_auras();assert(Match.attack_value(w)==3)
  m.players[side].board.erase(other);m.refresh_auras();assert(Match.attack_value(w)==2)
  m.players[side].board.insert(0,right);m.refresh_auras();assert(Match.attack_value(w)==3)
  m.players[side].board.insert(2,other);m.refresh_auras();assert(Match.attack_value(w)==3)
  right.health=0;other.health=0;m.refresh_auras();assert(Match.attack_value(w)==2)
  right.health=1;other.health=1;m.refresh_auras();w.ready=true
  assert(m.can_target(side,1,-1) and m.act(side,1,-1) and m.players[1-side].hp==17)
 assert(Profile.xp_cost(1)==5 and Profile.xp_cost(2)==8 and Profile.xp_cost(5)==23)
 print("OK: Montaria, vizinhança em ambos os lados, combate e progressão.")
 quit()
