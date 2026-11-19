extends SceneTree
# Run twice: --script tests/network_peer_runner.gd -- host|client PORT [TAG]
const Match=preload("res://scripts/match.gd")
const Rules=preload("res://scripts/network_duel.gd")
var session: Node
var role: String
var port:=24568
var tag: String="network"
var model: DuelMatch
var timer: Timer
var started:=0
var actions:=0
var results_written:=false
var rejected:=0
var final_digest: String=""
var timeout_ms:=45000
func _initialize() -> void:call_deferred("begin")
func begin() -> void:
 var args:=OS.get_cmdline_user_args()
 role=args[0] if args.size()>0 else "host"
 if args.size()>1:port=int(args[1])
 if args.size()>2:tag=args[2]
 session=root.get_node("DuelNetwork")
 model=Match.new()
 session.match_started.connect(func():print("CONNECTED "+role))
 session.command_rejected.connect(func(_message):rejected+=1)
 session.connection_lost.connect(func(message):
  if not results_written:push_error(message);quit(2))
 var profile=session.profile(Match.default_deck(0 if role=="host" else 2),role+" deck",role)
 var error: int=session.host(port,profile) if role=="host" else session.join("127.0.0.1",port,profile)
 if error!=OK:push_error("Falha ao abrir conexão: "+str(error));quit(3);return
 started=Time.get_ticks_msec()
 timer=Timer.new();timer.wait_time=0.02;timer.timeout.connect(tick);root.add_child(timer);timer.start()
func tick() -> void:
 if Time.get_ticks_msec()-started>timeout_ms:push_error("Timeout do teste: "+role);quit(4);return
 if not session.in_match or session.latest_state.is_empty():return
 Rules.apply_view(model,session.latest_state)
 if model.winner!=-1:
  if not results_written:
   var players: Array=[]
   for side in [0,1]:
    var p: Dictionary=model.players[side]
    players.append({"hp":p.hp,"mana":p.mana,"max_mana":p.max_mana,"hand_count":p.hand.size(),"deck_count":p.deck.size(),"board":p.board})
   if role=="client":players.reverse()
   final_digest=JSON.stringify({"players":players,"winner":Rules.map_side(model.winner,session.local_side),"turn":Rules.map_side(model.turn,session.local_side)}).sha256_text()
   var file:=FileAccess.open("res://work/%s-%s-result.json" % [tag,role],FileAccess.WRITE)
   file.store_string(JSON.stringify({"digest":final_digest,"winner":Rules.map_side(model.winner,session.local_side),"actions":actions,"rejected":rejected,"revision":session.last_revision}));file.close()
   results_written=true
  var other: String="res://work/%s-%s-result.json" % [tag,"client" if role=="host" else "host"]
  if FileAccess.file_exists(other):
   var result=JSON.parse_string(FileAccess.get_file_as_string(other))
   if result.digest!=final_digest:push_error("Os estados finais divergiram.");quit(5);return
   print("OK: "+role+" concluiu duelo real via ENet; estado idêntico, revisão %d, ações %d, rejeições %d." % [session.last_revision,actions,rejected])
   finish()
  return
 if not session.connected or session.pending:return
 if model.opening:
  if not model.mulligan_done[0]:send({"kind":"mulligan","indices":[]})
  return
 if model.turn!=0:return
 for i in range(model.players[0].hand.size()):
  var key: String=model.players[0].hand[i]
  var data: CardData=Match.CARD_DATA[key]
  if data.card_type==CardData.CardType.CREATURE:
   var target: int=model.entry_target(0,Match.CARDS[key]) if Match.entry_target_side(0,Match.CARDS[key])>=0 else -1
   if model.can_play(0,i,target):send({"kind":"play","hand":i,"target":target,"choice":"envenom" if data.entry_effect==CardData.EntryEffect.GRANT_ROGUE_CHOICE else ""});return
  elif model.has_spell_target(0,i):
   if model.spell_target_count(0,i)>1:continue
   for side in [1,0]:
    for index in range(-1,model.players[side].board.size()):
     if model.can_cast(0,i,side,index):send({"kind":"cast","hand":i,"target_side":side,"target":index,"trap_choice":2});return
 for i in range(model.players[0].board.size()):
  var target: int=model.preferred_attack_target(0,i)
  if target!=-2:send({"kind":"act","index":i,"target":target,"magical":false});return
  if model.can_target(0,i,-1,true):send({"kind":"act","index":i,"target":-1,"magical":true});return
 send({"kind":"end_turn"})
func send(command: Dictionary) -> void:
 actions+=1;session.submit(command)

func finish() -> void:
 timer.stop();session.close();quit()
