extends Control

const UiTheme = preload("res://scripts/ui_theme.gd")
const Match = preload("res://scripts/match.gd")
const DeckScene = preload("res://deck_editor.tscn")
const TitleFont = preload("res://assets/fonts/title_font.tres")
const Music = preload("res://scripts/game_music.gd")
const MatchSetup=preload("res://scripts/match_setup.gd")
var store := DeckStore.new()
var deck_layer: CanvasLayer
var rules_dialog: AcceptDialog
var options_dialog: AcceptDialog
var play_button: Button
var credits_dialog: AcceptDialog
var deck_selector: AcceptDialog
var enemy_deck_picker: OptionButton
const CLASS_NAMES=["Guerreiro","Mago","Neutros","Ladino","Clérigo","Horda"]

func _ready() -> void:
 theme = UiTheme.build()
 Music.ensure(get_tree()).play_menu()
 var background := ColorRect.new()
 background.color = Color("09121d")
 background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 background.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(background)
 var arena := TextureRect.new()
 arena.name="MenuBackground"
 arena.texture = preload("res://assets/ui/realmrift-menu-background.webp")
 arena.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 arena.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
 arena.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 arena.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(arena)
 var center := CenterContainer.new()
 center.name="MenuComposition"
 center.anchor_bottom=1.0
 center.offset_left=80
 center.offset_right=640
 center.offset_top=64
 center.offset_bottom=-64
 add_child(center)
 var left := VBoxContainer.new()
 left.custom_minimum_size.x=520
 left.add_theme_constant_override("separation",16)
 center.add_child(left)
 var title := TextureRect.new()
 title.name="GameTitle"
 title.texture=preload("res://assets/ui/realmrift-logo.webp")
 title.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 title.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 title.custom_minimum_size=Vector2(520,250)
 title.mouse_filter=Control.MOUSE_FILTER_IGNORE
 left.add_child(title)
 var subtitle:=text_label("ENTRE REINOS. FORJE SUA LENDA.",15,Color("d7c298"))
 subtitle.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 left.add_child(subtitle)
 var space:=Control.new()
 space.custom_minimum_size.y=24
 left.add_child(space)
 play_button=menu_button("Jogar contra IA",show_deck_selector,"menu-play")
 play_button.name="PlayAI"
 play_button.custom_minimum_size.y=78
 play_button.add_theme_font_size_override("font_size",27)
 play_button.add_theme_stylebox_override("normal",menu_style(Color("302b22"),Color("bf9a57")))
 play_button.add_theme_stylebox_override("hover",menu_style(Color("493b27"),Color("f4d994")))
 left.add_child(play_button)
 var decks:=menu_button("Meus decks",open_decks,"menu-decks")
 decks.name="OpenDecks"
 left.add_child(decks)
 var divider:=HSeparator.new()
 var line:=StyleBoxLine.new()
 line.color=Color(0.7,0.56,0.32,0.3)
 line.thickness=1
 divider.add_theme_stylebox_override("separator",line)
 divider.custom_minimum_size.y=1
 left.add_child(divider)
 var utilities:=HBoxContainer.new()
 utilities.add_theme_constant_override("separation",12)
 left.add_child(utilities)
 for entry in [["Opções",show_options,"menu-rules"],["Créditos",show_credits,"menu-credits"]]:
  var button:=menu_button(entry[0],entry[1],entry[2])
  button.custom_minimum_size=Vector2(0,54)
  button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
  button.add_theme_font_size_override("font_size",18)
  utilities.add_child(button)
 var exit_button:=Button.new()
 exit_button.text="Sair do jogo"
 exit_button.flat=true
 exit_button.custom_minimum_size.y=42
 exit_button.add_theme_color_override("font_color",Color("a0a8af"))
 exit_button.pressed.connect(func():get_tree().quit())
 left.add_child(exit_button)
 var footer:=text_label("FLAVW  /  REALMRIFT",12,Color("8c969e"))
 footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
 footer.offset_left=90;footer.offset_right=600
 footer.offset_top=-38;footer.offset_bottom=-18
 add_child(footer)
 play_button.grab_focus()

func menu_style(fill: Color,border: Color) -> StyleBoxFlat:
 var style:=StyleBoxFlat.new()
 style.bg_color=fill
 style.border_color=border
 style.set_border_width_all(1)
 style.set_corner_radius_all(2)
 style.content_margin_left=28
 style.content_margin_right=28
 style.content_margin_top=10
 style.content_margin_bottom=10
 style.shadow_color=Color(0,0,0,0.35)
 style.shadow_size=10
 return style

func text_label(value: String, font_size: int, color: Color) -> Label:
 var label := Label.new()
 label.text = value
 label.add_theme_font_size_override("font_size", font_size)
 label.add_theme_color_override("font_color", color)
 return label

func menu_button(value: String, callback: Callable,icon_name: String="") -> Button:
 var button := Button.new()
 button.set_script(preload("res://scripts/menu_button.gd"))
 button.text=value
 button.custom_minimum_size=Vector2(0,66)
 button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 button.add_theme_font_size_override("font_size",23)
 button.add_theme_font_override("font",TitleFont)
 button.add_theme_color_override("font_color",Color("e9ddc4"))
 button.add_theme_color_override("font_hover_color",Color("fff2cd"))
 button.add_theme_color_override("font_focus_color",Color("fff2cd"))
 button.add_theme_stylebox_override("normal",menu_style(Color(0.055,0.075,0.095,0.88),Color("72644c")))
 button.add_theme_stylebox_override("hover",menu_style(Color("24303a"),Color("d2b375")))
 button.add_theme_stylebox_override("pressed",menu_style(Color("121d27"),Color("f2d99e")))
 var focus:=StyleBoxFlat.new()
 focus.bg_color=Color.TRANSPARENT
 focus.border_color=Color(0.91,0.79,0.52,0.6)
 focus.set_border_width_all(2)
 focus.expand_margin_left=4;focus.expand_margin_right=4
 focus.expand_margin_top=4;focus.expand_margin_bottom=4
 button.add_theme_stylebox_override("focus",focus)
 if icon_name!="":
  button.icon=load("res://assets/ui/%s.svg" % icon_name)
  button.expand_icon=true
  button.add_theme_constant_override("icon_max_width",27)
  button.add_theme_constant_override("h_separation",16)
 button.pressed.connect(callback)
 return button

func start_game() -> void:
 get_tree().change_scene_to_file("res://main.tscn")

func show_deck_selector() -> void:
 if is_instance_valid(deck_selector):
  deck_selector.queue_free()
 deck_selector=AcceptDialog.new()
 deck_selector.name="DeckSelector"
 deck_selector.title="Escolha um deck"
 deck_selector.min_size=Vector2i(620,560)
 var content:=VBoxContainer.new()
 content.custom_minimum_size=Vector2(570,430)
 content.add_theme_constant_override("separation",10)
 deck_selector.add_child(content)
 var opponent_row:=HBoxContainer.new()
 opponent_row.add_theme_constant_override("separation",12)
 content.add_child(opponent_row)
 opponent_row.add_child(text_label("Deck da IA",17,Color("a8c4d8")))
 enemy_deck_picker=OptionButton.new()
 enemy_deck_picker.name="EnemyDeckPicker"
 enemy_deck_picker.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 enemy_deck_picker.add_item("Aleatório",0)
 for i in range(DeckStore.SLOT_COUNT):
  var candidate: Dictionary=store.slots[i]
  if Match.valid_deck(candidate.cards) and DeckStore.accepts_base(store.base_for(i),candidate.cards):
   enemy_deck_picker.add_item(candidate.name,i+1)
 opponent_row.add_child(enemy_deck_picker)
 var intro:=text_label("Escolha seu deck para enfrentar a IA.",17,Color("a8c4d8"))
 content.add_child(intro)
 var scroll:=ScrollContainer.new()
 scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
 scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
 content.add_child(scroll)
 var list:=GridContainer.new()
 list.columns=3
 list.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 list.add_theme_constant_override("h_separation",12)
 list.add_theme_constant_override("v_separation",12)
 scroll.add_child(list)
 var count:=0
 for index in range(DeckStore.SLOT_COUNT):
  var saved: Dictionary=store.slots[index]
  var valid: bool=Match.valid_deck(saved.cards) and DeckStore.accepts_base(store.base_for(index),saved.cards)
  if not valid:
   continue
  count+=1
  var base: int=store.base_for(index)
  var button:=Button.new()
  button.name="SelectDeck_%d" % index
  button.tooltip_text="Jogar contra a IA com %s." % saved.name
  button.custom_minimum_size=Vector2(175,245)
  button.clip_contents=true
  button.pressed.connect(launch_with_deck.bind(index))
  list.add_child(button)
  var cover_key:String=store.cover_for(index)
  var art:=TextureRect.new()
  art.mouse_filter=Control.MOUSE_FILTER_IGNORE
  art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
  art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
  if Match.CARD_DATA.has(cover_key):art.texture=Match.CARD_DATA[cover_key].artwork
  button.add_child(art)
  art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  var panel:=PanelContainer.new()
  panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
  panel.add_theme_stylebox_override("panel",UiTheme.panel(Color(0.03,0.06,0.1,0.92),Color("a88d5d"),7))
  button.add_child(panel)
  panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
  panel.offset_top=-67
  var caption:=text_label(saved.name,16,Color("fff0ce"))
  caption.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
  panel.add_child(caption)
 if count==0:
  var empty:=text_label("Nenhum deck completo disponível. Monte um deck de 22 cartas primeiro.",17,Color("ff9b9b"))
  empty.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
  list.add_child(empty)
  var edit:=menu_button("Abrir meus decks",func(): deck_selector.hide();open_decks())
  edit.custom_minimum_size=Vector2(0,44)
  list.add_child(edit)
 add_child(deck_selector)
 deck_selector.get_ok_button().hide()
 deck_selector.popup_centered(Vector2i(660,600))

func launch_with_deck(index: int) -> void:
 if not store.activate(index):
  return
 MatchSetup.enemy_slot=enemy_deck_picker.get_selected_id()-1 if is_instance_valid(enemy_deck_picker) else -1
 if is_instance_valid(deck_selector):
  deck_selector.hide()
 start_game()

func open_decks() -> void:
 if is_instance_valid(deck_layer):
  return
 deck_layer = CanvasLayer.new()
 deck_layer.layer = 30
 add_child(deck_layer)
 var editor = DeckScene.instantiate()
 editor.return_label = "Voltar ao início"
 editor.configure(store)
 deck_layer.add_child(editor)
 editor.closed.connect(close_decks)
 editor.play_requested.connect(func():MatchSetup.enemy_slot=-1;start_game())

func close_decks() -> void:
 if is_instance_valid(deck_layer):
  remove_child(deck_layer)
  deck_layer.queue_free()
 deck_layer = null
 play_button.grab_focus()

func show_options() -> void:
 if not is_instance_valid(options_dialog):
  options_dialog=load("res://scripts/options_dialog.gd").new()
  add_child(options_dialog)
  options_dialog.configure(Music.ensure(get_tree()),show_rules)
 options_dialog.popup_centered(Vector2i(620,450))

func show_rules() -> void:
 if not is_instance_valid(rules_dialog):
  rules_dialog = AcceptDialog.new()
  rules_dialog.title = "Como jogar — Realmrift"
  var manual := RichTextLabel.new()
  manual.custom_minimum_size = Vector2(780,500)
  manual.text = FileAccess.get_file_as_string("res://MANUAL.txt")
  rules_dialog.add_child(manual)
  add_child(rules_dialog)
 rules_dialog.popup_centered(Vector2i(840,600))

func show_credits() -> void:
 if not is_instance_valid(credits_dialog):
  credits_dialog=AcceptDialog.new()
  credits_dialog.title="Créditos — Realmrift"
  var content:=RichTextLabel.new()
  content.custom_minimum_size=Vector2(620,440)
  content.bbcode_enabled=true
  content.text="[center][font_size=24]REALMRIFT[/font_size]\n\nCriação do jogo\n[b]Flavw[/b]\nAuxiliado pelo ChatGPT\n\nFonte\n[b]At-Dawn-Regular[/b]\nCriada por Aurora\n\nMúsica de combate\n[b]Chariots Of War[/b]\nAakash Gandhi\n\nAgradecimentos aos artistas e criadores cujos créditos acompanham os recursos usados no projeto.[/center]"
  credits_dialog.add_child(content)
  add_child(credits_dialog)
 credits_dialog.popup_centered(Vector2i(680,540))
