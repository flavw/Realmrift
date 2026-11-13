extends SceneTree
const Adventure = preload("res://scripts/adventure_state.gd")
func _initialize() -> void:
 var run = Adventure.new()
 var sorted_curve: Array=run.draft_curve.duplicate()
 sorted_curve.sort()
 assert(sorted_curve==Adventure.CURVE)
 var orders: Array=[]
 for seed_value in range(5):
  run.rng.seed=seed_value
  orders.append(run.shuffled(Adventure.CURVE))
 assert(orders.any(func(order):return order!=orders[0]))
 for faction in [0,1,3,4,5,6]:
  run.faction = faction
  run.deck.clear()
  for i in range(15):
   var options: Array = run.draft_options()
   assert(options.size() == 3)
   assert(options[0] != options[1] and options[1] != options[2] and options[0] != options[2])
   for key in options:
    var card = DuelMatch.CARD_DATA[key]
    assert(card.faction == faction or card.faction == CardData.Faction.VILLAGER)
   run.deck.append(options[0])
  assert(run.draft_options().is_empty())
 var choices: Array = run.power_options()
 assert(choices.size() == 3)
 run.powers.append_array(choices)
 assert(run.power_options().size() == mini(3,Adventure.POWERS.size()-choices.size()))
 print("OK: recrutamento inicial e opções de poderes")
 quit()

