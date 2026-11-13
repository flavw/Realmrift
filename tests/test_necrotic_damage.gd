extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func fixture():
 var m=Match.new()
 for p in m.players:p.board.clear();p.hand.clear();p.mana=10;p.hp=20;p.deck=Match.default_deck(0)
 return m
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 assert(Match.CARD_DATA.ash_necromancer.magic_damage==0 and Match.CARD_DATA.ash_necromancer.necrotic_damage==1)
 assert(Match.CARD_DATA.ash_necromancer.ability_entries().any(func(entry):return entry.get("badge","")=="Necrotic"))
 assert(Store.accepts_base(7,["sepulchral_tide"]) and not Store.accepts_base(5,["sepulchral_tide"]))
 for side in [0,1]:
  var m=fixture();m.turn=side
  var caster=m.spawn_unit(side,"ash_necromancer")
  var ally=m.spawn_unit(side,"crypt_zombie");ally.health=1;ally.max_health=5;ally.poison=1;ally.bleeding=1;ally.antimagic=2
  var own_artifact=m.spawn_unit(side,"defiled_crypt")
  var enemies: Array=[]
  for key in ["farmer","wolf","wandering_ogre","crypt_zombie","village_wall","wild_elf"]:
   var unit=m.spawn_unit(1-side,key);unit.health=5;unit.max_health=5;unit.armor=9;unit.antimagic=0;enemies.append(unit)
  enemies[3].health=1
  m.players[side].hand=["sepulchral_tide"]
  assert(m.cast(side,0,side,-1) and m.players[side].mana==6 and m.players[side].hand.is_empty())
  for i in [0,1,2,5]:assert(enemies[i].health==3)
  assert(enemies[3].health==3 and enemies[4].health==5 and ally.health==3 and own_artifact.health==5 and caster.health==4)
  assert(ally.poison==1 and ally.bleeding==1 and ally.antimagic==2)
  assert(m.players[0].hp==20 and m.players[1].hp==20 and not m.last_action.castle)
  assert(m.last_action.area_hits.size()==4 and m.last_action.healed.size()==2 and m.last_action.damage_type==CardData.DamageType.NECROTIC)
  # Shot can restore both sides and cannot harm allied living creatures or artifacts.
  m=fixture();m.turn=side;caster=m.spawn_unit(side,"ash_necromancer");caster.ready=true
  ally=m.spawn_unit(side,"crypt_zombie");ally.health=1;ally.max_health=4;ally.antimagic=2
  var living=m.spawn_unit(1-side,"farmer");living.health=4;living.max_health=4;living.armor=10;living.attack=20
  var undead=m.spawn_unit(1-side,"crypt_zombie");undead.health=1;undead.max_health=4
  var artifact=m.spawn_unit(1-side,"village_wall")
  assert(m.can_necrotic_target(side,0,side,1) and not m.can_necrotic_target(side,0,side,0))
  assert(not m.can_necrotic_target(side,0,1-side,2))
  var before=JSON.stringify(m.players)
  var forecast=m.attack_forecast(side,0,1,true,side)
  assert(forecast.necrotic_healing and forecast.healing==1 and forecast.damage==0 and JSON.stringify(m.players)==before)
  assert(m.act(side,0,1,true,side) and ally.health==2 and ally.antimagic==2 and not caster.ready and m.players[side].mana==9)
  assert(not m.act(side,0,-1))
  caster.ready=true
  assert(m.act(side,0,0,true) and living.health==3 and caster.health==4)
  caster.ready=true
  assert(m.act(side,0,1,true) and undead.health==2)
  caster.ready=true;before=JSON.stringify(m.players)
  assert(not m.act(side,0,2,true) and JSON.stringify(m.players)==before)
  assert(m.apply_necrotic_damage(1-side,artifact,5)==0 and artifact.health==4)
 # Amplify increases damage and restored life; Resonance fires once per cast.
 var m=fixture();var familiar=m.spawn_unit(0,"runic_familiar")
 var ally=m.spawn_unit(0,"crypt_zombie");ally.health=1;ally.max_health=5
 var victim=m.spawn_unit(1,"farmer");victim.health=6;victim.max_health=6
 m.players[0].hand=["sepulchral_tide"]
 assert(m.cast(0,0,0,-1) and victim.health==3 and ally.health==4 and familiar.resonance_bonus==1)
 # Damage protection applies to living targets; undead restoration preserves ward charges.
 m=fixture();victim=m.spawn_unit(1,"antimagic_guardian")
 var undead=m.spawn_unit(1,"crypt_zombie");undead.health=1;undead.antimagic=2
 var artifact=m.spawn_unit(1,"village_wall");artifact.antimagic=2
 var immune=m.spawn_unit(1,"wild_badger")
 var immune_hp: int=immune.health
 m.players[0].hand=["sepulchral_tide"]
 assert(m.cast(0,0,0,-1) and victim.health==3 and victim.antimagic==0)
 assert(undead.health==2 and undead.antimagic==2 and artifact.antimagic==2 and immune.health==immune_hp)
 m=fixture();m.spawn_unit(1,"village_wall");m.players[0].hand=["sepulchral_tide"]
 assert(not m.has_spell_target(0,0) and not m.cast(0,0,0,-1) and m.players[0].mana==10)
 # Ordinary magic and Cura retain their existing, different interactions with undead.
 m=fixture();var mage=m.spawn_unit(0,"mage");mage.ready=true
 undead=m.spawn_unit(1,"crypt_zombie");undead.health=5;undead.max_health=5
 assert(m.act(0,0,0,true) and undead.health==4)
 assert(m.apply_healing(1,undead,1,0)==0 and undead.health==3)
 # A necrotic shot at the castle still triggers a trap before dealing damage.
 m=fixture();var trapped=m.spawn_unit(0,"ash_necromancer");trapped.ready=true
 m.castle_traps[1]=[{"remaining":1,"damage":5}]
 assert(m.act(0,0,-1,true) and m.last_action.trap_stopped and m.players[1].hp==20 and m.players[0].mana==9)
 assert(m.players[0].board.is_empty())
 # AI favors a wounded allied undead over healing enemies and avoids a harmful tide.
 m=fixture();m.turn=1;var caster=m.spawn_unit(1,"ash_necromancer");caster.ready=true
 ally=m.spawn_unit(1,"crypt_zombie");ally.health=1;ally.max_health=4
 assert(m.ai_step() and ally.health==2 and m.last_action.target_side==1)
 m=fixture();m.turn=1;undead=m.spawn_unit(0,"crypt_zombie");undead.health=1;undead.max_health=5
 m.players[1].hand=["sepulchral_tide"]
 assert(m.ai_spell_target(0).is_empty())
 m=fixture();m.turn=1;victim=m.spawn_unit(0,"farmer");victim.health=1
 m.players[1].hand=["sepulchral_tide"]
 assert(m.ai_step() and m.players[0].board.is_empty())
 # Actual field controls accept friendly undead and reject artifacts.
 var main=load("res://main.tscn").instantiate();main.enable_opening=false;main.muted=true
 root.add_child(main);await process_frame
 main.duel=fixture();caster=main.duel.spawn_unit(0,"ash_necromancer");caster.ready=true
 ally=main.duel.spawn_unit(0,"crypt_zombie");ally.health=1
 var human=main.duel.spawn_unit(0,"farmer")
 artifact=main.duel.spawn_unit(1,"village_wall");victim=main.duel.spawn_unit(1,"farmer");victim.health=6;victim.max_health=6
 main.redraw();await process_frame;main.select(0);await process_frame
 assert(main.magic and main.field_nodes[0][ally.id].available and not main.field_nodes[0][human.id].available and not main.field_nodes[1][artifact.id].available)
 assert(main.aimed_magic_damage(0,1)==1)
 var motion:=InputEventMouseMotion.new();motion.position=main.field_nodes[0][ally.id].get_global_rect().get_center();motion.global_position=motion.position
 root.push_input(motion,true);await process_frame;main._process(0.016)
 assert(main.heal_cursor_active and main.cursor_damage_badge.text=="+1")
 assert(main.show_combat_forecast(1,main.field_nodes[0][ally.id]))
 assert(main.forecast_panel.find_children("*","RichTextLabel",true,false).any(func(label):return label.text.contains("Restaura") and label.text.contains("de vida")))
 main.field_nodes[0][ally.id].activated.emit()
 assert(ally.health==2 and not caster.ready)
 await create_timer(0.8).timeout
 main.duel.players[0].hand=["sepulchral_tide"];main.duel.players[0].mana=10
 main.play(0);assert(main.duel.players[0].hand.is_empty() and victim.health==4 and artifact.health==4)
 await create_timer(1.3).timeout
 main.queue_free();await process_frame;await process_frame
 print("OK: dano necrótico, seis tipos, dois lados, Antimagia/imunidades, Amplificar, disparo/cura, IA, alvos e magia global na UI.")
 quit()
