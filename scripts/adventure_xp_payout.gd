extends AcceptDialog
signal acknowledged
const Profile=preload("res://scripts/adventure_profile.gd")
const Identity=preload("res://scripts/player_identity.gd")
var run
var avatar: Control
var xp_label: Label
var xp_bar: ProgressBar
var xp_tween: Tween
var reward_list: VBoxContainer
var reward_heading: Label
var revealed_levels: Dictionary={}
var initial_level:=1

func configure(state) -> void:run=state
func _ready() -> void:
 name="ExpeditionXPPayout";title="Experiência e recompensas";min_size=Vector2i(760,540)
 theme=preload("res://scripts/ui_theme.gd").build()
 add_theme_stylebox_override("panel",preload("res://scripts/ui_theme.gd").panel(Color("132630"),Color("b99d68"),20))
 var column:=VBoxContainer.new();column.custom_minimum_size=Vector2(710,440);column.add_theme_constant_override("separation",16);add_child(column)
 var heading:=Label.new();heading.text="+%d XP DE EXPEDIÇÃO" % run.pending_xp;heading.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;heading.add_theme_font_size_override("font_size",28);column.add_child(heading)
 avatar=preload("res://scripts/player_avatar.gd").new();avatar.size_flags_horizontal=Control.SIZE_SHRINK_CENTER;column.add_child(avatar)
 xp_bar=ProgressBar.new();xp_bar.name="ExpeditionXPBar";xp_bar.show_percentage=false;xp_bar.custom_minimum_size.y=18
 xp_bar.add_theme_stylebox_override("fill",preload("res://scripts/ui_theme.gd").panel(Color("87dcd8"),Color("d8c18b"),0));column.add_child(xp_bar)
 xp_label=Label.new();xp_label.name="AnimatedXPLabel";xp_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;xp_label.add_theme_font_size_override("font_size",22);column.add_child(xp_label)
 reward_heading=Label.new();reward_heading.name="LevelRewardsHeading";reward_heading.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;reward_heading.add_theme_font_size_override("font_size",22);reward_heading.modulate=Color("f0d693");column.add_child(reward_heading)
 var reward_count: int=run.profile.rewards_since(run.xp_before_settlement).size() if run.profile!=null else 0
 var scroll:=ScrollContainer.new();scroll.custom_minimum_size=Vector2(710,mini(440,maxi(150,reward_count*110)));scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;column.add_child(scroll)
 reward_list=VBoxContainer.new();reward_list.name="LevelRewards";reward_list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;reward_list.add_theme_constant_override("separation",10);scroll.add_child(reward_list)
 initial_level=Profile.level_at_xp(run.xp_before_settlement)
 display_xp(float(run.xp_before_settlement))
 get_ok_button().text="Continuar";get_ok_button().disabled=true
 confirmed.connect(func():acknowledged.emit())
 canceled.connect(func():
  if get_ok_button().disabled:popup_centered.call_deferred()
  else:acknowledged.emit())
 xp_tween=create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
 var target: int=run.profile.xp if run.profile!=null else run.xp_before_settlement+run.pending_xp
 xp_tween.tween_method(display_xp,float(run.xp_before_settlement),float(target),clampf(run.pending_xp*0.25,1.2,4.0))
 xp_tween.finished.connect(finish_animation)

func finish_animation() -> void:
 get_ok_button().disabled=false
 var has_choice: bool=run.profile!=null and not run.profile.pending_choice().is_empty()
 get_ok_button().text="Escolher melhoria" if has_choice else "Continuar"
 if revealed_levels.is_empty():reward_heading.text="Progresso guardado para o próximo nível"

func reveal_reward(level: int) -> void:
 if revealed_levels.has(level) or run.profile==null:return
 revealed_levels[level]=true
 reward_heading.text="NÍVEL ALCANÇADO · VOCÊ GANHOU"
 var reward: Dictionary=run.profile.reward_for_level(level)
 var panel:=PanelContainer.new();panel.name="LevelReward_%d" % level;panel.add_theme_stylebox_override("panel",preload("res://scripts/ui_theme.gd").panel(Color("1b343b"),Color("bba369"),12));reward_list.add_child(panel)
 var row:=HBoxContainer.new();row.add_theme_constant_override("separation",14);panel.add_child(row)
 var icon:=TextureRect.new();icon.texture=preload("res://scripts/card_skin.gd").texture(reward.icon);icon.custom_minimum_size=Vector2(40,40);icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;row.add_child(icon)
 var text:=VBoxContainer.new();text.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(text)
 var title:=Label.new();title.text="Nível %d · %s" % [level,reward.title];title.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;title.add_theme_font_size_override("font_size",19);title.modulate=Color("f0d693");text.add_child(title)
 var description:=Label.new();description.text=reward.description;description.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;description.add_theme_font_size_override("font_size",16);text.add_child(description)

func display_xp(total: float) -> void:
 var level:=1;var remaining:=total
 while remaining>=Profile.xp_cost(level):remaining-=Profile.xp_cost(level);level+=1
 avatar.configure(Identity.avatar(),level,remaining/Profile.xp_cost(level))
 xp_bar.max_value=Profile.xp_cost(level);xp_bar.value=remaining
 xp_label.text="Nível %d · %d/%d XP" % [level,int(remaining),Profile.xp_cost(level)]
 for reached in range(initial_level+1,level+1):reveal_reward(reached)
