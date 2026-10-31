extends SceneTree
const Store=preload("res://scripts/deck_store.gd")
const Match=preload("res://scripts/match.gd")
func _init() -> void:
 assert(Match.CARD_DATA.has("lightning_rogue") and not Match.CARD_DATA.has("rogue"))
 assert(Match.CARD_DATA.lightning_rogue.artwork.resource_path.ends_with("lightning_rogue.webp"))
 assert(Match.CARD_DATA.dusk_scout.attack==2 and Match.CARD_DATA.dusk_scout.health==2)
 assert(Match.CARD_DATA.shadow_step.cost==1)
 var initial=Store.new("user://old_rogue_test.json",false)
 var old=initial.slots.duplicate(true)
 var cards: Array=old[1].cards
 for i in range(cards.size()):
  if cards[i]=="lightning_rogue":cards[i]="rogue"
 old[1].cover="rogue"
 var f=FileAccess.open(initial.path,FileAccess.WRITE)
 f.store_string(JSON.stringify({"version":8,"active":1,"slots":old}))
 f.close()
 var migrated=Store.new(initial.path)
 assert(migrated.slots[1].cards.count("lightning_rogue")==2 and not migrated.slots[1].cards.has("rogue"))
 assert(migrated.slots[1].cover=="lightning_rogue" and migrated.active==1)
 assert(Match.valid_deck(migrated.slots[1].cards))
 var again=Store.new(initial.path)
 assert(again.slots[1].cards==migrated.slots[1].cards and again.slots[1].cover=="lightning_rogue")
 DirAccess.remove_absolute(ProjectSettings.globalize_path(initial.path))
 print("OK: nome, arte, atributos e migração persistente de deck e capa.")
 quit()
