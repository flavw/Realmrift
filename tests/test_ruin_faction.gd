extends SceneTree
const Store=preload("res://scripts/deck_store.gd")
const Match=preload("res://scripts/match.gd")
const Names=preload("res://scripts/faction_names.gd")
func _initialize():call_deferred("verify")
func verify():
 assert(Names.PT[5]=="Ruína" and Names.EN[5]=="Ruin" and CardData.Faction.RUIN==5)
 assert(not Match.CARD_DATA.has("horde_wolf") and Match.CARD_DATA.orc_mine_overseer.faction==CardData.Faction.RUIN)
 assert(Match.CARD_DATA.horde_roar.title=="Clamor da Ruína")
 var deck=Match.default_deck(5)
 assert(deck.size()==22 and deck.count("orc_mine_overseer")==2 and Match.valid_deck(deck))
 var path="res://work/ruin_migration_test.json"
 var store=Store.new(path,false)
 var slots=store.slots.duplicate(true)
 slots[4].name="Horda dos Ermos"
 for i in range(slots[4].cards.size()):
  if slots[4].cards[i]=="orc_mine_overseer":slots[4].cards[i]="horde_wolf"
 slots[4].cover="horde_wolf"
 var before=slots[4].cards.duplicate()
 var file=FileAccess.open(path,FileAccess.WRITE);file.store_string(JSON.stringify({"version":14,"active":4,"slots":slots}));file.close()
 var loaded=Store.new(path)
 assert(loaded.slots[4].name=="Ruína dos Ermos" and loaded.active==4)
 assert(loaded.slots[4].cards.count("orc_mine_overseer")==2 and loaded.slots[4].cover=="orc_mine_overseer" and Match.valid_deck(loaded.slots[4].cards))
 for i in range(before.size()):
  if before[i]!="horde_wolf":assert(before[i]==loaded.slots[4].cards[i])
 assert(Store.new(path).slots==loaded.slots)
 # A deck already containing two orcs needs another legal replacement, with no cards lost.
 var partial={"cards":["orc_mine_overseer","orc_mine_overseer","horde_wolf","horde_wolf"],"cover":"horde_wolf"}
 Store.replace_removed_wolves(partial,CardData.Faction.RUIN)
 assert(partial.cards.size()==4 and not partial.cards.has("horde_wolf") and partial.cards.count("orc_mine_overseer")==2)
 assert(Match.valid_deck(partial.cards,false,partial.cards.size()) and partial.cover in partial.cards)
 DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
 print("OK: Ruína PT/EN, código, deck padrão e atualização segura dos decks salvos.")
 quit()
