extends SceneTree
const Match=preload("res://scripts/match.gd")
const Scene=preload("res://field_card.tscn")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
 var seen: Dictionary={}
 for key in Match.CARD_DATA:
  var data: CardData=Match.CARD_DATA[key]
  if data.card_type==CardData.CardType.SPELL:continue
  var field=Scene.instantiate();field.set_card(data,data.health,true)
  root.add_child(field)
  await process_frame
  var strip=field.get_node("Canvas/StatusIcons")
  for badge in strip.get_children():
   seen[badge.name]=true
   assert(badge.get_node("Icon").texture!=null,"Ícone ausente: "+str(badge.name))
   assert(badge.position.x+badge.size.x<=124 and strip.position.y+badge.position.y+badge.size.y<=194,"Ícone deve caber sem invadir ataque/vida")
  field.queue_free();await process_frame
 for name in ["Armor","Block","Antimagic","Vigor","Fury","Arcane","Heal","Amplify","Aura","Wall","Growth","Harvest","Flying","Envenom","Spores","Regeneration"]:assert(seen.has(name),name)
 assert(not seen.has("Entry") and not seen.has("Swift") and not seen.has("AuraBonus"))
 var sample: CardData=Match.CARD_DATA.dawn_warden.duplicate();sample.block=1
 var field=Scene.instantiate();field.set_card(sample,4,true,false,2,0,true)
 field.set_meta("poison",2);field.set_meta("ability_context",{"aura_attack":1,"mana":0,"heal_target":true})
 root.add_child(field);await process_frame
 var strip=field.get_node("Canvas/StatusIcons")
 assert(strip.get_node("Block/Value").text=="0" and strip.get_node("Block").modulate.a<0.5)
 assert(strip.get_node("Poison/Value").text=="2" and strip.get_node_or_null("AuraBonus")==null)
 assert(strip.get_node("Vigor/Value").text=="4" and strip.get_node("Heal").modulate.a<0.5)
 field.set_meta("block",1);field.exhausted=false;field.set_meta("poison",0)
 field.set_meta("ability_context",{"mana":3,"heal_target":true});field.refresh();await process_frame
 assert(strip.get_node("Block/Value").text=="1" and strip.get_node("Block").modulate.a==1.0)
 assert(strip.get_node_or_null("Poison")==null and strip.get_node_or_null("AuraBonus")==null and strip.get_node("Heal").modulate.a==1.0)
 assert(field.get_node("Canvas/Stats").text=="2/4")
 field.queue_free();await process_frame;await create_timer(0.35).timeout
 print("OK: ícones de todas as habilidades, limites de espaço, cargas, Aura/Veneno, disponibilidade e atualização sem marcadores antigos.")
 quit()
