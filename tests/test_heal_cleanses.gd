extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func fixture():
 var m=Match.new()
 for p in m.players:p.board=[];p.hand=[];p.deck=["squire","wolf"];p.mana=10;p.max_mana=10;p.hp=20
 m.next_id=100
 return m
func verify() -> void:
 var data: CardData=Match.CARD_DATA.dawn_devotee
 assert(data.attack==1 and data.health==4 and data.heal_amount==1 and data.heal_cost==0 and data.cost==3)
 assert(Match.CARD_DATA.cleric.heal_cost==1 and Match.CARD_DATA.dawn_warden.heal_amount==0)
 var m=fixture();var dev=m.spawn_unit(0,"dawn_devotee");var target=m.spawn_unit(0,"farmer")
 var enemy=m.spawn_unit(1,"dawn_devotee");dev.ready=true;target.health=2;target.poison=3;m.players[0].mana=0
 assert(m.heal(0,0,1) and target.health==3 and target.poison==0 and not dev.ready and m.players[0].mana==0)
 assert(not m.can_heal(0,0,1),"Cura gratuita ainda esgota")
 assert(dev.attack==2 and dev.health==5 and enemy.attack==1 and enemy.health==4)
 assert(m.last_action.healed[0].cleansed==3 and m.last_action.healed[0].amount==1)
 # Full health cleansing is legal, spends resources, but does not grant Devoção.
 dev.ready=true;target.poison=4
 assert(m.can_heal(0,0,1) and m.heal(0,0,1) and target.poison==0 and target.health==3 and m.players[0].mana==0)
 assert(dev.attack==2 and enemy.attack==1 and not m.last_action.has("devotion_buffs"))
 assert(m.last_action.healed[0].amount==0 and m.last_action.healed[0].cleansed==4)
 # Healing magic and AI also cleanse a full-health target.
 m=fixture();target=m.spawn_unit(0,"farmer");target.poison=2;m.players[0].hand=["restoring_light"]
 assert(m.can_cast(0,0,0,0) and m.cast(0,0,0,0) and target.poison==0)
 m=fixture();m.turn=1;dev=m.spawn_unit(1,"dawn_devotee");dev.ready=true;target=m.spawn_unit(1,"farmer");target.poison=1
 assert(m.ai_step() and target.poison==0 and not dev.ready and dev.attack==1)
 m=fixture();m.turn=1;target=m.spawn_unit(1,"farmer");target.poison=1;m.players[1].hand=["restoring_light"]
 assert(m.ai_step() and target.poison==0)
 # Self-healing cleanses and grants the effective-heal bonus exactly once.
 m=fixture();dev=m.spawn_unit(0,"dawn_devotee");dev.ready=true;dev.health=3;dev.poison=2
 assert(m.heal(0,0,0) and dev.health==5 and dev.max_health==5 and dev.attack==2 and dev.poison==0)
 # Attribute gains are not healing and leave poison in place.
 target=m.spawn_unit(0,"farmer");target.poison=2;Match.grant_stats(target,0,1)
 assert(target.poison==2)
 var main=load("res://main.tscn").instantiate();main.enable_opening=false;main.muted=true;root.add_child(main)
 main.duel=fixture();dev=main.duel.spawn_unit(0,"dawn_devotee");dev.ready=true;target=main.duel.spawn_unit(0,"farmer");target.poison=1
 main.duel.players[0].mana=0;main.redraw();main.select(0)
 assert(main.context_for(dev,0).heal_target and "usar habilidades" in main.remaining_actions())
 assert(main.find_child("Ability_heal-icon",true,false)!=null)
 main.queue_free();await process_frame;await create_timer(0.35).timeout
 print("OK: Cura remove Veneno, alvo cheio, magia/IA, gastos/esgotamento, Devota 1/4 Cura 1 e Devoção sem gatilhos extras.")
 quit()
