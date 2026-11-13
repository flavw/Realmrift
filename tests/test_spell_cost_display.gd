extends SceneTree
const Match=preload("res://scripts/match.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var card=load("res://card_model.tscn").instantiate()
 root.add_child(card)
 var total: int=0
 for data in Match.CARD_DATA.values():
  if data.card_type!=CardData.CardType.SPELL:continue
  card.set_card(data)
  assert(card.get_node("CardCanvas/Cost").text==str(data.cost))
  assert(card.get_node("CardCanvas/Ability").find_child("AbilityManaCost",true,false)==null,"Magia só mostra a gema do topo")
  total+=1
 assert(total>=8,"Percorre toda a coleção de magias, incluindo as expansões")
 card.set_card(Match.CARD_DATA.mage)
 assert(card.get_node("CardCanvas/Ability").find_child("AbilityManaCost",true,false)!=null,"Habilidades de criaturas mantêm seu custo de ativação")
 card.set_card(Match.CARD_DATA.village_reconstruction)
 var entries=card.view_entries()
 assert(entries.size()==2 and entries[0].name=="Restaurar 2" and entries[1].name=="Campo aldeão: compre 1")
 assert(entries[0].description.contains("Restaure 2") and entries[0].description.contains("Muralha aliada") and not Match.CARD_DATA.village_reconstruction.neutral_deck_only)
 card.queue_free();await process_frame
 print("OK: %d magias sem custo repetido, habilidade de criatura e texto de Reconstrução preservados." % total)
 quit()

