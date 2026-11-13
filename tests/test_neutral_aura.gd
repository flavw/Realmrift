extends SceneTree
const Match=preload("res://scripts/match.gd")
func unit(key: String,id: int) -> Dictionary:
 var u: Dictionary=Match.CARDS[key].duplicate(true)
 u.merge({"key":key,"id":id,"ready":true,"max_health":u.health,"poison":0})
 return u
func fixture():
 var m=Match.new()
 for p in m.players:p.board=[];p.hand=[];p.mana=10
 m.next_id=100
 return m
func _init() -> void:
 assert(Match.CARD_DATA.size()==38)
 var recipe=Match.default_deck(4)
 assert(Match.valid_deck(recipe) and Match.deck_faction(recipe)==-1 and recipe.size()==Match.DECK_SIZE)
 for key in recipe:assert(recipe.count(key)<=2)
 var m=fixture()
 var wolf=unit("wolf",1)
 var mage=unit("mage",2)
 var enemy=unit("wolf",3)
 m.players[0].board=[wolf,mage];m.players[1].board=[enemy]
 m.players[0].hand=["village_leader","wolf"]
 assert(m.play(0,0) and m.players[0].mana==6)
 var leader: Dictionary=m.players[0].board[2]
 assert(not leader.ready and Match.attack_value(leader)==3)
 assert(wolf.aura_attack==1 and mage.aura_attack==1 and enemy.aura_attack==0)
 assert(Match.CARDS.wolf.attack==2 and wolf.attack==2,"Sem alterar recursos nem ataque permanente")
 assert(m.play(0,0) and m.players[0].board[3].aura_attack==1)
 assert(m.fury(0,0) and wolf.attack==3 and Match.attack_value(wolf)==4 and wolf.ready)
 var second=unit("village_leader",5)
 m.players[0].board.append(second);m.refresh_auras()
 assert(leader.aura_attack==1 and second.aura_attack==1 and wolf.aura_attack==2)
 m.players[0].board.erase(leader);m.refresh_auras()
 assert(wolf.aura_attack==1 and second.aura_attack==0)
 m.players[0].board.erase(second);m.refresh_auras()
 assert(wolf.aura_attack==0 and wolf.attack==3,"Fúria continua após Aura acabar")
 # Both target policies and self exclusion are data-driven.
 leader.aura_includes_self=false;leader.aura_targets=CardData.AuraTargets.ALLIES
 m.players[0].board=[leader,mage];m.refresh_auras()
 assert(leader.aura_attack==0 and mage.aura_attack==1)
 # Damage and simultaneous counter use effective attack; armor still applies.
 m=fixture();wolf=unit("wolf",1);leader=unit("village_leader",2)
 m.players[0].board=[wolf,leader]
 assert(m.act(0,0,-1) and m.players[1].hp==17)
 var warrior=unit("warrior",3)
 m.players[1].board=[warrior];wolf.ready=true;wolf.attack=1
 assert(m.act(0,0,0) and warrior.health==1,"Ataque 2 é absorvido por Armadura 2")
 m=fixture();leader=unit("village_leader",1);leader.health=1
 var fighter=unit("sentinel",2);fighter.health=10
 wolf=unit("wolf",3)
 m.players[0].board=[fighter];m.players[1].board=[leader,wolf]
 assert(m.act(0,0,0) and leader.health<=0 and fighter.health==8)
 assert(wolf.aura_attack==0,"Contra-ataque ainda usa Aura; removida após combate")
 # Magic kill and poison kill remove the bonus without another turn/attack.
 m=fixture();leader=unit("village_leader",1);leader.health=2;wolf=unit("wolf",2)
 m.players[1].board=[leader,wolf];m.players[0].hand=["astral_flame"]
 assert(m.cast(0,0,1,0) and wolf.aura_attack==0 and m.players[1].board.size()==1)
 m=fixture();leader=unit("village_leader",1);leader.health=1;leader.poison=1
 wolf=unit("wolf",2);m.players[0].board=[leader,wolf]
 m.end_turn(0)
 assert(wolf.aura_attack==0 and m.players[0].board.size()==1)
 # Zero-attack creatures gain and lose permission to attack.
 m=fixture();var familiar=unit("runic_familiar",1);leader=unit("village_leader",2)
 m.players[0].board=[familiar,leader]
 assert(m.can_target(0,0,-1) and Match.physical_attack(familiar)==1)
 leader.health=0;m.refresh_auras()
 assert(not m.can_target(0,0,-1) and Match.physical_attack(familiar)==0)
 # Vigor compares current life with all attack bonuses once.
 wolf.vigor=true;wolf.health=2;wolf.attack=3
 leader.health=4;m.players[0].board=[wolf,leader];m.refresh_auras()
 assert(Match.physical_attack(wolf)==4)
 wolf.health=6;assert(Match.physical_attack(wolf)==6)
 # Entry life is permanent, automatic, excludes source and preserves damage/status.
 m=fixture();wolf=unit("wolf",1);wolf.health=1;wolf.max_health=3;wolf.poison=2;wolf.ready=false
 mage=unit("mage",2);enemy=unit("wolf",3)
 m.players[0].board=[wolf,mage];m.players[1].board=[enemy]
 m.players[0].hand=["generous_peasant","generous_peasant"]
 assert(not Match.CARD_DATA.generous_peasant.entry_needs_target())
 assert(m.play(0,0) and wolf.health==2 and wolf.max_health==4 and wolf.poison==2 and not wolf.ready)
 var girl: Dictionary=m.players[0].board[2]
 assert(girl.health==3 and girl.max_health==3 and not girl.ready)
 assert(mage.health==3 and enemy.health==2 and m.players[0].hp==20)
 assert(m.play(0,0) and wolf.health==3 and wolf.max_health==5 and girl.health==4)
 assert(m.players[0].board[3].health==3)
 m.players[0].board.erase(girl);m.refresh_auras()
 assert(wolf.health==3 and wolf.max_health==5)
 m.players[0].board=[unit("generous_peasant",9)];m.players[0].board[0].health=3;m.players[0].board[0].max_health=3
 m.end_turn(0);m.end_turn(1)
 assert(m.players[0].board[0].health==3,"Chamado não repete a cada turno")
 # Production AI can play both new cards without a target-selection deadlock.
 for key in ["village_leader","generous_peasant"]:
  m=fixture();m.turn=1;m.players[1].hand=[key]
  assert(m.ai_step() and m.players[1].board[0].key==key)
 print("OK: Aura temporária, acúmulo/alvos, combate/magia/veneno, Fúria/Vigor, Chamado coletivo permanente e IA; deck aldeão válido.")
 quit()
