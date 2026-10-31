extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _initialize() -> void:call_deferred("verify")
func fresh():
 var m=Match.new()
 for p in m.players:
  p.board.clear();p.hand.clear();p.mana=10;p.hp=20
 return m
func summon_necro(m,side: int=0) -> void:
 m.turn=side;m.players[side].mana=10;m.players[side].hand=["necromancer_summoner"]
 assert(m.play(side,0))
func verify() -> void:
 var necro: CardData=Match.CARD_DATA.necromancer_summoner
 assert(necro.is_human() and necro.human_and_monster and necro.card_class==5)
 assert(Match.CARD_DATA.zombie_helper.creature_type==CardData.CreatureType.UNDEAD)
 assert(Match.CARD_DATA.summoned_ghoul.creature_type==CardData.CreatureType.UNDEAD)
 assert(not Match.CARD_DATA.summoned_ghoul.collectible)
 assert(Store.accepts_base(5,["necromancer_summoner","zombie_helper"]))
 assert(not Store.accepts_base(5,["farmer","necromancer_summoner"]))
 assert(not Store.accepts_base(2,["summoned_ghoul"]))
 assert(not Match.can_add_class([],"summoned_ghoul"))
 var deck=Match.default_deck(5)
 assert(deck.count("necromancer_summoner")==2)
 assert(Match.valid_deck(deck))
 var m=fresh();summon_necro(m)
 assert(m.players[0].board.size()==1) # No enemy Human has died.
 var friendly=m.spawn_unit(0,"farmer");friendly.health=0;m.remove_dead()
 assert(m.human_deaths==[1,0]);summon_necro(m)
 assert(m.players[0].board.size()==2) # A friendly death does not qualify.
 m=fresh()
 var caster=m.spawn_unit(0,"mage");caster.ready=true
 var victim=m.spawn_unit(1,"farmer");victim.health=1
 assert(m.act(0,0,0,true) and m.human_deaths[1]==1)
 m.remove_dead();assert(m.human_deaths[1]==1) # Count each death only once.
 summon_necro(m)
 assert(m.players[0].board.size()==3)
 var ghoul=m.players[0].board[2]
 assert(ghoul.key=="summoned_ghoul" and ghoul.attack==2 and ghoul.health==2 and not ghoul.ready)
 assert(m.last_action.spawned.size()==1)
 # Human death to poison also unlocks the condition, regardless of whose turn.
 m=fresh();victim=m.spawn_unit(1,"farmer");victim.health=1;victim.poison=1;m.resolve_poison(1)
 assert(m.human_deaths[1]==1);summon_necro(m)
 assert(m.players[0].board.size()==2)
 # A dead Beast does not unlock it; history persists after the body leaves.
 m=fresh();victim=m.spawn_unit(1,"wolf");victim.health=0;m.remove_dead();summon_necro(m)
 assert(m.human_deaths[1]==0 and m.players[0].board.size()==1)
 # Necromancer herself is Human even with Pacto Sombrio.
 m=fresh();victim=m.spawn_unit(1,"necromancer_summoner");victim.health=0;m.remove_dead()
 assert(m.human_deaths[1]==1)
 for i in range(5):m.spawn_unit(0,"wolf")
 summon_necro(m)
 assert(m.players[0].board.size()==6 and not m.last_action.has("spawned"))
 # Healing an undead deals exactly the healing amount as magic: armor ignored,
 # no counterattack, no poison cleanse and no Devotion trigger.
 m=fresh();caster=m.spawn_unit(0,"dawn_devotee");caster.ready=true
 var observer=m.spawn_unit(1,"dawn_devotee")
 victim=m.spawn_unit(1,"zombie_helper");victim.armor=99;victim.poison=2
 assert(m.can_heal(0,0,1,1) and m.heal(0,0,1,1))
 assert(victim.health==2 and victim.poison==2 and caster.health==4 and observer.health==4)
 assert(not caster.ready and m.players[0].mana==10)
 assert(m.last_action.kind=="magic" and m.last_action.target_side==1 and not m.last_action.has("healed"))
 caster.ready=true;victim.abascanto=1
 assert(m.heal(0,0,1,1) and victim.health==2 and victim.abascanto==0 and m.last_action.abascanto_blocked)
 caster.ready=true
 assert(m.heal(0,0,1,1) and victim.health==1)
 # Friendly undead can also be targeted, including at full health.
 victim=m.spawn_unit(0,"zombie_helper");caster.ready=true
 assert(m.heal(0,0,1) and victim.health==2)
 # Restoration spell can target enemy undead and kill, spending the spell/mana.
 m=fresh();victim=m.spawn_unit(1,"zombie_helper");m.players[0].hand=["restoring_light"]
 assert(m.can_cast(0,0,1,0) and m.cast(0,0,1,0))
 assert(m.players[1].board.is_empty() and m.players[0].hand.is_empty() and m.players[0].mana==8)
 assert(m.last_action.undead_damage and m.last_action.dead.size()==1 and not m.last_action.has("healed"))
 # Living enemies and enemy castles remain invalid healing targets.
 m=fresh();caster=m.spawn_unit(0,"cleric");caster.ready=true
 victim=m.spawn_unit(1,"farmer");victim.health=1;m.players[1].hp=10
 m.players[0].hand=["restoring_light"]
 assert(not m.can_heal(0,0,0,1) and not m.can_heal(0,0,-1,1))
 assert(not m.can_cast(0,0,1,0) and not m.can_cast(0,0,1,-1))
 # AI understands offensive healing and does not cure its own undead.
 m=fresh();m.turn=1;caster=m.spawn_unit(1,"cleric");caster.ready=true
 victim=m.spawn_unit(0,"summoned_ghoul")
 assert(m.ai_step() and m.players[0].board.is_empty())
 m=fresh();m.turn=1;m.players[1].hand=["restoring_light"];victim=m.spawn_unit(0,"zombie_helper")
 assert(m.ai_spell_target(0)=={"side":0,"index":0})
 var main=load("res://main.tscn").instantiate();main.enable_opening=false;main.muted=true;root.add_child(main)
 main.duel=fresh();caster=main.duel.spawn_unit(0,"dawn_devotee");caster.ready=true
 victim=main.duel.spawn_unit(1,"zombie_helper");main.duel.players[0].mana=0
 main.selected=0;main.healing=true;main.redraw()
 assert(main.context_for(caster,0).heal_target and "usar habilidades" in main.remaining_actions())
 var field=main.field_nodes[1][victim.id]
 var connections=field.activated.get_connections()
 assert(connections.size()==1 and connections[0].callable.get_bound_arguments()==[0,1])
 # The generator keeps the non-copyable, deck-only exception out of field badges.
 var field_necro=load("res://field_card.tscn").instantiate();root.add_child(field_necro)
 field_necro.set_card(necro,4,false,false,2,0,true,0)
 assert(field_necro.find_child("Pacto Sombrio",true,false)==null)
 field_necro.queue_free();main.queue_free();await process_frame;await create_timer(0.35).timeout
 print("OK: Mortos-vivos sofrem Cura como dano mágico, Abascanto/Armadura/prontidão/mana/Devoção/IA; Pacto Sombrio, registro de mortes, condição, limite de campo e Carniçal 2/2 invocado.")
 quit()
