extends PanelContainer
signal progress_requested
const Profile=preload("res://scripts/adventure_profile.gd")
const Identity=preload("res://scripts/player_identity.gd")
var run
func configure(state) -> void:run=state
func _ready() -> void:
 name="AdventureCompactHUD";custom_minimum_size=Vector2(558,144)
 add_theme_stylebox_override("panel",preload("res://scripts/ui_theme.gd").panel(Color("14252e"),Color("8f7951"),8))
 var row:=HBoxContainer.new();row.add_theme_constant_override("separation",25);add_child(row)
 var avatar=preload("res://scripts/player_avatar.gd").new();avatar.name="AdventureXPProgress"
 var level: int=run.profile.level() if run.profile!=null else 1
 var xp: int=run.profile.xp_in_level() if run.profile!=null else 0
 avatar.configure(Identity.avatar(),level,float(xp)/Profile.xp_cost(level));row.add_child(avatar)
 avatar.mouse_filter=Control.MOUSE_FILTER_STOP;avatar.focus_mode=Control.FOCUS_ALL;avatar.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND;avatar.tooltip_text="Nível %d · %d/%d XP\nClique para ver seu nível e poderes." % [level,xp,Profile.xp_cost(level)]
 avatar.gui_input.connect(func(event: InputEvent):
  if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed):
   avatar.accept_event();progress_requested.emit())
 add_stat(row,"Vida","res://assets/ui/hud-life.svg","%d/%d" % [run.current_life,run.max_life()],"Vida atual / máxima")
 add_stat(row,"Ouro","res://assets/ui/adventure-gold-icon.svg",str(run.gold),"Ouro disponível")
 add_stat(row,"Dados","res://assets/ui/hud-dice.svg","—","Dados · mecânica futura")

func add_stat(row: HBoxContainer,title: String,path: String,value: String,hint: String) -> void:
 var column:=VBoxContainer.new();column.name="HUD"+title;column.alignment=BoxContainer.ALIGNMENT_CENTER;column.custom_minimum_size.x=80;column.tooltip_text=hint;row.add_child(column)
 var icon:=TextureRect.new();icon.name="AdventureGoldIcon" if title=="Ouro" else "HUDIcon";icon.texture=load(path);icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;icon.custom_minimum_size=Vector2(32,32);column.add_child(icon)
 var label:=Label.new();label.name="Value";label.text=value;label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.add_theme_font_size_override("font_size",26);column.add_child(label)
