extends Control
signal confirmed(indices: Array)
const CardScene=preload("res://card_model.tscn")
const Match=preload("res://scripts/match.gd")
const UiTheme=preload("res://scripts/ui_theme.gd")
var game
var selected: Array=[]
var content: Control
func configure(value) -> void:
 game=value
func _ready() -> void:
 theme=UiTheme.build()
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 render()
func text_label(value: String,font_size: int=20) -> Label:
 var label:=Label.new()
 label.text=value
 label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 label.add_theme_font_size_override("font_size",font_size)
 return label
func render() -> void:
 if is_instance_valid(content):
  remove_child(content)
  content.queue_free()
 content=ColorRect.new()
 content.color=Color(0.025,0.045,0.075,0.98)
 add_child(content)
 content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var center:=CenterContainer.new()
 content.add_child(center)
 center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var page:=VBoxContainer.new()
 page.add_theme_constant_override("separation",20)
 center.add_child(page)
 var heading:=text_label("MÃO INICIAL · MULLIGAN GRÁTIS",28)
 heading.name="MulliganHeading"
 heading.modulate=Color("e5d2a4")
 page.add_child(heading)
 page.add_child(text_label("Você começa com 3 cartas." if game.first_player==0 else "Você joga em segundo: 4 cartas e 1 mana temporária no primeiro turno."))
 page.add_child(text_label("Clique nas cartas que deseja trocar.",17))
 var row:=HBoxContainer.new()
 row.alignment=BoxContainer.ALIGNMENT_CENTER
 row.add_theme_constant_override("separation",18)
 page.add_child(row)
 for i in range(game.players[0].hand.size()):
  var tile:=VBoxContainer.new()
  row.add_child(tile)
  var view=CardScene.instantiate()
  view.card_data=Match.CARD_DATA[game.players[0].hand[i]]
  view.custom_minimum_size=Vector2(220,294)
  view.gui_input.connect(card_input.bind(i))
  tile.add_child(view)
  if i in selected:
   var arrow:=Label.new()
   arrow.name="MulliganSelected"
   arrow.text="↻"
   arrow.mouse_filter=Control.MOUSE_FILTER_IGNORE
   arrow.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
   arrow.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
   arrow.add_theme_font_size_override("font_size",112)
   arrow.add_theme_color_override("font_color",Color("ffe098"))
   arrow.add_theme_color_override("font_outline_color",Color("16263c"))
   arrow.add_theme_constant_override("outline_size",8)
   view.add_child(arrow)
   arrow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var confirm:=Button.new()
 confirm.name="ConfirmMulligan"
 confirm.text=("Confirmar troca · %d carta(s)" % selected.size()) if not selected.is_empty() else "Manter mão e começar"
 confirm.custom_minimum_size.y=48
 confirm.pressed.connect(func():confirmed.emit(selected.duplicate()))
 UiTheme.primary(confirm)
 page.add_child(confirm)
 var tip:=text_label("A compra normal começa após as trocas.",14)
 tip.modulate=Color("91a7bc")
 page.add_child(tip)
 confirm.grab_focus()
func toggle_card(index: int) -> void:
 if index in selected:selected.erase(index)
 else:
  if game.mulligan_max_cards(0)==1:selected.clear()
  selected.append(index)
 selected.sort()
 render()
func card_input(event: InputEvent,index: int) -> void:
 if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
  toggle_card(index)
