extends SceneTree
const Match = preload("res://scripts/match.gd")
const Store = preload("res://scripts/deck_store.gd")

func creature(key: String, id: int) -> Dictionary:
 var unit: Dictionary = Match.CARDS[key].duplicate(true)
 unit.merge({"key": key, "id": id, "ready": true})
 return unit

func _init() -> void:
 var m = Match.new()
 m.players[0].mana = 10
 m.players[0].hand = ["lightning_rogue", "raven"]
 m.players[1].board = [creature("squire", 50)]
 assert(m.play(0, 0))
 assert(m.players[0].board[0].ready, "Arrancada entra pronta")
 assert(not m.can_target(0, 0, -1), "Arrancada respeita Bloqueio")
 assert(m.act(0, 0, 0))
 assert(not m.players[0].board[0].ready)
 assert(not m.act(0, 0, -1), "Só pode atacar uma vez")
 assert(m.play(0, 0))
 assert(not m.players[0].board[1].ready, "Voo não concede Arrancada")
 m.players[0].board[1].ready = true
 m.players[1].board = [creature("squire", 51), creature("sentinel", 52)]
 assert(m.can_target(0, 1, -1) and m.can_target(0, 1, 1), "Voo ignora Bloqueio")
 assert(m.act(0, 1, -1))
 assert(m.players[1].hp == 18 and m.players[1].board[0].block == 1)
 m.players[0].board = [creature("fire_mage", 60)]
 m.players[0].mana = 0
 assert(not m.act(0, 0, 1, true), "Feiticeira exige 1 mana")
 m.players[0].mana = 1
 assert(not m.act(0, 0, -1, true))
 assert(m.act(0, 0, 1, true))
 assert(m.players[0].mana == 0 and m.players[0].board[0].health == 3)
 assert(not m.players[0].board[0].ready)
 assert(m.players[1].board[1].health == 1, "2 danos mágicos ignoram Armadura 1")
 assert(m.players[1].board[0].block == 1)
 var decks = Store.new("user://decks_test_expansion.json", false)
 assert(decks.slots.size() == Store.SLOT_COUNT)
 for slot in decks.slots:
  assert(slot.cards.is_empty() or Match.valid_deck(slot.cards))
 var invalid: Array = Match.default_deck()
 invalid[0] = "not_a_card"
 assert(not Match.valid_deck(invalid))
 invalid = ["wolf", "wolf", "wolf"]
 invalid.append_array(Match.default_deck().slice(0, 9))
 assert(not Match.valid_deck(invalid))
 assert(not decks.save_slot(0, "Inválido", invalid))
 assert(decks.save_slot(2, "Meu deck", Match.default_deck(1)))
 assert(decks.activate(2))
 var loaded = Store.new("user://decks_test_expansion.json")
 assert(loaded.active == 2 and loaded.slots[2].name == "Meu deck")
 assert(loaded.active_cards() == Match.default_deck(1))
 var game = Match.new(loaded.active_cards())
 var actual: Array = game.players[0].deck.duplicate()
 actual.append_array(game.players[0].hand)
 actual.sort()
 var expected: Array = loaded.active_cards()
 expected.sort()
 assert(actual == expected, "Partida usa exatamente o deck escolhido")
 DirAccess.remove_absolute(ProjectSettings.globalize_path(decks.path))
 print("OK: Arrancada, Voo, novo mago, 9 decks, limite de 2 cópias, persistência e deck aplicado à partida.")
 quit()
