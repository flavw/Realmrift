extends SceneTree
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func unit(key: String,id: int) -> Dictionary:
 var u: Dictionary=Match.CARDS[key].duplicate(true)
 u.merge({"key":key,"id":id,"ready":false,"max_health":u.health,"poison":0})
 return u
func fixture():
 var m=Match.new()
 m.players[0].board=[];m.players[1].board=[]
 m.players[0].hand=["moon_herald"];m.players[0].mana=10
 return m
func _init() -> void:
 for style in range(3):assert(Match.valid_deck(Match.default_deck(style)))
 var mixed: Array=Match.default_deck(0)
 mixed[0]="mage"
 assert(not Match.valid_deck(mixed) and Match.valid_deck(mixed,false) and Match.deck_faction(mixed)==-2)
 assert(Match.can_add_faction(["mage"],"moon_herald") and not Match.can_add_faction(["mage"],"sentinel"))
 var neutrals: Array=Match.default_deck(4)
 assert(Match.valid_deck(neutrals) and Match.deck_faction(neutrals)==-1)
 var m=fixture()
 assert(m.play(0,0) and m.players[0].mana==8 and m.players[0].board[0].attack==1)
 assert(not m.players[0].board[0].ready and not m.last_action.has("buff_target"))
 m=fixture()
 var ally=unit("wolf",80)
 m.players[0].board=[ally]
 assert(not m.play(0,0) and not m.play(0,0,-2) and not m.play(0,0,1))
 assert(m.players[0].mana==10 and m.players[0].hand==["moon_herald"] and ally.attack==2)
 assert(m.play(0,0,0) and ally.attack==3 and not ally.ready and ally.health==3 and ally.max_health==3)
 assert(m.players[0].board[1].attack==1 and not m.players[0].board[1].ready)
 assert(m.last_action.buff_target==80 and m.last_action.buff_attack==1 and m.last_action.buff_health==1)
 m.players[0].hand=["moon_herald"]
 assert(m.play(0,0,0) and ally.attack==4 and ally.health==4 and ally.max_health==4,"Bônus permanentes de invocações distintas acumulam")
 m.end_turn(0);m.end_turn(1)
 assert(ally.attack==4,"Chamado não repete no início do turno")
 m=fixture()
 for i in range(5):m.players[0].board.append(unit("wolf",i+20))
 assert(not m.play(0,0,0) and m.players[0].mana==10)
 m=fixture();m.turn=1
 m.players[1].hand=["moon_herald"];m.players[1].mana=2
 var ai_ally=unit("wolf",90)
 m.players[1].board=[ai_ally]
 assert(m.ai_step() and ai_ally.attack==3 and ai_ally.health==3 and ai_ally.max_health==3 and m.players[1].board.size()==2 and m.last_action.buff_target==90)
 # Health bonus raises current and maximum life without erasing previous wounds or poison.
 m=fixture()
 var wounded=unit("cleric",95)
 wounded.health=1;wounded.poison=2
 m.players[0].board=[wounded]
 assert(m.play(0,0,0) and wounded.attack==2 and wounded.health==2 and wounded.max_health==5)
 assert(wounded.poison==2 and not wounded.ready and Match.physical_attack(wounded)==2)
 assert(m.players[0].board[1].health==2 and m.players[0].board[1].max_health==2)
 wounded.ready=true;wounded.health=4
 assert(m.heal(0,0,0) and wounded.health==5 and wounded.max_health==5 and Match.physical_attack(wounded)==5,"Cura e Vigor respeitam a vida máxima concedida")
 var entry: Dictionary=Match.CARD_DATA.moon_herald.ability_entries()[0]
 assert(entry.name=="Chamado" and entry.summary=="+1/+1 aliado humano" and "Ao jogar esta criatura da mão" in entry.description)
 # The trigger must also resolve a health-only buff, without depending on a positive attack bonus.
 var original: Dictionary=Match.CARDS.moon_herald
 var health_only: Dictionary=original.duplicate(true)
 health_only.entry_attack=0;health_only.entry_health=2
 Match.CARDS.moon_herald=health_only
 m=fixture();m.players[0].board=[unit("wolf",96)]
 assert(m.play(0,0,0) and m.players[0].board[0].attack==2 and m.players[0].board[0].health==4 and m.players[0].board[0].max_health==4)
 Match.CARDS.moon_herald=original
 var store=Store.new("user://test_class_migration.json",false)
 assert(not store.save_slot(0,"Inválido",mixed))
 var file:=FileAccess.open(store.path,FileAccess.WRITE)
 var saved: Array=store.slots.duplicate(true)
 saved[0]={"name":"Legado misturado","cards":mixed}
 file.store_string(JSON.stringify({"version":Store.DECKSET_VERSION,"active":0,"slots":saved}));file.close()
 var legacy=Store.new(store.path)
 assert(legacy.slots[0].cards==mixed and legacy.slots[0].name=="Legado misturado","Preserva deck antigo para edição")
 assert(not Match.valid_deck(legacy.active_cards()))
 var fallback=Match.new(legacy.active_cards())
 var actual: Array=fallback.players[0].hand.duplicate()
 actual.append_array(fallback.players[0].deck)
 assert(Match.valid_deck(actual),"Motor não inicia deck de facções misturadas")
 DirAccess.remove_absolute(ProjectSettings.globalize_path(store.path))
 print("OK: facção única + aldeões, migração sem perda, Chamado vazio/alvo/sem custo inválido/permanência/IA e limite de campo.")
 quit()
