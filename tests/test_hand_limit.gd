extends SceneTree
const Match=preload("res://scripts/match.gd")
func _init() -> void:
 var m=Match.new()
 m.players[0].hand=["wolf","wolf","wolf","wolf","wolf","wolf"]
 m.players[0].deck=["squire","squire"]
 m.draw(0)
 assert(m.players[0].hand.size()==6 and m.players[0].deck.size()==1)
 m.draw(0)
 assert(m.players[0].hand.size()==6 and m.players[0].deck.is_empty())
 assert(m.history.back().contains("mão cheia"))
 assert(m.draw_events.back().destroyed and m.draw_events.back().key=="squire")
 m.draw(0)
 assert(m.players[0].hp==19)
 m=Match.new()
 m.draw_events.clear()
 m.players[1].hand=["wolf","wolf","wolf","wolf","wolf"]
 m.players[1].deck=["squire","squire"]
 m.draw(1)
 assert(m.players[1].hand.size()==6 and not m.draw_events.back().get("destroyed",false))
 m.draw(1)
 assert(m.players[1].hand.size()==6 and m.draw_events.back().destroyed)
 print("OK: limite de seis cartas, descarte e fadiga.")
 quit()
