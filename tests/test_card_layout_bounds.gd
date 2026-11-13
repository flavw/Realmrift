extends SceneTree
const Match=preload("res://scripts/match.gd")
const CardScene=preload("res://card_model.tscn")
func _initialize() -> void:call_deferred("verify")

func check_bounds(card: Control) -> void:
 var rules: Control=card.get_node("CardCanvas/Ability")
 var fade: Control=card.get_node("CardCanvas/RulesPanel")
 var kind: Control=card.get_node("CardCanvas/TypeLabel")
 assert(rules.position.y>=80 and rules.get_rect().end.y<=452.1,card.card_data.title+": regras fora do card")
 assert(fade.position.y>=5 and fade.get_rect().end.y<=475.1,card.card_data.title+": degradê fora do card")
 assert(kind.position.y>=5 and kind.get_rect().end.y<=rules.position.y,card.card_data.title+": tipo fora do lugar")
 assert(card.get_node("CardCanvas").clip_contents)

func verify() -> void:
 var keys=["magic_missiles","astral_flame","aether_summoner","conductive_bolt","adventure_black_dragon","alley_ambush"]
 for key in keys:
  var card=CardScene.instantiate();card.card_data=Match.CARD_DATA[key];root.add_child(card)
  for size in [Vector2(192,256),Vector2(220,294),Vector2(355,474)]:
   card.size=size
   for repeat in range(3):
    card.refresh();check_bounds(card)
    await process_frame;check_bounds(card)
  card.queue_free();await process_frame
 var duel=Match.new([],[],1,true)
 duel.players[0].hand.assign(keys.slice(0,4))
 var view=load("res://scripts/mulligan_view.gd").new();view.configure(duel);root.add_child(view)
 for selected in [2,0,2]:
  view.toggle_card(selected)
  for card in view.find_children("CardModel","",true,false):check_bounds(card)
  await process_frame;await process_frame
  for card in view.find_children("CardModel","",true,false):check_bounds(card)
 view.queue_free();await process_frame
 print("OK: regras, tipo e degradê contidos nos cards, inclusive ao reconstruir o mulligan e redimensionar a mão")
 quit()
