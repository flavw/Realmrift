extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _initialize():call_deferred("verify")
func fresh():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10;p.max_mana=10;p.deck=["wolf","squire","farmer","wolf","squire","farmer"]
 return m
func verify():
 var deer=Match.CARD_DATA.wild_stag
 var spell=Match.CARD_DATA.wild_pack_spell
 assert(deer.cost==3 and deer.attack==1 and deer.health==2 and deer.turn_draw==1 and deer.aura_value==0)
 assert(spell.cost==2 and spell.spell_effect==CardData.SpellEffect.GRANT_PACK)
 var m=fresh()
 var d=m.spawn_unit(0,"wild_stag")
 m.begin_turn()
 assert(m.players[0].hand.size()==2 and m.players[0].deck.size()==4)
 d.health=0;m.remove_dead();m.begin_turn()
 assert(m.players[0].hand.size()==3)
 m=fresh()
 var ally=m.spawn_unit(0,"farmer")
 var own_beast=m.spawn_unit(0,"wolf")
 var rival=m.spawn_unit(1,"farmer")
 var immune=m.spawn_unit(1,"wild_badger")
 m.players[0].hand=["wild_pack_spell"]
 assert(m.has_spell_target(0,0) and m.cast(0,0,0,-1))
 assert(ally.pack==1 and own_beast.pack==1 and rival.pack==1 and immune.pack==0)
 assert(m.card_for_unit(ally).ability_entries().any(func(e):return e.name=="Matilha 1"))
 var wolf=m.spawn_unit(0,"wolf")
 assert(Match.attack_value(ally)==Match.CARD_DATA.farmer.attack+1)
 assert(Match.attack_value(own_beast)==Match.CARD_DATA.wolf.attack+1 and Match.attack_value(wolf)==Match.CARD_DATA.wolf.attack)
 assert(Match.attack_value(rival)==Match.CARD_DATA.farmer.attack)
 m.players[0].hand=["wild_pack_spell"]
 assert(m.cast(0,0,0,-1) and ally.pack==2)
 m.spawn_unit(0,"wild_swift_boar")
 assert(Match.attack_value(ally)==Match.CARD_DATA.farmer.attack+3)
 assert(m.end_turn(0) and Match.attack_value(ally)==Match.CARD_DATA.farmer.attack)
 assert(ally.pack==2 and rival.pack==2)
 m.spawn_unit(1,"wolf")
 assert(Match.attack_value(rival)==Match.CARD_DATA.farmer.attack+2)
 assert(m.end_turn(1) and Match.attack_value(rival)==Match.CARD_DATA.farmer.attack)
 assert(Store.accepts_base(CardData.Faction.WILD,["wild_stag","wild_pack_spell","wolf"]))
 print("OK: compra, Matilha nos dois lados, imunidade, acúmulo e duração.")
 quit()
