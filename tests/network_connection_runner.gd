extends SceneTree
const Match=preload("res://scripts/match.gd")
var session: Node
var role: String
var scenario: String
var began:=0
var stage:=0
var timer: Timer
func _initialize() -> void:call_deferred("begin")
func begin() -> void:
 var args:=OS.get_cmdline_user_args();role=args[0];scenario=args[1]
 session=root.get_node("DuelNetwork")
 session.connection_lost.connect(lost)
 session.match_started.connect(func():
  stage=1
  if role=="client" and scenario=="disconnect":call_deferred("drop_connection"))
 var profile=session.profile(Match.default_deck(0),"Deck",role)
 var result: int=session.host(24570,profile) if role=="host" else session.join("127.0.0.1",24570,profile)
 assert(result==OK)
 if role=="client" and scenario=="mismatch":session.signature="versao-diferente"
 began=Time.get_ticks_msec();timer=Timer.new();timer.wait_time=0.05;timer.timeout.connect(check);root.add_child(timer);timer.start()
func lost(message: String) -> void:
 if role=="client" and scenario=="mismatch":
  assert(message.contains("Versões diferentes"));print("OK: versão incompatível recusada com mensagem clara.");quit()
 elif role=="host" and scenario=="disconnect":
  assert(stage==1 and not session.active and not session.connected)
  print("OK: desconexão detectada durante o duelo.");quit()
 else:push_error("Desconexão inesperada: "+message);quit(2)
func drop_connection() -> void:
 await create_timer(0.2).timeout
 session.close();print("OK: cliente encerrou a conexão.");quit()
func check() -> void:
 if role=="host" and scenario=="mismatch" and session.remote_id==0 and Time.get_ticks_msec()-began>18000:
  assert(session.active and not session.connected and not session.in_match)
  print("OK: anfitrião continua disponível após recusar versão incompatível.");session.close();quit();return
 if Time.get_ticks_msec()-began>25000:push_error("Timeout no cenário de conexão.");quit(3)
