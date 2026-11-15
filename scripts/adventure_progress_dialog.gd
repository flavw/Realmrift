extends AcceptDialog
signal bonus_selected(key: String)
const Profile=preload("res://scripts/adventure_profile.gd")
const State=preload("res://scripts/adventure_state.gd")
const Identity=preload("res://scripts/player_identity.gd")
var run

func configure(state) -> void:run=state

func _ready() -> void:
 name="AdventureProgressDialog";title="Nível e poderes";min_size=Vector2i(860,680)
 add_theme_stylebox_override("panel",preload("res://scripts/ui_theme.gd").panel(Color("101f2b"),Color("b39968"),22))
 var scroll:=ScrollContainer.new();scroll.custom_minimum_size=Vector2(806,580);scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;add_child(scroll)
 var column:=VBoxContainer.new();column.custom_minimum_size.x=780;column.size_flags_horizontal=Control.SIZE_EXPAND_FILL;column.add_theme_constant_override("separation",15);scroll.add_child(column)
 var level: int=run.profile.level() if run.profile!=null else 1
 var xp: int=run.profile.xp_in_level() if run.profile!=null else 0
 var header:=HBoxContainer.new();header.add_theme_constant_override("separation",22);column.add_child(header)
 var avatar=preload("res://scripts/player_avatar.gd").new();avatar.size_flags_vertical=Control.SIZE_SHRINK_CENTER;avatar.configure(Identity.avatar(),level,float(xp)/Profile.xp_cost(level));header.add_child(avatar)
 var summary:=VBoxContainer.new();summary.size_flags_horizontal=Control.SIZE_EXPAND_FILL;summary.custom_minimum_size.x=570;summary.alignment=BoxContainer.ALIGNMENT_CENTER;header.add_child(summary)
 add_text(summary,"NÍVEL %d" % level,"ProgressLevel",30)
 add_text(summary,"%d/%d XP para o próximo nível" % [xp,Profile.xp_cost(level)],"ProgressXP",21)
 add_text(summary,"Vidas extras restantes: %d" % run.retries_left,"ProgressRetries",18)
 add_text(summary,"XP acumulado na expedição: %d" % run.pending_xp,"ExpeditionPendingXP",18)
 var bar:=ProgressBar.new();bar.name="LevelXPBar";bar.max_value=Profile.xp_cost(level);bar.value=xp;bar.show_percentage=false;bar.custom_minimum_size.y=12;column.add_child(bar)
 add_text(column,"MELHORIAS PERMANENTES","PermanentBonusesHeading",22)
 var totals: Dictionary=run.profile.totals() if run.profile!=null else {}
 var any_bonus:=false
 for key in totals:
  if int(totals[key])<=0:continue
  any_bonus=true
  add_text(column,"%s ×%d — %s" % [Profile.BONUSES[key].name,int(totals[key]),Profile.BONUSES[key].description],"Permanent_"+key,18)
 if not any_bonus:add_text(column,"Nenhuma melhoria permanente escolhida ainda.","NoPermanentBonuses",18)
 add_text(column,("Desbloqueado" if level>=3 else "Nível 3")+" · Uma tentativa extra por expedição.","Milestone3",18)
 add_text(column,("Desbloqueado" if level>=4 else "Nível 4")+" · +1 dado no início de cada expedição.","Milestone4",18)
 add_text(column,("Desbloqueado" if level>=5 else "Nível 5")+" · Um item inicial aleatório após montar o deck.","Milestone5",18)
 add_text(column,("Desbloqueado" if level>=8 else "Nível 8")+" · +1 dado no início de cada expedição.","Milestone8",18)
 var pending: Dictionary=run.profile.pending_choice() if run.profile!=null else {}
 if not pending.is_empty():
  add_text(column,"Nível %d alcançado — escolha uma melhoria" % int(pending.level),"PendingLevel",21)
  for key in pending.options:
   var button:=Button.new();button.name="ProgressBonus_"+key;button.text=Profile.BONUSES[key].name+" — "+Profile.BONUSES[key].description;button.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;button.custom_minimum_size.y=60;column.add_child(button)
   button.pressed.connect(func():bonus_selected.emit(key))
 column.add_child(HSeparator.new())
 add_text(column,"PODERES DESTA EXPEDIÇÃO","RunPowersHeading",22)
 if run.powers.is_empty():add_text(column,"Você ainda não recebeu um poder nesta expedição.","NoRunPowers",18)
 for key in run.powers:
  var row:=HBoxContainer.new();row.add_theme_constant_override("separation",12);column.add_child(row)
  var icon:=TextureRect.new();icon.name="PowerIcon_"+key;icon.texture=preload("res://scripts/card_skin.gd").texture(State.POWER_ICONS[key]);icon.custom_minimum_size=Vector2(36,36);icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;row.add_child(icon)
  add_text(row,State.POWERS[key].name+"\n"+State.POWERS[key].description,"PowerDetail_"+key,19)
 if run.farm_blessing_all_run or run.farm_blessing_pending:
  add_text(column,"Bênção do banquete\n+1 de vida às suas criaturas "+("até o fim da expedição." if run.farm_blessing_all_run else "no próximo combate."),"FarmPower",19)

func add_text(parent: Node,value: String,node_name: String,font_size: int) -> void:
 var label:=Label.new();label.name=node_name;label.text=value;label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;label.add_theme_font_size_override("font_size",font_size)
 if font_size>=22:label.add_theme_color_override("font_color",Color("e6cd92"))
 parent.add_child(label)
