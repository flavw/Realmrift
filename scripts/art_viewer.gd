extends CanvasLayer

var artwork: TextureRect
var lore_title: Label
var lore_text: Label
var event_mode := false
var event_caption: Label

static func is_open(owner: Node) -> bool:
 var tree_root := owner.get_tree().root
 return tree_root.has_meta("card_art_viewer") and is_instance_valid(tree_root.get_meta("card_art_viewer"))

static func open(owner: Node, data: CardData) -> void:
 if data == null:return
 var viewer = open_artwork(owner,data.artwork,false)
 if viewer == null:return
 viewer.lore_title.text = data.title
 viewer.lore_text.text = data.lore

static func open_event(owner: Node, texture: Texture2D, caption: String) -> void:
 var viewer = open_artwork(owner,texture,true)
 if viewer != null:viewer.event_caption.text = caption

static func open_artwork(owner: Node, texture: Texture2D, for_event: bool):
 if texture == null or is_open(owner):return null
 var viewer = load("res://scripts/art_viewer.gd").new()
 viewer.event_mode = for_event
 owner.get_tree().root.add_child(viewer)
 viewer.artwork.texture = texture
 owner.get_tree().root.set_meta("card_art_viewer",viewer)
 return viewer

func _ready() -> void:
 layer = 90
 var backdrop := ColorRect.new()
 backdrop.color = Color(0.008,0.012,0.02,1.0)
 backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
 add_child(backdrop)
 artwork = TextureRect.new()
 artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
 if event_mode:
  layout_event(backdrop)
  return
 backdrop.add_child(artwork)
 artwork.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 artwork.anchor_right=0.72
 artwork.offset_left=40
 artwork.offset_top=28
 artwork.offset_right=-40
 artwork.offset_bottom=-28
 var panel:=PanelContainer.new()
 panel.name="LorePanel"
 panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
 panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 panel.anchor_left=0.72
 panel.offset_left=12;panel.offset_right=-40;panel.offset_top=80;panel.offset_bottom=-80
 panel.add_theme_stylebox_override("panel",preload("res://scripts/ui_theme.gd").panel(Color("101c2c"),Color("8c7652"),24))
 backdrop.add_child(panel)
 var column:=VBoxContainer.new()
 column.alignment=BoxContainer.ALIGNMENT_CENTER
 column.add_theme_constant_override("separation",22)
 panel.add_child(column)
 lore_title=Label.new()
 lore_title.name="LoreTitle"
 lore_title.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 lore_title.add_theme_font_size_override("font_size",26)
 lore_title.add_theme_color_override("font_color",Color("e8cb8e"))
 column.add_child(lore_title)
 lore_text=Label.new()
 lore_text.name="LoreText"
 lore_text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 lore_text.add_theme_font_size_override("font_size",20)
 lore_text.add_theme_color_override("font_color",Color("e0d9c9"))
 column.add_child(lore_text)

func layout_event(backdrop: Control) -> void:
 var layout := VBoxContainer.new()
 layout.mouse_filter = Control.MOUSE_FILTER_IGNORE
 layout.add_theme_constant_override("separation",8)
 backdrop.add_child(layout)
 layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 layout.offset_left = 16
 layout.offset_right = -16
 layout.offset_top = 12
 layout.offset_bottom = -12
 artwork.size_flags_vertical = Control.SIZE_EXPAND_FILL
 layout.add_child(artwork)

 event_caption = Label.new()
 event_caption.name = "EventArtCaption"
 event_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
 event_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 event_caption.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
 event_caption.add_theme_font_override("font",preload("res://assets/fonts/card_title_font.tres"))
 event_caption.add_theme_font_size_override("font_size",22)
 event_caption.add_theme_color_override("font_color",Color("e8d3ab"))
 layout.add_child(event_caption)

func _input(event: InputEvent) -> void:
 if event is InputEventMouseButton and event.pressed:
  close()
 elif event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
  close()
 get_viewport().set_input_as_handled()

func close() -> void:
 if get_tree().root.get_meta("card_art_viewer",null)==self:
  get_tree().root.remove_meta("card_art_viewer")
 queue_free()
