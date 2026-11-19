extends Node
signal lobby_changed
signal match_started
signal state_received(state: Dictionary)
signal connection_lost(message: String)
signal command_rejected(message: String)
const Rules=preload("res://scripts/network_duel.gd")
const Match=preload("res://scripts/match.gd")
const DEFAULT_PORT=24567
var active:=false
var hosting:=false
var in_match:=false
var connected:=false
var pending:=false
var remote_id:=0
var local_side:=0
var status: String="Escolha criar ou entrar em uma partida."
var error: String=""
var opponent_name: String="Oponente"
var opponent_deck_name: String=""
var latest_state: Dictionary={}
var authoritative: DuelMatch
var revision:=0
var last_revision:=-1
var match_number:=0
var local_profile: Dictionary={}
var remote_profile: Dictionary={}
var connect_started:=0
var handshake_started:=0
var signature: String=""

func _ready() -> void:
 multiplayer.connected_to_server.connect(_connected_to_server)
 multiplayer.connection_failed.connect(func():_fail("Não foi possível conectar. Confira IP, porta UDP e firewall."))
 multiplayer.server_disconnected.connect(func():_fail("O anfitrião encerrou a conexão."))
 multiplayer.peer_connected.connect(_peer_connected)
 multiplayer.peer_disconnected.connect(_peer_disconnected)

func _process(_delta: float) -> void:
 if not active or connected:return
 if not hosting and connect_started>0 and Time.get_ticks_msec()-connect_started>15000:_fail("Tempo de conexão esgotado. Confira IP, porta UDP e firewall.")
 elif handshake_started>0 and Time.get_ticks_msec()-handshake_started>15000:_fail("O outro jogador não concluiu a conexão. Verifique a versão do jogo.")

func profile(cards: Array,deck_name: String,player_name: String) -> Dictionary:
 return {"cards":cards.duplicate(),"deck_name":deck_name.strip_edges().left(60),"name":player_name.strip_edges().replace("\n"," ").left(24)}

func valid_profile(value: Dictionary) -> bool:
 return value.size()==3 and value.get("cards") is Array and Match.valid_deck(value.cards) and value.get("name") is String and value.name.length() in range(1,25) and value.get("deck_name") is String and value.deck_name.length()<=60

func host(port: int,value: Dictionary) -> Error:
 if not valid_profile(value) or port<1024 or port>65535:return ERR_INVALID_PARAMETER
 close()
 var peer:=ENetMultiplayerPeer.new()
 var result:=peer.create_server(port,1)
 if result!=OK:status="Não foi possível abrir a porta UDP %d. Tente outra porta." % port;error=status;lobby_changed.emit();return result
 _begin(peer,value,true)
 status="Aguardando outro jogador · porta UDP %d" % port
 lobby_changed.emit()
 return OK

func join(address: String,port: int,value: Dictionary) -> Error:
 if not valid_profile(value) or address.strip_edges().is_empty() or address.length()>253 or port<1024 or port>65535:return ERR_INVALID_PARAMETER
 close()
 var peer:=ENetMultiplayerPeer.new()
 var result:=peer.create_client(address.strip_edges(),port)
 if result!=OK:status="Não foi possível iniciar a conexão.";error=status;lobby_changed.emit();return result
 _begin(peer,value,false)
 connect_started=Time.get_ticks_msec()
 status="Conectando a %s:%d…" % [address.strip_edges(),port]
 lobby_changed.emit()
 return OK

func _begin(peer: ENetMultiplayerPeer,value: Dictionary,as_host: bool) -> void:
 active=true;hosting=as_host;local_side=0 if as_host else 1
 local_profile=value.duplicate(true);signature=Rules.fingerprint()
 multiplayer.multiplayer_peer=peer

func close() -> void:
 active=false;connected=false;in_match=false;pending=false
 remote_id=0;revision=0;last_revision=-1;connect_started=0;handshake_started=0
 latest_state.clear();remote_profile.clear();authoritative=null
 multiplayer.multiplayer_peer=OfflineMultiplayerPeer.new()
 error="";status="Escolha criar ou entrar em uma partida."

func _fail(message: String) -> void:
 if not active:return
 active=false;connected=false;pending=false;error=message;status=message
 multiplayer.multiplayer_peer=OfflineMultiplayerPeer.new()
 lobby_changed.emit()
 connection_lost.emit(message)

func _peer_connected(id: int) -> void:
 if not active or not hosting:return
 if remote_id!=0:multiplayer.multiplayer_peer.disconnect_peer(id);return
 remote_id=id;handshake_started=Time.get_ticks_msec()
 status="Verificando versão e deck do oponente…";lobby_changed.emit()

func _connected_to_server() -> void:
 if not active or hosting:return
 remote_id=1;handshake_started=Time.get_ticks_msec();connect_started=0
 status="Verificando versão e deck…";lobby_changed.emit()
 _hello.rpc_id(1,Rules.PROTOCOL,signature,local_profile)

func _peer_disconnected(id: int) -> void:
 if not active or id!=remote_id:return
 if hosting and not in_match:
  remote_id=0;handshake_started=0;connected=false
  status="O jogador saiu. Aguardando outra conexão…";lobby_changed.emit()
 else:_fail("O outro jogador saiu da partida. A conexão foi encerrada.")

@rpc("any_peer","call_remote","reliable")
func _hello(protocol: int,catalog: String,value: Dictionary) -> void:
 if not active or not hosting or multiplayer.get_remote_sender_id()!=remote_id or connected:return
 if protocol!=Rules.PROTOCOL or catalog!=signature:
  _hello_refused.rpc_id(remote_id,"Versões diferentes do jogo. Os dois jogadores precisam usar a mesma versão.")
  status="O jogador tem uma versão diferente. Aguardando alguém com a mesma versão.";lobby_changed.emit();return
 if not valid_profile(value):_hello_refused.rpc_id(remote_id,"O deck enviado não é válido para o modo Duelo.");return
 remote_profile=value.duplicate(true);connected=true
 opponent_name=value.name;opponent_deck_name=value.deck_name
 _welcome.rpc_id(remote_id,local_profile.name,local_profile.deck_name)
 _start_match()

@rpc("authority","call_remote","reliable")
func _hello_refused(message: String) -> void:
 _fail(message.left(200))

@rpc("authority","call_remote","reliable")
func _welcome(player_name: String,deck_name: String) -> void:
 if not active or hosting:return
 connected=true;opponent_name=player_name;opponent_deck_name=deck_name
 status="Conectado. Preparando o duelo…";lobby_changed.emit()

func _start_match() -> void:
 authoritative=Match.new(local_profile.cards,remote_profile.cards,randi_range(0,1),true,{},[local_profile.name,remote_profile.name])
 match_number+=1;revision=0
 _publish(true)

func _publish(starting: bool=false) -> void:
 revision+=1
 var guest: Dictionary=Rules.view(authoritative,1)
 guest["revision"]=revision
 _receive_state.rpc_id(remote_id,guest,starting)
 var own: Dictionary=Rules.view(authoritative,0)
 own["revision"]=revision
 _accept_state(own,starting)
 authoritative.draw_events.clear()

@rpc("authority","call_remote","reliable")
func _receive_state(state: Dictionary,starting: bool) -> void:
 if not active or hosting or not connected:return
 _accept_state(state,starting)

func _accept_state(state: Dictionary,starting: bool) -> void:
 if int(state.get("revision",-1))<=last_revision:return
 last_revision=int(state.revision);latest_state=state.duplicate(true);pending=false
 if starting:
  in_match=true;status="Duelo conectado";match_started.emit()
 else:state_received.emit(state.duplicate(true))

func submit(command: Dictionary) -> void:
 if not active or not connected or not in_match or pending:return
 pending=true
 if hosting:_handle_command(0,command,last_revision)
 else:_request_command.rpc_id(1,command,last_revision)

@rpc("any_peer","call_remote","reliable")
func _request_command(command: Dictionary,expected_revision: int) -> void:
 if not hosting or not active or not connected or multiplayer.get_remote_sender_id()!=remote_id:return
 _handle_command(1,command,expected_revision)

func _handle_command(side: int,command: Dictionary,expected_revision: int) -> void:
 if authoritative==null or not Rules.valid_command(command):_reject(side);return
 # Both initial hands are independent: accepting the other player's mulligan
 # must not invalidate a simultaneous confirmation of this player's own hand.
 var independent_mulligan: bool=command.kind=="mulligan" and authoritative.opening and not authoritative.mulligan_done[side] and expected_revision>0 and expected_revision<=revision
 if expected_revision!=revision and not independent_mulligan:_reject(side);return
 var kind: String=command.kind
 if kind=="attack_all" or kind=="end_turn":
  if authoritative.opening or authoritative.turn!=side or authoritative.winner!=-1:_reject(side);return
  if kind=="attack_all":
   var ids: Array=[]
   for unit in authoritative.players[side].board:ids.append(unit.id)
   var acted:=false
   for id in ids:
    for i in range(authoritative.players[side].board.size()):
     if authoritative.players[side].board[i].id!=id:continue
     var target: int=authoritative.preferred_attack_target(side,i)
     if target!=-2 and authoritative.act(side,i,target,false):acted=true;_publish()
     break
    if authoritative.winner!=-1:break
   if not acted:_reject(side)
   return
  for _i in range(Match.MAX_BOARD):
   if not authoritative.perform_impulsive_attack(side):break
   _publish()
   if authoritative.winner!=-1:return
  for _i in range(Match.MAX_BOARD):
   if not authoritative.perform_automatic_hunt(side):break
   _publish()
   if authoritative.winner!=-1:return
 if not Rules.execute(authoritative,side,command):_reject(side);return
 _publish()

func _reject(side: int) -> void:
 if side==0:_command_refused()
 else:_command_refused.rpc_id(remote_id)

@rpc("authority","call_remote","reliable")
func _command_refused() -> void:
 pending=false
 command_rejected.emit("Essa jogada não é válida no estado atual da partida.")
