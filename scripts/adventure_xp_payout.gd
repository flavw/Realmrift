extends AcceptDialog
signal acknowledged
const Profile=preload("res://scripts/adventure_profile.gd")
const Identity=preload("res://scripts/player_identity.gd")
var run
var avatar: Control
var xp_label: Label
var xp_bar: ProgressBar
var xp_tween: Tween

func configure(state) -> void:run=state
func _ready() -> void:
 name="ExpeditionXPPayout";title="Experiência da expedição";min_size=Vector2i(600,350)
 theme=preload("res://scripts/ui_theme.gd").build()
 add_theme_stylebox_override("panel",preload("res://scripts/ui_theme.gd").panel(Color("132630"),Color("b99d68"),20))
 var column:=VBoxContainer.new();column.custom_minimum_size=Vector2(560,280);column.add_theme_constant_override("separation",18);add_child(column)
 var heading:=Label.new();heading.text="+%d XP DE EXPEDIÇÃO" % run.pending_xp;heading.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;heading.add_theme_font_size_override("font_size",28);column.add_child(heading)
 avatar=preload("res://scripts/player_avatar.gd").new();avatar.size_flags_horizontal=Control.SIZE_SHRINK_CENTER;column.add_child(avatar)
 xp_bar=ProgressBar.new();xp_bar.name="ExpeditionXPBar";xp_bar.show_percentage=false;xp_bar.custom_minimum_size.y=18
 xp_bar.add_theme_stylebox_override("fill",preload("res://scripts/ui_theme.gd").panel(Color("87dcd8"),Color("d8c18b"),0));column.add_child(xp_bar)
 xp_label=Label.new();xp_label.name="AnimatedXPLabel";xp_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;xp_label.add_theme_font_size_override("font_size",22);column.add_child(xp_label)
 display_xp(float(run.xp_before_settlement))
 get_ok_button().text="Continuar";get_ok_button().disabled=true
 confirmed.connect(func():acknowledged.emit())
 canceled.connect(func():acknowledged.emit())
 xp_tween=create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
 var target: int=run.profile.xp if run.profile!=null else run.xp_before_settlement+run.pending_xp
 xp_tween.tween_method(display_xp,float(run.xp_before_settlement),float(target),clampf(run.pending_xp*0.25,1.2,4.0))
 xp_tween.finished.connect(func():get_ok_button().disabled=false)

func display_xp(total: float) -> void:
 var level:=1;var remaining:=total
 while remaining>=Profile.xp_cost(level):remaining-=Profile.xp_cost(level);level+=1
 avatar.configure(Identity.avatar(),level,remaining/Profile.xp_cost(level))
 xp_bar.max_value=Profile.xp_cost(level);xp_bar.value=remaining
 xp_label.text="Nível %d · %d/%d XP" % [level,int(remaining),Profile.xp_cost(level)]
