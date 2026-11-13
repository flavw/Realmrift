extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
const CardSkin=preload("res://scripts/card_skin.gd")
func _initialize() -> void:call_deferred("verify")
func settle() -> void:
 for i in range(5):await process_frame
func verify() -> void:
 assert(Match.CARD_DATA.size()==47)
 for key in Match.CARD_DATA:
  var card: CardData=Match.CARD_DATA[key]
  assert(not card.creature_type_name().is_empty())
  assert(card.combat_data().creature_type==card.creature_type)
 assert(Match.CARD_DATA.wolf.creature_type==CardData.CreatureType.BEAST)
 assert(Match.CARD_DATA.village_wall.creature_type==CardData.CreatureType.ARTIFACT)
 assert(Match.CARD_DATA.farmer.is_human())
 assert(not Match.CARD_DATA.village_reconstruction.is_human())
 assert(Match.CARD_DATA.zombie_helper.creature_type==CardData.CreatureType.UNDEAD)
 for key in ["goblin_raider","minotaur_brute","moon_werewolf"]:
  assert(Match.CARD_DATA[key].faction==CardData.Faction.HORDE)
  assert(Match.CARD_DATA[key].creature_type==CardData.CreatureType.MONSTER)
 var deck=Match.default_deck(5)
 assert(deck.size()==20 and Match.valid_deck(deck) and Match.deck_faction(deck)==5)
 assert(Store.accepts_base(5,deck))
 for style in range(Match.DECK_NAMES.size()):assert(Match.valid_deck(Match.default_deck(style)))
 for human in ["squire","farmer","moon_herald","peasant_uprising"]:
  assert(not Store.accepts_base(5,[human]))
  assert(not Match.can_add_faction(["goblin_raider"],human))
  assert(not Match.can_add_faction([human],"goblin_raider"))
  var invalid=deck.duplicate();invalid[0]=human
  assert(not Match.valid_deck(invalid))
 assert(Store.accepts_base(5,["zombie_helper","wolf","village_wall","village_reconstruction"]))
 assert(Store.accepts_base(2,["farmer","zombie_helper"]))
 assert(Match.can_add_faction(["warrior"],"farmer"))
 assert(not Store.accepts_base(5,["mage"]))
 assert(CardSkin.faction_symbol(5)!=null and CardSkin.faction_color(5)!=CardSkin.faction_color(2))
 var store=Store.new("user://test_monsters_decks.json",false)
 assert(store.save_slot(5,"Horda",deck,5))
 var invalid_deck=deck.duplicate();invalid_deck[0]="farmer"
 assert(not store.save_slot(5,"Inválido",invalid_deck,5))
 assert(store.slots[5].cards==deck)
 var reopened=Store.new(store.path)
 assert(reopened.base_for(5)==5 and reopened.slots[5].cards==deck)
 var editor=load("res://deck_editor.tscn").instantiate()
 editor.configure(store);root.add_child(editor);editor.choose_slot(6)
 await settle()
 assert(editor.find_child("ChooseBase_5",true,false)!=null)
 editor.select_base_faction(5);await settle()
 assert(editor.collection_keys().size()==14)
 assert(editor.find_child("CollectionTypeFilter",true,false).item_count==8)
 assert(not editor.add_card("farmer") and not editor.add_card("peasant_uprising"))
 assert(editor.add_card("goblin_raider") and editor.add_card("zombie_helper"))
 editor.type_filter=5 # Monstro: creature type 3 plus 2.
 assert(editor.collection_keys().size()==5)
 editor.type_filter=6
 assert(editor.collection_keys()==["zombie_helper"])
 editor.type_filter=-1;editor.search_query="morto-vivo"
 assert(editor.collection_keys()==["zombie_helper"])
 var m=Match.new(deck,Match.default_deck(0))
 m.players[0].board.clear();m.players[0].hand.clear();m.players[0].mana=10
 m.spawn_unit(0,"goblin_raider")
 assert(m.players[0].board[0].ready)
 m.players[0].hand.append("zombie_helper")
 assert(m.play(0,0,0))
 assert(m.players[0].board[0].armor==1)
 m.spawn_unit(0,"minotaur_brute")
 assert(m.players[0].board[2].block==1)
 m.spawn_unit(0,"moon_werewolf")
 assert(m.players[0].board[3].fury==1)
 var card=load("res://card_model.tscn").instantiate()
 card.card_data=Match.CARD_DATA.goblin_raider;root.add_child(card);await settle()
 assert(card.get_node("CardCanvas/TypeLabel").text=="MONSTRO")
 card.card_data=Match.CARD_DATA.zombie_helper
 assert(card.get_node("CardCanvas/TypeLabel").text=="MORTO-VIVO")
 card.card_data=Match.CARD_DATA.village_reconstruction
 assert(card.get_node("CardCanvas/TypeLabel").text=="MAGIA")
 var gallery=load("res://card_gallery.tscn").instantiate()
 assert(gallery.get_node("Scroll/Page/Grid").get_child_count()==47)
 gallery.free()
 card.queue_free();editor.queue_free();await settle()
 print("OK: 47 recursos tipados, facção Horda, restrição de Humanos em ambas as ordens, deck legal de 20, persistência, filtros, rótulos e habilidades das novas criaturas.")
 quit()

