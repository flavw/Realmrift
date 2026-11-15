extends Control
const State=preload("res://scripts/adventure_state.gd")
const Save=preload("res://scripts/adventure_save.gd")
const Profile=preload("res://scripts/adventure_profile.gd")
var profile

func _ready() -> void:
 theme=preload("res://scripts/ui_theme.gd").build()
 preload("res://scripts/game_music.gd").ensure(get_tree()).play_menu()
 if State.current==null:State.current=Save.load_run()
 profile=State.current.profile if State.current!=null and State.current.profile!=null else Profile.new()
 render()

func render() -> void:
 for child in get_children():remove_child(child);child.queue_free()
 var background:=ColorRect.new();background.color=Color("0d1923");background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(background)
 var center:=CenterContainer.new();center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(center)
 var column:=VBoxContainer.new();column.custom_minimum_size.x=1000;column.add_theme_constant_override("separation",18);center.add_child(column)
 var title:=Label.new();title.text="ESCOLHA SUA AVENTURA";title.add_theme_font_size_override("font_size",30);column.add_child(title)
 var tile:=PanelContainer.new();tile.add_theme_stylebox_override("panel",preload("res://scripts/ui_theme.gd").panel(Color("132733"),Color("b69962"),16));column.add_child(tile)
 var content:=VBoxContainer.new();content.add_theme_constant_override("separation",14);tile.add_child(content)
 var art:=TextureRect.new();art.name="AdventureSelectionArtwork";art.texture=preload("res://assets/ui/adventure-opening.webp");art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;art.custom_minimum_size=Vector2(960,340);content.add_child(art)
 var heading:=Label.new();heading.text="Da Vila à Fenda";heading.add_theme_font_size_override("font_size",30);content.add_child(heading)
 var description:=Label.new();description.text="De uma pequena vila às ruínas do Dragão Negro. Recrute aliados de todos os reinos e feche a fenda.";description.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;description.custom_minimum_size.x=920;content.add_child(description)
 var current=State.current
 if current!=null:
  var status:=Label.new();status.text="Expedição salva · etapa %d/%d · %d cartas · %d XP acumulado" % [mini(current.step+1,State.STAGES.size()),State.STAGES.size(),current.deck.size(),current.pending_xp];content.add_child(status)
  if current.phase not in ["victory","defeat","abandoned"] or current.xp_animation_pending or not current.xp_settled:
   add_button(content,"Ver resultado" if current.phase in ["victory","defeat","abandoned"] else "Continuar expedição",continue_run,"ContinueExpedition")
  if current.phase not in ["victory","defeat","abandoned"]:add_button(content,"Abandonar expedição",confirm_abandon,"AbandonExpedition")
 add_button(content,"Iniciar nova expedição",new_run,"NewExpedition")
 if not Save.last_error.is_empty():
  var error:=Label.new();error.text=Save.last_error;content.add_child(error)
 add_button(column,"Voltar ao menu inicial",func():get_tree().change_scene_to_file("res://start_menu.tscn"),"BackToMenu")

func add_button(parent: Node,value: String,callback: Callable,node_name: String) -> void:
 var button:=Button.new();button.name=node_name;button.text=value;button.custom_minimum_size.y=54;button.pressed.connect(callback);parent.add_child(button)

func continue_run() -> void:
 if State.current==null:return
 var run=State.current
 run.in_combat=run.phase=="combat"
 get_tree().change_scene_to_file("res://main.tscn" if run.in_combat else "res://adventure.tscn")

func new_run() -> void:
 if State.current!=null and State.current.phase not in ["victory","defeat","abandoned"]:
  confirm_abandon(true)
  return
 if State.current!=null and (State.current.xp_animation_pending or not State.current.xp_settled):continue_run();return
 State.current=State.new(profile);State.current.save_checkpoint()
 get_tree().change_scene_to_file("res://adventure.tscn")

func confirm_abandon(start_new: bool=false) -> void:
 var dialog:=ConfirmationDialog.new();dialog.name="ConfirmAbandon";dialog.title="Abandonar expedição?";dialog.dialog_text="Você receberá os %d XP acumulados e encerrará esta expedição." % State.current.pending_xp;add_child(dialog)
 dialog.confirmed.connect(func():
  dialog.queue_free()
  if State.current.abandon():
   State.current.save_checkpoint()
   if start_new:continue_run()
   else:get_tree().change_scene_to_file("res://adventure.tscn"))
 dialog.canceled.connect(dialog.queue_free);dialog.popup_centered()
