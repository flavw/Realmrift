extends SceneTree
const Match=preload("res://scripts/match.gd")
func fresh():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.deck=["wolf","squire"];p.mana=10;p.hp=20
 return m
func _init() -> void:
 assert(Match.CARD_DATA.mage.attack==1 and Match.CARD_DATA.mage.health==2)
 assert(Match.CARD_DATA.magic_missiles.spell_value==2)
 assert(Match.CARD_DATA.wizard_apprentice.resonance==1 and Match.CARD_DATA.aether_summoner.resonance==1)
 var m=fresh()
 var apprentice=m.spawn_unit(0,"wizard_apprentice")
 var conjurer=m.spawn_unit(0,"aether_summoner")
 var enemy=m.spawn_unit(1,"farmer")
 var guard=m.spawn_unit(1,"squire")
 apprentice.ready=true
 assert(m.can_target(0,0,-1,true) and not m.can_target(0,0,-1,false))
 assert(m.act(0,0,-1,true) and m.players[1].hp==19 and guard.block==1)
 assert(apprentice.attack==1 and apprentice.health==3 and conjurer.attack==2 and conjurer.health==4)
 assert(m.last_action.resonance_buffs.size()==2)
 m.players[0].hand=["magic_missiles"]
 var first={"side":1,"index":0};var castle={"side":1,"index":-1}
 assert(not m.cast_multiple(0,0,[castle,castle]))
 assert(m.cast_multiple(0,0,[first,castle]))
 assert(m.players[1].hp==17 and enemy.health==1)
 assert(apprentice.attack==2 and apprentice.health==4 and conjurer.attack==3 and conjurer.health==5)
 assert(m.last_action.missile_hits.size()==2 and m.last_action.missile_hits[1].castle)
 assert(m.last_action.resonance_buffs.size()==2)
 m=fresh()
 m.players[0].hand=["magic_missiles"]
 assert(not m.has_spell_target(0,0))
 m.spawn_unit(1,"farmer")
 assert(m.can_cast(0,0,1,-1) and m.can_cast(0,0,1,0))
 m.turn=1
 var other=m.spawn_unit(1,"wizard_apprentice");other.ready=true
 var ally=m.spawn_unit(0,"wizard_apprentice")
 assert(m.act(1,1,-1,true))
 assert(other.attack==1 and ally.attack==0 and m.players[0].hp==19)
 m=fresh()
 apprentice=m.spawn_unit(0,"wizard_apprentice");apprentice.ready=true
 enemy=m.spawn_unit(1,"farmer");enemy.abascanto=1
 assert(m.act(0,0,0,true) and enemy.health==3 and apprentice.attack==1)
 print("OK: magia e castelo, Bloqueio, dois alvos distintos e Ressonância por ação.")
 quit()

