extends Control
const Music=preload("res://scripts/game_music.gd")
const Profile=preload("res://scripts/adventure_profile.gd")
const State=preload("res://scripts/adventure_state.gd")
const Match=preload("res://scripts/match.gd")
const CardScene=preload("res://card_model.tscn")
const ArtViewer=preload("res://scripts/art_viewer.gd")
const TitleFont=preload("res://assets/fonts/card_title_font.tres")
const Names=preload("res://scripts/faction_names.gd")
const Save=preload("res://scripts/adventure_save.gd")
var xp_payout_shown := false
var run
var body: VBoxContainer
var selection_busy := false
var recent_level_reward := ""
var level_notice_serial := 0
var flight_target_key := ""
const DECK_CHOICE_PHASES=["draft","reward","farm_recruit","river_recruit","item","equip"]
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

func _unhandled_key_input(event: InputEvent) -> void:
 if run==null or run.phase!="shop" or selection_busy:return
 if not event is InputEventKey or not event.pressed or event.echo:return
 if event.keycode!=KEY_F9 or not event.ctrl_pressed or not event.shift_pressed or event.alt_pressed or event.meta_pressed:return
 get_viewport().set_input_as_handled()
 run.gold+=5
 refresh_market()

func text(value: String,size: int=22,parent: Control=null) -> void:
 var label=Label.new()
 label.text=value
 label.add_theme_font_size_override("font_size",size)
 if size>=26:
  label.add_theme_font_override("font",TitleFont)
  label.add_theme_color_override("font_color",Color("ead09a"))
  label.add_theme_color_override("font_shadow_color",Color("050b12"))
  label.add_theme_constant_override("shadow_offset_y",2)
 label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 (body if parent==null else parent).add_child(label)
func action(value: String,callback: Callable,icon_name: String="",parent: Control=null) -> Button:
 var b=Button.new()
 b.text=value
 b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 b.custom_minimum_size.y=62
 if not icon_name.is_empty():
  b.icon=preload("res://scripts/card_skin.gd").texture(icon_name);b.expand_icon=true;b.add_theme_constant_override("icon_max_width",28);b.add_theme_constant_override("h_separation",12)
 b.pressed.connect(callback)
 (body if parent==null else parent).add_child(b)
 return b
func card_label(key: String) -> String:
 var c=Match.CARD_DATA[key]
 var rules: String=" · ".join(c.ability_entries().map(func(entry):return entry.get("summary",entry.name)))
 return "%s · %s · Mana %d · %d/%d\n%s%s" % [c.title,Names.name_for(c.faction),c.cost,c.attack,c.health,"Sem habilidades" if rules.is_empty() else rules,"\nExclusivo da aventura" if c.adventure_only else ""]
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
  var top_controls:=HBoxContainer.new();top_controls.name="OpeningControls";top_controls.set_anchors_preset(Control.PRESET_TOP_RIGHT);top_controls.offset_left=-132;top_controls.offset_right=-16;top_controls.offset_top=16;top_controls.offset_bottom=70;add_child(top_controls);add_expedition_controls(top_controls)
  return
 var scroll=ScrollContainer.new();scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 scroll.name="AdventureContentScroll";scroll.offset_left=40;scroll.offset_right=-470 if deck_open else -40;scroll.offset_top=24;scroll.offset_bottom=-24;add_child(scroll)
 body=VBoxContainer.new();body.size_flags_horizontal=Control.SIZE_EXPAND_FILL;body.size_flags_vertical=Control.SIZE_EXPAND_FILL;body.add_theme_constant_override("separation",12);scroll.add_child(body)
 var header:=HBoxContainer.new();header.name="AdventureHeader";body.add_child(header)
 if run.phase=="shop":
  add_merchant_identity(header,State.merchant_at(run.step))
  add_market_wallet(header)
 else:
  var hud=preload("res://scripts/adventure_hud.gd").new();hud.configure(run);hud.progress_requested.connect(show_progress);header.add_child(hud)
 var spacer:=Control.new();spacer.size_flags_horizontal=Control.SIZE_EXPAND_FILL;header.add_child(spacer)
 if run.phase!="shop":
  var title:=Label.new();title.text="Da Vila à Fenda";title.add_theme_font_override("font",preload("res://assets/fonts/At-Dawn-Regular.otf"));title.add_theme_font_size_override("font_size",28);title.modulate=Color("ead09a");header.add_child(title)
 else:add_leave_market(header)
 var deck_button:=Button.new();deck_button.name="AdventureDeckToggle";deck_button.icon=preload("res://assets/ui/deck-toggle-icon.svg");deck_button.expand_icon=true;deck_button.add_theme_constant_override("icon_max_width",36);deck_button.text=str(run.deck.size());deck_button.tooltip_text="Ocultar deck" if deck_open else "Mostrar deck";deck_button.custom_minimum_size=Vector2(96,54);deck_button.size_flags_vertical=Control.SIZE_SHRINK_CENTER;deck_button.pressed.connect(toggle_deck);header.add_child(deck_button)
 add_expedition_controls(header)
 if deck_open:build_sidebar()
 if run.xp_animation_pending and not xp_payout_shown:call_deferred("show_xp_payout")
 if not recent_level_reward.is_empty():
  var receipt:=PanelContainer.new();receipt.name="LevelBonusReceipt";receipt.add_theme_stylebox_override("panel",preload("res://scripts/ui_theme.gd").panel(Color("193b35"),Color("8dbfa4"),12));body.add_child(receipt)
  var message:=Label.new();message.text=recent_level_reward;message.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;message.add_theme_font_size_override("font_size",18);receipt.add_child(message)
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
   var choices:=illustrated_encounter("res://assets/ui/adventure-farm.webp","Fazenda do Vale","Pão fresco e conversa à porta da fazenda.")
   text("A família recebe sua visita entre os campos. Como você deseja retribuir a hospitalidade?",22,choices)
   action("Conversar com os moradores",farm_recruits,"",choices)
   var gift:=action("Dar um presente · 2 ouro",farm_gift,"adventure-gold-icon",choices)
   gift.disabled=run.gold<2
   var grand:=action("Dar um grande presente · 4 ouro",farm_gift.bind(true),"adventure-gold-icon",choices)
   grand.disabled=run.gold<4
  "farm_recruit":
   text("Escolha uma destas criaturas da Aldeia para seu deck.")
   card_choices(run.options,"Recrutar",farm_take_card)
  "faction":
   text("Uma fenda ameaça a pequena Vila do Vale. Escolha sua origem e reúna aliados.")
   text(State.DECK_RULES,18)
   for f in State.STARTING_FACTIONS:
    var choice:=action(Names.PT[f],choose_faction.bind(f))
    choice.icon=preload("res://scripts/card_skin.gd").faction_symbol(f)
    choice.expand_icon=true
    choice.add_theme_constant_override("icon_max_width",32)
  "draft":
   text("Recrute seu aliado %d/15. Escolha uma carta." % (run.deck.size()+1))
   text("O deck começa com 15 cartas e pode crescer além de 22, sem limite de cópias por carta.",16)
   if run.options.is_empty():run.options=run.draft_options()
   card_choices(run.options, "Recrutar", pick_card)
   add_reroll_button("DraftReroll","Trocar as cartas · custa 1 dado")
  "power","midpower":
   var choices:=illustrated_encounter("res://assets/ui/adventure-power-sanctuary.webp","O despertar do viajante","Uma luz antiga desperta entre as pedras do santuário.")
   text("Escolha um poder para esta expedição.",22,choices)
   if run.options.is_empty():run.options=run.power_options()
   for p in run.options:
    var power_button:=action(State.POWERS[p].name+"\n"+State.POWERS[p].description,pick_power.bind(p),"",choices)
    power_button.custom_minimum_size.y=96
    power_button.name="AdventurePower_"+p
    power_button.icon=preload("res://scripts/card_skin.gd").texture(State.POWER_ICONS[p]);power_button.expand_icon=true;power_button.add_theme_constant_override("icon_max_width",38)
   add_reroll_button("PowerReroll","Trocar os poderes · custa 1 dado",choices)
  "map":
   var navigation:=HBoxContainer.new();navigation.add_theme_constant_override("separation",20);body.add_child(navigation)
   var direction:=Label.new();direction.text=("Travessia obrigatória · ponte ou rio" if run.step==2 else "Arraste o mapa em qualquer direção")+" · etapa %d/%d" % [run.step+1,State.STAGES.size()];direction.add_theme_font_size_override("font_size",16);direction.modulate=Color("b4c9c1");direction.size_flags_horizontal=Control.SIZE_EXPAND_FILL;navigation.add_child(direction)
   var map_spacer:=Control.new();map_spacer.name="AdventureMapTopSpace";map_spacer.custom_minimum_size.y=4;body.add_child(map_spacer)
   var map_scroll:=preload("res://scripts/adventure_map_scroll.gd").new();map_scroll.name="AdventureMapScroll";map_scroll.custom_minimum_size.y=740;map_scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;map_scroll.configure(run);body.add_child(map_scroll)
   var map=preload("res://scripts/adventure_map.gd").new();map.configure(run);map.route_selected.connect(choose_route);map_scroll.add_child(map)
   var focus:=Button.new();focus.name="LocateAdventureRoute";focus.text="Localizar caminho";focus.pressed.connect(func():
    var center:=Vector2.ZERO;var count:=0
    for branch in range(run.route_rows[run.step].size()):
     if run.route_available(branch):center+=map.node_center(run.step,branch);count+=1
    center/=maxi(1,count);map_scroll.follow_stage(center.x,center.y+28.0))
   navigation.add_child(focus)
  "combat":
   text("Há um confronto em andamento neste caminho.")
   action("Retomar confronto",resume_encounter)
  "healer":
   var choices:=illustrated_encounter("res://assets/ui/adventure-healer.webp","Curandeira","À sombra da tenda, a curandeira recebe os feridos.")
   text("Vida atual: %d/%d" % [run.current_life,run.max_life()],22,choices)
   if run.preparation_active:
    action("Recuperar toda a vida · grátis",heal_at_node.bind(false),"hud-life",choices)
   else:
    var heal_amount: int=mini(run.max_life()-run.current_life,ceili(run.max_life()*0.25))
    action("Curar %d de vida · grátis" % heal_amount if heal_amount>0 else "Seguir viagem",heal_at_node.bind(false),"hud-life",choices)
    var full_heal:=action("Recuperar toda a vida · %d ouro" % run.healer_cost(),heal_at_node.bind(true),"adventure-gold-icon",choices)
    full_heal.disabled=run.gold<run.healer_cost()
    full_heal.visible=heal_amount>0 and run.current_life+heal_amount<run.max_life()
  "treasure":
   var choices:=illustrated_encounter("res://assets/ui/adventure-chest.webp","Tesouro da estrada","O brilho do ouro denuncia o esconderijo.")
   text("Você encontrou %d ouro no tesouro." % run.treasure_roll,22,choices)
   action("Prosseguir",finish_service_encounter,"",choices)
  "reward":
   text("Vitória",32)
   var rewards: Array[String]=["+"+str(run.victory_gold)+" ouro","+"+str(run.last_xp_gained)+" XP da expedição"]
   if run.victory_recovery>0:rewards.append("+"+str(run.victory_recovery)+" de vida recuperada")
   if run.extra_item_reward:rewards.append("1 equipamento")
   text("  ·  ".join(rewards),20)
   if not run.reward_message.is_empty():text(run.reward_message,22)
   text("Escolha uma carta para o deck",26)
   card_choices(run.options, "Recrutar", pick_card)
   add_reroll_button("RewardReroll","Trocar as cartas da vitória · custa 1 dado")
  "shop":
   market_display()
  "upgrade":
   text("Recompensa do encontro — escolha uma melhoria para toda a expedição.")
   action("Vitalidade · +1 vida inicial em cada duelo",upgrade_life)

   action("Bolsa de suprimentos · +2 ouro",upgrade_gold)
  "equip","item":
   var spec: Dictionary=State.Items.DEFINITIONS[run.pending_item]
   var icon:=TextureRect.new();icon.texture=load(spec.icon);icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;icon.custom_minimum_size=Vector2(64,64);body.add_child(icon)
   text(spec.name+" — "+spec.description)
   text("Escolha uma destas cartas: todas as cópias dela, atuais e futuras, receberão o item nesta expedição.",18)
   card_choices(run.options,"Aprimorar",equip)
   add_reroll_button("ItemReroll","Trocar o item · custa 1 dado")
  "bridge":
   var choices:=illustrated_encounter("res://assets/ui/adventure-bridge.webp","A ponte está bloqueada","Os bandidos vigiam a passagem sobre o rio.")
   text("O chefe dos bandidos exige sua bolsa. Mais abaixo, pedras rasas permitem cruzar o rio.",22,choices)
   var toll:=action("Pagar %d ouro e recuperar 10%% de vida" % run.gold,bridge_choice.bind("pay"),"adventure-gold-icon",choices)
   toll.disabled=run.gold<=0
   action("Lutar · +2 ouro e um item extras",bridge_choice.bind("fight"),"fury-icon",choices)
   action("Desviar pelo rio",show_river_crossing,"",choices)
  "river":
   var choices:=illustrated_encounter("res://assets/ui/adventure-river.webp","O vau da correnteza","As pedras rasas marcam a passagem para a outra margem.")
   text("A água parece rasa, mas o fundo é traiçoeiro.",22,choices)
   text("50% de contratempo\n25% de encontrar um companheiro\n25% de encontrar um tesouro",19,choices)
   action("Cruzar o rio",cross_river,"",choices)
  "river_recruit":
   text("Um companheiro improvável",27)
   text(run.event_message,18)
   card_choices(run.options,"Recrutar",river_take_card)
  "fortune":
   fortune_panel()
  "chest":
   var choices:=illustrated_encounter("res://assets/ui/adventure-chest.webp","Baú Misterioso","Entre as raízes, um baú antigo ainda guarda seu segredo.")
   text("Um baú fechado. Pode conter ouro, um item… ou um mímico (50%).",22,choices)
   action("Abrir o baú",open_chest,"",choices)
   action("Ir embora sem abrir",leave_chest,"",choices)
  "event_result":
   if run.event_art=="fortune":fortune_panel()
   else:
    var choices: Control=body
    if run.event_art=="banquet":choices=illustrated_encounter("res://assets/ui/adventure-farm-banquet.webp","Um lugar à mesa","A família serve uma refeição para os viajantes.")
    elif run.event_art=="river":choices=illustrated_encounter("res://assets/ui/adventure-river.webp","Do outro lado do rio","A correnteza fica para trás, e a trilha reaparece.")
    text(run.event_message,22,choices)
    action("Prosseguir",finish_event,"",choices)
  "retry":
   text("Seu castelo caiu. Você pode usar uma vida extra para repetir este mesmo confronto.",26)
   text("Vida ao tentar novamente: %d/%d · tentativas extras restantes: %d" % [run.current_life,run.max_life(),run.retries_left],18)
   action("Usar vida extra e tentar novamente",retry_combat)
   action("Encerrar expedição",decline_retry)
  "victory","defeat","abandoned":
   if run.phase=="victory":
    var epilogue:=illustrated_encounter("res://assets/ui/adventure-epilogue.webp","O retorno à Vila do Vale","Os sinos da vila anunciam a volta dos viajantes.")
    text("Sem o dragão, a Fenda enfim se fecha. Quando os sinos anunciam a chegada da expedição, o povo da vila sai para receber quem reabriu a estrada.",22,epilogue)
    action("Nova aventura",new_run,"",epilogue)
   else:text("Você abandonou a expedição." if run.phase=="abandoned" else "A expedição terminou.",30)
   expedition_summary()
   if run.phase!="victory":action("Nova aventura",new_run)

func fortune_panel() -> void:
 var ambush: bool=run.phase=="event_result" and run.fortune_outcome=="ambush"
 var path: String="res://assets/ui/adventure-fortune-ambush.webp" if ambush else "res://assets/ui/adventure-fortune.webp"
 var caption: String="Os guardiões ergueram-se entre as ruínas." if ambush else "Uma moeda repousa entre o sol e a tempestade."
 var column:=illustrated_encounter(path,"Guardiões do Santuário" if ambush else "Sorte ou Revés",caption)
 if run.phase=="fortune":
  text("Uma moeda antiga repousa ao pé do santuário. Deposite 1 ouro e o destino revelará o que aguarda na estrada.",22,column)
  text("50% de sorte\nOuro, cura com um dado ou equipamento.",18,column)
  text("50% de revés\nFerimentos, perda de um dado ou emboscada.",18,column)
  var offering:=action("Fazer a oferenda · %d ouro" % State.FORTUNE_PRICE,reveal_fortune,"adventure-gold-icon",column)
  offering.name="FortuneOffering"
  offering.disabled=run.gold<State.FORTUNE_PRICE
  if offering.disabled:offering.tooltip_text="Você precisa de 1 ouro."
  action("Ir embora",leave_fortune,"",column)
 else:
  text(run.event_message,22,column)
  if ambush:action("Enfrentar os guardiões",fight_fortune_guardians,"fury-icon",column)
  else:action("Prosseguir",finish_event,"",column)

func expedition_summary() -> void:
 var panel:=PanelContainer.new()
 panel.name="ExpeditionSummary"
 panel.add_theme_stylebox_override("panel",preload("res://scripts/ui_theme.gd").panel(Color("152731"),Color("8f7951"),16))
 body.add_child(panel)
 var row:=HBoxContainer.new()
 panel.add_child(row)
 var stats: Array=[["Vitórias",run.xp_awarded_steps.size(),"fury-icon"],["Cartas no deck",run.deck.size(),"deck-toggle-icon"],["Equipamentos",run.equipment.size(),"armor-icon"],["XP recebido" if run.xp_settled else "XP acumulado",run.pending_xp,"vigor-icon"]]
 for stat in stats:
  var column:=VBoxContainer.new()
  column.size_flags_horizontal=Control.SIZE_EXPAND_FILL
  row.add_child(column)
  var icon:=TextureRect.new()
  icon.texture=preload("res://scripts/card_skin.gd").texture(stat[2])
  icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
  icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  icon.custom_minimum_size.y=34
  column.add_child(icon)
  var value:=Label.new()
  value.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  value.text="%s\n%s" % [stat[1],stat[0]]
  column.add_child(value)

func add_expedition_controls(header: HBoxContainer) -> void:
 var save_button:=Button.new();save_button.name="SaveAndLeaveExpedition";save_button.icon=load("res://assets/ui/adventure-exit.svg");save_button.expand_icon=true;save_button.add_theme_constant_override("icon_max_width",30);save_button.custom_minimum_size=Vector2(54,54);save_button.size_flags_vertical=Control.SIZE_SHRINK_CENTER;save_button.tooltip_text="Salvar e sair";save_button.pressed.connect(return_to_selection);header.add_child(save_button)
 if run.phase not in ["victory","defeat","abandoned"]:
  var abandon:=Button.new();abandon.name="AbandonExpeditionIcon";abandon.icon=load("res://assets/ui/adventure-abandon.svg");abandon.expand_icon=true;abandon.add_theme_constant_override("icon_max_width",30);abandon.custom_minimum_size=Vector2(54,54);abandon.size_flags_vertical=Control.SIZE_SHRINK_CENTER;abandon.tooltip_text="Abandonar expedição";abandon.pressed.connect(confirm_abandon);header.add_child(abandon)

func add_reroll_button(node_name: String,hint: String,parent: Control=null) -> void:
 var button:=Button.new();button.name=node_name;button.icon=load("res://assets/ui/adventure-reroll-dice.webp");button.expand_icon=true;button.add_theme_constant_override("icon_max_width",48);button.custom_minimum_size=Vector2(70,60);button.size_flags_horizontal=Control.SIZE_SHRINK_BEGIN;button.tooltip_text=hint;button.disabled=not run.can_reroll_offer();button.pressed.connect(reroll_draft)
 (body if parent==null else parent).add_child(button)

func reroll_draft() -> void:
 if selection_busy:return
 if run.reroll_offer():render()

func choose_faction(f: int) -> void:
 if f not in State.STARTING_FACTIONS:return
 run.faction=f
 run.phase="draft"
 render()
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
 if run.phase!="shop" or key not in run.options:return
 if run.buy_card(key,run.market_price(key)):
  run.options.erase(key)
  flight_target_key=run.deck.back()
  refresh_market()
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

func card_choices(keys: Array, _caption: String, callback: Callable) -> void:
 var grid:=GridContainer.new()
 grid.name="AdventureCardChoices"
 if run.phase=="draft":grid.size_flags_horizontal=Control.SIZE_SHRINK_CENTER
 grid.columns=3
 grid.add_theme_constant_override("h_separation",8 if run.phase=="draft" else 18)
 grid.add_theme_constant_override("v_separation",18)
 body.add_child(grid)
 for key in keys:
  var column:=VBoxContainer.new()
  column.size_flags_horizontal=Control.SIZE_SHRINK_BEGIN if run.phase=="draft" else Control.SIZE_EXPAND_FILL
  grid.add_child(column)
  var card:=choice_card(key,callback)
  card.custom_minimum_size=Vector2(320,427) if run.phase=="draft" else Vector2(280,374)
  card.size_flags_horizontal=Control.SIZE_EXPAND_FILL
  column.add_child(card)

func previewable_card(key: String) -> Control:
 var card=CardScene.instantiate()
 card.name="AdventureCard_"+key
 card.set_card(Match.CARD_DATA[key])
 card.focus_mode=Control.FOCUS_ALL
 card.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
 return card

func choice_card(key: String,callback: Callable) -> Control:
 var card:=previewable_card(key)
 card.gui_input.connect(card_choice_input.bind(key,card,callback))
 return card

func card_choice_input(event: InputEvent,key: String,card: Control,callback: Callable) -> void:
 var clicked: bool=event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed
 if event.is_action_pressed("ui_accept") or clicked:
  if selection_busy:return
  card.accept_event()
  commit_card_choice(key,card.get_global_rect(),callback)

func commit_card_choice(key: String,source: Rect2,callback: Callable) -> void:
 selection_busy=true
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
  "bridge":run.phase="bridge";run.event_claimed=false;render()
  "river":run.phase="river";run.event_claimed=false;render()
  "fortune":run.phase="fortune";run.event_claimed=false;render()
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
 if run.in_combat:resume_encounter()
 else:render()

func show_river_crossing() -> void:
 if run.phase!="bridge":return
 run.chosen_routes[run.step]=1
 run.phase="river"
 render()

func open_chest() -> void:
 if run.phase!="chest":return
 run.resolve_chest()
 if run.in_combat:resume_encounter()
 else:render()

func finish_event() -> void:
 if run.phase!="event_result":return
 if run.event_art=="fortune" and run.fortune_outcome=="ambush":return
 if run.event_art in ["river","fortune"] and run.extra_item_reward:
  run.extra_item_reward=false;run.pending_item="";run.prepare_item();render();return
 run.advance();render()

func cross_river() -> void:
 if run.resolve_river():render()

func river_take_card(key: String) -> void:
 if run.recruit_from_river(key):render()

func reveal_fortune() -> void:
 if run.resolve_fortune():
  run.save_checkpoint()
  render()

func fight_fortune_guardians() -> void:
 if run.start_fortune_ambush():resume_encounter()

func leave_fortune() -> void:
 if run.leave_fortune():render()


func resume_encounter() -> void:
 run.in_combat=true
 run.save_checkpoint()
 get_tree().change_scene_to_file("res://main.tscn")





func choose_level_bonus(key: String) -> void:
 if run.profile==null or not run.profile.choose_bonus(key):return
 recent_level_reward="Melhoria recebida · %s\n%s" % [Profile.BONUSES[key].name,Profile.BONUSES[key].description]
 if run.phase in ["intro","faction"] and run.deck.is_empty():
  State.current=State.new(run.profile)
  run=State.current
 render()
 level_notice_serial+=1
 get_tree().create_timer(6.0).timeout.connect(clear_level_notice.bind(level_notice_serial))

func clear_level_notice(serial: int) -> void:
 if serial!=level_notice_serial:return
 recent_level_reward=""
 var receipt:=find_child("LevelBonusReceipt",true,false)
 if is_instance_valid(receipt):receipt.queue_free()

func retry_combat() -> void:
 if run.use_extra_life():resume_encounter()

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
 if run.buy_premium_card(key):
  flight_target_key=run.deck.back()
  refresh_market()

func add_market_wallet(header: HBoxContainer) -> void:
 var wallet:=market_gold(run.gold,false,27)
 wallet.name="MarketWallet"
 wallet.size_flags_vertical=Control.SIZE_SHRINK_CENTER
 wallet.mouse_filter=Control.MOUSE_FILTER_PASS
 header.add_child(wallet)
 wallet.tooltip_text="Ouro disponível: %d" % run.gold

func market_gold(amount: int,unavailable: bool,icon_size: int) -> PanelContainer:
 var badge:=PanelContainer.new()
 badge.add_theme_stylebox_override("panel",preload("res://scripts/ui_theme.gd").panel(Color("121c28"),Color("9c6c65") if unavailable else Color("a6854d"),5))
 badge.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var row:=HBoxContainer.new()
 row.add_theme_constant_override("separation",5)
 row.alignment=BoxContainer.ALIGNMENT_CENTER
 row.mouse_filter=Control.MOUSE_FILTER_IGNORE
 badge.add_child(row)
 var coin:=TextureRect.new()
 coin.texture=load("res://assets/ui/market-coin.svg")
 coin.custom_minimum_size=Vector2(icon_size,icon_size)
 coin.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 coin.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 coin.mouse_filter=Control.MOUSE_FILTER_IGNORE
 row.add_child(coin)
 var gold:=Label.new()
 gold.text=str(amount)
 gold.add_theme_font_size_override("font_size",icon_size)
 gold.add_theme_color_override("font_color",Color("d5a3a1") if unavailable else Color("eed39a"))
 row.add_child(gold)
 return badge

const MARKET_CARD_SIZE:=Vector2(228,304)
const MARKET_ASIDE_WIDTH:=420
const MARKET_GAP:=10

func market_card(key: String,price: int,premium: bool=false) -> Control:
 var unavailable: bool=run.gold<price
 var card:=previewable_card(key)
 card.gui_input.connect(func(event: InputEvent):
  var clicked: bool=event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed
  if not selection_busy and (event.is_action_pressed("ui_accept") or clicked):
   card.accept_event()
   show_market_offer(key,price,premium,card.get_global_rect()))
 card.custom_minimum_size=MARKET_CARD_SIZE
 var badge:=market_gold(price,unavailable,20)
 badge.name="MarketPrice"
 card.add_child(badge)
 badge.set_anchors_preset(Control.PRESET_TOP_RIGHT)
 badge.offset_left=-62
 badge.offset_right=-8
 badge.offset_top=36
 badge.offset_bottom=73
 return card

func show_market_offer(key: String,price: int,premium: bool,source: Rect2) -> void:
 if find_child("MarketOfferPreview",true,false)!=null:return
 var dialog:=ConfirmationDialog.new()
 dialog.name="MarketOfferPreview"
 dialog.title=Match.CARD_DATA[key].title
 dialog.ok_button_text="Comprar"
 dialog.cancel_button_text="Voltar"
 dialog.add_theme_stylebox_override("panel",preload("res://scripts/ui_theme.gd").panel(Color("142431"),Color("8f7951"),16))
 var content:=VBoxContainer.new()
 content.add_theme_constant_override("separation",12)
 dialog.add_child(content)
 var card=CardScene.instantiate()
 card.set_card(Match.CARD_DATA[key])
 card.custom_minimum_size=Vector2(420,560)
 content.add_child(card)
 var price_row:=HBoxContainer.new()
 price_row.alignment=BoxContainer.ALIGNMENT_CENTER
 content.add_child(price_row)
 price_row.add_child(market_gold(price,run.gold<price,22))
 var balance:=Label.new()
 balance.text="Saldo insuficiente" if run.gold<price else "Saldo: %d" % run.gold
 price_row.add_child(balance)
 add_child(dialog)
 dialog.get_ok_button().disabled=run.gold<price
 dialog.canceled.connect(dialog.queue_free)
 dialog.confirmed.connect(func():
  dialog.queue_free()
  if run.phase!="shop" or run.gold<price:return
  if premium and key!=run.shop_premium_key:return
  if not premium and key not in run.options:return
  var callback: Callable=purchase_premium if premium else purchase
  commit_card_choice(key,source,callback))
 dialog.popup_centered()

func refresh_market() -> void:
 var previous:=find_child("AdventureContentScroll",true,false) as ScrollContainer
 var position:=previous.scroll_vertical
 render()
 var next:=find_child("AdventureContentScroll",true,false) as ScrollContainer
 await get_tree().process_frame
 if is_instance_valid(next):next.scroll_vertical=position

func add_merchant_identity(header: HBoxContainer,merchant: Dictionary) -> void:
 var heading_column:=VBoxContainer.new()
 heading_column.add_theme_constant_override("separation",0)
 header.add_child(heading_column)
 var identity:=HBoxContainer.new()
 identity.add_theme_constant_override("separation",10)
 heading_column.add_child(identity)
 var icon:=TextureRect.new()
 icon.texture=preload("res://assets/ui/adventure-merchant-icon.svg")
 icon.custom_minimum_size=Vector2(35,35)
 icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 identity.add_child(icon)
 var merchant_name:=Label.new()
 merchant_name.text=merchant.name
 merchant_name.add_theme_font_override("font",TitleFont)
 merchant_name.add_theme_font_size_override("font_size",28)
 merchant_name.add_theme_color_override("font_color",Color("ead09a"))
 identity.add_child(merchant_name)
 var location:=Label.new()
 location.text=merchant.location
 location.add_theme_font_size_override("font_size",15)
 heading_column.add_child(location)

func add_leave_market(header: HBoxContainer) -> void:
 var leave:=Button.new()
 leave.name="LeaveMarket"
 leave.text="Voltar ao mapa"
 leave.custom_minimum_size=Vector2(205,52)
 leave.size_flags_vertical=Control.SIZE_SHRINK_CENTER
 leave.pressed.connect(finish_service_encounter)
 header.add_child(leave)

func market_display() -> void:
 var merchant:=State.merchant_at(run.step)
 var market:=HBoxContainer.new()
 market.name="AdventureMarket"
 market.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 market.add_theme_constant_override("separation",24)
 body.add_child(market)
 var regular:=GridContainer.new()
 regular.name="MarketOffers"
 regular.columns=4
 regular.add_theme_constant_override("h_separation",MARKET_GAP)
 regular.add_theme_constant_override("v_separation",MARKET_GAP)
 market.add_child(regular)
 var stock: Array=run.options.duplicate()
 if not run.shop_groups.is_empty():
  stock.clear()
  var groups: Array=run.shop_groups
  for row in range(State.SHOP_GROUP_COUNTS.max()):
   for column in range(groups.size()):
    var index: int=(row+column)%groups.size()
    var cards: Array=groups[index].cards
    if row<mini(cards.size(),State.SHOP_GROUP_COUNTS[index]):stock.append(cards[row])
 for key in stock:
  if key in run.options:
   regular.add_child(market_card(key,run.market_price(key)))
  else:
   var sold:=PanelContainer.new()
   sold.custom_minimum_size=MARKET_CARD_SIZE
   sold.add_theme_stylebox_override("panel",preload("res://scripts/ui_theme.gd").panel(Color("14232c"),Color("35414a"),10))
   var label:=Label.new()
   label.text="Vendido"
   label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
   label.modulate=Color("a0abb2")
   sold.add_child(label)
   regular.add_child(sold)
 var aside:=VBoxContainer.new()
 aside.custom_minimum_size.x=MARKET_ASIDE_WIDTH
 aside.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 aside.add_theme_constant_override("separation",MARKET_GAP)
 market.add_child(aside)
 var introduction:=VBoxContainer.new()
 introduction.add_theme_constant_override("separation",12)
 aside.add_child(introduction)
 var portrait:=TextureRect.new()
 portrait.name="MerchantPortrait"
 portrait.texture=load(merchant.art)
 portrait.size_flags_vertical=Control.SIZE_EXPAND_FILL
 portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 introduction.add_child(portrait)
 enable_art_preview(portrait,"%s · %s" % [merchant.name,merchant.location])
 var greeting:=Label.new()
 greeting.text=merchant.greeting
 greeting.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 greeting.add_theme_color_override("font_color",Color("ddd4c5"))
 introduction.add_child(greeting)
 var title:=Label.new()
 title.text="OFERTA ESPECIAL"
 title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 title.add_theme_color_override("font_color",Color("eed39a"))
 introduction.add_child(title)
 var special: Control
 if not run.shop_premium_key.is_empty():
  special=market_card(run.shop_premium_key,run.market_price(run.shop_premium_key,true),true)
  var outline:=Panel.new()
  outline.mouse_filter=Control.MOUSE_FILTER_IGNORE
  outline.show_behind_parent=true
  var glow:=StyleBoxFlat.new()
  glow.draw_center=false
  glow.set_corner_radius_all(10)
  glow.set_border_width_all(2)
  glow.border_color=Color("f5d284")
  glow.shadow_color=Color(1.0,0.72,0.28,0.42)
  glow.shadow_size=12
  outline.add_theme_stylebox_override("panel",glow)
  special.add_child(outline)
  outline.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  outline.offset_left=-1
  outline.offset_top=-1
  outline.offset_right=1
  outline.offset_bottom=1
 else:
  var sold:=Label.new()
  sold.text="Oferta vendida" if run.shop_premium_sold else "Sem oferta elegível"
  sold.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  sold.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
  special=sold
 special.name="MarketSpecialOffer"
 special.size_flags_horizontal=Control.SIZE_SHRINK_CENTER
 aside.add_child(special)
 var scroll:=find_child("AdventureContentScroll",true,false) as ScrollContainer
 scroll.resized.connect(fit_market_grid.bind(scroll,regular,introduction,special))
 fit_market_grid.call_deferred(scroll,regular,introduction,special)

func fit_market_grid(scroll: ScrollContainer,grid: GridContainer,introduction: Control,special: Control) -> void:
 if not is_instance_valid(grid):return
 var width: float=scroll.size.x-MARKET_ASIDE_WIDTH-24-scroll.get_v_scroll_bar().get_combined_minimum_size().x
 var card_width:=maxf(1.0,floorf((width-(grid.columns-1)*MARKET_GAP)/grid.columns))
 var card_size:=Vector2(card_width,card_width*4.0/3.0)
 for card in grid.get_children():card.custom_minimum_size=card_size
 introduction.custom_minimum_size.y=card_size.y
 special.custom_minimum_size=card_size



func illustrated_encounter(path: String,title: String,caption: String) -> VBoxContainer:
 var row:=HBoxContainer.new()
 row.name="IllustratedEncounter"
 row.size_flags_vertical=Control.SIZE_EXPAND_FILL
 row.add_theme_constant_override("separation",24)
 body.add_child(row)
 var frame:=PanelContainer.new()
 frame.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 frame.add_theme_stylebox_override("panel",preload("res://scripts/ui_theme.gd").panel(Color("0c1721"),Color("534b3d"),8))
 row.add_child(frame)
 var art:=TextureRect.new()
 art.name="EncounterArtwork"
 art.texture=load(path)
 art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 art.custom_minimum_size=Vector2(570,625)
 frame.add_child(art)
 enable_art_preview(art,caption)
 var panel:=PanelContainer.new()
 panel.custom_minimum_size.x=508
 panel.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 panel.size_flags_stretch_ratio=0.26
 panel.add_theme_stylebox_override("panel",preload("res://scripts/ui_theme.gd").panel(Color("182a36"),Color("8f7951"),24))
 row.add_child(panel)
 var column:=VBoxContainer.new()
 column.alignment=BoxContainer.ALIGNMENT_CENTER
 column.add_theme_constant_override("separation",16)
 panel.add_child(column)
 text(title,32,column)
 return column

func enable_art_preview(art: TextureRect,caption: String) -> void:
 art.mouse_filter=Control.MOUSE_FILTER_PASS
 art.gui_input.connect(func(event: InputEvent):
  if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_RIGHT and event.pressed:
   art.accept_event()
   ArtViewer.open_event(self,art.texture,caption))

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
 var art:=TextureRect.new();art.name="StoryArtwork";art.texture=preload("res://assets/ui/adventure-opening.webp")
 art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);frame.add_child(art)
 enable_art_preview(art,"O amanhecer marca a partida da Vila do Vale.")
 var margin:=MarginContainer.new();margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);margin.mouse_filter=Control.MOUSE_FILTER_IGNORE
 for edge in ["left","right","top","bottom"]:margin.add_theme_constant_override("margin_"+edge,40)
 frame.add_child(margin)
 var layout:=VBoxContainer.new();layout.mouse_filter=Control.MOUSE_FILTER_IGNORE;margin.add_child(layout)
 var space:=Control.new();space.mouse_filter=Control.MOUSE_FILTER_IGNORE;space.size_flags_vertical=Control.SIZE_EXPAND_FILL;layout.add_child(space)
 intro_overlay=VBoxContainer.new();intro_overlay.name="OpeningTextOverlay";intro_overlay.mouse_filter=Control.MOUSE_FILTER_IGNORE;intro_overlay.add_theme_constant_override("separation",14);layout.add_child(intro_overlay)
 var dialogue:=PanelContainer.new();dialogue.name="OpeningDialogue";dialogue.mouse_filter=Control.MOUSE_FILTER_IGNORE;intro_overlay.add_child(dialogue)
 dialogue.add_theme_stylebox_override("panel",preload("res://scripts/ui_theme.gd").panel(Color(0.04,0.08,0.12,0.82),Color("af915c"),20))
 var column:=VBoxContainer.new();column.add_theme_constant_override("separation",10);dialogue.add_child(column)
 var heading:=Label.new();heading.text="Um chamado ao amanhecer";heading.add_theme_font_override("font",TitleFont);heading.add_theme_font_size_override("font_size",26);heading.modulate=Color("ead09a");column.add_child(heading)
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
 if not run.save_checkpoint():
  var warning:=AcceptDialog.new();warning.title="Não foi possível salvar";warning.dialog_text=Save.last_error;add_child(warning);warning.confirmed.connect(warning.queue_free);warning.popup_centered();return
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
