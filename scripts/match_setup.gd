extends RefCounted

# Session-only selection: -1 chooses a random valid saved deck each match.
static var enemy_slot: int=-1

static func choose_enemy(store: DeckStore) -> Array:
 var valid: Array[int]=[]
 for i in range(DeckStore.SLOT_COUNT):
  var cards: Array=store.slots[i].cards
  if DuelMatch.valid_deck(cards) and DeckStore.accepts_base(store.base_for(i),cards):valid.append(i)
 if valid.is_empty():return DuelMatch.default_deck(randi_range(0,DuelMatch.DECK_NAMES.size()-1))
 var index: int=enemy_slot if enemy_slot in valid else valid[randi_range(0,valid.size()-1)]
 return store.slots[index].cards.duplicate()
