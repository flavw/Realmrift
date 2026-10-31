extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
const KEY="abascanto_guardian"
func _initialize() -> void:call_deferred("verify")
func unit(key: String,id: int) -> Dictionary:
 var u: Dictionary=Match.CARDS[key].duplicate(true)
 u.merge({"key":key,"id":id,"ready":true,"max_health":u.health,"poison":0})
 return u
func fixture():
 var m=Match.new()
 for p in m.players:
  p.board=[];p.hand=[];p.deck=["squire","squire","wolf"];p.mana=10;p.max_mana=10;p.hp=20
 return m
func verify() -> void:
 assert(Match.CARD_DATA[KEY].cost==3 and Match.CARD_DATA[KEY].attack==2 and Match.CARD_DATA[KEY].health==3 and Match.CARD_DATA[KEY].card_class==0)
 var u=unit(KEY,1)
 assert(Match.damage(u,99,true)==0 and u.health==3 and u.abascanto==0)
 assert(Match.damage(u,1,true)==1 and u.health==2)
 u=unit(KEY,1)
 assert(Match.damage(u,1,false)==1 and u.abascanto==1)
 assert(Match.damage(u,0,true)==0 and u.abascanto==1)
 var m=fixture();m.players[0].board=[u];m.turn=1
 assert(m.end_turn(1) and u.abascanto==1)
 u.abascanto=0
 assert(m.end_turn(0) and u.abascanto==0)
 assert(m.end_turn(1) and u.abascanto==1)
 m.end_turn(0);m.end_turn(1);assert(u.abascanto==1)
 # Future ranks recharge one per own turn, not all missing charges.
 var data=Match.CARD_DATA[KEY];data.abascanto=3;u.abascanto=0
 m.end_turn(0);m.end_turn(1);assert(u.abascanto==1)
 m.end_turn(0);m.end_turn(1);assert(u.abascanto==2)
 data.abascanto=1
 # Magic abilities spend mana and exhaust the caster even when absorbed, without counter.
 m=fixture();var caster=unit("mage",2);u=unit(KEY,3)
 m.players[0].board=[caster];m.players[1].board=[u]
 assert(m.act(0,0,0,true) and not caster.ready and caster.health==2 and u.health==3 and u.abascanto==0)
 assert(m.last_action.abascanto_blocked and m.last_action.amount==0)
 # Single-target offensive spells are consumed and do not damage or retaliate.
 for key in ["astral_flame","conductive_bolt"]:
  m=fixture();u=unit(KEY,1);u.armor=2
  m.players[0].hand=[key];m.players[1].board=[u]
  assert(m.cast(0,0,1,0) and m.players[0].hand.is_empty() and u.health==3 and u.armor==2 and u.abascanto==0)
  assert(m.last_action.abascanto_blocked)
 # An area spell only spares the protected creature; all other enemies take damage.
 m=fixture();u=unit(KEY,1);var other=unit("dawn_warden",2)
 m.players[1].board=[u,other];m.players[0].hand=["fireball"]
 assert(m.cast(0,0,1,-1) and u.health==3 and u.abascanto==0 and other.health==2)
 assert(m.last_action.area_hits[0].amount==0 and m.last_action.area_hits[1].amount==3)
 # Healing and poison neither consume nor benefit from the ward.
 m=fixture();u=unit(KEY,1);u.health=1;m.players[0].board=[u];m.players[0].hand=["restoring_light"]
 assert(m.cast(0,0,0,0) and u.health==3 and u.abascanto==1)
 Match.apply_poison(u,1);m.resolve_poison(0)
 assert(u.health==2 and u.abascanto==1 and u.poison==0)
 # Legacy keys migrate before validation, including covers, without changing metadata.
 var path="user://test_abascanto_rename.json"
 var original=Store.new(path,false)
 var slots=original.slots.duplicate(true)
 slots[2].cards=Match.default_deck(2)
 for i in range(slots[2].cards.size()):
  if slots[2].cards[i]=="fireball":slots[2].cards[i]="solar_storm"
 slots[2].cover="solar_storm";slots[2].name="Meu Mago"
 var file=FileAccess.open(path,FileAccess.WRITE);file.store_string(JSON.stringify({"version":7,"active":2,"slots":slots}));file.close()
 var migrated=Store.new(path)
 assert(migrated.active==2 and migrated.slots[2].name=="Meu Mago" and migrated.slots[2].cover=="fireball")
 assert(migrated.slots[2].cards==Match.default_deck(2) and Store.new(path).slots==migrated.slots)
 assert(Match.CARD_DATA.fireball.title=="Bola de Fogo" and not Match.CARD_DATA.has("solar_storm"))
 var editor=load("res://deck_editor.tscn").instantiate();editor.configure(original);root.add_child(editor)
 editor.choose_slot(0);assert(KEY in editor.collection_keys())
 var view=load("res://card_model.tscn").instantiate();view.card_data=data;view.ability_context={"abascanto":0};root.add_child(view)
 assert(view.view_entries().any(func(e):return e.name=="Guarda Arcana 0"))
 var field=load("res://field_card.tscn").instantiate();field.set_card(data,3,true);field.set_meta("abascanto",0);root.add_child(field)
 assert(field.get_node("Canvas/StatusIcons/Abascanto").visible and field.get_node("Canvas/StatusIcons/Abascanto/Value").text=="0")
 editor.queue_free();view.queue_free();field.queue_free();await process_frame;await create_timer(0.35).timeout
 DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
 print("OK: Abascanto, recarga por turno/capacidade, dano físico, Veneno, cura, magia, área, UI e migração Bola de Fogo.")
 quit()
