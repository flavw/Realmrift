extends SceneTree
const Factions=preload("res://scripts/faction_names.gd")
const Match=preload("res://scripts/match.gd")
const Store=preload("res://scripts/deck_store.gd")
func _initialize():call_deferred("verify")
func verify():
 assert(Factions.PT==["Vanguarda","Arcano","Aldeia","Submundo","Luminares","Ruína","Selvagem","Necrópole","Ermos"])
 assert(Factions.EN==["Vanguard","Arcane","Village","Underworld","Luminaries","Ruin","Wilds","Necropolis","Wastes"])
 for i in range(9):
  assert(Factions.name_for(i,"pt_BR")==Factions.PT[i])
  assert(Factions.name_for(i,"en_US")==Factions.EN[i])
 var m=load("res://main.tscn").instantiate();m.enable_opening=false;m.muted=true
 root.add_child(m);await process_frame
 m.enemy_deck=Match.default_deck(0);assert(m.opponent_label()=="IA — Vanguarda")
 m.enemy_deck=Match.default_deck(1);assert(m.opponent_label()=="IA — Submundo")
 m.enemy_deck=Match.default_deck(2);assert(m.opponent_label()=="IA — Arcano")
 m.enemy_deck=Match.default_deck(3);assert(m.opponent_label()=="IA — Luminares")
 var editor=load("res://deck_editor.tscn").instantiate();editor.configure(Store.new("user://faction_test.json",false));root.add_child(editor);await process_frame
 assert(editor.FACTION_NAMES[0]=="Vanguarda" and editor.FACTION_NAMES[3]=="Submundo")
 assert(Match.CARD_DATA.warrior.faction==0 and Match.CARD_DATA.mage.faction==1 and Match.CARD_DATA.cleric.faction==4)
 editor.queue_free();m.queue_free();await process_frame
 print("OK: nomes PT/EN, rótulos do jogo e identificadores preservados.")
 quit()
