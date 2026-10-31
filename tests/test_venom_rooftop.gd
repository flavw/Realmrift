extends SceneTree
const Match=preload("res://scripts/match.gd")
const KEY="venom_rooftop"
func fixture():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10;p.hp=20
 return m
func _init() -> void:
 var card: CardData=Match.CARD_DATA[KEY]
 assert(card.legendary and card.cost==5 and card.attack==3 and card.health==3 and card.flying and card.loot==0 and card.title=="O Sombra")
 assert(card.entry_effect==CardData.EntryEffect.POISON_ALL_ENEMIES and card.entry_value==1 and not card.entry_needs_target())
 assert(card.ability_entries().any(func(e):return e.name=="Chamado" and "Todos os inimigos" in e.summary))
 assert(Match.copy_limit(KEY)==1 and card.artwork!=null)
 var m=fixture()
 var a=m.spawn_unit(0,"lightning_rogue");a.ready=true;a.armor=10
 var d=m.spawn_unit(1,"lightning_rogue");d.armor=10
 assert(m.act(0,0,0))
 assert(a.health==2 and d.health==2 and a.poison==1 and d.poison==1)
 assert(m.last_action.poisoned.size()==2)
 m=fixture();a=m.spawn_unit(0,"lightning_rogue");a.ready=true
 d=m.spawn_unit(1,"village_wall")
 assert(m.act(0,0,0) and d.poison==0)
 m=fixture()
 var ally=m.spawn_unit(0,"wolf")
 var victim=m.spawn_unit(1,"farmer");victim.poison=2
 var enemy2=m.spawn_unit(1,"wolf")
 var wall=m.spawn_unit(1,"village_wall")
 m.players[0].hand=[KEY]
 assert(m.can_play(0,0) and m.play(0,0))
 assert(victim.poison==3 and enemy2.poison==1 and wall.poison==0 and ally.poison==0)
 assert(m.players[1].hp==20 and m.last_action.poisoned.size()==2)
 var summoned=m.players[0].board.back()
 assert(summoned.flying and not summoned.ready)
 summoned.ready=true
 m.players[0].hand.clear();m.players[0].deck=["squire"]
 assert(m.act(0,1,-1) and m.players[0].hand.is_empty())
 m=fixture();m.players[0].hand=[KEY]
 assert(m.play(0,0) and m.last_action.get("poisoned",[]).is_empty())
 m=fixture();m.turn=1;m.players[1].hand=[KEY]
 m.spawn_unit(0,"farmer")
 assert(m.ai_step() and m.players[0].board[0].poison==1)
 print("OK: veneno absorvido, contra-ataque, imunidade, Chamado em área, Voo, IA e raridade.")
 quit()
