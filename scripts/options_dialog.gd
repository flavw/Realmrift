extends AcceptDialog

const GameDisplaySettings=preload("res://scripts/game_display.gd")

var music: Node
var rules_action: Callable

func configure(audio: Node,rules: Callable) -> void:
 music=audio
 rules_action=rules
 title="Opções"
 name="OptionsDialog"
 var content:=VBoxContainer.new()
 content.custom_minimum_size=Vector2(540,330)
 content.add_theme_constant_override("separation",16)
 add_child(content)
 var music_slider:=add_slider(content,"Música","MusicVolume",music.music_volume)
 music_slider.value_changed.connect(func(value):music.set_music_volume(value/100.0))
 var effects_slider:=add_slider(content,"Efeitos sonoros","EffectsVolume",music.effects_volume)
 effects_slider.value_changed.connect(func(value):music.set_effects_volume(value/100.0))
 var display:=Button.new()
 display.name="DisplayMode"
 display.add_to_group("display_mode_buttons")
 display.text=display_text()
 display.custom_minimum_size.y=46
 display.pressed.connect(func():
  GameDisplaySettings.toggle(get_tree().root)
  display.text=display_text())
 content.add_child(display)
 var rules_button:=Button.new()
 rules_button.name="OptionsRules"
 rules_button.text="Regras"
 rules_button.custom_minimum_size.y=46
 rules_button.pressed.connect(func():hide();rules_action.call())
 content.add_child(rules_button)

func add_slider(parent: VBoxContainer,caption: String,node_name: String,initial: float) -> HSlider:
 var row:=HBoxContainer.new()
 row.add_theme_constant_override("separation",12)
 parent.add_child(row)
 var label:=Label.new()
 label.text=caption
 label.custom_minimum_size.x=150
 row.add_child(label)
 var slider:=HSlider.new()
 slider.name=node_name
 slider.min_value=0;slider.max_value=100;slider.step=1;slider.value=roundi(initial*100)
 slider.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 slider.custom_minimum_size=Vector2(250,40)
 row.add_child(slider)
 var amount:=Label.new()
 amount.text="%d%%" % int(slider.value)
 amount.custom_minimum_size.x=55
 row.add_child(amount)
 slider.value_changed.connect(func(value):amount.text="%d%%" % int(value))
 return slider

func display_text() -> String:
 return "Modo janela · F11" if GameDisplaySettings.is_fullscreen(get_tree().root) else "Tela cheia · F11"
