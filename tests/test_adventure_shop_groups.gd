extends SceneTree
const State=preload("res://scripts/adventure_state.gd")
const Match=preload("res://scripts/match.gd")
const Items=preload("res://scripts/adventure_items.gd")
func _initialize() -> void:call_deferred("verify")
func check_novel(run,group) -> void:
 var pool: Array=Match.CARD_DATA.keys().filter(func(key):return Match.CARD_DATA[key].collectible and not Match.CARD_DATA[key].neutral_deck_only and Match.CARD_DATA[key].faction in group.factions and run.card_copies(key)==0)
 if not pool.is_empty():assert(group.cards.any(func(key):return run.card_copies(key)==0))
func verify() -> void:
 preload("res://scripts/adventure_save.gd").enabled=false
 for initial in [0,1,3,4,5,6]:
  for seed_value in range(8):
   var run=State.new();run.faction=initial;run.rng.seed=seed_value
   var extra: int=1 if initial!=1 else 3
   var owned: Array=[]
   for key in Match.CARD_DATA:
    var data: CardData=Match.CARD_DATA[key]
    if data.collectible and data.card_type==CardData.CardType.CREATURE and data.faction in [initial,extra]:
     if owned.filter(func(k):return Match.CARD_DATA[k].faction==data.faction).size()<2:owned.append(key)
   run.deck=owned;run.generate_shop()
   assert(run.options.size()==8 and run.shop_groups.size()==3)
   var unique: Dictionary={}
   for key in run.options:unique[key]=true
   assert(unique.size()==8)
   var first: Dictionary=run.shop_groups[0];var second: Dictionary=run.shop_groups[1];var third: Dictionary=run.shop_groups[2]
   assert(first.cards.size()==3 and second.cards.size()==3 and third.cards.size()==2)
   assert(first.cards.all(func(key):return Match.CARD_DATA[key].faction==initial))
   assert(second.cards.all(func(key):return Match.CARD_DATA[key].faction==extra))
   assert(third.cards.all(func(key):return Match.CARD_DATA[key].faction not in [initial,extra]))
   check_novel(run,first);check_novel(run,second)
   var offers: Array=run.options.duplicate();var premium: String=run.shop_premium_key
   run.generate_shop();assert(run.options==offers and run.shop_premium_key==premium)
 var run=State.new();run.faction=0;run.deck=["warrior","squire"]
 run.generate_shop()
 assert(run.options.size()==8 and run.shop_groups[1].fallback and run.shop_groups[1].factions.is_empty())
 assert(run.shop_groups[1].cards.all(func(key):return Match.CARD_DATA[key].faction!=0))
 # All factions acquired: neutrals remain available as the third group.
 run=State.new();run.faction=0
 for key in Match.CARD_DATA:
  var data: CardData=Match.CARD_DATA[key]
  if data.collectible and not data.neutral_deck_only:run.deck.append(key)
 run.generate_shop()
 assert(run.options.size()==8 and run.shop_groups[2].cards.all(func(key):return Match.CARD_DATA[key].faction in [CardData.Faction.VILLAGER,CardData.Faction.WASTES]))
 # Upgraded copies still count as owned for the novelty guarantee.
 run=State.new();run.faction=0;run.deck=[Items.enhance("warrior","sword"),"mage"]
 run.generate_shop();check_novel(run,run.shop_groups[0]);check_novel(run,run.shop_groups[1])
 State.current=run;run.gold=20
 root.content_scale_size=Vector2i(1920,1080)
 root.size=Vector2i(1920,1080)
 var view=load("res://adventure.tscn").instantiate();root.add_child(view)
 var shortcut:=InputEventKey.new()
 shortcut.keycode=KEY_F9
 shortcut.pressed=true
 shortcut.ctrl_pressed=true
 shortcut.shift_pressed=true
 root.push_input(shortcut)
 shortcut.echo=true
 root.push_input(shortcut)
 assert(run.gold==25 and run.options.size()==8)
 await process_frame
 await process_frame
 var grid: GridContainer=view.find_child("MarketOffers",true,false)
 assert(grid.columns==4 and grid.get_child_count()==8)
 assert(grid.get_child(0).custom_minimum_size.x>228)
 for card in grid.get_children():
  var badge: PanelContainer=card.get_node("MarketPrice")
  assert(badge.mouse_filter==Control.MOUSE_FILTER_IGNORE)
  assert(badge.get_child(0).get_child(0).texture.resource_path=="res://assets/ui/market-coin.svg")
  assert(badge.get_child(0).get_child(1).text.is_valid_int())
 var offers: Array=run.options.duplicate();var bought: String=offers[0]
 var first: Control=grid.get_child(0)
 var click:=InputEventMouseButton.new()
 click.button_index=MOUSE_BUTTON_LEFT
 click.pressed=true
 first.gui_input.emit(click)
 var offer: ConfirmationDialog=view.find_child("MarketOfferPreview",true,false)
 assert(offer!=null and offer.get_ok_button().text=="Comprar")
 assert(run.options==offers and run.gold==25)
 offer.get_ok_button().pressed.emit()
 assert(run.options.size()==7 and bought not in run.options and run.options==offers.slice(1))
 assert(run.gold==25-run.market_price(bought))
 grid=view.find_child("MarketOffers",true,false)
 assert(grid.get_child_count()==8 and grid.get_child(0).get_child(0).text=="Vendido")
 run.generate_shop();assert(run.options.size()==7)
 await process_frame;await process_frame
 if DisplayServer.get_name()!="headless":root.get_texture().get_image().save_png("res://.local/adventure-shop-nine-curated.png")
 view.queue_free();await process_frame;await process_frame;State.current=null
 print("OK: curadoria 3/3/2, oito cartas em duas fileiras, atalho de ouro, confirmação e estoque estável.")
 quit()
