extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
const KEY="peasant_uprising"
func _initialize() -> void:call_deferred("verify")
func fixture():
 var m=Match.new()
 for p in m.players:p.board=[];p.hand=[];p.deck=["squire","wolf","farmer"];p.mana=10;p.max_mana=10;p.hp=20
 m.next_id=100
 return m
func spawn(m,key: String,side: int=0) -> Dictionary:return m.spawn_unit(side,key)
func verify() -> void:
 assert(Match.CARD_DATA[KEY].legendary and Match.copy_limit(KEY)==1 and Match.CARD_DATA[KEY].cost==5)
 assert(Match.CARD_DATA.lightning_rogue.attack==3 and Match.CARD_DATA.lightning_rogue.swift and Match.CARD_DATA.lightning_rogue.envenom==1)
 var cards: Array=Match.default_deck(4)
 cards[cards.find(KEY)]="village_reconstruction"
 cards[cards.find("life_pilgrim")]=KEY
 assert(Match.valid_deck(cards))
 var twice: Array=cards.duplicate();twice[twice.find("life_pilgrim")]=KEY
 assert(not Match.valid_deck(twice))
 var store=Store.new("user://test_legendary_decks.json",false)
 assert(store.save_slot(4,"Lendária",cards,2) and not store.save_slot(4,"Duplicada",twice,2))
 var editor=load("res://deck_editor.tscn").instantiate();editor.configure(store);root.add_child(editor)
 editor.choose_slot(6);editor.select_base_class(2)
 assert(editor.add_card(KEY) and not editor.add_card(KEY) and "1 cópia" in editor.addition_reason(KEY))
 assert(editor.add_card("wolf") and editor.add_card("wolf") and not editor.add_card("wolf"))
 # Alone: counts itself. Enemy abilities never transfer.
 var m=fixture();spawn(m,"lightning_rogue",1);spawn(m,"abascanto_guardian",1)
 var mob=spawn(m,KEY)
 assert(mob.attack==1 and mob.health==1 and not mob.swift and mob.envenom==0 and mob.abascanto==0)
 # Two farmers give Cultivo 2. Repeated refreshes never grow, heal or duplicate abilities.
 m=fixture();var a=spawn(m,"farmer");var b=spawn(m,"farmer");mob=spawn(m,KEY)
 assert(mob.attack==3 and mob.health==3 and mob.growth==2)
 for i in range(8):m.refresh_auras()
 assert(mob.health==3 and mob.attack==3 and mob.growth==2)
 m.begin_turn();assert(mob.health==5 and mob.max_health==5 and mob.attack==3)
 Match.damage(mob,1,true);m.players[0].board.erase(a);m.refresh_auras()
 assert(mob.health==3 and mob.max_health==4 and mob.attack==2 and mob.growth==1)
 m.players[0].board.erase(b);m.refresh_auras()
 assert(mob.health==2 and mob.max_health==3 and mob.attack==1 and mob.growth==0)
 # Inherited charge capacity stacks; consuming a charge is not undone by refresh.
 m=fixture();spawn(m,"squire");var neutral_ward=spawn(m,"squire");neutral_ward.abascanto=1;neutral_ward.abascanto_capacity=1
 spawn(m,"abascanto_guardian");mob=spawn(m,KEY)
 assert(m.block_capacity(mob)==2 and mob.block==2 and mob.abascanto==1)
 mob.block=0;assert(Match.damage(mob,100,true)==0 and mob.abascanto==0)
 m.refresh_auras();assert(mob.block==0 and mob.abascanto==0)
 m.begin_turn();assert(mob.block==1 and mob.abascanto==1)
 # No entry copies, including enemy and allied targeted/untargeted Chamados.
 m=fixture();var herald=spawn(m,"moon_herald");spawn(m,"generous_peasant");spawn(m,"mist_alchemist",1)
 m.players[0].hand=[KEY];assert(m.can_play(0,0) and m.play(0,0))
 mob=m.players[0].board[-1]
 assert(mob.entry_effect==CardData.EntryEffect.NONE and mob.attack==3 and mob.health==3 and herald.attack==1 and herald.health==2)
 assert(mob.envenom==0 and mob.poison==0)
 # Class allies are excluded. Neutral allies can still grant the same unique flag.
 m=fixture();spawn(m,"lightning_rogue");spawn(m,"raven");mob=spawn(m,KEY)
 assert(mob.attack==1 and mob.health==1 and not mob.swift and not mob.ready and not mob.flying and mob.envenom==0)
 m=fixture();spawn(m,"messenger_hawk");spawn(m,"messenger_hawk");mob=spawn(m,KEY)
 assert(mob.attack==3 and mob.health==3 and mob.flying)
 m=fixture();spawn(m,"mage");spawn(m,"mage");spawn(m,"runic_familiar");mob=spawn(m,KEY)
 assert(mob.magic_damage==0 and mob.magic_power==1 and mob.attack==2)
 assert(m.magic_bonus(0)==2)
 # Inherited wall restrictions and poison immunity disappear with their source.
 m=fixture();var wall=spawn(m,"village_wall");mob=spawn(m,KEY)
 assert(mob.wall and mob.armor==1 and m.block_capacity(mob)==Match.CARD_DATA.village_wall.block and not Match.apply_poison(mob,2))
 mob.ready=true;assert(not m.can_target(0,1,-1))
 m.players[0].board.erase(wall);m.refresh_auras()
 assert(not mob.wall and mob.armor==0 and mob.block==0 and m.can_target(0,0,-1))
 # A copied Aura belongs to the mob, buffs its allies and does not recurse.
 m=fixture();var leader=spawn(m,"village_leader");mob=spawn(m,KEY)
 assert(mob.attack==2 and mob.aura_attack==1 and Match.attack_value(mob)==3 and Match.attack_value(leader)==4)
 for i in range(6):m.refresh_auras()
 assert(mob.aura_attack==1 and Match.attack_value(leader)==4)
 # Losing a neutral source can kill a damaged mob; death joins the action metadata.
 m=fixture();a=spawn(m,"farmer");mob=spawn(m,KEY);Match.damage(mob,1,true)
 m.last_action={"kind":"spell","dead":[]};m.players[0].board.erase(a);m.refresh_auras()
 assert(m.players[0].board.is_empty() and m.last_action.dead.size()==1 and m.last_action.dead[0].id==mob.id)
 m=fixture();a=spawn(m,"farmer");mob=spawn(m,KEY);Match.damage(mob,1,true)
 m.turn=1;m.players[1].hand=["astral_flame"]
 assert(m.cast(1,0,0,0) and m.players[0].board.is_empty() and m.last_action.dead.size()==2)
 # Two mobs do not recursively copy one another's inherited ranks.
 m=fixture();spawn(m,"farmer");a=spawn(m,KEY);b=spawn(m,KEY)
 for i in range(8):m.refresh_auras()
 assert(a.attack==3 and b.attack==3 and a.growth==1 and b.growth==1)
 # UI keeps */* in the collection, exposes live inherited abilities in the field.
 var card=load("res://card_model.tscn").instantiate();card.card_data=Match.CARD_DATA[KEY];root.add_child(card)
 assert(card.get_node("CardCanvas/Stats").text=="*/*")
 var runtime: CardData=m.card_for_unit(a)
 assert(runtime.growth==1 and runtime.collective and runtime.legendary)
 var field=load("res://field_card.tscn").instantiate();field.set_card(runtime,a.health,true,false,Match.attack_value(a));root.add_child(field)
 assert(field.get_node("Canvas/StatusIcons").has_node("Collective") and field.get_node("Canvas/StatusIcons").has_node("Growth"))
 field.queue_free();card.queue_free();editor.queue_free();await process_frame;await create_timer(0.35).timeout
 DirAccess.remove_absolute(ProjectSettings.globalize_path(store.path))
 print("OK: lendária 1/deck, Multidão aliada sem Chamados, atributos/dano, acúmulo, recargas, Aura, Muralha, morte, UI e Ladina 3/2.")
 quit()

