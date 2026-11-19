extends Control
const UiTheme=preload("res://scripts/ui_theme.gd")
const Match=preload("res://scripts/match.gd")
var store:=DeckStore.new()
var address: LineEdit
var port: SpinBox
var nickname: LineEdit
var deck: OptionButton
var feedback: Label
var host_button: Button
var join_button: Button
var cancel_button: Button

func _ready() -> void:
 DuelNetwork.close()
 theme=UiTheme.build()
 var bg:=ColorRect.new();bg.color=Color("09131f");bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(bg)
 var art:=TextureRect.new();art.texture=preload("res://assets/ui/realmrift-menu-background.webp");art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;art.modulate=Color(0.4,0.4,0.4);art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);art.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(art)
 var center:=CenterContainer.new();center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(center)
 var panel:=PanelContainer.new();panel.custom_minimum_size=Vector2(790,650);panel.add_theme_stylebox_override("panel",UiTheme.panel(Color("101e2d"),Color("b49a64"),22));center.add_child(panel)
 var box:=VBoxContainer.new();box.add_theme_constant_override("separation",14);panel.add_child(box)
 box.add_child(label("DUELO MULTIPLAYER",30,Color("eed8aa")))
 box.add_child(label("Crie uma partida ou entre pelo IP de quem está hospedando.",18))
 nickname=LineEdit.new();nickname.name="PlayerName";nickname.max_length=24;nickname.text="Jogador";nickname.placeholder_text="Seu nome";nickname.custom_minimum_size.y=42
 box.add_child(field("Seu nome",nickname))
 deck=OptionButton.new();deck.name="NetworkDeck";deck.custom_minimum_size.y=44
 for i in range(DeckStore.SLOT_COUNT):
  if Match.valid_deck(store.slots[i].cards) and DeckStore.accepts_base(store.base_for(i),store.slots[i].cards):deck.add_item(store.slots[i].name,i)
 for i in range(deck.item_count):
  if deck.get_item_id(i)==store.active:deck.select(i)
 box.add_child(field("Seu deck",deck))
 address=LineEdit.new();address.name="HostAddress";address.placeholder_text="Ex.: 192.168.1.10";address.text="127.0.0.1";address.custom_minimum_size.y=42
 box.add_child(field("IP do anfitrião",address))
 port=SpinBox.new();port.name="NetworkPort";port.min_value=1024;port.max_value=65535;port.value=DuelNetwork.DEFAULT_PORT;port.custom_minimum_size.y=42
 box.add_child(field("Porta UDP",port))
 var actions:=HBoxContainer.new();actions.add_theme_constant_override("separation",14);box.add_child(actions)
 host_button=action("Criar partida",host_game);host_button.name="HostGame";UiTheme.primary(host_button);actions.add_child(host_button)
 join_button=action("Entrar pelo IP",join_game);join_button.name="JoinGame";actions.add_child(join_button)
 feedback=label("",17);feedback.name="ConnectionStatus";feedback.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;feedback.custom_minimum_size=Vector2(720,58);box.add_child(feedback)
 var hint:=label("Na mesma rede, use o IP local do anfitrião. Pela internet, encaminhe a porta UDP no roteador ou use uma VPN de rede local. Os dois precisam da mesma versão do jogo. Para testar no mesmo computador, use 127.0.0.1 em uma segunda janela.",15,Color("9eafbf"));hint.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;hint.custom_minimum_size.x=720;box.add_child(hint)
 var local_ips: PackedStringArray=[]
 for ip in IP.get_local_addresses():
  if ip.contains(":") or ip.begins_with("127.") or ip.begins_with("169.254."):continue
  local_ips.append(ip)
 var ip_label:=label("Seus IPs locais: "+(", ".join(local_ips) if not local_ips.is_empty() else "não encontrados"),14,Color("bacdbd"));ip_label.name="LocalAddresses";ip_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;ip_label.custom_minimum_size.x=720;box.add_child(ip_label)
 cancel_button=action("Cancelar conexão",func():DuelNetwork.close();refresh());box.add_child(cancel_button)
 box.add_child(action("Voltar ao início",func():DuelNetwork.close();get_tree().change_scene_to_file("res://start_menu.tscn")))
 DuelNetwork.lobby_changed.connect(refresh)
 DuelNetwork.match_started.connect(start_game)
 refresh()

func label(value: String,font_size: int,color: Color=Color("dfebf2")) -> Label:
 var node:=Label.new();node.text=value;node.add_theme_font_size_override("font_size",font_size);node.modulate=color;return node

func field(title: String,control: Control) -> HBoxContainer:
 var row:=HBoxContainer.new();var caption:=label(title,17);caption.custom_minimum_size.x=180;row.add_child(caption);control.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(control);return row

func action(title: String,callback: Callable) -> Button:
 var node:=Button.new();node.text=title;node.custom_minimum_size.y=46;node.size_flags_horizontal=Control.SIZE_EXPAND_FILL;node.pressed.connect(callback);return node

func selected_profile() -> Dictionary:
 if deck.item_count==0:return {}
 var index:=deck.get_selected_id()
 var player_name:=nickname.text.strip_edges()
 if player_name.is_empty():player_name="Jogador"
 return DuelNetwork.profile(store.slots[index].cards,store.slots[index].name,player_name)

func host_game() -> void:
 var value:=selected_profile()
 if value.is_empty():return
 DuelNetwork.host(int(port.value),value)

func join_game() -> void:
 if address.text.strip_edges().is_empty():feedback.text="Informe o IP de quem está hospedando.";return
 var value:=selected_profile()
 if value.is_empty():return
 DuelNetwork.join(address.text,int(port.value),value)

func refresh() -> void:
 var locked: bool=DuelNetwork.active
 for control in [nickname,address,port.get_line_edit()]:control.editable=not locked
 port.editable=not locked
 deck.disabled=locked
 host_button.disabled=locked or deck.item_count==0
 join_button.disabled=host_button.disabled
 cancel_button.visible=locked
 feedback.text=DuelNetwork.status if deck.item_count>0 else "Monte um deck válido de 22 cartas em Meus decks antes de jogar."
 feedback.modulate=Color("f1a7a0") if not DuelNetwork.error.is_empty() else Color("cee1bb")

func start_game() -> void:
 get_tree().change_scene_to_file.call_deferred("res://main.tscn")
