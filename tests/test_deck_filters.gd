extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _initialize() -> void:call_deferred("verify")
func settle() -> void:
 for i in range(5):await process_frame
func verify() -> void:
 var store=Store.new("user://test_deck_filters.json",false)
 var editor=load("res://deck_editor.tscn").instantiate();editor.configure(store);root.add_child(editor);editor.choose_slot(0)
 await settle()
 assert(editor.collection_keys().size()==21)
 var picker=editor.find_child("CollectionFactionFilter",true,false)
 picker.item_selected.emit(1)
 assert(editor.faction_filter==CardData.Faction.WARRIOR)
 assert(editor.collection_keys().all(func(key):return Match.CARD_DATA[key].faction==CardData.Faction.WARRIOR))
 editor.find_child("CollectionFactionFilter",true,false).item_selected.emit(2)
 assert(editor.collection_keys().all(func(key):return Match.CARD_DATA[key].faction==CardData.Faction.VILLAGER))
 assert(not editor.add_card("mage"))
 editor.clear_collection_filters()
 editor.find_child("CollectionTypeFilter",true,false).item_selected.emit(2)
 assert(editor.collection_keys().size()==2 and editor.collection_keys().all(func(key):return Match.CARD_DATA[key].card_type==CardData.CardType.SPELL))
 var search=editor.find_child("CollectionSearch",true,false)
 search.text="reconstrucao";search.caret_column=5;search.text_changed.emit(search.text)
 assert(editor.collection_keys()==["village_reconstruction"])
 assert(editor.find_child("CollectionSearch",true,false).has_focus() and editor.find_child("CollectionSearch",true,false).caret_column==5)
 # A right-side item is present even when its collection card is filtered out.
 var locate:=InputEventMouseButton.new();locate.button_index=MOUSE_BUTTON_RIGHT;locate.pressed=true
 editor.find_child("DeckCard_wall_guard",true,false).gui_input.emit(locate)
 await settle()
 assert(editor.focused_card=="wall_guard" and editor.search_query=="" and editor.type_filter==-1)
 assert(editor.collection_scroll.scroll_vertical>0)
 var tile: Control=editor.collection_tiles.wall_guard
 assert(editor.collection_scroll.get_global_rect().has_point(tile.get_global_rect().get_center()))
 assert(tile.get_theme_stylebox("panel").border_width_left==4)
 # Clicking another collection card clears the old border without rebuilding the UI.
 var clicked: bool=false
 for key in editor.collection_tiles:
  if key=="wall_guard":continue
  var other: Control=editor.collection_tiles[key]
  var visible_rect: Rect2=other.get_global_rect().intersection(editor.collection_scroll.get_global_rect())
  if visible_rect.size.y<100:continue
  var click:=InputEventMouseButton.new()
  click.button_index=MOUSE_BUTTON_LEFT;click.pressed=true;click.position=visible_rect.get_center()
  root.push_input(click,true)
  click.pressed=false;root.push_input(click,true)
  clicked=true;break
 assert(clicked and editor.focused_card=="" and tile.get_theme_stylebox("panel").border_width_left<4)
 # Clear search, type and class controls together; empty result gets feedback.
 editor.search_query="xyz sem resultado";editor.render()
 assert(editor.find_child("CollectionEmpty",true,false)!=null)
 editor.clear_collection_filters();assert(editor.collection_keys().size()==21)
 editor.choose_slot(5);editor.select_base_faction(CardData.Faction.MAGE);editor.clear_draft()
 assert(editor.add_card("mage") and editor.add_card("squire") and not editor.add_card("warrior"))
 assert(editor.draft==["mage","squire"])
 assert(editor.remove_card("mage") and not editor.add_card("warrior"))
 assert(not editor.add_card("cleric"))
 # Save and activation independently reject mixed decks, including legacy lists.
 var mixed=Match.default_deck(0);mixed[0]="mage"
 assert(not store.save_slot(0,"Misto",mixed))
 store.slots[0].cards=mixed
 assert(not store.activate(0))
 editor.clear_draft();editor.begin_faction_choice();editor.select_base_faction(CardData.Faction.WARRIOR)
 editor.faction_filter=-1;editor.render()
 assert(editor.collection_keys().all(func(key):return Match.CARD_DATA[key].faction in [CardData.Faction.WARRIOR,CardData.Faction.VILLAGER]))
 editor.queue_free();await process_frame;await create_timer(0.35).timeout
 print("OK: filtros facção/tipo/aldeões, busca sem acentos e foco, navegação real pela lista, rolagem e proibição de mistura em adicionar/salvar/jogar.")
 quit()
