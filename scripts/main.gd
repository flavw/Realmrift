extends Control

@export var enable_opening := true
@export_range(-1,1) var starting_player := -1
const MulliganView = preload("res://scripts/mulligan_view.gd")
var mulligan_layer: CanvasLayer
var mulligan_view: Control

const ArtViewer = preload("res://scripts/art_viewer.gd")
var preview_ticket := 0
var pending_preview_owner: Control
const Match = preload("res://scripts/match.gd")
const MatchSetup=preload("res://scripts/match_setup.gd")
const DeckStoreScript = preload("res://scripts/deck_store.gd")
const DeckEditorScene = preload("res://deck_editor.tscn")
var enemy_deck_style := 1
var combat_menu_layer: CanvasLayer
var deck_store = DeckStoreScript.new()
var enemy_deck: Array=Match.default_deck(enemy_deck_style)
var duel = Match.new(deck_store.active_cards(), enemy_deck)
var deck_editor: Control
var deck_editor_layer: CanvasLayer
var rogue_choice_dialog: AcceptDialog
var summoning := -1
var needs_deck_fix := false
var casting := -1
var spell_targets: Array=[]
var arcane_cursor_active:=false
var physical_cursor_active:=false
var heal_cursor_active:=false
var log_dialog: AcceptDialog
var log_text: RichTextLabel
var log_card_dialog: PopupPanel
var log_card_view: Control
var mana_preview_owner: Control
var log_count: int=-1

func _process(_delta: float) -> void:
 if is_instance_valid(log_dialog) and log_dialog.visible and log_count!=duel.history.size():
  refresh_match_log()
 var heal_aiming: bool=can_act() and (healing or (casting>=0 and casting<duel.players[0].hand.size() and Match.CARD_DATA[duel.players[0].hand[casting]].spell_effect in [CardData.SpellEffect.RESTORE,CardData.SpellEffect.RECONSTRUCT]))
 var shot_available: bool=can_act() and magic and selected>=0 and selected<duel.players[0].board.size() and duel.has_magic_target(0,selected)
 var spell_available: bool=can_act() and casting>=0 and casting<duel.players[0].hand.size() and Match.CARD_DATA[duel.players[0].hand[casting]].card_class==CardData.CardClass.MAGE and duel.has_spell_target(0,casting)
 var aiming:bool=can_act() and not ArtViewer.is_open(self) and not heal_aiming and (shot_available or spell_available)
 var physical:bool=can_act() and not ArtViewer.is_open(self) and not magic and not healing and casting<0 and summoning<0 and selected>=0 and selected<duel.players[0].board.size() and duel.players[0].board[selected].ready and Match.physical_attack(duel.players[0].board[selected])>0 and not duel.players[0].board[selected].get("wall",false) and is_enemy_target_hovered()
 if aiming==arcane_cursor_active and physical==physical_cursor_active and heal_aiming==heal_cursor_active:return
 arcane_cursor_active=aiming
 physical_cursor_active=physical
 heal_cursor_active=heal_aiming
 var cursor:Texture2D=preload("res://assets/ui/heal-cursor.svg") if heal_aiming else preload("res://assets/ui/arcane-cursor.svg") if aiming else preload("res://assets/ui/attack-cursor.svg") if physical else null
 for shape in [Input.CURSOR_ARROW,Input.CURSOR_POINTING_HAND]:Input.set_custom_mouse_cursor(cursor,shape,Vector2(24,24) if aiming or physical or heal_aiming else Vector2.ZERO)

func is_enemy_target_hovered() -> bool:
 var hovered: Node=get_viewport().gui_get_hovered_control()
 while is_instance_valid(hovered):
  if hovered.get_meta("enemy_attack_target",false):return true
  hovered=hovered.get_parent()
 return false

func _exit_tree() -> void:
 for shape in [Input.CURSOR_ARROW,Input.CURSOR_POINTING_HAND]:Input.set_custom_mouse_cursor(null,shape)
var selected := -1
var magic := false
var healing := false
var quick_healing := false
var busy := false
var root: VBoxContainer
const CardScene = preload("res://card_model.tscn")
const FieldScene = preload("res://field_card.tscn")
const CardVfxSkin = preload("res://scripts/card_skin.gd")
const UiTheme = preload("res://scripts/ui_theme.gd")
const GameDisplaySettings=preload("res://scripts/game_display.gd")
const ResultScene = preload("res://result_overlay.tscn")
var forecast_panel: PanelContainer
var forecast_owner: Control
var preview: Control
var preview_owner: Control
var field_nodes: Array = [{}, {}]
var board_background: Control
var input_shield: Control
var sounds: Dictionary = {}
const Music=preload("res://scripts/game_music.gd")
var music: Node
const StatusVfx=preload("res://scripts/status_vfx.gd")
var block_feedback_until: int=0
var vfx_layer: CanvasLayer
var muted := false
var result_shown := false
var result_layer: CanvasLayer
var result_overlay: Control
var sound_counts: Dictionary = {}
var rules_dialog: AcceptDialog
var options_dialog: AcceptDialog

func _input(event: InputEvent) -> void:
 if ArtViewer.is_open(self):
  return
 if not event is InputEventKey or not event.pressed or event.echo:
  return
 if event.ctrl_pressed or event.alt_pressed or event.meta_pressed or event.shift_pressed:
  return
 if event.keycode==KEY_ESCAPE:
  if is_instance_valid(options_dialog) and options_dialog.visible:
   options_dialog.hide()
  elif is_instance_valid(log_card_dialog) and log_card_dialog.visible:
   log_card_dialog.hide()
  elif is_instance_valid(log_dialog) and log_dialog.visible:
   log_dialog.hide()
  elif is_instance_valid(rules_dialog) and rules_dialog.visible:
   rules_dialog.hide()
  elif is_instance_valid(deck_editor):return
  elif is_instance_valid(combat_menu_layer):close_combat_menu()
  else:open_combat_menu()
  get_viewport().set_input_as_handled()
  return
 var turn_key: bool = event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_KP_0] or event.physical_keycode == KEY_KP_0
 if not turn_key or not can_act():
  return
 if is_instance_valid(rules_dialog) and rules_dialog.visible:
  return
 var focus := get_viewport().gui_get_focus_owner()
 if focus is LineEdit or focus is TextEdit:
  return
 get_viewport().set_input_as_handled()
 end_turn()

func play_sound(kind: String) -> void:
 if sounds.has(kind) and not muted:
  sound_counts[kind] = int(sound_counts.get(kind, 0)) + 1
  sounds[kind].play()

func toggle_sound() -> void:
 muted = not muted
 music.set_muted(muted)
 for player in sounds.values():
  player.volume_db = -80 if muted else Music.volume_db(music.effects_volume,-10.0)
 redraw()

func update_effect_volume() -> void:
 for player in sounds.values():player.volume_db=-80.0 if muted else Music.volume_db(music.effects_volume,-10.0)

func set_busy(value: bool) -> void:
 busy = value
 input_shield.visible = value
 if value:
  hide_preview()
  get_viewport().gui_release_focus()

func _ready() -> void:
 music=Music.ensure(get_tree())
 music.play_combat()
 muted=muted or music.muted
 music.set_muted(muted)
 board_background = Control.new()
 board_background.set_script(preload("res://scripts/board.gd"))
 board_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(board_background)
 theme = UiTheme.build()
 var overlay := CanvasLayer.new()
 overlay.layer = 20
 add_child(overlay)
 preview = CardScene.instantiate()
 preview.custom_minimum_size = Vector2.ZERO
 preview.size = Vector2(360, 480)
 preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
 preview.hide()
 overlay.add_child(preview)
 var lock_layer := CanvasLayer.new()
 lock_layer.layer = 12
 add_child(lock_layer)
 vfx_layer = CanvasLayer.new()
 vfx_layer.layer = 11
 add_child(vfx_layer)
 input_shield = Control.new()
 input_shield.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 input_shield.mouse_filter = Control.MOUSE_FILTER_STOP
 input_shield.hide()
 lock_layer.add_child(input_shield)
 for kind in ["summon","attack","death","magic","victory","castle","block","heal","poison_apply","poison_tick","fury","draw","devotion","regeneration","poison_throw","buff","resonance","fire"]:
  var player := AudioStreamPlayer.new()
  player.stream = load("res://assets/audio/%s.ogg" % kind)
  player.volume_db = Music.volume_db(music.effects_volume,-10.0)
  player.max_polyphony = 6
  add_child(player)
  sounds[kind] = player
 music.audio_settings_changed.connect(update_effect_volume)
 enemy_deck=MatchSetup.choose_enemy(deck_store)
 if enable_opening:
  duel = Match.new(deck_store.active_cards(),enemy_deck,randi_range(0,1) if starting_player<0 else starting_player,true)
 else:
  duel = Match.new(deck_store.active_cards(),enemy_deck)
 redraw()
 if not Match.valid_deck(deck_store.active_cards()):
  needs_deck_fix=true
  open_decks()
 elif duel.opening:show_mulligan()

func label_text(value: String, size: int = 18) -> Label:
 var l := Label.new()
 l.text = value
 l.add_theme_font_size_override("font_size", size)
 l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 return l

func button(value: String, callback: Callable, enabled: bool = true) -> Button:
 var b := Button.new()
 b.text = value
 b.disabled = not enabled
 b.custom_minimum_size.y = 38
 b.pressed.connect(callback)
 return b

func ability_button(symbol: String, value: String, callback: Callable, enabled: bool = true) -> Button:
 var control := button("", callback, enabled)
 control.name="Ability_"+symbol
 control.tooltip_text=value
 var font: Font=get_theme_font("font","Button")
 control.custom_minimum_size=Vector2(font.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,18).x+64,44)
 var content:=HBoxContainer.new()
 content.name="AbilityContents"
 content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 content.offset_left=12;content.offset_right=-12;content.offset_top=6;content.offset_bottom=-6
 content.add_theme_constant_override("separation",8)
 content.mouse_filter=Control.MOUSE_FILTER_IGNORE
 control.add_child(content)
 var icon:=TextureRect.new()
 icon.name="AbilitySymbol"
 icon.texture=CardVfxSkin.texture(symbol)
 icon.custom_minimum_size=Vector2(32,32)
 icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 icon.mouse_filter=Control.MOUSE_FILTER_IGNORE
 content.add_child(icon)
 var caption:=Label.new()
 caption.text=value
 caption.add_theme_font_size_override("font_size",18)
 caption.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
 caption.mouse_filter=Control.MOUSE_FILTER_IGNORE
 content.add_child(caption)
 if not enabled:content.modulate=Color(0.55,0.6,0.65)
 return control

func redraw() -> void:
 if casting<0:spell_targets.clear()
 duel.refresh_auras()
 hide_preview()
 field_nodes = [{}, {}]
 if is_instance_valid(root):
  remove_child(root)
  root.queue_free()
 root = VBoxContainer.new()
 root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 root.offset_left = 28
 root.offset_right = -28
 root.offset_top = 16
 root.offset_bottom = -16
 root.add_theme_constant_override("separation", 6)
 add_child(root)
 var header:=Control.new()
 header.name="EnemyCitadel"
 header.custom_minimum_size.y=104
 root.add_child(header)
 var center:=CenterContainer.new()
 center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 center.mouse_filter=Control.MOUSE_FILTER_IGNORE
 header.add_child(center)
 var enemy_identity:=VBoxContainer.new()
 enemy_identity.alignment=BoxContainer.ALIGNMENT_CENTER
 enemy_identity.add_theme_constant_override("separation",3)
 center.add_child(enemy_identity)
 var enemy_name:=label_text(opponent_label(),22)
 enemy_name.name="EnemyDeckName"
 enemy_name.modulate=Color("e5c7d5")
 header.add_child(enemy_name)
 enemy_name.position=Vector2(4,5)
 var enemy_counts:=label_text("Mão %d · Baralho %d" % [duel.players[1].hand.size(),duel.players[1].deck.size()],14)
 enemy_counts.name="EnemyCardCounts"
 enemy_counts.horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT
 enemy_counts.modulate=Color("a6b8ca")
 header.add_child(enemy_counts)
 enemy_counts.position=Vector2(4,36)
 var enemy_mana:=label_text("✦ %d / %d%s" % [int(duel.players[1].mana)-int(duel.players[1].get("temporary_mana",0)),duel.players[1].max_mana," +%d" % duel.players[1].temporary_mana if int(duel.players[1].get("temporary_mana",0))>0 else ""],20)
 enemy_mana.name="EnemyMana"
 enemy_mana.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
 header.add_child(enemy_mana)
 enemy_mana.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
 enemy_mana.offset_left=-215;enemy_mana.offset_right=-50;enemy_mana.offset_top=3;enemy_mana.offset_bottom=37
 enemy_mana.modulate=Color("a8cfe8")
 enemy_mana.tooltip_text="Mana disponível da IA / reserva máxima"
 add_hero(1,enemy_identity)
 var settings:=button("",open_combat_menu)
 settings.name="CombatSettings"
 settings.icon=CardVfxSkin.texture("settings-icon")
 settings.expand_icon=true
 settings.add_theme_constant_override("icon_max_width",24)
 settings.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
 settings.offset_left=-36;settings.offset_right=0;settings.offset_top=0;settings.offset_bottom=36
 settings.tooltip_text="Menu do combate · Esc"
 header.add_child(settings)
 var history_button:=button("",show_match_log)
 history_button.name="MatchLogButton"
 history_button.icon=preload("res://assets/ui/eye-icon.svg")
 history_button.expand_icon=true
 history_button.add_theme_constant_override("icon_max_width",25)
 header.add_child(history_button)
 history_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
 history_button.offset_left=-36;history_button.offset_right=0;history_button.offset_top=44;history_button.offset_bottom=80
 history_button.tooltip_text="Histórico completo da partida"
 add_board(1)
 var status:=selection_hint()
 var status_panel := PanelContainer.new()
 status_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
 var command_bar:=HBoxContainer.new()
 command_bar.name="BattleCommands"
 command_bar.custom_minimum_size.y=48
 command_bar.add_theme_constant_override("separation",12)
 root.add_child(command_bar)
 status_panel.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 command_bar.add_child(status_panel)
 var status_text := label_text(status, 16)
 status_text.custom_minimum_size.x=120
 status_text.name="BattleHint"
 status_text.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
 status_text.modulate = Color("aad7ec") if duel.turn == 0 else Color("cbb9dd")
 status_panel.add_child(status_text)
 var actions := HBoxContainer.new()
 actions.alignment = BoxContainer.ALIGNMENT_END
 actions.name="BattleActions"
 actions.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 command_bar.add_child(actions)
 var all_attack:=button("Atacar com todos",attack_all,can_act() and can_attack_all())
 all_attack.name="AttackAll"
 all_attack.tooltip_text="Ataques físicos na ordem do campo. Prioriza o castelo; respeita Bloqueio e Voo. Não usa habilidades nem mana."
 var has_selection: bool = selected >= 0 and selected < duel.players[0].board.size()
 if has_selection and not duel.players[0].board[selected].get("wall",false) and Match.physical_attack(duel.players[0].board[selected]) > 0:
  actions.add_child(button("Ataque físico", func(): magic = false; healing = false; redraw(), can_act() and duel.players[0].board[selected].ready))
 var spell: Dictionary = duel.players[0].board[selected] if has_selection else {}
 var spell_damage: int = spell.get("magic_damage", 0)
 if spell_damage > 0:
  spell_damage += duel.magic_bonus(0)
 var spell_cost: int = spell.get("magic_cost", 1)
 if spell_damage > 0:
  var fiery: bool=int(spell.get("magic_splash",0))>0
  actions.add_child(ability_button("flame-icon" if fiery else "arcane-icon", ("Mãos Flamejantes %d • %d mana + esgotar" if fiery else "Disparo Arcano %d • %d mana + esgotar") % [spell_damage, spell_cost], func(): magic = true; healing = false; redraw(), can_act() and spell.get("ready", false) and duel.players[0].mana >= spell_cost and duel.has_magic_target(0,selected)))
 if spell.get("heal_amount", 0) > 0:
  actions.add_child(ability_button("heal-icon", "Cura %d • %d mana + esgotar" % [spell.heal_amount, spell.heal_cost], select_heal, can_act() and spell.get("ready", false) and duel.players[0].mana >= spell.heal_cost and context_for(spell,0).heal_target))
 if spell.get("quick_heal_amount",0)>0:
  actions.add_child(ability_button("heal-icon", "Cura Célere %d • %d mana" % [spell.quick_heal_amount,spell.quick_heal_cost], select_heal.bind(true), can_act() and context_for(spell,0).quick_heal_target))
 var fury_selected: bool = has_selection and duel.players[0].board[selected].get("fury", 0) > 0
 if fury_selected:
  actions.add_child(ability_button("fury-icon", "Fúria +1 • 1 mana", use_fury, can_act() and not duel.players[0].board[selected].get("fury_used",false) and duel.players[0].mana >= 1))
 if has_selection or casting >= 0 or summoning>=0:
  actions.add_child(button("Cancelar", func(): selected = -1; casting = -1; summoning = -1; magic = false; healing = false; redraw()))
 var pass_turn := button("Encerrar turno →", end_turn, can_act())
 pass_turn.name="EndTurn"
 pass_turn.tooltip_text = "Encerrar turno: Enter ou 0 do teclado numérico"
 UiTheme.primary(pass_turn)
 var remaining:=remaining_actions()
 pass_turn.set_meta("actions_remaining",not remaining.is_empty())
 if not remaining.is_empty():
  pass_turn.add_theme_stylebox_override("normal",UiTheme.panel(Color("5b4518"),Color("e3bb59"),8))
  pass_turn.add_theme_stylebox_override("hover",UiTheme.panel(Color("7a5b20"),Color("ffe193"),8))
  pass_turn.add_theme_color_override("font_color",Color("ffe49b"))
  pass_turn.tooltip_text="Ainda pode: %s.\nEnter ou 0 do teclado numérico para encerrar." % ", ".join(remaining)
 actions.add_child(all_attack)
 actions.add_child(pass_turn)
 add_board(0)
 var p: Dictionary = duel.players[0]
 var footer:=HBoxContainer.new()
 footer.name="BattleFooter"
 footer.add_theme_constant_override("separation",12)
 root.add_child(footer)
 var life_panel:=PanelContainer.new()
 life_panel.name="CastleVitals"
 life_panel.custom_minimum_size.x=312
 life_panel.add_theme_stylebox_override("panel",StyleBoxEmpty.new())
 footer.add_child(life_panel)
 var life_column:=VBoxContainer.new()
 life_column.alignment=BoxContainer.ALIGNMENT_CENTER
 life_panel.add_child(life_column)
 var life_caption:=label_text("SEU CASTELO",15)
 life_caption.modulate=Color("95aabd")
 life_column.add_child(life_caption)
 add_hero(0,life_column)
 var hand_area:=Control.new()
 hand_area.name="HandArea"
 hand_area.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 hand_area.custom_minimum_size.y=257
 hand_area.mouse_filter=Control.MOUSE_FILTER_IGNORE
 footer.add_child(hand_area)
 var mana_panel:=Control.new()
 mana_panel.name="ManaReserves"
 mana_panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
 hand_area.add_child(mana_panel)
 mana_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
 mana_panel.offset_left=-240;mana_panel.offset_right=0
 mana_panel.offset_top=-126;mana_panel.offset_bottom=-5
 var mana_column:=VBoxContainer.new()
 mana_column.mouse_filter=Control.MOUSE_FILTER_IGNORE
 mana_column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mana_column.alignment=BoxContainer.ALIGNMENT_END
 mana_column.add_theme_constant_override("separation",3)
 mana_panel.add_child(mana_column)
 add_mana(0,mana_column,240.0)
 var hand_panel := PanelContainer.new()
 hand_panel.add_theme_stylebox_override("panel",StyleBoxEmpty.new())
 hand_panel.name="PlayerHandPanel"
 hand_panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
 hand_area.add_child(hand_panel)
 hand_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 hand_panel.offset_left=-(life_panel.custom_minimum_size.x+footer.get_theme_constant("separation"))
 var hand_content := VBoxContainer.new()
 hand_panel.add_child(hand_content)
 var hand_caption := label_text("SUA MÃO · %d CARTAS     |     BARALHO · %d" % [p.hand.size(),p.deck.size()], 14)
 hand_caption.name="PlayerCardCounts"
 hand_caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 hand_caption.modulate = Color("aab9c7")
 hand_content.add_child(hand_caption)
 var hand := HBoxContainer.new()
 hand.alignment = BoxContainer.ALIGNMENT_CENTER
 hand.custom_minimum_size.y = 224
 hand.add_theme_constant_override("separation",4)
 hand_content.add_child(hand)
 if p.hand.is_empty():
  var empty_hand := label_text("Seu próximo turno traz uma nova carta.", 17)
  empty_hand.modulate = Color("8393a5")
  hand.add_child(empty_hand)
 for i in range(p.hand.size()):
  var key: String = p.hand[i]
  var box := VBoxContainer.new()
  hand.add_child(box)
  var art = CardScene.instantiate()
  art.set_card(Match.CARD_DATA[key])
  art.set_meta("preview_managed", true)
  art.ability_context = context_for(Match.CARDS[key],0,false)
  art.ability_context["castable"] = duel.has_spell_target(0,i)
  art.set_meta("ability_context",art.ability_context)
  art.custom_minimum_size = Vector2(168, 224)
  art.name="HandCard_%d" % i
  art.mouse_filter = Control.MOUSE_FILTER_STOP
  art.gui_input.connect(hand_card_input.bind(i))
  var playable: bool=hand_card_can_play(i)
  art.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND if playable else Control.CURSOR_ARROW
  art.modulate=Color.WHITE if playable else Color(0.58,0.62,0.7)
  art.mouse_entered.connect(hover_hand_card.bind(art,true))
  art.mouse_exited.connect(hover_hand_card.bind(art,false))
  box.add_child(art)
  var hand_frame: StyleBoxFlat=art.get_node("CardCanvas/Frame").get_theme_stylebox("panel").duplicate()
  if playable:
   hand_frame.shadow_color=Color(0.5,0.8,0.9,0.36)
   hand_frame.shadow_size=5
  if casting==i or summoning==i:
   hand_frame.border_color=Color("ffe09b")
   hand_frame.set_border_width_all(3)
  art.get_node("CardCanvas/Frame").add_theme_stylebox_override("panel",hand_frame)
 var log_label := label_text(duel.history[-1] if not duel.history.is_empty() else "", 12)
 log_label.name="BattleHistory"
 log_label.hide()
 log_label.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
 log_label.modulate = Color("a8b8c8")
 root.add_child(log_label)
 finish_if_needed()
 if not duel.opening and not duel.draw_events.is_empty():
  var events: Array=duel.draw_events.duplicate(true)
  duel.draw_events.clear()
  animate_draws.call_deferred(events)

func animate_draws(events: Array) -> void:
 await get_tree().process_frame
 for event in events:
  if event.get("destroyed",false):
   await animate_destroyed_draw(event)
   continue
  play_sound("draw")
  var node: Control
  if int(event.side)==0:
   var index: int=duel.players[0].hand.rfind(event.key)
   node=find_child("HandCard_%d" % index,true,false) if index>=0 else null
  else:node=find_child("EnemyCardCounts",true,false)
  if not is_instance_valid(node):continue
  if int(event.side)==0 and Match.CARD_DATA.has(event.key):
   var ghost: Control=CardScene.instantiate()
   ghost.card_data=Match.CARD_DATA[event.key]
   ghost.mouse_filter=Control.MOUSE_FILTER_IGNORE
   ghost.custom_minimum_size=Vector2.ZERO
   ghost.size=node.size
   var origin: Control=find_child("PlayerCardCounts",true,false)
   ghost.position=origin.get_global_rect().get_center() if is_instance_valid(origin) else node.global_position
   ghost.scale=Vector2(0.4,0.4)
   ghost.modulate.a=0.7
   vfx_layer.add_child(ghost)
   node.modulate.a=0.0
   var flight:=create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
   flight.tween_property(ghost,"position",node.global_position,0.25)
   flight.tween_property(ghost,"scale",Vector2.ONE,0.25)
   flight.tween_property(ghost,"modulate:a",1.0,0.25)
   flight.finished.connect(func():
    if is_instance_valid(node):node.modulate.a=1.0
    if is_instance_valid(ghost):ghost.queue_free())
   continue
  node.pivot_offset=node.size*0.5
  node.scale=Vector2(0.82,0.82)
  var tween:=create_tween()
  tween.tween_property(node,"scale",Vector2.ONE,0.23).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func animate_destroyed_draw(event: Dictionary) -> void:
 var ghost: Control
 if int(event.side)==0:
  ghost=CardScene.instantiate()
  ghost.card_data=Match.CARD_DATA[event.key]
 else:
  var back:=PanelContainer.new()
  back.add_theme_stylebox_override("panel",UiTheme.panel(Color("20293e"),Color("bc9364"),18))
  var symbol:=label_text("✦",64)
  symbol.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  back.add_child(symbol)
  ghost=back
 ghost.name="DestroyedDraw"
 ghost.mouse_filter=Control.MOUSE_FILTER_IGNORE
 ghost.custom_minimum_size=Vector2.ZERO
 ghost.size=Vector2(168,224)
 ghost.position=Vector2(get_viewport_rect().size.x-220,135 if int(event.side)==1 else get_viewport_rect().size.y-380)
 ghost.pivot_offset=ghost.size*0.5
 vfx_layer.add_child(ghost)
 var warning:=label_text("MÃO CHEIA",18)
 warning.name="OverflowNotice"
 warning.position=ghost.position+Vector2(0,-30)
 warning.modulate=Color("ffb07b")
 warning.mouse_filter=Control.MOUSE_FILTER_IGNORE
 vfx_layer.add_child(warning)
 play_sound("death")
 var tween:=create_tween()
 tween.tween_property(ghost,"modulate",Color(1.5,0.65,0.3),0.15)
 status_effect("destroy",ghost)
 tween.set_parallel(true)
 tween.tween_property(ghost,"scale",Vector2(0.65,0.65),0.45).set_delay(0.2)
 tween.tween_property(ghost,"rotation",0.12,0.45).set_delay(0.2)
 tween.tween_property(ghost,"modulate:a",0.0,0.45).set_delay(0.2)
 await tween.finished
 ghost.queue_free()
 warning.queue_free()

func opponent_label() -> String:
 var faction: int=Match.deck_class(enemy_deck)
 var names: Dictionary={-1:"Neutros",0:"Guerreiro",1:"Mago",3:"Ladino",4:"Clérigo",5:"Horda"}
 return "IA — "+String(names.get(faction,"Neutros"))

func has_allied_wall() -> bool:
 return duel.players[0].board.any(func(unit):return unit.health>0 and unit.get("wall",false))

func hand_card_can_play(index: int) -> bool:
 if not can_act() or index<0 or index>=duel.players[0].hand.size():return false
 var card: CardData=Match.CARD_DATA[duel.players[0].hand[index]]
 if card.card_type==CardData.CardType.SPELL:return duel.has_spell_target(0,index)
 var owner: int=Match.entry_target_side(0,card.combat_data())
 if owner>=0 and not duel.entry_valid_targets(0,card.combat_data()).is_empty():
  for target_index in duel.entry_valid_targets(0,card.combat_data()):
   if duel.can_play(0,index,target_index):return true
  return false
 return duel.can_play(0,index)

func hand_card_input(event: InputEvent,index: int) -> void:
 if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT and hand_card_can_play(index):
  get_viewport().set_input_as_handled()
  play(index)

func remaining_actions() -> PackedStringArray:
 var found:=PackedStringArray()
 if not can_act():return found
 for index in range(duel.players[0].hand.size()):
  if hand_card_can_play(index):
   found.append("jogar cartas")
   break
 for index in range(duel.players[0].board.size()):
  var unit: Dictionary=duel.players[0].board[index]
  for target_index in range(-1,duel.players[1].board.size()):
   if duel.can_target(0,index,target_index,false) and not "atacar" in found:found.append("atacar")
   if duel.can_target(0,index,target_index,true) and not "usar habilidades" in found:found.append("usar habilidades")
   if duel.can_heal(0,index,target_index,1) and not "usar habilidades" in found:found.append("usar habilidades")
   if duel.can_heal(0,index,target_index,1,true) and not "usar habilidades" in found:found.append("usar habilidades")
  for target_index in range(-1,duel.players[0].board.size()):
   if duel.can_heal(0,index,target_index) and not "usar habilidades" in found:found.append("usar habilidades")
   if duel.can_heal(0,index,target_index,0,true) and not "usar habilidades" in found:found.append("usar habilidades")
  if unit.get("fury",0)>0 and not unit.get("fury_used",false) and duel.players[0].mana>=1 and not "usar habilidades" in found:found.append("usar habilidades")
 return found

func open_combat_menu() -> void:
 if is_instance_valid(combat_menu_layer) or is_instance_valid(deck_editor) or ArtViewer.is_open(self):return
 hide_preview()
 get_viewport().gui_release_focus()
 combat_menu_layer=CanvasLayer.new()
 combat_menu_layer.name="CombatMenuLayer"
 combat_menu_layer.layer=60
 add_child(combat_menu_layer)
 var surface:=Control.new()
 surface.theme=theme
 surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 combat_menu_layer.add_child(surface)
 var shade:=ColorRect.new()
 shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 shade.color=Color(0.02,0.035,0.06,0.86)
 shade.gui_input.connect(func(event):
  if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:close_combat_menu())
 surface.add_child(shade)
 var center:=CenterContainer.new()
 center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 center.mouse_filter=Control.MOUSE_FILTER_IGNORE
 surface.add_child(center)
 var panel:=PanelContainer.new()
 panel.custom_minimum_size.x=340
 panel.add_theme_stylebox_override("panel",UiTheme.panel(Color("101e2d"),Color("7c8d9e"),20))
 center.add_child(panel)
 var content:=VBoxContainer.new()
 content.add_theme_constant_override("separation",10)
 panel.add_child(content)
 content.add_child(label_text("MENU",23))
 var resume:=button("Continuar · Esc",close_combat_menu)
 resume.name="ResumeCombat"
 content.add_child(resume)
 content.add_child(button("Início",combat_menu_action.bind("start"),not busy))
 content.add_child(button("Nova partida",combat_menu_action.bind("restart"),not busy))
 content.add_child(button("Meus decks",combat_menu_action.bind("decks"),not busy))
 var options:=button("Opções",show_options)
 options.name="CombatOptions"
 content.add_child(options)
 resume.grab_focus()

func show_options() -> void:
 if is_instance_valid(options_dialog):
  options_dialog.popup_centered(Vector2i(620,450))
  return
 options_dialog=load("res://scripts/options_dialog.gd").new()
 add_child(options_dialog)
 options_dialog.configure(music,show_rules)
 options_dialog.popup_centered(Vector2i(620,450))

func close_combat_menu() -> void:
 if is_instance_valid(combat_menu_layer):
  remove_child(combat_menu_layer)
  combat_menu_layer.queue_free()
 combat_menu_layer=null
 if not busy:redraw()

func combat_menu_action(action: String) -> void:
 close_combat_menu()
 match action:
  "start":get_tree().change_scene_to_file("res://start_menu.tscn")
  "restart":restart()
  "decks":open_decks()
  "rules":show_rules()

func can_act() -> bool:
 if is_instance_valid(log_dialog) and log_dialog.visible:return false
 return Match.valid_deck(deck_store.active_cards()) and not duel.opening and duel.turn == 0 and duel.winner == -1 and not busy and not is_instance_valid(deck_editor) and not ArtViewer.is_open(self) and not is_instance_valid(combat_menu_layer)

func add_board(side: int) -> void:
 var row := HBoxContainer.new()
 row.alignment = BoxContainer.ALIGNMENT_CENTER
 row.name="EnemyBattlefield" if side==1 else "PlayerBattlefield"
 row.custom_minimum_size.y = 240
 row.size_flags_vertical=Control.SIZE_EXPAND_FILL
 row.add_theme_constant_override("separation", 10)
 root.add_child(row)
 var board: Array = duel.players[side].board
 for i in range(Match.MAX_BOARD):
  var slot := PanelContainer.new()
  slot.custom_minimum_size = Vector2(240, 240)
  slot.size_flags_horizontal=Control.SIZE_EXPAND_FILL
  var style:=StyleBoxEmpty.new()
  style.content_margin_top=6;style.content_margin_bottom=6
  style.content_margin_left=6;style.content_margin_right=6
  slot.add_theme_stylebox_override("panel",style)
  slot.mouse_filter=Control.MOUSE_FILTER_IGNORE
  row.add_child(slot)
  if i >= board.size():continue
  var u: Dictionary = board[i]
  var art = FieldScene.instantiate()
  if side==1:art.set_meta("enemy_attack_target",true)
  art.custom_minimum_size = Vector2(224, 224)
  var enabled: bool = duel.can_heal(0,selected,i,side,quick_healing) if healing else (duel.can_target(0, selected, i, magic) if side == 1 else true)
  if casting >= 0:
   enabled = duel.can_cast(0,casting,side,i)
  if summoning>=0:
   enabled=side==Match.entry_target_side(0,Match.CARDS[duel.players[0].hand[summoning]]) and duel.can_play(0,summoning,i)
  var selected_unit: bool=side==0 and selected==i and casting<0 and summoning<0
  var targeting: bool=can_act() and (casting>=0 or summoning>=0 or selected>=0)
  var valid_target: bool=targeting and enabled and (casting>=0 or summoning>=0 or healing or side==1)
  art.set_meta("selection_kind","selected" if selected_unit else "target" if valid_target else "")
  art.set_card(duel.card_for_unit(u), u.health, can_act() and enabled, selected_unit or valid_target, Match.attack_value(u), u.get("block", 0), not u.ready, u.armor)
  art.set_meta("max_health",u.get("max_health",Match.CARD_DATA[u.key].health))
  art.set_meta("ability_context",context_for(u,side))
  art.set_meta("target_index",i)
  art.set_meta("summoned_this_turn",u.get("summoned_this_turn",false))
  art.set_meta("attacked_this_turn",u.get("attacked_this_turn",false))
  art.set_meta("exhausting_action_taken",u.get("exhausting_action_taken",false))
  art.set_meta("vigor",u.get("vigor",false))
  art.set_meta("poison",u.get("poison",0))
  art.set_meta("abascanto",u.get("abascanto",0))
  slot.add_child(art)
  if valid_target and int(u.get("abascanto",0))>0 and is_offensive_magic_target(side,u):
   add_arcane_guard_indicator(art)
  if {"side":side,"index":i} in spell_targets:
   var mark:=label_text("✦ 1",26)
   mark.mouse_filter=Control.MOUSE_FILTER_IGNORE
   mark.position=Vector2(8,8)
   mark.modulate=Color("c4a1ff")
   art.add_child(mark)
  field_nodes[side][u.get("id", -1)] = art
  art.activated.connect(summon_target.bind(side,i) if summoning>=0 else (cast_target.bind(side,i) if casting >= 0 else (heal_target.bind(i,side) if healing else (target.bind(i) if side == 1 else select.bind(i)))))
  if side==1:art.activation_rejected.connect(notify_blocked_attack.bind(i))
  art.inspect_requested.connect(request_preview)
  art.inspect_closed.connect(close_preview)

func is_offensive_magic_target(side: int, unit: Dictionary) -> bool:
 if casting>=0 and casting<duel.players[0].hand.size():
  var effect: int=Match.CARD_DATA[duel.players[0].hand[casting]].spell_effect
  if effect in [CardData.SpellEffect.ARCANE,CardData.SpellEffect.CONDUCTIVE,CardData.SpellEffect.MAGIC_MISSILES]:return side==1
  return effect==CardData.SpellEffect.RESTORE and Match.is_undead(unit)
 if healing:return Match.is_undead(unit)
 return selected>=0 and magic and side==1

func add_arcane_guard_indicator(card: Control) -> void:
 var symbol:=TextureRect.new()
 symbol.name="ArcaneGuardTargetIndicator"
 symbol.texture=CardVfxSkin.texture("abascanto-icon")
 symbol.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 symbol.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 symbol.mouse_filter=Control.MOUSE_FILTER_IGNORE
 symbol.set_anchors_preset(Control.PRESET_CENTER)
 symbol.offset_left=-38;symbol.offset_top=-38
 symbol.offset_right=38;symbol.offset_bottom=38
 symbol.modulate=Color(0.72,0.92,1.0,0.0)
 card.add_child(symbol)
 var tween:=symbol.create_tween().set_loops()
 tween.tween_property(symbol,"modulate:a",0.95,0.38).set_trans(Tween.TRANS_SINE)
 tween.tween_interval(0.25)
 tween.tween_property(symbol,"modulate:a",0.15,0.45).set_trans(Tween.TRANS_SINE)
 tween.tween_interval(0.15)

func request_preview(data: CardData, health: int, owner: Control) -> void:
 hide_preview()
 pending_preview_owner = owner
 var ticket := preview_ticket
 await get_tree().create_timer(0.25).timeout
 if ticket != preview_ticket or not is_instance_valid(owner) or pending_preview_owner != owner:
  return
 var hovered := get_viewport().gui_get_hovered_control()
 if ArtViewer.is_open(self) or not owner.is_visible_in_tree():
  return
 if hovered != owner and (not is_instance_valid(hovered) or not owner.is_ancestor_of(hovered)):
  return
 pending_preview_owner = null
 if owner.get_meta("enemy_attack_target",false) and show_combat_forecast(int(owner.get_meta("target_index",-1)),owner):return
 show_preview(data,health,owner)

func context_for(unit: Dictionary, side: int, on_board: bool = true) -> Dictionary:
 var heal_target: bool = duel.players[side].hp<20
 for ally in duel.players[side].board:
  heal_target = heal_target or Match.is_undead(ally) or (not ally.get("wall",false) and (ally.health < ally.get("max_health",ally.health) or ally.get("poison",0)>0 or ally.get("bleeding",0)>0))
 for enemy in duel.players[1-side].board:heal_target=heal_target or Match.is_undead(enemy)
 var quick_target:=false
 if on_board:
  var actor_index: int=duel.players[side].board.find(unit)
  for target_side in [side,1-side]:
   for i in range(duel.players[target_side].board.size()):
    if duel.can_heal(side,actor_index,i,target_side,true):quick_target=true
 return {"side":side,"on_board":on_board,"turn":duel.turn,"ready":unit.get("ready",false),"mana":duel.players[side].mana,"busy":busy,"winner":duel.winner,"max_health":unit.get("max_health",unit.get("health",1)),"magic_target":duel.has_magic_target(side,duel.players[side].board.find(unit)) if on_board else true,"heal_target":heal_target,"quick_heal_target":quick_target,"quick_heal_used":unit.get("quick_heal_used",false),"magic_bonus":duel.magic_bonus(side),"armor":unit.get("armor",0),"vigor":unit.get("vigor",false),"poison":unit.get("poison",0),"bleeding":unit.get("bleeding",0),"aura_attack":unit.get("aura_attack",0),"turn_attack":unit.get("turn_attack",0),"turn_flying":unit.get("turn_flying",false),"turn_swift":unit.get("turn_swift",false),"abascanto":unit.get("abascanto",0),"fury_used":unit.get("fury_used",false)}

func show_preview(data: CardData, health: int, owner: Control) -> void:
 if busy or is_instance_valid(deck_editor) or not is_instance_valid(preview):
  return
 preview_owner = owner
 preview.ability_context = owner.get_meta("ability_context",{})
 preview.set_card(data, health, owner.get_meta("attack", -1), owner.get_meta("block", -1))
 preview.tooltip_text = ""
 var bounds := owner.get_global_rect()
 var viewport := get_viewport_rect().size
 var x := bounds.end.x + 16
 if x + preview.size.x > viewport.x - 16:
  x = bounds.position.x - preview.size.x - 16
 preview.position = Vector2(clampf(x, 16, viewport.x - preview.size.x - 16), clampf(bounds.position.y - 110, 16, viewport.y - preview.size.y - 16))
 preview.show()
 preview.set_hint_forced(true,true)

func close_preview(owner: Control) -> void:
 if forecast_owner==owner:hide_forecast()
 if pending_preview_owner == owner:
  preview_ticket += 1
  pending_preview_owner = null
 if preview_owner == owner:
  hide_preview()

func hide_preview() -> void:
 hide_forecast()
 preview_ticket += 1
 pending_preview_owner = null
 preview_owner = null
 if is_instance_valid(preview):
  preview.set_hint_forced(false)
  preview.hide()

func add_hero(side: int, parent: Node = null) -> void:
 var p: Dictionary = duel.players[side]
 var row := HBoxContainer.new()
 row.alignment = BoxContainer.ALIGNMENT_CENTER
 row.add_theme_constant_override("separation", 6)
 (root if parent==null else parent).add_child(row)
 var castle := Button.new()
 castle.name = "EnemyCastle" if side == 1 else "PlayerCastle"
 if side==1:castle.set_meta("enemy_attack_target",true)
 var castle_texture: Texture2D=preload("res://assets/art/castle_enemy_wide.webp") if side==1 else preload("res://assets/art/castle_player_wide.webp")
 castle.custom_minimum_size = Vector2(288,104)
 castle.text=""
 castle.add_theme_font_size_override("font_size",36)
 castle.add_theme_color_override("font_disabled_color",Color("f28e82") if p.hp<=5 else Color("fff1d5"))
 castle.add_theme_color_override("font_color",Color("f28e82") if p.hp<=5 else Color("fff1d5"))
 for state in ["normal","hover","pressed","focus","disabled"]:castle.add_theme_color_override("icon_"+state+"_color",Color.WHITE)
 var castle_bg: Color=Color("38202c") if side==1 else Color("152d47")
 var castle_edge: Color=Color("c76d79") if side==1 else Color("70b7e7")
 castle.add_theme_stylebox_override("normal",UiTheme.panel(castle_bg,castle_edge,6))
 castle.add_theme_stylebox_override("disabled",UiTheme.panel(castle_bg,castle_edge.darkened(0.3),6))
 castle.tooltip_text = "Ataque direto ao castelo da IA" if side == 1 else ("Curar seu castelo" if healing else "Seu castelo")
 var castle_allowed: bool = (healing and duel.can_heal(0, selected, -1,0,quick_healing)) if side == 0 else (not healing and duel.can_target(0, selected, -1, magic))
 if casting >= 0:
  castle_allowed = duel.can_cast(0,casting,side,-1)
  castle.tooltip_text = "Alvo permitido para a magia" if castle_allowed else "Esta magia não pode atingir este castelo"
 if summoning>=0:castle_allowed=false
 castle.disabled = not can_act() or not castle_allowed
 if not castle.disabled and (selected>=0 or casting>=0):
  var target_style:=UiTheme.panel(castle_bg,Color("72ead6"),6)
  target_style.set_border_width_all(4)
  target_style.shadow_color=Color(0.3,0.95,0.8,0.55)
  target_style.shadow_size=9
  castle.add_theme_stylebox_override("normal",target_style)
 castle.pressed.connect(cast_target.bind(side,-1) if casting >= 0 else (heal_target.bind(-1) if side == 0 else target.bind(-1)))
 row.add_child(castle)
 if side==1:
  castle.mouse_entered.connect(func():show_combat_forecast(-1,castle))
  castle.mouse_exited.connect(func():
   if forecast_owner==castle:hide_forecast())
 var art:=TextureRect.new()
 art.name="CastleArtwork"
 art.texture=castle_texture
 art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
 art.clip_contents=true
 art.mouse_filter=Control.MOUSE_FILTER_IGNORE
 art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 art.offset_left=6;art.offset_right=-66;art.offset_top=6;art.offset_bottom=-6
 castle.add_child(art)
 var life:=label_text(str(p.hp),36)
 life.name="CastleLife"
 life.mouse_filter=Control.MOUSE_FILTER_IGNORE
 life.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
 life.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 life.anchor_left=1.0
 life.offset_left=-64;life.offset_right=-4
 life.add_theme_color_override("font_color",Color("f28e82") if p.hp<=5 else Color("fff1d5"))
 castle.add_child(life)
 if {"side":side,"index":-1} in spell_targets:
  var mark:=label_text("✦ 1",24)
  mark.name="CastleSpellTargetMark"
  mark.position=Vector2(8,8)
  mark.modulate=Color("c4a1ff")
  mark.mouse_filter=Control.MOUSE_FILTER_IGNORE
  castle.add_child(mark)
 if side==1 and can_act() and not magic and not healing and casting<0 and summoning<0 and not duel.attack_blockers(0,selected,-1).is_empty():
  var blocked:=Control.new()
  blocked.name="BlockedCastleTarget"
  blocked.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  blocked.tooltip_text="Bloqueio: ataque uma criatura com cargas."
  blocked.gui_input.connect(blocked_castle_input)
  castle.add_child(blocked)

func add_mana(side: int, parent: Node = null, bar_width: float = 240.0) -> void:
 var p: Dictionary=duel.players[side]
 var box:=VBoxContainer.new()
 box.name="EnemyMana" if side==1 else "PlayerMana"
 box.add_theme_constant_override("separation",3)
 (root if parent==null else parent).add_child(box)
 var temporary: int=int(p.get("temporary_mana",0))
 var base_mana: int=maxi(0,int(p.mana)-temporary)
 if temporary>0:
  var bonus:=HBoxContainer.new()
  bonus.alignment=BoxContainer.ALIGNMENT_END
  box.add_child(bonus)
  var gold:=TextureRect.new()
  gold.name="TemporaryManaGem"
  gold.texture=CardVfxSkin.texture("mana-crystal-gold")
  gold.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
  gold.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  gold.custom_minimum_size=Vector2(22,22)
  bonus.add_child(gold)
  add_mana_spend_ring(gold)
  var counter:=label_text("+%d" % temporary,18)
  counter.name="TemporaryMana"
  counter.modulate=Color("ffd47a")
  bonus.tooltip_text="Mana temporária: gasta primeiro e termina no fim do turno."
  bonus.add_child(counter)
 var bar:=Control.new()
 bar.name="ManaBar"
 bar.custom_minimum_size=Vector2(bar_width,90)
 box.add_child(bar)
 var frame_art:=TextureRect.new()
 frame_art.name="ManaBarArtwork"
 frame_art.texture=CardVfxSkin.texture("mana-compact-frame")
 frame_art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 frame_art.stretch_mode=TextureRect.STRETCH_SCALE
 frame_art.mouse_filter=Control.MOUSE_FILTER_IGNORE
 frame_art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 bar.add_child(frame_art)
 var gems:=GridContainer.new()
 gems.name="ManaGems"
 gems.columns=5
 gems.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 gems.offset_left=22;gems.offset_right=-22;gems.offset_top=10;gems.offset_bottom=-10
 gems.add_theme_constant_override("h_separation",5)
 gems.add_theme_constant_override("v_separation",4)
 bar.add_child(gems)
 for i in range(10):
  var gem:=TextureRect.new()
  gem.name="ManaGem%d" % i
  gem.texture=CardVfxSkin.texture("mana-crystal-blue")
  gem.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
  gem.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  gem.custom_minimum_size=Vector2(31,31)
  gem.size_flags_horizontal=Control.SIZE_EXPAND_FILL
  gem.size_flags_vertical=Control.SIZE_EXPAND_FILL
  gem.modulate=Color.WHITE if i<base_mana else Color(0.37,0.42,0.52) if i<p.max_mana else Color(0.18,0.22,0.28)
  gem.tooltip_text="Disponível" if i<base_mana else "Gasta neste turno" if i<p.max_mana else "Ainda bloqueada"
  gems.add_child(gem)
  add_mana_spend_ring(gem)

func add_mana_spend_ring(gem: Control) -> void:
 var ring:=Control.new()
 ring.name="ManaSpendRing"
 ring.set_script(preload("res://scripts/mana_spend_ring.gd"))
 ring.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 ring.mouse_filter=Control.MOUSE_FILTER_IGNORE
 ring.hide()
 gem.add_child(ring)

func select(index: int) -> void:
 if not can_act():
  return
 selected = index
 casting = -1
 summoning = -1
 healing = false
 magic = duel.has_magic_target(0,index)
 redraw()

func play(index: int) -> void:
 if not can_act() or index < 0 or index >= duel.players[0].hand.size():
  return
 summoning=-1
 spell_targets.clear()
 var data: CardData=Match.CARD_DATA[duel.players[0].hand[index]]
 var owner: int=Match.entry_target_side(0,data.combat_data())
 if data.entry_needs_target() and owner>=0 and not duel.entry_valid_targets(0,data.combat_data()).is_empty():
  summoning=index
  casting=-1
  selected=-1
  healing=false
  magic=false
  redraw()
  return
 if Match.CARD_DATA[duel.players[0].hand[index]].card_type == CardData.CardType.SPELL:
  if not duel.has_spell_target(0,index):
   return
  if data.spell_effect in [CardData.SpellEffect.AREA_ARCANE,CardData.SpellEffect.HORDE_ROAR] or (data.spell_effect==CardData.SpellEffect.RECONSTRUCT and not has_allied_wall()):
   casting=index
   await cast_target(1 if data.spell_effect==CardData.SpellEffect.AREA_ARCANE else 0,-1)
   return
  summoning=-1
  casting = index
  selected = -1
  healing = false
  magic = false
  redraw()
  return
 if not duel.play(0, index):
  return
 play_sound("summon")
 casting = -1
 summoning = -1
 selected = -1
 healing = false
 magic = false
 redraw()
 show_summon_feedback.call_deferred(duel.last_action.duplicate(true))
 animate_summon_poison(duel.last_action.duplicate(true))

func target(index: int) -> void:
 if can_act() and selected >= 0 and not healing:
  var snapshot := field_nodes.duplicate()
  if not duel.act(0, selected, index, magic):
   notify_blocked_attack(index)
   return
  set_busy(true)
  selected = -1
  magic = false
  await animate_action(duel.last_action, snapshot)
  set_busy(false)
  redraw()

func can_attack_all() -> bool:
 for index in range(duel.players[0].board.size()):
  if duel.preferred_attack_target(0,index)!=-2:return true
 return false

func attack_all() -> void:
 if not can_act() or not can_attack_all():return
 var attackers: Array=[]
 for unit in duel.players[0].board:attackers.append(unit.id)
 selected=-1;casting=-1;summoning=-1;magic=false;healing=false
 set_busy(true)
 for id in attackers:
  if duel.winner!=-1 or duel.turn!=0:break
  var index: int=-1
  for current in range(duel.players[0].board.size()):
   if duel.players[0].board[current].id==id:index=current;break
  if index<0:continue
  var destination: int=duel.preferred_attack_target(0,index)
  if destination==-2:continue
  var snapshot: Array=field_nodes.duplicate()
  if not duel.act(0,index,destination,false):continue
  await animate_action(duel.last_action,snapshot)
  redraw()
  await get_tree().process_frame
  await get_tree().process_frame
 set_busy(false)
 redraw()

func cast_target(target_side: int, index: int) -> void:
 if not can_act() or casting < 0:
  return
 var snapshot := field_nodes.duplicate()
 if duel.spell_target_count(0,casting)>1:
  if not duel.can_cast(0,casting,target_side,index):return
  var choice:Dictionary={"side":target_side,"index":index}
  if choice in spell_targets:
   spell_targets.erase(choice);redraw();return
  spell_targets.append(choice)
  if spell_targets.size()<duel.spell_target_count(0,casting):redraw();return
  if not duel.cast_multiple(0,casting,spell_targets):spell_targets.clear();redraw();return
 else:
  if not duel.cast(0,casting,target_side,index):return
 casting = -1
 summoning = -1
 selected = -1
 healing = false
 magic = false
 set_busy(true)
 await animate_action(duel.last_action,snapshot)
 set_busy(false)
 redraw()

func select_heal(quick: bool=false) -> void:
 if not can_act() or selected < 0:
  return
 healing = true
 quick_healing=quick
 magic = false
 redraw()

func heal_target(index: int, target_side: int=0) -> void:
 if not can_act() or not healing:
  return
 var snapshot := field_nodes.duplicate()
 if not duel.heal(0, selected, index,target_side,quick_healing):
  return
 set_busy(true)
 selected = -1
 healing = false
 magic = false
 await animate_action(duel.last_action, snapshot)
 set_busy(false)
 redraw()

func use_fury() -> void:
 var snapshot:=field_nodes.duplicate()
 if can_act() and duel.fury(0, selected):
  set_busy(true)
  await animate_action(duel.last_action,snapshot)
  set_busy(false)
  selected = -1
  healing = false
  magic = false
  redraw()

func end_turn() -> void:
 if not can_act():
  return
 casting = -1
 summoning = -1
 selected = -1
 healing = false
 magic = false
 var snapshot := field_nodes.duplicate()
 set_busy(true)
 duel.end_turn(0)
 await animate_action(duel.last_action,snapshot)
 redraw()
 if duel.turn==1 and duel.winner==-1:
  await run_ai_turn()
 else:
  set_busy(false)
  redraw()

func run_ai_turn() -> void:
 set_busy(true)
 await get_tree().create_timer(0.65).timeout
 while duel.turn == 1 and duel.winner == -1:
  var snapshot := field_nodes.duplicate()
  if not duel.ai_step():break
  if duel.last_action.get("kind","")=="spell":
   await show_enemy_spell(duel.last_action)
  if duel.last_action.get("kind","")=="summon":
   redraw()
   snapshot=field_nodes.duplicate()
  await animate_action(duel.last_action,snapshot)
  redraw()
  await get_tree().create_timer(0.25).timeout
 if duel.turn==1 and duel.winner==-1:
  var snapshot := field_nodes.duplicate()
  duel.end_turn(1)
  await animate_action(duel.last_action,snapshot)
 set_busy(false)
 redraw()

func create_enemy_spell_preview(action: Dictionary) -> CanvasLayer:
 var key: String=String(action.get("card",""))
 if int(action.get("side",-1))!=1 or action.get("kind","")!="spell" or not Match.CARD_DATA.has(key):return null
 var overlay:=CanvasLayer.new()
 overlay.name="EnemySpellPreview"
 overlay.layer=24
 add_child(overlay)
 var margin:=MarginContainer.new()
 margin.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
 margin.offset_left=-266;margin.offset_right=-24
 margin.offset_top=70;margin.offset_bottom=414
 margin.mouse_filter=Control.MOUSE_FILTER_IGNORE
 overlay.add_child(margin)
 var panel:=PanelContainer.new()
 panel.add_theme_stylebox_override("panel",UiTheme.panel(Color("101b2b"),Color("c7996c"),8))
 panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
 margin.add_child(panel)
 var content:=VBoxContainer.new()
 content.add_theme_constant_override("separation",5)
 content.mouse_filter=Control.MOUSE_FILTER_IGNORE
 panel.add_child(content)
 var title:=label_text("MAGIA DA IA",15)
 title.add_theme_color_override("font_color",Color("f1b3a7"))
 title.mouse_filter=Control.MOUSE_FILTER_IGNORE
 content.add_child(title)
 var card: Control=CardScene.instantiate()
 card.name="EnemySpellCard"
 card.custom_minimum_size=Vector2(210,280)
 card.mouse_filter=Control.MOUSE_FILTER_IGNORE
 card.set_card(Match.CARD_DATA[key])
 content.add_child(card)
 return overlay

func show_enemy_spell(action: Dictionary) -> void:
 var overlay:=create_enemy_spell_preview(action)
 if not is_instance_valid(overlay):return
 await get_tree().create_timer(1.5).timeout
 if is_instance_valid(overlay):overlay.queue_free()

func status_effect(kind: String,node: Control,amount: int=0) -> Tween:
 if not is_instance_valid(node):return null
 var effect=StatusVfx.new()
 effect.name="StatusEffect_"+kind
 effect.configure(kind,node.get_global_rect(),amount)
 vfx_layer.add_child(effect)
 var tween:=create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
 tween.tween_property(effect,"progress",1.0,0.38 if kind=="block" else 0.45)
 tween.finished.connect(effect.queue_free)
 return tween

func float_result(node: Control, value: String, color: Color, vertical_offset: float=0.0) -> void:
 if not is_instance_valid(node):return
 var number:=Label.new()
 number.name="FloatingResult"
 number.text=value
 number.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 number.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
 number.mouse_filter=Control.MOUSE_FILTER_IGNORE
 number.position=node.get_global_rect().get_center()+Vector2(-90,-25+vertical_offset)
 number.size=Vector2(180,48)
 number.add_theme_font_size_override("font_size",28)
 number.add_theme_color_override("font_color",color)
 number.add_theme_color_override("font_outline_color",Color("10131b"))
 number.add_theme_constant_override("outline_size",5)
 vfx_layer.add_child(number)
 var tween:=create_tween().set_parallel(true)
 tween.tween_property(number,"position:y",number.position.y-36,0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
 tween.tween_property(number,"modulate:a",0.0,0.8).set_delay(0.35)
 tween.finished.connect(number.queue_free)

func show_armor_from_summon(action: Dictionary, snapshot: Array) -> void:
 var amount: int=int(action.get("buff_armor",0))
 if amount<=0:return
 var node: Control=snapshot[int(action.side)].get(action.get("buff_target",-1))
 float_result(node,"+%d armadura" % amount,Color("e8d18a"))

func animate_records(records: Array,snapshot: Array,effect: String,sound: String) -> void:
 if records.is_empty():return
 # Wait for freshly redrawn cards to receive their container positions.
 await get_tree().process_frame
 await get_tree().process_frame
 play_sound(sound)
 var last: Tween
 for entry in records:
  var node: Control=find_child("PlayerCastle" if entry.side==0 else "EnemyCastle",true,false) if entry.castle else snapshot[entry.side].get(entry.id)
  if is_instance_valid(node):last=status_effect(effect,node,int(entry.get("amount",0)))
 if last:await last.finished

func blocked_castle_input(event: InputEvent) -> void:
 if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
  get_viewport().set_input_as_handled()
  notify_blocked_attack(-1)

func notify_blocked_attack(target_index: int) -> void:
 if not can_act() or magic or healing or casting>=0 or summoning>=0:return
 var guards:=duel.attack_blockers(0,selected,target_index)
 if guards.is_empty() or Time.get_ticks_msec()<block_feedback_until:return
 block_feedback_until=Time.get_ticks_msec()+300
 play_sound("block")
 for index in guards:
  var unit: Dictionary=duel.players[1].board[index]
  var node: Control=field_nodes[1].get(unit.id)
  if is_instance_valid(node):status_effect("block",node)

func animate_action(action: Dictionary, snapshot: Array) -> void:
 var kind: String = action.get("kind", "")
 if kind=="fury":
  play_sound("fury")
  var fury_source: Control=snapshot[int(action.side)].get(action.attacker)
  if is_instance_valid(fury_source):await status_effect("fury",fury_source).finished
  await animate_records(action.get("bleeding_damage",[]),snapshot,"bleed","poison_tick")
  await animate_deaths(action,snapshot)
  return
 if kind=="summon":
  play_sound("summon")
  show_armor_from_summon(action,snapshot)
  if action.has("granted_ability"):
   play_sound("buff")
   var recipient: Control=snapshot[int(action.side)].get(action.get("buff_target",-1))
   if is_instance_valid(recipient):await status_effect("spell_buff",recipient).finished
  await animate_poison_bottles(action,snapshot)
  await animate_records(action.get("poisoned",[]),snapshot,"poison_apply","poison_apply")
  return
 if kind in ["poison","turn_end"]:
  await animate_records(action.get("ticks",[]),snapshot,"poison_tick","poison_tick")
  await animate_records(action.get("regenerated",[]),snapshot,"heal","regeneration")
  await animate_devotion(action,snapshot)
  await animate_deaths(action,snapshot)
  return
 if kind not in ["attack", "magic", "heal", "spell"]:
  return
 var side: int = action.side
 var attacker: Control = snapshot[side].get(action.attacker)
 var destination: Control
 if kind == "spell":
  destination = find_child("PlayerCastle" if action.target_side==0 else "EnemyCastle",true,false) if action.castle else snapshot[action.target_side].get(action.target)
 elif action.castle:
  destination = find_child(("PlayerCastle" if side == 0 else "EnemyCastle") if kind == "heal" else ("EnemyCastle" if side == 0 else "PlayerCastle"), true, false)
 else:
  destination = snapshot[int(action.get("target_side",side if kind == "heal" else 1-side))].get(action.target)
 if kind == "spell":
  if int(action.effect)==CardData.SpellEffect.MAGIC_MISSILES:
   var source:Control=find_child("PlayerCastle" if side==0 else "EnemyCastle",true,false)
   for hit in action.get("missile_hits",[]):
    var victim:Control=find_child("PlayerCastle" if hit.side==0 else "EnemyCastle",true,false) if hit.get("castle",false) else snapshot[hit.side].get(hit.id)
    if is_instance_valid(source) and is_instance_valid(victim):
     await animate_missile(source,victim)
     float_result(victim,"−%d" % int(hit.amount),Color("ff8d86"))
  elif int(action.effect)==CardData.SpellEffect.HORDE_ROAR:
   await animate_records(action.get("buffs",[]),snapshot,"fury","fury")
  elif int(action.effect)==CardData.SpellEffect.AREA_ARCANE:
   await animate_records(action.get("area_hits",[]),snapshot,"fire","fire")
  elif int(action.effect) in [CardData.SpellEffect.SHADOW_STEP,CardData.SpellEffect.FORTIFY,CardData.SpellEffect.VIGOR] and is_instance_valid(destination):
   play_sound("buff")
   var effect:Tween=status_effect("spell_buff",destination)
   if int(action.get("armor_gain",0))>0:float_result(destination,"+%d armadura" % int(action.armor_gain),Color("e8d18a"))
   if effect:await effect.finished
  elif int(action.effect) in [CardData.SpellEffect.RESTORE,CardData.SpellEffect.RECONSTRUCT]:
   if action.get("undead_damage",false) and is_instance_valid(destination):
    await animate_missile(find_child("PlayerCastle" if side==0 else "EnemyCastle",true,false),destination)
    float_result(destination,"−%d" % int(action.get("amount",0)),Color("ff8d86"))
   elif action.get("healed",[]).is_empty():play_sound("magic")
   else:await animate_records(action.healed,snapshot,"heal","heal")
  elif int(action.effect) in [CardData.SpellEffect.ARCANE,CardData.SpellEffect.CONDUCTIVE] and is_instance_valid(destination):
   var source: Control = find_child("PlayerCastle" if side==0 else "EnemyCastle",true,false)
   await animate_missile(source,destination)
   float_result(destination,"−%d" % int(action.get("amount",0)),Color("ff8d86"))
  else:
   play_sound("magic")
   if is_instance_valid(destination):
    var glow: Control = destination.get_node("Canvas") if destination.has_node("Canvas") else destination
    var original: Color = glow.modulate
    var pulse := create_tween()
    pulse.tween_property(glow,"modulate",Color(1.15,1.5,1.25),0.08)
    pulse.tween_property(glow,"modulate",original,0.18)
    await pulse.finished
 elif kind == "heal":
  await animate_records(action.get("healed",[]),snapshot,"heal","heal")
 elif kind=="magic" and action.has("fire_hits"):
  await animate_records(action.fire_hits,snapshot,"fire","fire")
 elif kind == "magic" and is_instance_valid(attacker) and is_instance_valid(destination):
  await animate_missile(attacker, destination)
  float_result(destination,"−%d" % int(action.get("amount",0)),Color("ff8d86"))
 elif is_instance_valid(attacker) and is_instance_valid(destination):
  var canvas: Control = attacker.get_node("Canvas")
  var start := canvas.position
  var travel := destination.get_global_rect().get_center() - attacker.get_global_rect().get_center()
  attacker.z_index = 10
  var lunge := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
  lunge.tween_property(canvas, "position", start + travel * 0.82, 0.18)
  await lunge.finished
  play_sound("castle" if action.castle else "attack")
  float_result(destination,"−%d" % int(action.get("amount",0)),Color("ff8d86"))
  if int(action.get("absorbed",0))>0:float_result(destination,"Armadura %d" % int(action.absorbed),Color("e8d18a"),38)
  if not action.castle:
   float_result(attacker,"−%d" % int(action.get("received",0)),Color("ff8d86"))
   if int(action.get("counter_absorbed",0))>0:float_result(attacker,"Armadura %d" % int(action.counter_absorbed),Color("e8d18a"),38)
  var hit: Control = destination.get_node("Canvas") if destination.has_node("Canvas") else destination
  var initial_color := hit.modulate
  var recoil := create_tween().set_parallel(true)
  recoil.tween_property(canvas, "position", start, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
  recoil.tween_property(hit, "modulate", Color(1.6, 0.75, 0.75), 0.06)
  recoil.chain().tween_property(hit, "modulate", initial_color, 0.08)
  await recoil.finished
  attacker.z_index = 0
 else:
  play_sound("magic" if kind == "magic" else ("castle" if action.castle else "attack"))
 await animate_records(action.get("poisoned",[]),snapshot,"poison_apply","poison_apply")
 await animate_records(action.get("bleeding_applied",[]),snapshot,"bleed","poison_apply")
 await animate_records(action.get("bleeding_damage",[]),snapshot,"bleed","poison_tick")
 await animate_devotion(action,snapshot)
 await animate_resonance(action,snapshot)
 await animate_deaths(action,snapshot)

func animate_devotion(action: Dictionary,snapshot: Array) -> void:
 var buffs: Array=action.get("devotion_buffs",[])
 if buffs.is_empty():return
 var totals: Dictionary={}
 for entry in buffs:
  var key: String="%d:%d" % [entry.side,entry.id]
  if not totals.has(key):totals[key]={"side":entry.side,"id":entry.id,"amount":0}
  totals[key].amount+=int(entry.amount)
 var tween: Tween
 var played:=false
 for entry in totals.values():
  var node: Control=snapshot[int(entry.side)].get(entry.id)
  if not is_instance_valid(node):continue
  if not played:
   play_sound("devotion")
   played=true
  tween=status_effect("devotion",node)
  float_result(node,"+%d/+%d" % [entry.amount,entry.amount],Color("8ff7a9"))
 if tween:await tween.finished

func animate_resonance(action: Dictionary,snapshot: Array) -> void:
 var buffs: Array=action.get("resonance_buffs",[])
 if buffs.is_empty():return
 var totals: Dictionary={}
 for entry in buffs:
  var key: String="%d:%d" % [entry.side,entry.id]
  if not totals.has(key):totals[key]={"side":entry.side,"id":entry.id,"amount":0}
  totals[key].amount+=int(entry.amount)
 var tween: Tween
 var played:=false
 for entry in totals.values():
  var node: Control=snapshot[int(entry.side)].get(entry.id)
  if not is_instance_valid(node):continue
  if not played:
   play_sound("resonance")
   played=true
  tween=status_effect("resonance",node)
  float_result(node,"+%d/+%d" % [entry.amount,entry.amount],Color("96ceff"))
 if tween:await tween.finished

func animate_deaths(action: Dictionary,snapshot: Array) -> void:
 if not action.get("dead",[]).is_empty():
  play_sound("death")
  var fade := create_tween().set_parallel(true)
  var found := false
  for victim in action.dead:
   var node: Control = snapshot[victim.side].get(victim.id)
   if not is_instance_valid(node):
    continue
   found = true
   status_effect("destroy",node)
   var canvas: Control = node.get_node("Canvas")
   canvas.pivot_offset = Vector2(100, 100)
   fade.tween_property(canvas, "modulate:a", 0.0, 0.32)
   fade.tween_property(canvas, "scale", canvas.scale * 0.82, 0.32)
  if found:
   await fade.finished
  else:
   fade.kill()

func animate_summon_poison(action: Dictionary) -> void:
 if action.get("poisoned",[]).is_empty():return
 await get_tree().process_frame
 await get_tree().process_frame
 var snapshot:=field_nodes.duplicate()
 await animate_poison_bottles(action,snapshot)
 await animate_records(action.get("poisoned",[]),snapshot,"poison_apply","poison_apply")

func animate_poison_bottles(action: Dictionary, snapshot: Array) -> void:
 var records: Array=action.get("poisoned",[])
 if records.is_empty():return
 await get_tree().process_frame
 await get_tree().process_frame
 var source: Control=snapshot[int(action.side)].get(action.attacker)
 if not is_instance_valid(source):return
 var flights:=create_tween().set_parallel(true)
 var bottles: Array[Control]=[]
 for entry in records:
  var target: Control=snapshot[int(entry.side)].get(entry.id)
  if not is_instance_valid(target):continue
  var bottle:=TextureRect.new()
  bottle.name="PoisonBottle"
  bottle.texture=load("res://assets/ui/poison-bottle.svg")
  bottle.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
  bottle.mouse_filter=Control.MOUSE_FILTER_IGNORE
  bottle.size=Vector2(50,62)
  bottle.pivot_offset=bottle.size/2
  bottle.position=source.get_global_rect().get_center()-bottle.pivot_offset
  vfx_layer.add_child(bottle)
  bottles.append(bottle)
  flights.tween_property(bottle,"position",target.get_global_rect().get_center()-bottle.pivot_offset,0.36).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
  flights.tween_property(bottle,"rotation",TAU,0.36)
 if bottles.is_empty():
  flights.kill()
  return
 play_sound("poison_throw")
 await flights.finished
 for bottle in bottles:
  if is_instance_valid(bottle):bottle.queue_free()

func animate_missile(attacker: Control, destination: Control) -> void:
 var missile := TextureRect.new()
 missile.name = "MagicMissile"
 missile.texture = CardVfxSkin.texture("magic-missile")
 missile.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 missile.stretch_mode = TextureRect.STRETCH_SCALE
 missile.mouse_filter = Control.MOUSE_FILTER_IGNORE
 missile.size = Vector2(130, 52)
 missile.pivot_offset = missile.size * 0.5
 var source := attacker.get_global_rect().get_center()
 var target_point := destination.get_global_rect().get_center()
 missile.position = source - missile.pivot_offset
 missile.rotation = (target_point - source).angle()
 vfx_layer.add_child(missile)
 play_sound("magic")
 var flight := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
 flight.tween_property(missile, "position", target_point - missile.pivot_offset, 0.38)
 await flight.finished
 missile.queue_free()
 var hit: Control = destination.get_node("Canvas") if destination.has_node("Canvas") else destination
 var original := hit.modulate
 var impact := create_tween()
 impact.tween_property(hit, "modulate", Color(1.3, 0.8, 1.8), 0.06)
 impact.tween_property(hit, "modulate", original, 0.12)
 await impact.finished

func restart() -> void:
 # Prevent an outstanding AI coroutine from entering the new match.
 if busy:
  return
 if not Match.valid_deck(deck_store.active_cards()):
  needs_deck_fix=true
  open_decks()
  return
 clear_result()
 result_shown = false
 if is_instance_valid(board_background):board_background.choose_random_background()
 casting = -1
 summoning = -1
 enemy_deck=MatchSetup.choose_enemy(deck_store)
 duel = Match.new(deck_store.active_cards(), enemy_deck,(randi_range(0,1) if starting_player<0 else starting_player) if enable_opening else 0,enable_opening)
 selected = -1
 healing = false
 magic = false
 redraw()
 if duel.opening:show_mulligan()

func open_decks() -> void:
 if busy or is_instance_valid(deck_editor):
  return
 hide_preview()
 get_viewport().gui_release_focus()
 deck_editor_layer = CanvasLayer.new()
 deck_editor_layer.layer = 30
 add_child(deck_editor_layer)
 deck_editor = DeckEditorScene.instantiate()
 deck_editor.configure(deck_store)
 deck_editor.theme = theme
 deck_editor_layer.add_child(deck_editor)
 deck_editor.closed.connect(close_decks)
 deck_editor.play_requested.connect(play_selected_deck)

func close_decks(restart_fixed: bool=true) -> void:
 if is_instance_valid(deck_editor_layer):
  remove_child(deck_editor_layer)
  deck_editor_layer.queue_free()
 deck_editor = null
 deck_editor_layer = null
 redraw()
 if restart_fixed and needs_deck_fix and Match.valid_deck(deck_store.active_cards()):
  needs_deck_fix=false
  restart()

func play_selected_deck() -> void:
 close_decks(false)
 needs_deck_fix=false
 restart()

func finish_if_needed() -> void:
 if duel.winner == -1 or busy or result_shown:
  return
 result_shown = true
 hide_preview()
 result_layer = CanvasLayer.new()
 result_layer.layer = 40
 add_child(result_layer)
 result_overlay = ResultScene.instantiate()
 result_overlay.configure(duel.winner, deck_store.slots[deck_store.active].name, duel.players[0].hp)
 result_layer.add_child(result_overlay)
 result_overlay.replay_requested.connect(restart)
 result_overlay.deck_requested.connect(func(): clear_result(); open_decks())
 result_overlay.menu_requested.connect(func(): get_tree().change_scene_to_file("res://start_menu.tscn"))
 result_overlay.dismissed.connect(clear_result)
 if duel.winner == 0:
  play_sound("victory")
 elif duel.winner == 1:
  play_sound("death")

func clear_result() -> void:
 if is_instance_valid(result_layer):
  remove_child(result_layer)
  result_layer.queue_free()
 result_layer = null
 result_overlay = null

func is_card_name_character(character: String) -> bool:
 return character!="" and (character.to_lower()!=character.to_upper() or character in "0123456789_")

func log_card_segments(message: String) -> Array:
 var result: Array=[]
 var position:=0
 while position<message.length():
  var best_position:=message.length()
  var best_key: String=""
  var best_length:=0
  for key in Match.CARD_DATA:
   var title: String=Match.CARD_DATA[key].title
   if title.is_empty():continue
   var found:=message.find(title,position)
   while found>=0:
    var after:=found+title.length()
    var before_ok: bool=found==0 or not is_card_name_character(message.substr(found-1,1))
    var after_ok: bool=after>=message.length() or not is_card_name_character(message.substr(after,1))
    if before_ok and after_ok:break
    found=message.find(title,found+1)
   if found>=0 and (found<best_position or (found==best_position and title.length()>best_length)):
    best_position=found;best_key=key;best_length=title.length()
  if best_key.is_empty():
   result.append({"text":message.substr(position),"key":""})
   break
  if best_position>position:result.append({"text":message.substr(position,best_position-position),"key":""})
  result.append({"text":message.substr(best_position,best_length),"key":best_key})
  position=best_position+best_length
 return result

func refresh_match_log() -> void:
 log_count=duel.history.size()
 log_text.clear()
 for index in range(log_count):
  var side: int=duel.history_sides[index] if index<duel.history_sides.size() else -1
  log_text.push_color(Color("bfe3f5") if side==0 else Color("f1b3a7") if side==1 else Color("f2ead9"))
  for segment in log_card_segments(duel.history[index]):
   if not segment.key.is_empty():
    log_text.push_meta(segment.key,RichTextLabel.META_UNDERLINE_ALWAYS,"Ver carta")
    log_text.add_text(segment.text)
    log_text.pop()
   else:log_text.add_text(segment.text)
  log_text.pop()
  log_text.add_text("\n\n")

func show_log_card(key: Variant) -> void:
 var card_key:=String(key)
 if not Match.CARD_DATA.has(card_key):return
 if not is_instance_valid(log_card_dialog):
  log_card_dialog=PopupPanel.new()
  log_card_dialog.name="HistoryCardDialog"
  log_card_dialog.add_theme_stylebox_override("panel",StyleBoxEmpty.new())
  log_dialog.add_child(log_card_dialog)
  log_card_view=CardScene.instantiate()
  log_card_view.name="HistoryCard"
  log_card_view.custom_minimum_size=Vector2(400,534)
  log_card_view.set_meta("disable_art_viewer",true)
  log_card_view.set_meta("preview_managed",true)
  log_card_dialog.add_child(log_card_view)
 log_card_view.set_card(Match.CARD_DATA[card_key])
 log_card_dialog.popup_centered(Vector2i(400,534))

func show_match_log() -> void:
 hide_preview()
 if not is_instance_valid(log_dialog):
  log_dialog=AcceptDialog.new()
  log_dialog.title="Histórico da partida · clique nos nomes para ver as cartas"
  log_text=RichTextLabel.new()
  log_text.custom_minimum_size=Vector2(820,540)
  log_text.scroll_following=true
  log_text.selection_enabled=false
  log_text.add_theme_font_size_override("normal_font_size",18)
  log_text.meta_clicked.connect(show_log_card)
  log_dialog.add_child(log_text)
  add_child(log_dialog)
 refresh_match_log()
 log_dialog.popup_centered(Vector2i(880,620))

func show_rules() -> void:
 if is_instance_valid(rules_dialog):
  rules_dialog.popup_centered(Vector2i(840, 600))
  return
 var dialog := AcceptDialog.new()
 rules_dialog = dialog
 dialog.title = "Manual do duelo"
 var manual := RichTextLabel.new()
 manual.custom_minimum_size = Vector2(780, 500)
 manual.text = FileAccess.get_file_as_string("res://MANUAL.txt")
 manual.scroll_active = true
 dialog.add_child(manual)
 add_child(dialog)
 dialog.popup_centered(Vector2i(840, 600))
 dialog.confirmed.connect(dialog.queue_free)


func show_mulligan() -> void:
 hide_preview()
 if is_instance_valid(mulligan_layer):
  remove_child(mulligan_layer)
  mulligan_layer.queue_free()
 mulligan_layer=CanvasLayer.new()
 mulligan_layer.layer=50
 add_child(mulligan_layer)
 mulligan_view=Control.new()
 mulligan_view.set_script(MulliganView)
 mulligan_view.configure(duel)
 mulligan_layer.add_child(mulligan_view)
 mulligan_view.confirmed.connect(finish_mulligan)

func finish_mulligan(indices: Array) -> void:
 if not duel.mulligan(0,indices):return
 while duel.opening and not duel.mulligan_done[1]:
  var swaps: Array=[]
  var limit: int=duel.mulligan_max_cards(1)
  for i in range(duel.players[1].hand.size()):
   if Match.CARD_DATA[duel.players[1].hand[i]].cost>=4 and swaps.size()<limit:swaps.append(i)
  if not duel.mulligan(1,swaps):break
 if duel.opening:
  show_mulligan()
  return
 hide_preview()
 remove_child(mulligan_layer)
 mulligan_layer.queue_free()
 mulligan_layer=null
 mulligan_view=null
 redraw()
 if duel.turn==1 and duel.winner==-1:await run_ai_turn()

func summon_target(side: int,index: int,choice: String="") -> void:
 if not can_act() or summoning<0:return
 if side!=Match.entry_target_side(0,Match.CARDS[duel.players[0].hand[summoning]]):return
 var data: CardData=Match.CARD_DATA[duel.players[0].hand[summoning]]
 if data.entry_effect==CardData.EntryEffect.GRANT_ROGUE_CHOICE and choice.is_empty():
  show_rogue_choice(side,index)
  return
 if not duel.play(0,summoning,index,choice):return
 play_sound("summon")
 summoning=-1
 casting=-1
 selected=-1
 healing=false
 magic=false
 redraw()
 show_summon_feedback.call_deferred(duel.last_action.duplicate(true))
 animate_summon_poison(duel.last_action.duplicate(true))

func show_rogue_choice(side: int,index: int) -> void:
 if is_instance_valid(rogue_choice_dialog):rogue_choice_dialog.queue_free()
 var data: CardData=Match.CARD_DATA[duel.players[0].hand[summoning]]
 rogue_choice_dialog=AcceptDialog.new()
 rogue_choice_dialog.name="RogueChoiceMenu"
 rogue_choice_dialog.borderless=true
 rogue_choice_dialog.title="Chamado — Negociante de Segredos"
 rogue_choice_dialog.add_theme_stylebox_override("panel",UiTheme.panel(Color("101b24"),Color("b79b64"),24))
 add_child(rogue_choice_dialog)
 rogue_choice_dialog.get_ok_button().hide()
 var content:=VBoxContainer.new()
 content.custom_minimum_size=Vector2(720,310)
 content.add_theme_constant_override("separation",18)
 rogue_choice_dialog.add_child(content)
 var title:=label_text("OURO OU VENENO?",27)
 title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 title.modulate=Color("ead6a6")
 content.add_child(title)
 var target_name:=label_text("Conceder a %s" % duel.players[side].board[index].name,19)
 target_name.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 content.add_child(target_name)
 var choices:=HBoxContainer.new()
 choices.add_theme_constant_override("separation",20)
 content.add_child(choices)
 choices.add_child(rogue_choice_option("loot","Saquear %d" % data.entry_value,"Ao atacar o castelo inimigo,\ncompre %d carta(s)." % data.entry_value,"draw-icon",Color("d8b65e")))
 choices.add_child(rogue_choice_option("envenom","Envenenar %d" % data.entry_secondary,"Ataques e contra-ataques aplicam\nVeneno %d a criaturas." % data.entry_secondary,"envenom-icon",Color("8cd276")))
 var note:=label_text("Bônus permanente · Acumula com habilidades existentes",15)
 note.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 note.modulate=Color("a4b4bd")
 content.add_child(note)
 rogue_choice_dialog.add_cancel_button("Voltar")
 rogue_choice_dialog.custom_action.connect(func(choice):
  rogue_choice_dialog.hide()
  summon_target(side,index,choice))
 rogue_choice_dialog.popup_centered(Vector2i(790,420))

func rogue_choice_option(choice: String,title: String,description: String,icon_name: String,tint: Color) -> Button:
 var option:=Button.new()
 option.name="RogueChoice_"+choice
 option.custom_minimum_size=Vector2(350,205)
 option.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 option.add_theme_stylebox_override("normal",UiTheme.panel(Color("152530"),tint.darkened(0.4),18))
 option.add_theme_stylebox_override("hover",UiTheme.panel(Color("243844"),tint,18))
 option.add_theme_stylebox_override("pressed",UiTheme.panel(Color("0d1922"),tint.lightened(0.2),18))
 var column:=VBoxContainer.new()
 column.mouse_filter=Control.MOUSE_FILTER_IGNORE
 column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 column.offset_left=18;column.offset_right=-18;column.offset_top=18;column.offset_bottom=-18
 column.alignment=BoxContainer.ALIGNMENT_CENTER
 column.add_theme_constant_override("separation",12)
 option.add_child(column)
 var icon:=TextureRect.new()
 icon.texture=CardVfxSkin.texture(icon_name)
 icon.custom_minimum_size=Vector2(56,56)
 icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 icon.mouse_filter=Control.MOUSE_FILTER_IGNORE
 column.add_child(icon)
 var heading:=label_text(title,24)
 heading.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 heading.modulate=tint
 heading.mouse_filter=Control.MOUSE_FILTER_IGNORE
 column.add_child(heading)
 var details:=label_text(description,16)
 details.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 details.mouse_filter=Control.MOUSE_FILTER_IGNORE
 column.add_child(details)
 option.pressed.connect(func():rogue_choice_dialog.custom_action.emit(choice))
 return option

func show_summon_feedback(action: Dictionary) -> void:
 await get_tree().process_frame
 show_armor_from_summon(action,field_nodes)
 if action.has("granted_ability"):
  play_sound("buff")
  status_effect("spell_buff",field_nodes[int(action.side)].get(action.get("buff_target",-1)))


func selection_hint() -> String:
 if duel.winner!=-1:return ""
 if duel.turn==1:return "Turno da IA"
 if summoning>=0:return "Escolha outro aliado" if Match.entry_target_side(0,Match.CARDS[duel.players[0].hand[summoning]])==0 else "Escolha um inimigo"
 if casting>=0:
  if duel.spell_target_count(0,casting)>1:return "Alvos: %d/2" % spell_targets.size()
  return "Escolha um alvo"
 if selected>=0 and selected<duel.players[0].board.size():
  var unit: Dictionary=duel.players[0].board[selected]
  if not unit.ready:return "Recém-invocada" if unit.get("summoned_this_turn",false) and not unit.get("exhausting_action_taken",false) else "Já agiu"
 return ""

func hover_hand_card(card: Control,active: bool) -> void:
 if not is_instance_valid(card):return
 card.set_meta("hand_hover",active)
 if not active and mana_preview_owner==card:
  mana_preview_owner=null
  update_mana_cost_preview(-1)
 if card.has_meta("hover_tween"):
  var old: Tween=card.get_meta("hover_tween")
  if old and old.is_valid():old.kill()
 if active:
  await get_tree().create_timer(0.12).timeout
  if not is_instance_valid(card) or not card.get_meta("hand_hover",false) or ArtViewer.is_open(self):return
  mana_preview_owner=card
  update_mana_cost_preview(card.card_data.cost)
 card.pivot_offset=Vector2(card.size.x*0.5,card.size.y)
 card.z_index=30 if active else 0
 card.set_hint_forced(active)
 var tween:=create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
 card.set_meta("hover_tween",tween)
 tween.tween_property(card,"scale",Vector2.ONE*(1.72 if active else 1.0),0.15)
 var normal: Color=Color.WHITE if hand_card_can_play(int(String(card.name).get_slice("_",1))) else Color(0.58,0.62,0.7)
 tween.tween_property(card,"modulate",Color.WHITE if active else normal,0.15)

func update_mana_cost_preview(cost: int) -> void:
 var mana_bar:=find_child("PlayerMana",true,false)
 if not is_instance_valid(mana_bar):return
 var p: Dictionary=duel.players[0]
 var temporary: int=int(p.get("temporary_mana",0))
 var available: int=maxi(0,int(p.mana)-temporary)
 var paid: int=mini(maxi(cost,0),int(p.mana)) if cost>=0 else 0
 var temporary_paid: int=mini(temporary,paid)
 var normal_paid: int=mini(available,paid-temporary_paid)
 var temporary_gem:=mana_bar.find_child("TemporaryManaGem",true,false) as TextureRect
 var temporary_label:=mana_bar.find_child("TemporaryMana",true,false) as Label
 if temporary_gem:temporary_gem.get_node("ManaSpendRing").visible=temporary_paid>0
 if temporary_label:
  temporary_label.text="+%d → +%d" % [temporary,temporary-temporary_paid] if temporary_paid>0 else "+%d" % temporary
 for i in range(10):
  var gem:=mana_bar.find_child("ManaGem%d" % i,true,false) as TextureRect
  if not gem:continue
  var will_spend: bool=i>=available-normal_paid and i<available
  gem.get_node("ManaSpendRing").visible=will_spend

func hide_forecast() -> void:
 forecast_owner=null
 if is_instance_valid(forecast_panel):
  forecast_panel.hide()
  forecast_panel.queue_free()
 forecast_panel=null

func show_combat_forecast(target_index: int,owner: Control) -> bool:
 if not can_act() or selected<0 or healing or casting>=0 or summoning>=0:return false
 var result: Dictionary=duel.attack_forecast(0,selected,target_index,magic)
 if result.is_empty():return false
 hide_forecast()
 forecast_owner=owner
 forecast_panel=PanelContainer.new()
 forecast_panel.name="AttackForecast"
 forecast_panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
 forecast_panel.add_theme_stylebox_override("panel",UiTheme.panel(Color("101c29"),Color("a69268"),14))
 preview.get_parent().add_child(forecast_panel)
 var content:=RichTextLabel.new()
 content.bbcode_enabled=true
 content.fit_content=true
 content.scroll_active=false
 content.custom_minimum_size=Vector2(310,0)
 content.mouse_filter=Control.MOUSE_FILTER_IGNORE
 content.add_theme_font_size_override("normal_font_size",18)
 var info: String="[b]Prévia do combate[/b]\nCausa [color=#ffb28c]%d[/color] de dano" % result.damage
 if not result.castle:info+=" · Recebe [color=#ffb28c]%d[/color]" % result.received
 if result.absorbed>0:info+="\nArmadura do alvo absorve %d" % result.absorbed
 if result.flight_reduction>0:info+="\nVoo reduz o dano em %d" % result.flight_reduction
 if result.counter_absorbed>0:info+="\nSua Armadura absorve %d" % result.counter_absorbed
 for hit in result.get("splash_hits",[]):
  if hit.index==target_index:continue
  var victim: Dictionary=duel.players[1].board[hit.index]
  info+="\n%s: %d de dano" % [victim.name,hit.amount]
 if result.bleeding>0:info+="\nSangramento após agir: %d" % result.bleeding
 if result.warded:info+="\nGuarda Arcana anula o dano"
 if result.target_dies:info+="\n[color=#ff8c80]%s[/color]" % ("Castelo será destruído" if result.castle else "Alvo será destruído")
 if result.attacker_dies:info+="\n[color=#ff8c80]Sua criatura será destruída[/color]"
 content.text=info
 forecast_panel.add_child(content)
 var bounds:=owner.get_global_rect()
 var viewport:=get_viewport_rect().size
 forecast_panel.position=Vector2(clampf(bounds.end.x+12,12,viewport.x-350),clampf(bounds.position.y,12,viewport.y-240))
 return true
