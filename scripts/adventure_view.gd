extends Control
const Music=preload("res://scripts/game_music.gd")
const Profile=preload("res://scripts/adventure_profile.gd")
const State=preload("res://scripts/adventure_state.gd")
const Match=preload("res://scripts/match.gd")
const CardScene=preload("res://card_model.tscn")
const Names=preload("res://scripts/faction_names.gd")
const Save=preload("res://scripts/adventure_save.gd")
var xp_payout_shown := false
var run
var body: VBoxContainer
var selection_busy := false
var flight_target_key := ""
const DECK_CHOICE_PHASES=["draft","reward","farm_recruit","item","equip"]
var deck_open := false
var deck_tween: Tween
var progress_dialog: AcceptDialog
var rendered_phase := ""
var intro_characters := 0
var intro_label: Label
var intro_button: Button
var intro_tween: Tween
var intro_overlay: VBoxContainer
var intro_fade: Tween
var intro_hidden := false

func _ready() -> void:
 theme=preload("res://scripts/ui_theme.gd").build()
 Music.ensure(get_tree()).play_menu()
 if State.current==null:State.current=Save.load_run()
 if State.current==null:State.current=State.new(Profile.new())
 run=State.current
 render()
 if run.victory_sound_pending:
  run.victory_sound_pending=false
  call_deferred("play_victory_sound")
func text(value: String,size: int=22) -> void:
 var label=Label.new()
 label.text=value
 label.add_theme_font_size_override("font_size",size)
 if size>=26:
  label.add_theme_font_override("font",preload("res://assets/fonts/At-Dawn-Regular.otf"))
  label.add_theme_color_override("font_color",Color("ead09a"))
  label.add_theme_color_override("font_shadow_color",Color("050b12"))
  label.add_theme_constant_override("shadow_offset_y",2)
 label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 body.add_child(label)
func action(value: String,callback: Callable) -> Button:
 var b=Button.new()
 b.text=value
 b.custom_minimum_size.y=62
 b.pressed.connect(callback)
 body.add_child(b)
 return b
func card_label(key: String) -> String:
 var c=Match.CARD_DATA[key]
 return "%s · %s · Mana %d · %d/%d\n%s" % [c.title,Names.PT[c.faction],c.cost,c.attack,c.health,c.ability_text]
func render() -> void:
 stop_intro_typing()
 if run.phase in ["victory","defeat","abandoned"] and not run.xp_settled:run.settle_xp(run.phase)
 call_deferred("checkpoint")
 if deck_tween and deck_tween.is_valid():deck_tween.kill()
 if rendered_phase!=run.phase:
  deck_open=run.phase in DECK_CHOICE_PHASES
  rendered_phase=run.phase
 for child in get_children():remove_child(child);child.queue_free()
 var bg=ColorRect.new();bg.color=Color("0d1923");bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(bg)
 if run.phase=="intro":
  body=null
  opening_story()
  return
 var scroll=ScrollContainer.new();scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 scroll.name="AdventureContentScroll";scroll.offset_left=40;scroll.offset_right=-470 if deck_open else -40;scroll.offset_top=24;scroll.offset_bottom=-24;add_child(scroll)
 body=VBoxContainer.new();body.size_flags_horizontal=Control.SIZE_EXPAND_FILL;body.add_theme_constant_override("separation",12);scroll.add_child(body)
 var header:=HBoxContainer.new();header.name="AdventureHeader";body.add_child(header)
 var hud=preload("res://scripts/adventure_hud.gd").new();hud.configure(run);hud.progress_requested.connect(show_progress);header.add_child(hud)
 var spacer:=Control.new();spacer.size_flags_horizontal=Control.SIZE_EXPAND_FILL;header.add_child(spacer)
 if run.phase!="shop":
  var title:=Label.new();title.text="Da Vila à Fenda";title.add_theme_font_override("font",preload("res://assets/fonts/At-Dawn-Regular.otf"));title.add_theme_font_size_override("font_size",28);title.modulate=Color("ead09a");header.add_child(title)
 var deck_button:=Button.new();deck_button.name="AdventureDeckToggle";deck_button.icon=preload("res://assets/ui/deck-toggle-icon.svg");deck_button.expand_icon=true;deck_button.add_theme_constant_override("icon_max_width",36);deck_button.text=str(run.deck.size());deck_button.tooltip_text="Ocultar deck" if deck_open else "Mostrar deck";deck_button.custom_minimum_size=Vector2(96,54);deck_button.size_flags_vertical=Control.SIZE_SHRINK_CENTER;deck_button.pressed.connect(toggle_deck);header.add_child(deck_button)
 if deck_open:build_sidebar()
 if run.xp_animation_pending and not xp_payout_shown:call_deferred("show_xp_payout")
 if run.profile!=null:
  if not run.profile.last_error.is_empty():text(run.profile.last_error,16)
  var choice: Dictionary=run.profile.pending_choice()
  if not choice.is_empty():
   text("NÍVEL %d ALCANÇADO — escolha uma melhoria permanente" % choice.level,26)
   text("Estes bônus se acumulam para as próximas expedições. XP permanece mesmo após derrotas.",18)

   for key in choice.options:action(Profile.BONUSES[key].name+" — "+Profile.BONUSES[key].description,choose_level_bonus.bind(key))
   return
 if run.farm_blessing_all_run:text("Bênção do banquete: +1 vida às suas criaturas até o fim da expedição.",18)
 elif run.farm_blessing_pending:text("Bênção preparada: +1 vida às suas criaturas no próximo combate.",18)
 match run.phase:
  "intro":
   opening_story()
  "farm":
   encounter_art("farm")
   text("Fazenda do Vale",28)
   text("A família recebe sua visita entre os campos. Como você deseja retribuir a hospitalidade?")
   action("Conversar com os moradores · sem custo",farm_recruits)
   var gift:=action("Dar um presente · 2 ouro",farm_gift)
   gift.disabled=run.gold<2
   var grand:=action("Dar um grande presente · 4 ouro",farm_gift.bind(true))
   grand.disabled=run.gold<4
  "farm_recruit":
   text("Escolha uma destas criaturas da Aldeia para seu deck.")
   card_choices(run.options,"Recrutar",farm_take_card)
  "faction":
   text("Uma fenda ameaça a pequena Vila do Vale. Escolha sua origem e reúna aliados.")
   text(State.DECK_RULES,18)
   for f in [0,1,3,4,5,6]:action(Names.PT[f],choose_faction.bind(f))
  "draft":
   text("Recrute seu aliado %d/15. Escolha uma carta." % (run.deck.size()+1))
   text("O deck começa com 15 cartas e pode crescer além de 22, sem limite de cópias por carta.",16)
   if run.options.is_empty():run.options=run.draft_options()
   card_choices(run.options, "Recrutar", pick_card)
  "power","midpower":
   encounter_art("power_event")
   text("O despertar do viajante — escolha um poder para esta expedição.")
   if run.options.is_empty():run.options=run.power_options()
   for p in run.options:action(State.POWERS[p].name+" — "+State.POWERS[p].description,pick_power.bind(p))
  "map":
   var map_scroll:=preload("res://scripts/adventure_map_scroll.gd").new();map_scroll.name="AdventureMapScroll";map_scroll.custom_minimum_size.y=740;map_scroll.configure(run);body.add_child(map_scroll)
   var map=preload("res://scripts/adventure_map.gd").new();map.configure(run);map.route_selected.connect(choose_route);map_scroll.add_child(map)
  "combat":
   text("Há um confronto em andamento neste caminho.")
   action("Retomar confronto",resume_encounter)
  "healer":
   encounter_art("healer")
   text("Curandeira · Vida %d/%d" % [run.current_life,run.max_life()])
   if run.preparation_active:
    action("Preparação final · recuperar toda a vida grátis",heal_at_node.bind(false))
   else:
    action("Curar %d de vida · grátis" % ceili(run.max_life()*0.25),heal_at_node.bind(false))
    var full_heal:=action("Recuperar toda a vida · %d ouro" % run.healer_cost(),heal_at_node.bind(true))
    full_heal.disabled=run.gold<run.healer_cost()
  "treasure":
   encounter_art("treasure")
   text("Você encontrou %d ouro no tesouro." % run.treasure_roll)
   action("Prosseguir",finish_service_encounter)
  "reward":
   text("Vitória! +%d XP acumulado nesta expedição. Receba seu ouro e recrute um aliado de qualquer origem." % run.last_xp_gained)
   if not run.reward_message.is_empty():text(run.reward_message,22)
   card_choices(run.options, "Recrutar", pick_card)
  "shop":
   text("O mercador dos caminhos",28)
   text(("Preparação final · " if run.preparation_active else "")+"Cartas de todos os reinos · 1 a 3 ouro, conforme o custo de mana")
   market_display()
   action("Sair da loja",finish_service_encounter)
  "upgrade":
   text("Recompensa do encontro — escolha uma melhoria para toda a expedição.")
   action("Vitalidade · +1 vida inicial em cada duelo",upgrade_life)

   action("Bolsa de suprimentos · +2 ouro",upgrade_gold)
  "equip","item":
   encounter_art("item")
   var spec: Dictionary=State.Items.DEFINITIONS[run.pending_item]
   var icon:=TextureRect.new();icon.texture=load(spec.icon);icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;icon.custom_minimum_size=Vector2(64,64);body.add_child(icon)
   text(spec.name+" — "+spec.description)
   text("Escolha uma destas cartas: todas as cópias dela, atuais e futuras, receberão o item nesta expedição.",18)
   card_choices(run.options,"Aprimorar",equip)
  "bridge":
   encounter_art("bridge")
   text("Bandidos bloquearam a ponte. Qual será sua decisão?")
   action("Pagar todo o ouro (%d) · recuperar 10%% da vida máxima" % run.gold,bridge_choice.bind("pay"))
   action("Lutar · dificuldade mediana · +2 ouro e um item extras",bridge_choice.bind("fight"))
   action("Fugir · 50% de sofrer 10% de dano não letal · 50% de ganhar +1 ouro ou vida máxima",bridge_choice.bind("flee"))
  "chest":
   encounter_art("chest")
   text("Um baú fechado. Pode conter ouro, um item… ou um mímico (50%).")
   action("Abrir o baú",open_chest)
   action("Ir embora sem abrir",leave_chest)
  "event_result":
   if run.event_art=="banquet":illustrated_story("res://assets/ui/adventure-farm-banquet.png","Um lugar à mesa",run.event_message)
   else:text(run.event_message)
   action("Prosseguir",finish_event)
  "retry":
   text("Seu castelo caiu. Você pode usar uma vida extra para repetir este mesmo confronto.",26)
   text("Vida ao tentar novamente: %d/%d · tentativas extras restantes: %d" % [run.current_life,run.max_life(),run.retries_left],18)
   action("Usar vida extra e tentar novamente",retry_combat)
   action("Encerrar expedição",decline_retry)
  "victory","defeat","abandoned":
   text("A fenda foi fechada. A vila está salva!" if run.phase=="victory" else "Você abandonou a expedição." if run.phase=="abandoned" else "A expedição terminou. Uma nova jornada espera por você.",30)
   action("Nova aventura",new_run)

 action("Salvar e voltar à seleção de aventuras",return_to_selection)
 if run.phase not in ["victory","defeat","abandoned"]:action("Abandonar expedição",confirm_abandon)
func choose_faction(f: int) -> void:run.faction=f;run.phase="draft";render()
func pick_card(key: String) -> void:
 flight_target_key=run.add_card_to_deck(key);run.options.clear()
 if run.deck.size()>=15:run.apply_account_creature_bonuses()
 if run.phase=="reward":
  if run.extra_item_reward:
   run.extra_item_reward=false;run.pending_item="";run.prepare_item()
  else:run.advance()
 elif run.deck.size()==15:
  if not run.begin_initial_item():run.phase="power"
 render()
func pick_power(p: String) -> void:
 var previous_max: int=run.max_life()
 run.powers.append(p);run.options.clear()
 run.heal(run.max_life()-previous_max)
 if run.phase=="midpower":run.phase="upgrade"
 else:run.phase="map"
 render()
func open_midpower() -> void:run.phase="midpower";run.options.clear();render()
func event_reward(amount: int) -> void:
 if run.phase in ["treasure","shop","healer"]:
  finish_service_encounter()
  return
 run.gold+=amount
 if amount==0:run.grant_vitality()
 open_upgrade()
func open_upgrade() -> void:
 if run.phase in ["treasure","shop","healer"]:
  finish_service_encounter()
  return
 run.phase="upgrade";render()
func finish_service_encounter() -> void:
 if run.phase not in ["treasure","shop","healer"]:return
 run.advance();render()
func upgrade_life() -> void:run.grant_vitality();run.advance();render()
func upgrade_gold() -> void:run.gold+=2;run.advance();render()
func choose_equipment() -> void:run.prepare_item();render()
func equip(key: String) -> void:
 if run.apply_item(key):
  flight_target_key=run.equipment.back().card
  render()
func open_shop() -> void:
 run.generate_shop();render()
func purchase(key: String) -> void:
 if run.buy_card(key,run.market_price(key)):run.options.erase(key);flight_target_key=run.deck.back()
 render()
func new_run() -> void:
 if not run.xp_settled and run.phase in ["victory","defeat","abandoned"]:run.settle_xp(run.phase)
 if not run.xp_settled:return
 if run.xp_animation_pending:show_xp_payout();return
 intro_characters=0;intro_hidden=false;xp_payout_shown=false;State.current=State.new(run.profile);run=State.current;render()
func toggle_deck() -> void:
 if selection_busy:return
 if deck_tween and deck_tween.is_valid():deck_tween.kill()
 deck_open=not deck_open
 var panel: Control=find_child("AdventureDeckSidebar",true,false)
 if not is_instance_valid(panel):
  build_sidebar();panel=find_child("AdventureDeckSidebar",true,false)
  panel.offset_left=20;panel.offset_right=420
 panel.show()
 var content: Control=find_child("AdventureContentScroll",true,false)
 var button: Button=find_child("AdventureDeckToggle",true,false)
 if button:button.tooltip_text="Ocultar deck" if deck_open else "Mostrar deck"
 deck_tween=create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
 deck_tween.tween_property(panel,"offset_left",-430.0 if deck_open else 20.0,0.28)
 deck_tween.tween_property(panel,"offset_right",-30.0 if deck_open else 420.0,0.28)
 deck_tween.tween_property(content,"offset_right",-470.0 if deck_open else -40.0,0.28)
 if not deck_open:deck_tween.chain().tween_callback(panel.hide)

func show_progress() -> void:
 if is_instance_valid(progress_dialog) and progress_dialog.is_inside_tree():
  progress_dialog.popup_centered()
  return
 progress_dialog=preload("res://scripts/adventure_progress_dialog.gd").new()
 progress_dialog.configure(run);add_child(progress_dialog)
 progress_dialog.bonus_selected.connect(func(key: String):
  progress_dialog.hide();progress_dialog.queue_free()
  choose_level_bonus(key))
 progress_dialog.popup_centered()
func fight(f: int) -> void:
 run.enemy_faction=f
 run.enemy=run.enemy_deck_for(f,run.step)
 if State.STAGES[run.step]=="boss":run.encounter="black_dragon"
 run.in_combat=true
 get_tree().change_scene_to_file("res://main.tscn")

func card_choices(keys: Array, _caption: String, callback: Callable, shopping: bool=false,price: int=-1,target_parent: Control=null) -> void:
 var grid:=GridContainer.new()
 grid.name="AdventureCardChoices"
 grid.columns=3
 grid.add_theme_constant_override("h_separation",18)
 grid.add_theme_constant_override("v_separation",18)
 (body if target_parent==null else target_parent).add_child(grid)
 for key in keys:
  var card_price: int=run.market_price(key) if price<0 else price
  var column:=VBoxContainer.new()
  column.size_flags_horizontal=Control.SIZE_EXPAND_FILL
  grid.add_child(column)
  var card=CardScene.instantiate()
  card.name="AdventureCard_"+key
  card.set_card(Match.CARD_DATA[key])
  card.custom_minimum_size=Vector2(280,374)
  card.size_flags_horizontal=Control.SIZE_EXPAND_FILL
  column.add_child(card)
  var unavailable: bool=shopping and run.gold<card_price
  card.focus_mode=Control.FOCUS_ALL
  card.mouse_default_cursor_shape=Control.CURSOR_ARROW if unavailable else Control.CURSOR_POINTING_HAND
  if unavailable:card.modulate=Color(0.55,0.55,0.6)
  card.gui_input.connect(card_choice_input.bind(key,card,callback,unavailable))
  if shopping:
   var cost:=Label.new();cost.text="%d ouro" % card_price+(" · Inédita no deck" if run.card_copies(key)==0 else "");cost.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;column.add_child(cost)

func card_choice_input(event: InputEvent, key: String, card: Control, callback: Callable, unavailable: bool) -> void:
 var clicked: bool=event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed
 if event.is_action_pressed("ui_accept") or clicked:
  if unavailable or selection_busy:return
  selection_busy=true
  card.accept_event()
  var source:=card.get_global_rect()
  flight_target_key=key
  callback.call(key)
  await get_tree().process_frame
  await get_tree().process_frame
  var target: Control=find_child("AdventureDeckCard_"+flight_target_key,true,false)
  if not is_instance_valid(target):target=find_child("AdventureDeckToggle",true,false)
  if is_instance_valid(target):
   var scroll: ScrollContainer=find_child("AdventureDeckListScroll",true,false)
   if is_instance_valid(scroll) and scroll.is_ancestor_of(target):scroll.ensure_control_visible(target)
   await get_tree().process_frame
   var layer:=CanvasLayer.new();layer.layer=40;add_child(layer)
   var tween: Tween=preload("res://scripts/card_add_flight.gd").play(layer,Match.CARD_DATA[flight_target_key],source,target.get_global_rect())
   await tween.finished
   layer.queue_free()
  selection_busy=false
func build_sidebar() -> void:
 var panel:=PanelContainer.new()
 panel.name="AdventureDeckSidebar"
 panel.anchor_left=1.0;panel.anchor_right=1.0;panel.anchor_bottom=1.0
 panel.offset_left=-430;panel.offset_right=-30;panel.offset_top=35;panel.offset_bottom=-30
 add_child(panel)
 var margin:=MarginContainer.new()
 for edge in ["left","right","top","bottom"]:margin.add_theme_constant_override("margin_"+edge,16)
 panel.add_child(margin)
 var column:=VBoxContainer.new()
 column.add_theme_constant_override("separation",12)
 margin.add_child(column)
 var heading:=Label.new()
 heading.text="DECK ATUAL · %d cartas" % run.deck.size()
 heading.add_theme_font_size_override("font_size",23)
 column.add_child(heading)
 var rules:=Label.new();rules.text="Sem limite de tamanho ou de cópias nesta expedição.";rules.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;rules.add_theme_font_size_override("font_size",15);column.add_child(rules)
 var curve:=VBoxContainer.new();curve.name="AdventureManaCurve";column.add_child(curve)
 var title:=Label.new();title.text="CURVA DE MANA";curve.add_child(title)
 var counts: Array[int]=[0,0,0,0,0,0,0,0]
 for key in run.deck:counts[clampi(Match.CARD_DATA[key].cost,0,7)]+=1
 var peak:=1
 for count in counts:peak=maxi(peak,count)
 var bars:=HBoxContainer.new();curve.add_child(bars)
 for cost in range(8):
  var bar_column:=VBoxContainer.new();bar_column.size_flags_horizontal=Control.SIZE_EXPAND_FILL;bars.add_child(bar_column)
  var number:=Label.new();number.text=str(counts[cost]);number.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;bar_column.add_child(number)
  var well:=VBoxContainer.new();well.custom_minimum_size.y=64;well.alignment=BoxContainer.ALIGNMENT_END;bar_column.add_child(well)
  var bar:=ColorRect.new();bar.color=Color("63b8df");bar.custom_minimum_size.y=maxf(2,60.0*counts[cost]/peak);well.add_child(bar)
  var label:=Label.new();label.text="7+" if cost==7 else str(cost);label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;bar_column.add_child(label)
 var list_scroll:=ScrollContainer.new();list_scroll.name="AdventureDeckListScroll";list_scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;column.add_child(list_scroll)
 var list:=VBoxContainer.new();list.name="AdventureDeckList";list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;list_scroll.add_child(list)
 var keys: Array=[]
 for key in run.deck:
  if key not in keys:keys.append(key)
 keys.sort_custom(func(a,b):return Match.CARD_DATA[a].cost<Match.CARD_DATA[b].cost if Match.CARD_DATA[a].cost!=Match.CARD_DATA[b].cost else Match.CARD_DATA[a].title<Match.CARD_DATA[b].title)
 for key in keys:
  var button:=Button.new()
  button.name="AdventureDeckCard_"+key
  button.text="%d   %s  ×%d" % [Match.CARD_DATA[key].cost,Match.CARD_DATA[key].title,run.deck.count(key)]
  button.alignment=HORIZONTAL_ALIGNMENT_LEFT
  var upgrades: Array=Match.CARD_DATA[key].get_meta("adventure_items",[])
  if not upgrades.is_empty():
   button.icon=load(State.Items.DEFINITIONS[upgrades[0]].icon);button.expand_icon=true;button.add_theme_constant_override("icon_max_width",24)
   button.tooltip_text="\n".join(upgrades.map(func(id):return State.Items.DEFINITIONS[id].name+": "+State.Items.DEFINITIONS[id].description))
  button.custom_minimum_size.y=40
  button.add_theme_font_size_override("font_size",16)
  button.pressed.connect(preview_card.bind(key))
  list.add_child(button)

func preview_card(key: String) -> void:
 var dialog:=AcceptDialog.new()
 dialog.title=Match.CARD_DATA[key].title
 dialog.min_size=Vector2i(420,580)
 var card=CardScene.instantiate()
 card.set_card(Match.CARD_DATA[key])
 card.custom_minimum_size=Vector2(360,480)
 dialog.add_child(card)
 add_child(dialog)
 dialog.popup_centered()
 dialog.confirmed.connect(dialog.queue_free)
 dialog.canceled.connect(dialog.queue_free)

func encounter_art(stage: String) -> void:
 var path: String={"intro":"res://assets/art/village_reconstruction.webp","farm":"res://assets/art/generous_peasant.webp","item":"res://assets/ui/adventure-items.png","bridge":"res://assets/art/lightning_rogue.webp","chest":"res://assets/ui/adventure-chest.png","healer":"res://assets/art/cleric.webp","treasure":"res://assets/art/wise_merchant.webp","event":"res://assets/art/generous_peasant.webp","shop":"res://assets/art/wise_merchant.webp","power_event":"res://assets/ui/adventure-power-sanctuary.png"}.get(stage,"")
 if path.is_empty():return
 var art:=TextureRect.new()
 art.name="EncounterArtwork"
 art.texture=load(path)
 art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
 art.custom_minimum_size.y=240
 if stage=="farm":
  art.custom_minimum_size.y=300
  art.stretch_mode=TextureRect.STRETCH_SCALE
  var material:=ShaderMaterial.new()
  material.shader=preload("res://scripts/artwork.gdshader")
  material.set_shader_parameter("source_aspect",float(art.texture.get_width())/art.texture.get_height())
  material.set_shader_parameter("view_aspect",4.5)
  material.set_shader_parameter("artwork_focus",Vector2(0.5,0.24))
  art.material=material
  art.resized.connect(func():material.set_shader_parameter("view_aspect",art.size.x/maxf(1.0,art.size.y)))
 if stage=="power_event":
  art.custom_minimum_size.y=340
  art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 art.mouse_filter=Control.MOUSE_FILTER_IGNORE
 body.add_child(art)

func choose_route(index: int) -> void:
 if run.phase!="map" or not run.route_available(index):return
 var node: Dictionary=run.route_rows[run.step][index]
 run.chosen_routes[run.step]=index
 run.preparation_active=bool(node.get("preparation",false))
 match node.kind:
  "combat","boss":
   run.enemy_faction=node.faction;run.enemy=node.deck.duplicate();run.in_combat=true;run.encounter="black_dragon" if node.kind=="boss" else "";run.phase="combat"
   run.save_checkpoint()
   get_tree().change_scene_to_file("res://main.tscn")
  "farm":run.phase="farm";render()
  "item":run.pending_item="";run.prepare_item();render()
  "bridge":run.phase="bridge";render()
  "chest":run.phase="chest";run.chest_result="";render()
  "power_event":open_midpower()
  "shop":open_shop()
  "healer":run.phase="healer";render()
  "treasure":
   run.treasure_roll=run.rng.randi_range(1,6);run.gold+=run.treasure_roll;run.phase="treasure";render()

func heal_at_node(full: bool) -> void:
 if run.phase!="healer":return
 if run.visit_healer(full):run.advance();render()

func bridge_choice(choice: String) -> void:
 if not run.resolve_bridge(choice):return
 if run.in_combat:get_tree().change_scene_to_file("res://main.tscn")
 else:render()

func open_chest() -> void:
 if run.phase!="chest":return
 run.resolve_chest()
 if run.in_combat:get_tree().change_scene_to_file("res://main.tscn")
 else:render()

func finish_event() -> void:
 if run.phase!="event_result":return
 run.advance();render()


func resume_encounter() -> void:
 run.in_combat=true
 get_tree().change_scene_to_file("res://main.tscn")





func choose_level_bonus(key: String) -> void:
 if run.profile==null or not run.profile.choose_bonus(key):return
 if run.phase in ["intro","faction"] and run.deck.is_empty():
  State.current=State.new(run.profile)
  run=State.current
 render()

func retry_combat() -> void:
 if run.use_extra_life():get_tree().change_scene_to_file("res://main.tscn")

func decline_retry() -> void:
 run.decline_retry();render()




func advance_intro() -> void:
 if run.phase=="intro":run.phase="faction";render()

func skip_intro() -> void:
 if run.phase=="intro":run.phase="faction";render()

func farm_recruits() -> void:
 run.visit_farm_recruits();render()

func farm_take_card(key: String) -> void:
 if run.recruit_from_farm(key):render()

func farm_gift(large: bool=false) -> void:
 if run.gift_farmer(large):render()

func leave_chest() -> void:
 if run.leave_closed_chest():render()

func play_victory_sound() -> void:
 var music=Music.ensure(get_tree())
 if not music.is_inside_tree():await get_tree().process_frame
 music.play_effect(preload("res://assets/audio/victory.ogg"))




func purchase_premium(key: String) -> void:
 if run.buy_premium_card(key):flight_target_key=run.deck.back();render()

func market_display() -> void:
 var market:=HBoxContainer.new();market.name="AdventureMarket";market.add_theme_constant_override("separation",22);body.add_child(market)
 var regular:=VBoxContainer.new();regular.size_flags_horizontal=Control.SIZE_EXPAND_FILL;market.add_child(regular)
 var heading:=Label.new();heading.text="9 RECRUTAS · 1 A 3 OURO";regular.add_child(heading)
 if run.shop_groups.is_empty():card_choices(run.options,"Comprar",purchase,true,-1,regular)
 else:
  for group in run.shop_groups:
   var title:=Label.new();title.name="ShopGroup_"+group.kind;title.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;title.add_theme_font_size_override("font_size",18)
   var origins: String=", ".join(group.factions.map(func(origin):return Names.PT[origin]))
   title.text=("SUA FACÇÃO · "+origins) if group.kind=="initial" else ("NOVAS FACÇÕES · ainda sem facções extras recrutadas" if group.fallback else "FACÇÕES RECRUTADAS · "+origins) if group.kind=="extra" else "OUTRAS FACÇÕES E ALDEIA"
   regular.add_child(title)
   var remaining: Array=group.cards.filter(func(key):return key in run.options)
   if remaining.is_empty():
    var sold:=Label.new();sold.text="Todas as ofertas deste grupo foram compradas.";regular.add_child(sold)
   else:card_choices(remaining,"Comprar",purchase,true,-1,regular)
 var frame:=PanelContainer.new();frame.custom_minimum_size.x=310;market.add_child(frame)
 frame.add_theme_stylebox_override("panel",preload("res://scripts/ui_theme.gd").panel(Color("172b33"),Color("d6b56c"),12))
 var special:=VBoxContainer.new();special.add_theme_constant_override("separation",12);frame.add_child(special)
 var title:=Label.new();title.text="OFERTA ESPECIAL · %d OURO" % run.shop_premium_price;title.add_theme_font_size_override("font_size",18);special.add_child(title)
 var detail:=Label.new();detail.text="Uma criatura com item. O item beneficia todas as cópias desta carta na expedição.";detail.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;special.add_child(detail)
 if not run.shop_premium_key.is_empty():card_choices([run.shop_premium_key],"Comprar aprimorada",purchase_premium,true,run.shop_premium_price,special)
 else:
  var sold:=Label.new();sold.text="Oferta vendida" if run.shop_premium_sold else "Sem oferta elegível";special.add_child(sold)



func illustrated_story(path: String,title: String,story: String) -> void:
 var row:=HBoxContainer.new();row.name="IllustratedStory";row.add_theme_constant_override("separation",26);body.add_child(row)
 var frame:=PanelContainer.new();frame.custom_minimum_size=Vector2(620,400);frame.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 frame.add_theme_stylebox_override("panel",preload("res://scripts/ui_theme.gd").panel(Color("142531"),Color("af915c"),8))
 row.add_child(frame)
 var art:=TextureRect.new();art.name="StoryArtwork";art.texture=load(path)
 art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;art.custom_minimum_size=Vector2(600,380)
 frame.add_child(art)
 var column:=VBoxContainer.new();column.alignment=BoxContainer.ALIGNMENT_CENTER;column.custom_minimum_size.x=450;column.size_flags_horizontal=Control.SIZE_EXPAND_FILL;column.add_theme_constant_override("separation",16);row.add_child(column)
 var heading:=Label.new();heading.text=title;heading.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 heading.add_theme_font_override("font",preload("res://assets/fonts/At-Dawn-Regular.otf"));heading.add_theme_font_size_override("font_size",27);heading.modulate=Color("ead09a");column.add_child(heading)
 var paragraph:=Label.new();paragraph.name="ContinuousStory";paragraph.text=story;paragraph.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;paragraph.add_theme_font_size_override("font_size",20);column.add_child(paragraph)

func stop_intro_typing() -> void:
 if is_instance_valid(intro_label):
  intro_characters=intro_label.get_total_character_count() if intro_label.visible_characters<0 else intro_label.visible_characters
 if intro_tween and intro_tween.is_valid():intro_tween.kill()
 if intro_fade and intro_fade.is_valid():intro_fade.kill()
 intro_label=null
 intro_button=null

func opening_story() -> void:
 var frame:=Control.new();frame.name="OpeningArtworkFrame";frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(frame)
 frame.gui_input.connect(func(event: InputEvent):
  if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:intro_continue()
  elif event.is_action_pressed("ui_accept"):intro_continue())
 frame.focus_mode=Control.FOCUS_ALL
 var art:=TextureRect.new();art.name="StoryArtwork";art.texture=preload("res://assets/ui/adventure-opening.png")
 art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;art.mouse_filter=Control.MOUSE_FILTER_IGNORE;art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);frame.add_child(art)
 var margin:=MarginContainer.new();margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);margin.mouse_filter=Control.MOUSE_FILTER_IGNORE
 for edge in ["left","right","top","bottom"]:margin.add_theme_constant_override("margin_"+edge,40)
 frame.add_child(margin)
 var layout:=VBoxContainer.new();layout.mouse_filter=Control.MOUSE_FILTER_IGNORE;margin.add_child(layout)
 var space:=Control.new();space.mouse_filter=Control.MOUSE_FILTER_IGNORE;space.size_flags_vertical=Control.SIZE_EXPAND_FILL;layout.add_child(space)
 intro_overlay=VBoxContainer.new();intro_overlay.name="OpeningTextOverlay";intro_overlay.mouse_filter=Control.MOUSE_FILTER_IGNORE;intro_overlay.add_theme_constant_override("separation",14);layout.add_child(intro_overlay)
 var dialogue:=PanelContainer.new();dialogue.name="OpeningDialogue";dialogue.mouse_filter=Control.MOUSE_FILTER_IGNORE;intro_overlay.add_child(dialogue)
 dialogue.add_theme_stylebox_override("panel",preload("res://scripts/ui_theme.gd").panel(Color(0.04,0.08,0.12,0.82),Color("af915c"),20))
 var column:=VBoxContainer.new();column.add_theme_constant_override("separation",10);dialogue.add_child(column)
 var heading:=Label.new();heading.text="Um chamado ao amanhecer";heading.add_theme_font_override("font",preload("res://assets/fonts/At-Dawn-Regular.otf"));heading.add_theme_font_size_override("font_size",26);heading.modulate=Color("ead09a");column.add_child(heading)
 intro_label=Label.new();intro_label.name="ContinuousStory";intro_label.text=State.INTRO_TEXT;intro_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;intro_label.add_theme_font_size_override("font_size",20);column.add_child(intro_label)
 var total:=State.INTRO_TEXT.length()
 intro_label.visible_characters=mini(intro_characters,total)
 var controls:=HBoxContainer.new();controls.mouse_filter=Control.MOUSE_FILTER_IGNORE;intro_overlay.add_child(controls)
 var back:=Button.new();back.text="Seleção de aventuras";back.pressed.connect(return_to_selection);controls.add_child(back)
 intro_button=Button.new();intro_button.text="Revelar história" if intro_characters<total else "Contemplar a paisagem · clique novamente para partir";intro_button.size_flags_horizontal=Control.SIZE_EXPAND_FILL;intro_button.pressed.connect(intro_continue);controls.add_child(intro_button)
 intro_button.name="IntroContinue";intro_button.custom_minimum_size.y=48
 intro_overlay.visible=not intro_hidden
 call_deferred("focus_intro")
 if intro_characters<total:
  intro_tween=create_tween()
  intro_tween.tween_property(intro_label,"visible_characters",total,float(total-intro_characters)/60.0)
  intro_tween.finished.connect(func():
   intro_characters=total
   if is_instance_valid(intro_button):intro_button.text="Contemplar a paisagem · clique novamente para partir"
   schedule_intro_fade())
 elif not intro_hidden:schedule_intro_fade()

func schedule_intro_fade() -> void:
 if intro_fade and intro_fade.is_valid():intro_fade.kill()
 intro_fade=create_tween()
 intro_fade.tween_interval(maxf(8.0,State.INTRO_TEXT.length()/65.0))
 intro_fade.tween_property(intro_overlay,"modulate:a",0.0,1.2)
 intro_fade.tween_callback(hide_intro_text)

func focus_intro() -> void:
 if run.phase!="intro":return
 var frame:=find_child("OpeningArtworkFrame",true,false)
 if is_instance_valid(frame) and frame.is_inside_tree():frame.grab_focus()

func hide_intro_text() -> void:
 intro_hidden=true
 if is_instance_valid(intro_overlay):intro_overlay.hide()
 var frame:=find_child("OpeningArtworkFrame",true,false)
 if frame:frame.grab_focus()

func intro_continue() -> void:
 if run.phase!="intro":return
 if is_instance_valid(intro_label) and intro_label.visible_characters<State.INTRO_TEXT.length():
  if intro_tween and intro_tween.is_valid():intro_tween.kill()
  intro_characters=State.INTRO_TEXT.length();intro_label.visible_characters=intro_characters
  intro_button.text="Contemplar a paisagem · clique novamente para partir"
  schedule_intro_fade()
 elif not intro_hidden:
  if intro_fade and intro_fade.is_valid():intro_fade.kill()
  intro_fade=create_tween()
  intro_fade.tween_property(intro_overlay,"modulate:a",0.0,0.6)
  intro_fade.tween_callback(hide_intro_text)
 else:advance_intro()

func checkpoint() -> void:
 if is_inside_tree():run.save_checkpoint()

func return_to_selection() -> void:
 run.save_checkpoint()
 get_tree().change_scene_to_file("res://adventure_select.tscn")

func confirm_abandon() -> void:
 var dialog:=ConfirmationDialog.new();dialog.name="ConfirmAbandon";dialog.title="Abandonar expedição?";dialog.dialog_text="Encerrar esta expedição e receber os %d XP acumulados?" % run.pending_xp;add_child(dialog)
 dialog.confirmed.connect(func():
  dialog.queue_free()
  if run.abandon():render())
 dialog.canceled.connect(dialog.queue_free);dialog.popup_centered()

func show_xp_payout() -> void:
 if not run.xp_animation_pending or xp_payout_shown:return
 xp_payout_shown=true
 var dialog=preload("res://scripts/adventure_xp_payout.gd").new();dialog.configure(run);add_child(dialog)
 dialog.acknowledged.connect(func():
  run.xp_animation_pending=false;run.save_checkpoint();dialog.queue_free();render())
 dialog.popup_centered()
