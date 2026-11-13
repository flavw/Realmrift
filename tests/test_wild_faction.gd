extends SceneTree
const Match=preload("res://scripts/match.gd")
func _init():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10
 var elf=Match.CARD_DATA.wild_elf
 assert(elf.creature_type==CardData.CreatureType.ELF and elf.reach and elf.envenom==1)
 var a=m.spawn_unit(0,"wild_scout");a.ready=true
 var b=m.spawn_unit(1,"raven");b.health=8;b.armor=0;b.antimagic=0
 assert(m.attack_forecast(0,0,0).damage==2)
 var f=m.spawn_unit(1,"wild_badger")
 assert(Match.damage(f,3,true)==0 and not Match.apply_poison(f,1))
 m.players[0].hand=["wild_roots"]
 assert(not m.can_cast(0,0,1,1) and m.cast(0,0,1,0) and b.rooted)
 m.turn=1;b.ready=true
 assert(not m.can_target(1,0,-1,false))
 assert(m.end_turn(1) and not b.rooted)
 print("OK: elfo, Alcance, imunidade e raízes.")
 quit()
