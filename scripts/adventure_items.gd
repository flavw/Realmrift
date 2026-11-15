extends RefCounted
const Match=preload("res://scripts/match.gd")
const DEFINITIONS={
 "boots":{"name":"Botas da Disparada","description":"Concede Disparada: pode atacar no turno de entrada. Se já tiver Disparada, recebe +1 de ataque.","icon":"res://assets/ui/item-boots.svg"},
 "boots_attack":{"name":"Botas da Disparada · ataque","description":"Esta criatura já tinha Disparada: recebeu +1 de ataque permanente em todas as cópias desta carta na expedição.","icon":"res://assets/ui/item-boots.svg"},
 "training_health":{"name":"Treino de resistência","description":"+1 de vida nesta cópia durante esta expedição (bônus de nível).","icon":"res://assets/ui/item-heart.svg"},
 "training_attack":{"name":"Treino de força","description":"+1 de ataque nesta cópia durante esta expedição (bônus de nível).","icon":"res://assets/ui/item-sword.svg"},
 "charm":{"name":"Talismã de mana","description":"Custo de mana reduzido em 1 em todas as cópias desta carta (mínimo 0).","icon":"res://assets/ui/item-charm.svg"},
 "heart":{"name":"Amuleto vital","description":"+2 de vida permanente em todas as cópias desta carta na expedição.","icon":"res://assets/ui/item-heart.svg"},
 "sword":{"name":"Lâmina afiada","description":"+1 de ataque permanente em todas as cópias desta carta na expedição.","icon":"res://assets/ui/item-sword.svg"},
 "shield":{"name":"Broquel de ferro","description":"+1 de Armadura permanente em todas as cópias desta carta na expedição.","icon":"res://assets/ui/item-shield.svg"}
}
static var serial:=0
static func base_key(key: String) -> String:
 return String(Match.CARD_DATA[key].get_meta("adventure_base",key))
static func enhance(key: String,item: String) -> String:
 if not DEFINITIONS.has(item) or not Match.CARD_DATA.has(key):return key
 serial+=1
 var id: String="adventure_item_%d" % serial
 var data: CardData=Match.CARD_DATA[key].duplicate()
 data.collectible=false
 var applied_item: String=item
 match item:
  "boots":
   if data.swift:data.attack+=1;applied_item="boots_attack"
   else:data.swift=true
  "training_health":data.health+=1
  "training_attack":data.attack+=1
  "charm":data.cost=maxi(0,data.cost-1)
  "heart":data.health+=2
  "sword":data.attack+=1
  "shield":data.armor+=1
 var applied: Array=data.get_meta("adventure_items",[]).duplicate()
 applied.append(applied_item)
 data.set_meta("adventure_items",applied)
 data.set_meta("adventure_base",base_key(key))
 Match.CARD_DATA[id]=data
 Match.CARDS[id]=data.combat_data()
 return id
static func entries(data: CardData) -> Array[Dictionary]:
 var result: Array[Dictionary]=[]
 for item in data.get_meta("adventure_items",[]):
  var spec: Dictionary=DEFINITIONS[item]
  result.append({"name":spec.name,"description":spec.description,"runtime":true})
 return result
static func decorate(host: Control,data: CardData) -> void:
 var canvas: Control=host.get_node_or_null("CardCanvas")
 if canvas==null:canvas=host.get_node_or_null("Canvas")
 if canvas==null:canvas=host
 var old=canvas.get_node_or_null("AdventureItems")
 if old:canvas.remove_child(old);old.queue_free()
 var applied: Array=data.get_meta("adventure_items",[])
 if applied.is_empty():return
 var holder:=VBoxContainer.new();holder.name="AdventureItems"
 holder.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var compact: bool=canvas.name=="Canvas"
 holder.position=Vector2(168,72) if compact else Vector2(316,90)
 canvas.add_child(holder)
 for item in applied:
  var icon:=TextureRect.new();icon.texture=load(DEFINITIONS[item].icon)
  icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;icon.custom_minimum_size=Vector2(28,28) if compact else Vector2(34,34)
  icon.mouse_filter=Control.MOUSE_FILTER_IGNORE;holder.add_child(icon)
