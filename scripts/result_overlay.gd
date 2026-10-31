extends Control

signal replay_requested
signal deck_requested
signal menu_requested
signal dismissed
const UiTheme = preload("res://scripts/ui_theme.gd")
const CardSkin = preload("res://scripts/card_skin.gd")
var winner := 0
var deck_name := ""
var remaining_life := 20
var intro_finished := false

func configure(result: int, name_of_deck: String, life: int) -> void:
 winner = result
 deck_name = name_of_deck
 remaining_life = life

func label(value: String, font_size: int, color: Color = Color("e7e3da")) -> Label:
 var text := Label.new()
 text.text = value
 text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 text.add_theme_font_size_override("font_size", font_size)
 text.add_theme_color_override("font_color", color)
 return text

func action(value: String, callback: Callable) -> Button:
 var button := Button.new()
 button.text = value
 button.custom_minimum_size = Vector2(240, 46)
 button.pressed.connect(callback)
 return button

func _ready() -> void:
 theme = UiTheme.build()
 var dim := ColorRect.new()
 dim.name = "Dim"
 dim.color = Color(0.015, 0.025, 0.045, 0.84)
 dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 dim.modulate.a = 0
 add_child(dim)
 var sparks := Control.new()
 sparks.set_script(preload("res://scripts/victory_sparks.gd"))
 sparks.set("celebrate", winner == 0)
 sparks.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(sparks)
 var panel := PanelContainer.new()
 panel.name = "ResultPanel"
 panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
 panel.offset_left = -390
 panel.offset_right = 390
 panel.offset_top = -300
 panel.offset_bottom = 300
 panel.custom_minimum_size = Vector2(780, 600)
 var gold := Color("dcc080") if winner == 0 else Color("929fb4")
 var border := UiTheme.panel(Color("101c2b"), gold, 28)
 border.set_border_width_all(2)
 border.shadow_size = 28
 panel.add_theme_stylebox_override("panel", border)
 add_child(panel)
 var content := VBoxContainer.new()
 content.alignment = BoxContainer.ALIGNMENT_CENTER
 content.add_theme_constant_override("separation", 12)
 panel.add_child(content)
 content.add_child(label("D U E L O   E N C E R R A D O", 14, gold))
 var emblem := TextureRect.new()
 emblem.texture = CardSkin.texture("victory-medallion")
 emblem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 emblem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 emblem.custom_minimum_size = Vector2(170, 170)
 emblem.mouse_filter = Control.MOUSE_FILTER_IGNORE
 if winner != 0:
  emblem.modulate = Color(0.7, 0.75, 0.9)
 content.add_child(emblem)
 var title := label(["VITÓRIA", "DERROTA", "EMPATE"][winner], 54, gold)
 title.name = "ResultTitle"
 title.add_theme_font_override("font", preload("res://assets/fonts/title_font.tres"))
 content.add_child(title)
 content.add_child(label(["O castelo inimigo caiu. A noite é sua.", "Seu castelo caiu. Um novo duelo espera por você.", "Os dois castelos caíram neste duelo."][winner], 21))
 var summary := label("Deck: %s   •   Vida restante: %d" % [deck_name, maxi(0, remaining_life)], 17, Color("91a8bb"))
 content.add_child(summary)
 var buttons := HBoxContainer.new()
 buttons.alignment = BoxContainer.ALIGNMENT_CENTER
 buttons.add_theme_constant_override("separation", 14)
 content.add_child(buttons)
 var replay := action("Jogar novamente", func(): replay_requested.emit())
 replay.name = "ReplayButton"
 UiTheme.primary(replay)
 buttons.add_child(replay)
 buttons.add_child(action("Menu inicial", func(): menu_requested.emit()))
 var view := action("Ver tabuleiro", func(): dismissed.emit())
 view.add_theme_font_size_override("font_size", 15)
 view.custom_minimum_size.y = 34
 content.add_child(view)
 panel.modulate.a = 0
 panel.scale = Vector2(0.9, 0.9)
 await get_tree().process_frame
 panel.pivot_offset = panel.size * 0.5
 var intro := create_tween().set_parallel(true)
 intro.tween_property(dim, "modulate:a", 1.0, 0.4)
 intro.tween_property(panel, "modulate:a", 1.0, 0.45)
 intro.tween_property(panel, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
 await intro.finished
 intro_finished = true
