extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
const KEY="fireball"
func _initialize() -> void:call_deferred("verify")
func unit(key: String,id: int) -> Dictionary:
 var u: Dictionary=Match.CARDS[key].duplicate(true)
 u.merge({"key":key,"id":id,"ready":true,"max_health":u.health,"poison":0})
 return u
func pool(m,side: int) -> Array:
 var result: Array=m.players[side].hand.duplicate();result.append_array(m.players[side].deck);result.sort();return result
func verify() -> void:
 for starter in [0,1]:
  var m=Match.new([],[],starter,true)
  var second: int=1-starter
  var before=[pool(m,0),pool(m,1)]
  assert(m.mulligan(starter,[0]) and m.mulligan_done[starter])
  assert(not m.mulligan(starter,[]) and m.mulligan(second,[]))
  assert(m.opening and not m.mulligan_done[second] and m.mulligan_rounds[second]==1)
  assert(m.players[0].mana==0 and m.players[1].mana==0 and m.players[starter].hand.size()==3 and m.players[second].hand.size()==4)
  var hand: Array=m.players[second].hand.duplicate()
  assert(not m.mulligan(second,[0,1]) and not m.mulligan(second,[0,0]) and not m.mulligan(second,[-1]))
  assert(m.players[second].hand==hand and m.mulligan_rounds[second]==1)
  assert(m.mulligan(second,[2]) and not m.opening and m.turn==starter)
  assert(m.players[starter].mana==1 and m.players[second].mana==0 and m.players[starter].hand.size()==4 and m.players[second].hand.size()==4)
  assert(pool(m,0)==before[0] and pool(m,1)==before[1] and not m.mulligan(second,[]))
 # The extra swap is optional and may be declined even after keeping the first hand.
 var m=Match.new([],[],0,true)
 assert(m.mulligan(0,[]) and m.mulligan(1,[]) and m.opening and m.mulligan(1,[]) and not m.opening)
 assert(Match.CARD_DATA.farmer.attack==1 and Match.CARD_DATA.farmer.health==3)
 m=Match.new();m.players[0].board=[unit("farmer",1)]
 m.end_turn(0);m.end_turn(1)
 assert(m.players[0].board[0].health==4 and m.players[0].board[0].max_health==4)
 var data: CardData=Match.CARD_DATA[KEY]
 assert(data.cost==6 and data.faction==CardData.Faction.MAGE and data.spell_value==3 and data.card_type==CardData.CardType.SPELL)
 m=Match.new();m.players[0].hand=[KEY];m.players[0].mana=5;m.players[1].board=[unit("village_wall",2)]
 assert(not m.cast(0,0,1,-1) and m.players[0].hand==[KEY] and m.players[0].mana==5)
 m.players[0].mana=6
 assert(not m.cast(0,0,0,-1) and not m.cast(0,0,1,0) and m.players[0].mana==6)
 var wall=m.players[1].board[0]
 m.players[0].board=[unit("wolf",1)]
 m.players[1].board.append(unit("cleric",3));m.players[1].board.append(unit("warrior",4))
 assert(m.cast(0,0,1,-1) and wall.health==1 and wall.armor==1 and wall.block==4)
 assert(m.players[1].board.size()==2 and m.players[1].board[1].health==1)
 assert(m.players[0].board[0].health==2 and m.players[0].board[0].ready and m.players[0].hp==20 and m.players[1].hp==20)
 assert(m.last_action.area_hits.size()==3 and m.last_action.dead.size()==1 and m.players[0].mana==0)
 # Amplify is applied to every target, all at once; allied creatures remain untouched.
 m=Match.new();m.players[0].board=[unit("runic_familiar",1)];m.players[0].hand=[KEY];m.players[0].mana=6
 m.players[1].board=[]
 for i in range(5):m.players[1].board.append(unit("village_wall",i+2))
 assert(m.cast(0,0,1,-1) and m.players[1].board.is_empty() and m.players[0].board[0].health==3 and m.last_action.dead.size()==5)
 m.players[0].hand=[KEY];m.players[0].mana=6
 assert(not m.has_spell_target(0,0) and not m.cast(0,0,1,-1))
 m=Match.new();m.turn=1;m.players[1].hand=[KEY];m.players[1].mana=6;m.players[1].board=[];m.players[0].board=[unit("wolf",1),unit("squire",2)]
 assert(m.ai_step() and m.players[0].board.is_empty() and m.last_action.effect==CardData.SpellEffect.AREA_ARCANE)
 # UI only allows one selected card in the extra phase.
 var opening=Match.new([],[],1,true);assert(opening.mulligan(0,[]))
 var view=load("res://scripts/mulligan_view.gd").new();view.configure(opening);root.add_child(view)
 view.toggle_card(0);view.toggle_card(2)
 assert(view.selected==[2] and "EXTRA" in view.find_child("MulliganHeading",true,false).text)
 view.queue_free();await process_frame
 # AOE casts immediately, without asking the player to pick one of its targets.
 var main=load("res://main.tscn").instantiate();main.enable_opening=false;main.deck_store=Store.new("user://unused_solar_test.json",false);root.add_child(main)
 main.duel.players[0].hand=[KEY];main.duel.players[0].mana=6;main.duel.players[1].board=[unit("wolf",22),unit("squire",23)];main.redraw()
 main.play(0)
 assert(main.casting==-1 and main.duel.players[1].board.is_empty() and main.duel.players[0].mana==0)
 for i in range(100):
  if not main.busy:break
  await create_timer(0.02).timeout
 assert(not main.busy and main.sound_counts.get("magic",0)==1)
 main.queue_free();await process_frame;await create_timer(0.35).timeout
 print("OK: mulligan extra de 1 para o segundo, conservação/limites, Fazendeiro 1/3, área 6 mana/3 dano, Armadura/Vigor/Amplificar, IA e conjuração imediata.")
 quit()
