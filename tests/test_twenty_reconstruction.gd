extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
const KEY="village_reconstruction"
func fixture(neutral: bool=true):
 var m=Match.new(Match.default_deck(4 if neutral else 0),Match.default_deck(0))
 m.players[0].hand=[KEY];m.players[0].mana=10;m.players[0].hp=15
 m.players[0].deck=["wolf"]
 return m
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 assert(Match.DECK_SIZE==20 and Match.CARD_DATA.size()==38)
 for style in range(5):
  var cards=Match.default_deck(style)
  assert(cards.size()==20 and Match.valid_deck(cards))
  for key in cards:assert(cards.count(key)<=2)
 var neutral=Match.default_deck(4)
 assert(neutral.count(KEY)==2 and Match.deck_class(neutral)==-1)
 assert(not Match.valid_deck(neutral.slice(0,12)))
 assert(Match.can_add_class([KEY],"warrior"))
 assert(Match.can_add_class(["warrior"],KEY))
 assert(Match.can_add_class([KEY],"wolf") and Match.can_add_class([],KEY))
 var mixed: Array=neutral.duplicate();mixed[0]="warrior"
 assert(Match.valid_deck(mixed) and Match.deck_class(mixed)==0)
 var m=fixture()
 for target in [[1,-1],[0,0]]:
  assert(not m.cast(0,0,target[0],target[1]) and m.players[0].mana==10 and m.players[0].hand==[KEY])
 assert(m.cast(0,0,0,-1) and m.players[0].hand==["wolf"] and m.players[0].hp==17 and m.players[0].mana==8)
 assert(m.players[0].deck.is_empty() and m.players[0].board.is_empty())
 for hp in [19,20]:
  m=fixture();m.players[0].hp=hp
  assert(m.cast(0,0,0,-1) and m.players[0].hp==20 and m.players[0].hand==["wolf"])
 m=fixture(false)
 assert(m.cast(0,0,0,-1) and m.players[0].hand==["wolf"] and m.players[0].hp==17)
 # Only the current allied battlefield controls the conditional draw.
 for key in ["wolf","warrior","mage","cleric","lightning_rogue"]:
  m=fixture(false);m.spawn_unit(0,key)
  var draws: bool=key=="wolf"
  assert(m.cast(0,0,0,-1) and m.players[0].hp==17 and m.players[0].mana==8)
  assert(m.players[0].hand.size()==(1 if draws else 0) and m.players[0].deck.size()==(0 if draws else 1))
 m=fixture();m.spawn_unit(0,"wolf");m.spawn_unit(0,"warrior")
 assert(m.cast(0,0,0,-1) and m.players[0].hand.is_empty() and m.players[0].hp==17)
 m=fixture(false);m.spawn_unit(1,"warrior")
 assert(m.cast(0,0,0,-1) and m.players[0].hand==["wolf"],"Inimigos não afetam a condição")
 m=fixture();m.players[0].hp=20;m.players[0].deck=[]
 assert(m.cast(0,0,0,-1) and m.players[0].hp==19,"Cura antes da compra e da fadiga")
 m=fixture();m.players[0].mana=1
 assert(not m.cast(0,0,0,-1) and m.players[0].hp==15)
 m=fixture();m.players[0].deck=[];m.players[0].hp=1
 assert(m.cast(0,0,0,-1) and m.players[0].fatigue==1 and m.players[0].hp==2 and m.winner==-1)
 m=fixture();m.players[0].deck=[];m.players[0].hp=1;m.players[0].fatigue=3
 assert(m.cast(0,0,0,-1) and m.players[0].hp==-1 and m.winner==1)
 # Consuming the spell frees a hand slot before the draw; no accidental overdraw.
 m=fixture();m.players[0].hand=[KEY,"wolf","wolf","squire","squire","farmer","farmer"]
 assert(m.cast(0,0,0,-1) and m.players[0].hand.size()==7 and m.players[0].hand.count("wolf")==3)
 # A full battlefield is irrelevant to a castle spell.
 m=fixture()
 for i in range(5):m.spawn_unit(0,"squire")
 assert(m.cast(0,0,0,-1) and m.players[0].board.size()==5)
 m=Match.new(Match.default_deck(0),Match.default_deck(4),1)
 m.players[1].hand=[KEY];m.players[1].mana=2;m.players[1].hp=20;m.players[1].deck=["wolf"]
 assert(m.ai_step() and m.players[1].hand==["wolf"] and m.players[1].mana==0)
 # Migrate an old custom deck and keep its cards, name, cover and active slot.
 var old: Array=["messenger_hawk","messenger_hawk","squire","squire","wolf","wolf","farmer","farmer","village_leader","village_leader","generous_peasant","generous_peasant"]
 var seed=Store.new("user://test_twenty_migration.json",false)
 var slots=seed.slots.duplicate(true)
 slots[4]={"name":"Minha Aldeia","cards":old,"cover":"generous_peasant"}
 slots[1].cards=Match.default_deck(1).slice(0,12)
 var file=FileAccess.open(seed.path,FileAccess.WRITE)
 file.store_string(JSON.stringify({"version":5,"active":4,"slots":slots}));file.close()
 var migrated=Store.new(seed.path)
 assert(migrated.active==4 and migrated.slots[4].name=="Minha Aldeia" and migrated.cover_for(4)=="generous_peasant")
 assert(Match.valid_deck(migrated.slots[4].cards) and migrated.slots[4].cards.count(KEY)==2)
 for key in old:assert(migrated.slots[4].cards.count(key)>=old.count(key))
 assert(migrated.slots[5].cards.is_empty() and Match.valid_deck(migrated.slots[1].cards))
 var reopened=Store.new(seed.path)
 assert(reopened.slots==migrated.slots and reopened.active==4)
 # Editor allows this ordinary neutral spell with any single class.
 var editor=load("res://deck_editor.tscn").instantiate();editor.configure(migrated);root.add_child(editor)
 editor.choose_slot(5);editor.select_base_class(CardData.CardClass.MAGE);editor.clear_draft()
 assert(editor.add_card(KEY) and editor.add_card("mage"))
 editor.clear_draft();assert(editor.add_card("mage") and editor.add_card(KEY))
 editor.draft=Match.default_deck(2);editor.render()
 assert(editor.draft.size()==20 and editor.deck_description(editor.draft)=="20/20 cartas")
 assert(editor.save_deck())
 editor.queue_free();await process_frame;await create_timer(0.35).timeout
 DirAccess.remove_absolute(ProjectSettings.globalize_path(seed.path))
 print("OK: 20 cartas, campo neutro/vazio/misto, qualquer classe no deck, cura antes da compra, fadiga, IA, migração e editor.")
 quit()
