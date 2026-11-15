@tool
class_name CardData
extends Resource

enum Faction { WARRIOR, MAGE, VILLAGER, LADINO, CLERIC, RUIN, WILD, NECROPOLIS, WASTES }
enum CreatureType { HUMAN, BEAST, ARTIFACT, MONSTER, UNDEAD, ELF, DWARF }
enum CardType { CREATURE, SPELL }
enum SpellEffect { NONE, FORTIFY, ARCANE, SHADOW_STEP, RESTORE, VIGOR, CONDUCTIVE, RECONSTRUCT, AREA_ARCANE, RUIN_ROAR, MAGIC_MISSILES, ROOTS, NATURE_REGEN, GRANT_PACK, DRAGON_POISON, DRAGON_ACID, CASTLE_TRAP, SEPULCHRAL_TIDE, SANDSTORM, WAR_PAINT }

enum DamageType { PHYSICAL, MAGIC, NECROTIC }
enum AuraEffect { NONE, ATTACK }
enum AuraTargets { ALLIED_VILLAGERS, ALLIES, ALLIED_BEASTS, ALLIED_WASTES }
enum EntryEffect { NONE, BUFF_ALLY, ARMOR_ALLY, SUMMON, POISON_ENEMY, BUFF_OTHER_ALLIES, SUMMON_AFTER_ENEMY_HUMAN_DEATH, BUFF_MONSTER_UNDEAD, POISON_ALL_ENEMIES, GRANT_ROGUE_CHOICE, HEAL_ALLIES, WHIP_ALLY, DAMAGE_ENEMY }

@export_range(0, 10) var cost: int = 1:
 set(value):
  cost = value
  emit_changed()

@export var attack: int = 1:
 set(value):
  attack = value
  emit_changed()

@export var health: int = 2:
 set(value):
  health = value
  emit_changed()

@export_multiline var ability_help_override: String = "":
 set(value):
  ability_help_override = value
  emit_changed()

@export var ability_name_override: String = "":
 set(value):
  ability_name_override = value
  emit_changed()

@export_multiline var ability_text: String = "Sem habilidades":
 set(value):
  ability_text = value
  emit_changed()

@export_range(0, 10) var antimagic: int = 0:
 set(value):
  antimagic=value
  emit_changed()

@export var armor: int = 0:
 set(value):
  armor = value
  emit_changed()

@export var artwork: Texture2D:
 set(value):
  artwork = value
  emit_changed()

@export var artwork_focus: Vector2 = Vector2(0.5, 0.5):
 set(value):
  artwork_focus = value.clamp(Vector2.ZERO, Vector2.ONE)
  emit_changed()

@export_range(1.0, 2.0, 0.01) var artwork_zoom: float = 1.0:
 set(value):
  artwork_zoom = clampf(value, 1.0, 2.0)
  emit_changed()

@export var aura_effect: AuraEffect = AuraEffect.NONE:
 set(value):
  aura_effect=value
  emit_changed()

@export var aura_includes_self: bool = true:
 set(value):
  aura_includes_self=value
  emit_changed()

@export var aura_targets: AuraTargets = AuraTargets.ALLIED_VILLAGERS:
 set(value):
  aura_targets=value
  emit_changed()

@export_range(0,10) var aura_value: int = 0:
 set(value):
  aura_value=value
  emit_changed()

@export_range(0,10) var bleed: int = 0:
 set(value):
  bleed=value
  emit_changed()

@export_range(0, 10) var block: int = 0:
 set(value):
  block = value
  emit_changed()

@export var card_type: CardType = CardType.CREATURE:
 set(value):
  card_type = value
  emit_changed()

@export_range(0,5) var carrion: int=0:
 set(value):
  carrion=value
  emit_changed()

@export var collectible: bool = true:
 set(value):
  collectible=value
  emit_changed()

@export var collective: bool=false:
 set(value):
  collective=value
  emit_changed()

@export_range(0, 10) var commerce: int = 0:
 set(value):
  commerce=value
  emit_changed()

@export var creature_type: CreatureType = CreatureType.HUMAN:
 set(value):
  creature_type=value
  emit_changed()

@export_range(0, 10) var devotion: int = 0:
 set(value):
  devotion=value
  emit_changed()

@export var dragon_breaths: bool=false

@export var end_random_attack: bool=false:
 set(value):
  end_random_attack=value
  emit_changed()

@export_range(0,10) var end_turn_attack: int = 0:
 set(value):
  end_turn_attack=value
  emit_changed()

@export_range(0,10) var entry_attack: int = 0:
 set(value):
  entry_attack = value
  emit_changed()

@export var entry_effect: EntryEffect = EntryEffect.NONE:
 set(value):
  entry_effect = value
  emit_changed()

@export_range(0,10) var entry_health: int = 0:
 set(value):
  entry_health = value
  emit_changed()

@export var entry_human_only: bool=false

@export_range(0,10) var entry_secondary: int = 0:
 set(value):
  entry_secondary=value
  emit_changed()

@export var entry_summon_key: String = "":
 set(value):
  entry_summon_key=value
  emit_changed()

@export_range(0,10) var entry_value: int = 0:
 set(value):
  entry_value=value
  emit_changed()

@export_range(0,10) var envenom: int = 0:
 set(value):
  envenom = value
  emit_changed()

@export var ephemeral: bool = false:
 set(value):
  ephemeral=value
  emit_changed()

@export var faction: Faction = Faction.VILLAGER:
 set(value):
  faction = value
  emit_changed()

@export var field_artwork_focus: Vector2 = Vector2(0.5,0.5):
 set(value):
  field_artwork_focus=value.clamp(Vector2.ZERO,Vector2.ONE)
  emit_changed()

@export var flying: bool = false:
 set(value):
  flying = value
  emit_changed()

@export_range(0, 10) var fury: int = 0:
 set(value):
  fury = value
  emit_changed()

@export_range(0, 10) var growth: int = 0:
 set(value):
  growth = value
  emit_changed()

@export_range(0, 10) var harvest: int = 0:
 set(value):
  harvest=value
  emit_changed()

@export_range(0, 10) var heal_amount: int = 0:
 set(value):
  heal_amount = value
  emit_changed()

@export_range(0, 10) var heal_cost: int = 1:
 set(value):
  heal_cost = value
  emit_changed()

@export var impulsive: bool=false:
 set(value):
  impulsive=value
  emit_changed()

@export var legendary: bool=false:
 set(value):
  legendary=value
  emit_changed()

@export_range(0,10) var loot: int = 0:
 set(value):
  loot=value
  emit_changed()

@export_multiline var lore: String = "":
 set(value):
  lore=value
  emit_changed()

@export_range(0, 10) var magic_cost: int = 1:
 set(value):
  magic_cost = value
  emit_changed()

@export_range(0, 10) var magic_damage: int = 0:
 set(value):
  magic_damage = value
  emit_changed()

@export_range(0,5) var magic_power: int = 0:
 set(value):
  magic_power = value
  emit_changed()

@export_range(0, 10) var magic_splash: int = 0:
 set(value):
  magic_splash=value
  emit_changed()

@export_range(0,10) var mount_attack: int=0:
 set(value):
  mount_attack=value
  emit_changed()

@export_range(0,10) var necrotic_damage: int=0:
 set(value):
  necrotic_damage=value
  emit_changed()

@export var neutral_deck_only: bool = false:
 set(value):
  neutral_deck_only=value
  emit_changed()

@export_range(0,10) var pack: int=0

@export var poison_immune: bool=false

@export_range(0, 10) var quick_heal_amount: int = 0:
 set(value):
  quick_heal_amount = value
  emit_changed()

@export_range(0, 10) var quick_heal_cost: int = 1:
 set(value):
  quick_heal_cost = value
  emit_changed()

@export var reach: bool=false

@export_range(0,10) var regeneration: int=0:
 set(value):
  regeneration=value
  emit_changed()

@export_range(0, 10) var resonance: int = 0:
 set(value):
  resonance=value
  emit_changed()

@export var root_power: bool=false

@export_range(0, 10) var rural_pride: int = 0:
 set(value):
  rural_pride=value
  emit_changed()

@export_range(0,5) var soul_harvest: int=0:
 set(value):
  soul_harvest=value
  emit_changed()

@export var spell_effect: SpellEffect = SpellEffect.NONE:
 set(value):
  spell_effect = value
  emit_changed()

@export var spell_immune: bool=false

@export_range(0,10) var spell_secondary: int = 0:
 set(value):
  spell_secondary = value
  emit_changed()

@export_range(0,10) var spell_value: int = 0:
 set(value):
  spell_value = value
  emit_changed()

@export_range(0,10) var spores: int=0:
 set(value):
  spores=value
  emit_changed()

@export var stealth: bool = false:
 set(value):
  stealth = value
  emit_changed()

@export var swift: bool = false:
 set(value):
  swift = value
  emit_changed()

@export var title: String = "Nova carta":
 set(value):
  title = value
  emit_changed()

@export var trample: bool=false

@export_range(0,10) var turn_castle_damage: int=0

@export_range(0,10) var turn_draw: int=0

@export var turn_summon_key: String="":
 set(value):
  turn_summon_key=value
  emit_changed()

@export var vigor: bool = false:
 set(value):
  vigor = value
  emit_changed()

@export var wall: bool = false:
 set(value):
  wall=value
  emit_changed()

@export var wide_entry_summary: bool=false

@export var wounded_entry: bool=false:
 set(value):
  wounded_entry=value
  emit_changed()

func copy_limit() -> int:
 return 1 if legendary else 2

func creature_type_name() -> String:
 if card_type==CardType.SPELL:return "Magia"
 return ["Humano","Fera","Artefato","Monstro","Morto-vivo","Elfo","Anão"][creature_type]

func has_creature_type(value: int) -> bool:
 return card_type==CardType.CREATURE and creature_type==value

func is_human() -> bool:
 return card_type==CardType.CREATURE and creature_type==CreatureType.HUMAN

func combat_data() -> Dictionary:
 return {"mount_attack":mount_attack,"stealth":stealth,"end_random_attack":end_random_attack,"ephemeral":ephemeral,"wounded_entry":wounded_entry,"end_turn_attack":end_turn_attack,"impulsive":impulsive,"necrotic_damage":necrotic_damage,"carrion":carrion,"soul_harvest":soul_harvest,"dragon_breaths":dragon_breaths,"reach":reach,"spell_immune":spell_immune,"poison_immune":poison_immune,"root_power":root_power,"trample":trample,"entry_human_only":entry_human_only,"turn_castle_damage":turn_castle_damage,"turn_draw":turn_draw,"turn_summon_key":turn_summon_key,"pack":pack,"name": title,"creature_type":creature_type,"legendary":legendary,"collective":collective, "faction":faction, "neutral_deck_only":neutral_deck_only, "cost": cost, "attack": attack, "health": health, "armor": armor, "antimagic":antimagic, "block": block, "fury": fury, "swift": swift, "flying": flying, "magic_damage": magic_damage,"magic_splash":magic_splash, "magic_cost": magic_cost, "growth": growth,"resonance":resonance,"rural_pride":rural_pride,"spores":spores,"regeneration":regeneration,"harvest":harvest,"commerce":commerce,"devotion":devotion, "heal_amount": heal_amount, "heal_cost": heal_cost, "quick_heal_amount":quick_heal_amount,"quick_heal_cost":quick_heal_cost, "card_type":card_type, "spell_effect":spell_effect, "spell_value":spell_value, "spell_secondary":spell_secondary, "magic_power":magic_power,"wall":wall,"vigor":vigor,"envenom":envenom,"loot":loot,"bleed":bleed,"entry_attack":entry_attack,"entry_health":entry_health,"entry_effect":entry_effect,"entry_value":entry_value,"entry_secondary":entry_secondary,"entry_summon_key":entry_summon_key,"aura_effect":aura_effect,"aura_value":aura_value,"aura_targets":aura_targets,"aura_includes_self":aura_includes_self}
func ability_entries(remaining_block: int = -1, magic_bonus: int = 0, remaining_armor: int = -1, granted_vigor: bool = false, poison_stacks: int = 0, received_aura_attack: int = 0, remaining_antimagic: int = -1) -> Array[Dictionary]:
 var entries: Array[Dictionary] = []
 if collective:
  entries.append({"name":"Multidão","icon":"collective-icon","badge":"Collective","value":attack,"description":"Ataque e vida base iguais ao número de aliados da Aldeia em campo, incluindo esta criatura. Herda as habilidades dos OUTROS ALIADOS DA ALDEIA, exceto Chamados. Valores compatíveis somam; habilidades únicas não acumulam. Atualiza enquanto as fontes estiverem em campo. Bônus permanentes e dano sofrido são preservados. Não copia outras Multidões nem raridade."})
 if card_type == CardType.SPELL:
  var entry := {"cost":cost,"spell":true,"name":"Magia","description":"Escolha um efeito de magia no campo Spell Effect do Inspector."}
  match spell_effect:
   SpellEffect.CASTLE_TRAP:
    entry.merge({"name":"Armadilha: %d de dano físico\nao 1º ou 2º atacante do castelo." % spell_value,"icon":"trap-icon","description":"Escolha secretamente o 1º ou o 2º próximo ataque de criatura ao seu castelo. Antes do golpe, a armadilha causa %d de dano físico ao atacante, reduzido por Armadura. Também conta Disparo Místico/Arcano. Se a criatura morrer, o golpe é cancelado. Permanece até disparar ou ser desarmada por um card; magias da mão e ataques a criaturas não contam." % spell_value},true)
   SpellEffect.GRANT_PACK:
    entry.merge({"name":"Todas as criaturas ganham\nMatilha 1.","icon":"pack-icon","description":"Todas as criaturas em campo recebem Matilha 1, inclusive inimigas; criaturas imunes a magias não são afetadas."},true)
   SpellEffect.ROOTS:
    entry.merge({"name":"Uma criatura inimiga não ataca\nno próximo turno.","icon":"growth-icon","description":"Uma criatura inimiga não pode atacar durante seu próximo turno."},true)
   SpellEffect.NATURE_REGEN:
    entry.merge({"name":"Dê Regeneração 2 a um aliado\npor 5 turnos.","icon":"regeneration-icon","description":"Uma criatura aliada recebe Regeneração 2 durante cinco fins de turno."},true)
   SpellEffect.MAGIC_MISSILES:
    entry.merge({"name":"Cause %d de dano mágico\na dois inimigos diferentes." % (spell_value+magic_bonus),"icon":"arcane-icon","description":"Escolha duas criaturas inimigas distintas ou uma criatura e o castelo inimigo. Cause %d de dano mágico a cada alvo. Ignora Armadura e Bloqueio; Amplificar aumenta cada míssil." % (spell_value+magic_bonus)},true)
   SpellEffect.WAR_PAINT:
    entry.merge({"name":"Um aliado ganha +%d de ataque\ne Impulsivo." % spell_value,"icon":"impulsive-icon","description":"Uma criatura aliada ganha +%d de ataque e Impulsivo permanentemente. Impulsivo faz a criatura atacar ao encerrar o turno se estiver apta. Não a deixa pronta nem concede ataque extra." % spell_value},true)
   SpellEffect.RUIN_ROAR:
    if spell_secondary>0:
     entry.merge({"name":"Seus Monstros ganham +%d de ataque\ne Impulsivo neste turno." % spell_value,"icon":"impulsive-icon","description":"Seus Monstros em campo recebem +%d de ataque e Impulsivo até o fim deste turno. Impulsivo força um ataque ao encerrar o turno, se a criatura estiver apta; não a deixa pronta nem concede ataque adicional." % spell_value},true)
    else:
     entry.merge({"name":"Seus Monstros ganham\n+%d de ataque neste turno." % spell_value,"icon":"fury-icon","description":"Todos os seus aliados do tipo Monstro que já estão em campo ganham +%d de ataque até o fim deste turno. Não afeta Humanos, Feras, Artefatos ou Mortos-vivos. Bônus acumulam e expiram juntos; não deixa criaturas prontas." % spell_value},true)
   SpellEffect.SANDSTORM:
    entry.merge({"name":"Cause %d de dano mágico a todos,\nexceto criaturas dos Ermos." % (spell_value+magic_bonus),"icon":"sandstorm-icon","description":"Cause %d de dano mágico aos dois castelos e a todas as criaturas, exceto as da facção Ermos, independentemente do lado. Ignora Armadura; Antimagia e imunidade a magia protegem. Amplificar aumenta o dano." % (spell_value+magic_bonus)},true)
   SpellEffect.SEPULCHRAL_TIDE:
    entry.merge({"name":"Cause %d de dano necrótico aos inimigos.\nCure %d de todos os Mortos-vivos." % [spell_value+magic_bonus,spell_value+magic_bonus],"icon":"necrotic-icon","description":"Aplica %d de dano necrótico a todas as criaturas inimigas e a todos os Mortos-vivos dos dois lados. Dano necrótico restaura a vida de Mortos-vivos até o máximo, ignora Artefatos e causa dano aos demais tipos, ignorando Armadura. Amplificar aumenta o valor; Antimagia protege contra o dano e imunidade a magia impede o efeito. Não atinge castelos. A restauração não remove Veneno/Sangramento nem ativa Devoção." % (spell_value+magic_bonus)},true)
   SpellEffect.AREA_ARCANE:
    entry.merge({"name":"Cause %d de dano mágico\na todas as criaturas inimigas." % (spell_value+magic_bonus),"icon":"arcane-icon","description":"Cause %d de dano mágico a todas as criaturas inimigas. Ignora Armadura, sem contra-ataque." % (spell_value+magic_bonus)},true)
   SpellEffect.RECONSTRUCT:
    entry.merge({"name":"Restaure %d de vida do castelo\nou de uma Muralha aliada." % spell_secondary,"icon":"rebuild-icon","description":"Restaure %d de vida do seu castelo ou de uma Muralha aliada. Reconstrução pode reparar Muralhas mesmo que não recebam cura comum." % spell_secondary},true)
   SpellEffect.VIGOR:
    entry.merge({"name":"Dê Vigor a um aliado.","icon":"vigor-icon","description":"Concede Vigor permanente a um aliado que ainda não tenha essa habilidade. Não acumula."},true)
   SpellEffect.CONDUCTIVE:
    entry.merge({"name":"Cause %d de dano mágico a uma\ncriatura; dobre se tiver Armadura." % (spell_value+magic_bonus),"icon":"lightning-icon","description":"Cause %d de dano mágico a uma criatura inimiga. Se ela tiver Armadura maior que zero, dobre o dano para %d. O bônus de Amplificar entra antes da multiplicação. Armadura não é subtraída do dano. Não atinge castelos e não há contra-ataque." % [spell_value+magic_bonus,(spell_value+magic_bonus)*2]},true)
   SpellEffect.FORTIFY:
    entry.merge({"name":"Dê a um aliado +%d de ataque,\n%d de Armadura e 1 Bloqueio." % [spell_value,spell_secondary],"icon":"fortify-icon","description":"Um aliado ganha +%d de ataque, %d de Armadura e 1 de Bloqueio permanentemente. Bloqueio recupera todas as cargas no início de cada turno." % [spell_value,spell_secondary]},true)
   SpellEffect.ARCANE:
    entry.merge({"name":"Cause %d de dano mágico\na uma criatura ou castelo inimigo." % (spell_value+magic_bonus),"icon":"arcane-icon","description":"Cause %d de dano mágico a uma criatura ou ao castelo inimigo. Ignora Armadura e Bloqueio, sem contra-ataque." % (spell_value+magic_bonus)},true)
   SpellEffect.SHADOW_STEP:
    entry.merge({"name":"Dê +%d de ataque, Voo e Disparada\na um aliado neste turno." % spell_value,"icon":"shadow-step-icon","description":"Um aliado ganha +%d de ataque, Voo e Disparada até o fim do turno. Disparada permite atacar no turno de invocação; não deixa pronta uma criatura que já atacou ou usou uma habilidade que esgota." % spell_value},true)
   SpellEffect.RESTORE:
    entry.merge({"name":"Cure %d de vida de um aliado\nou do seu castelo." % spell_value,"icon":"heal-icon","description":"Cure %d de vida de uma criatura aliada ou do seu castelo. Remove Veneno dos vivos. Em Mortos-vivos de qualquer lado, causa esse valor de dano mágico, ignorando Armadura, sem curar ou remover Veneno; Antimagia pode anular." % spell_value},true)
  if not ability_name_override.is_empty(): entry.name = ability_name_override
  if not ability_help_override.is_empty(): entry.description = ability_help_override
  entries.append(entry)
  if spell_effect==SpellEffect.RECONSTRUCT:
   entries.append({"name":"Só Aldeia em campo? Compre 1.","icon":"draw-icon","description":"Se todas as suas criaturas em campo forem da Aldeia, compre 1 carta. Campo vazio também ativa o efeito."})
  if neutral_deck_only:
   entries.append({"name":"Exige um deck só da Aldeia.","icon":"faction-small-villagers","description":"Seu deck original precisa conter apenas cartas da Aldeia. A restrição vale na montagem e na conjuração, mesmo depois que as cartas forem compradas ou saírem do campo."})
  if legendary:entries.append({"name":"Lendária","description":"Você pode usar apenas uma cópia desta carta no deck.","runtime":true})
  return entries
 if aura_effect!=AuraEffect.NONE:
  var group: String="todos os seus aliados dos Ermos em campo" if aura_targets==AuraTargets.ALLIED_WASTES else ("todas as suas Feras em campo" if aura_targets==AuraTargets.ALLIED_BEASTS else ("todos os seus aliados da Aldeia em campo" if aura_targets==AuraTargets.ALLIED_VILLAGERS else "todos os seus aliados em campo"))
  var self_note: String="" if aura_targets==AuraTargets.ALLIED_BEASTS and creature_type!=CreatureType.BEAST else (" Inclui esta criatura." if aura_includes_self else " Não inclui esta criatura.")
  entries.append({"name":"Aura","icon":"aura-icon","badge":"Aura","value":aura_value,"summary":aura_summary(),"description":"Enquanto estiver em campo, %s recebem +%d de ataque.%s Acumula com outras Auras; termina quando a fonte sai do campo." % [group,aura_value,self_note]})
 if entry_effect!=EntryEffect.NONE:
  var details: String="Ao jogar esta criatura da mão:"
  if entry_effect==EntryEffect.BUFF_ALLY:
   details+="\nConcede %s permanentemente a %s." % [entry_bonus_description(),"outro Humano aliado" if entry_human_only else "outro aliado"]
  elif entry_effect==EntryEffect.GRANT_ROGUE_CHOICE:
   details+="\nEscolha: outro aliado ganha Punga %d ou Envenenar %d permanentemente." % [entry_value,entry_secondary]
  elif entry_effect==EntryEffect.ARMOR_ALLY:
   details+="\nOutro aliado ganha +%d de Armadura permanente." % entry_value
  elif entry_effect==EntryEffect.BUFF_MONSTER_UNDEAD:
   details+="\nOutro aliado Monstro ou Morto-vivo ganha %s permanentemente." % entry_bonus_description()
  elif entry_effect==EntryEffect.SUMMON_AFTER_ENEMY_HUMAN_DEATH:
   details+="\nSe um Humano inimigo morreu nesta partida, invoca um Carniçal 2/2 Morto-vivo, se houver espaço."
  elif entry_effect==EntryEffect.SUMMON:
   var summon_path: String="res://cards/%s.tres" % entry_summon_key
   var companion: CardData=load(summon_path) if ResourceLoader.exists(summon_path) else null
   var summon_name: String="%s %d/%d" % [companion.title,companion.attack,companion.health] if companion!=null else "um aliado"
   if companion!=null and companion.block>0:summon_name+=" com Bloqueio %d" % companion.block
   details+="\nInvoca %s se houver espaço. Ele entra esgotado, salvo se tiver Disparada." % summon_name
  elif entry_effect==EntryEffect.POISON_ALL_ENEMIES:
   details+="\nAplica Veneno %d a todas as criaturas inimigas, exceto as imunes." % entry_value
  elif entry_effect==EntryEffect.POISON_ENEMY:
   details+="\nAplica Veneno %d a uma criatura inimiga." % entry_value
  elif entry_effect==EntryEffect.DAMAGE_ENEMY:
   details+="\nCausa %d de dano físico a uma criatura inimiga. Armadura reduz o dano. Sem criaturas inimigas, não faz efeito." % entry_value
  elif entry_effect==EntryEffect.WHIP_ALLY:
   details+="\nOutro aliado ganha +%d de ataque permanentemente e recebe %d de dano físico, reduzido por Armadura. Sem outros aliados, não faz efeito." % [entry_attack,entry_value]
  elif entry_effect==EntryEffect.HEAL_ALLIES:
   details+="\nCura %d de vida de todas as criaturas aliadas, incluindo esta. Remove Veneno e Sangramento; em Mortos-vivos, causa dano mágico. Muralhas não recebem Cura." % entry_value
  elif entry_effect==EntryEffect.BUFF_OTHER_ALLIES:
   details+="\nTodos os outros aliados ganham %s permanentemente." % entry_bonus_description()
  entries.append({"name":"Chamado","icon":"entry-icon","badge":"Entry","summary":entry_summary(),"description":details})
 if ephemeral:
  entries.append({"name":"Efêmero","icon":"ephemeral-icon","badge":"Ephemeral","description":"Após atacar ou defender de um ataque físico, esta criatura é destruída. Disparo Arcano, outras habilidades e magias não contam como ataque ou defesa."})
 if wounded_entry:
  entries.append({"name":"Ferido","icon":"wounded-entry-icon","badge":"WoundedEntry","description":"Sempre é invocado com apenas 1 de vida atual, mantendo sua vida máxima. Não conta como dano. Pode recuperar vida normalmente depois de entrar em campo."})
 if wall:
  entries.append({"name":"Muralha","icon":"wall-icon","badge":"Wall","description":"Imune a Veneno. Não pode receber cura comum nem declarar ataques. Reconstrução pode repará-la."})
 if end_turn_attack>0:
  entries.append({"name":"Forjar %d" % end_turn_attack,"badge":"Forge","value":end_turn_attack,"icon":"forge-icon","description":"No fim do seu turno, outro aliado aleatório ganha +%d de ataque permanentemente. Sem outro aliado, não faz efeito." % end_turn_attack})
 if end_random_attack:
  entries.append({"name":"Predador dos Ermos","badge":"RandomHunt","icon":"random-hunt-icon","description":"Não pode atacar normalmente. No fim do seu turno, ataca uma criatura aleatória, aliada ou inimiga, que não seja dos Ermos, mesmo se estiver esgotado ou tiver acabado de entrar. Ignora Bloqueio, mas respeita impedimentos de ataque; sem alvo válido, não ataca."})
 if impulsive:
  entries.append({"name":"Impulsivo","badge":"Impulsive","icon":"impulsive-icon","description":"Ao encerrar seu turno, se estiver apto e ainda não tiver atacado, ataca automaticamente como no comando Atacar com todos. Respeita Bloqueio e impedimentos de ataque. Não concede ataques extras nem deixa a criatura pronta."})
 if vigor or granted_vigor:
  entries.append({"name":"Vigor","badge":"Vigor","icon":"vigor-icon","description":"No ataque e defesa, usa o maior valor entre ataque e vida atual. Vale contra castelos, sem alterar o ataque exibido."})
 if carrion>0:
  entries.append({"name":"Carniceiro %d" % carrion,"badge":"Carrion","value":carrion,"icon":"carrion-icon","description":"Quando outra criatura morre, aliada ou inimiga, recupera %d de vida até sua vida máxima. Não é Cura: funciona em Mortos-vivos e não remove Veneno ou Sangramento. Não revive uma criatura morta." % carrion})
 if mount_attack>0:
  entries.append({"name":"Montaria %d" % mount_attack,"badge":"Mount","value":mount_attack,"icon":"mount-icon","description":"Enquanto houver pelo menos um aliado vivo imediatamente ao lado, recebe +%d de ataque. Ter aliados nos dois lados não duplica o bônus." % mount_attack})
 if soul_harvest>0:
  entries.append({"name":"Colher Almas %d" % soul_harvest,"badge":"SoulHarvest","value":soul_harvest,"icon":"soul-harvest-icon","description":"Quando outro aliado morre, esta criatura ganha +%d de ataque e +%d de vida permanentemente." % [soul_harvest,soul_harvest]})
 if magic_power > 0:
  entries.append({"name":"Amplificar %d" % magic_power,"badge":"Amplify","value":magic_power,"icon":"amplify-icon","description":"Enquanto esta criatura estiver em campo, as magias e habilidades de dano mágico ou necrótico aliadas causam +%d de dano. Soma com outras fontes de Amplificar. O bônus acaba quando ela sai do campo." % magic_power})
 var effective_armor := armor if remaining_armor<0 else remaining_armor
 if effective_armor > 0:
  entries.append({"name": "Armadura %d" % effective_armor, "icon":"armor-icon", "badge_icon":"armor-icon","badge":"Armor","value":effective_armor, "description": "Reduz cada dano físico recebido em %d, inclusive de contra-ataques. Não é consumida e não reduz dano mágico." % effective_armor})
 if block > 0:
  var charges := block if remaining_block < 0 else remaining_block
  entries.append({"name": "Bloqueio %d" % charges, "icon":"block-icon", "badge_icon":"block-icon","badge":"Block","value":charges, "description": "Com cargas, deve ser alvo dos ataques físicos. Cada ataque recebido gasta 1 carga. Recupera todas as cargas no início de cada turno, até %d. Voo e magia ignoram; contra-ataques não gastam cargas." % block})
 if antimagic > 0:
  var charges: int=antimagic if remaining_antimagic<0 else remaining_antimagic
  entries.append({"name":"Antimagia %d" % charges,"badge":"Antimagic","value":charges,"icon":"antimagic-icon","description":"Anula uma magia ofensiva ou uma ocorrência de dano mágico ou necrótico recebido por carga. Recupera 1 no início do seu turno, até %d. Não protege de ataques físicos nem Veneno." % antimagic})
 if stealth:
  entries.append({"name":"Furtivo","badge":"Stealth","icon":"stealth-icon","description":"Não pode ser atacada nem escolhida como alvo de magias ou habilidades, inclusive aliadas. Efeitos sem alvo ainda a afetam. Perde Furtivo pelo resto da partida ao atacar."})
 if fury > 0:
  entries.append({"name": "Fúria %d" % fury,"badge":"Fury","value":fury, "cost": 1, "icon": "fury-icon", "description": "Uma vez por turno, pague 1 mana: ganhe +%d de ataque permanente, sem esgotar." % fury})
 if swift:
  entries.append({"name": "Disparada","icon":"swift-icon","badge":"Swift", "description": "Entra pronta e pode atacar no mesmo turno em que é invocada."})
 if trample:
  entries.append({"name":"Atropelar","badge":"Trample","icon":"trample-icon","description":"Ao atacar uma criatura, o dano físico que exceder sua vida, após Armadura e Voo, atinge o castelo inimigo. Não se aplica ao contra-ataque."})
 if turn_castle_damage>0:entries.append({"name":"Escavação %d" % turn_castle_damage,"badge":"Mining","value":turn_castle_damage,"icon":"mining-icon","description":"No início do seu turno, causa %d de dano físico a cada castelo. Armadura reduz o dano. Cada criatura com Escavação ativa separadamente." % turn_castle_damage})
 if turn_draw>0:entries.append({"name":"Compre %d no início do turno" % turn_draw,"badge":"TurnDraw","value":turn_draw,"icon":"draw-icon","description":"No início do seu turno, compre %d carta(s)." % turn_draw})
 if not turn_summon_key.is_empty():
  var summon_path: String="res://cards/%s.tres" % turn_summon_key
  var companion: CardData=load(summon_path) if ResourceLoader.exists(summon_path) else null
  var summon_name: String="%s %d/%d" % [companion.title,companion.attack,companion.health] if companion!=null else "um aliado"
  entries.append({"name":"Reanimar: "+summon_name,"badge":"TurnSummon","value":1,"icon":"reanimate-icon","description":"No início do seu turno, invoca %s se houver espaço no campo. A criatura entra esgotada, salvo se tiver Disparada. Não gasta mana nem cartas da mão." % summon_name})
 if pack>0:entries.append({"name":"Matilha %d" % pack,"badge":"Pack","value":pack,"icon":"pack-icon","description":"Quando outra Fera aliada entra em campo, ganha +%d de ataque até o fim do turno. Valores acumulam." % pack})
 if reach:entries.append({"name":"Alcance","badge":"Reach","icon":"reach-icon","description":"Voadoras devem atacar um defensor com Alcance. Recebe +1 de ataque contra Voo e ignora a redução de dano de Voo ao atacar."})
 if spell_immune:entries.append({"name":"Imune a magia","badge":"MagicImmunity","icon":"antimagic-icon","description":"Imune a magias, inclusive aliadas, e a dano mágico ou necrótico."})
 if poison_immune:entries.append({"name":"Imune a veneno","badge":"PoisonImmunity","icon":"poison-icon","description":"Não pode receber Veneno."})
 if root_power:entries.append({"name":"Raízes Enredantes","badge":"Roots","icon":"growth-icon","cost":1,"tap":true,"description":"Pague 1 mana e esgote: uma criatura inimiga não pode atacar no próximo turno."})
 if necrotic_damage>0:
  entries.append({"name":"Disparo Necrótico %d" % (necrotic_damage+magic_bonus),"badge":"Necrotic","value":necrotic_damage+magic_bonus,"cost":magic_cost,"tap":true,"icon":"necrotic-icon","description":"Pague %d mana e esgote: aplica %d de dano necrótico a uma criatura inimiga, ao castelo inimigo ou a um Morto-vivo aliado. Cura Mortos-vivos dos dois lados até a vida máxima, ignora Artefatos e causa dano aos demais tipos, ignorando Armadura e sem contra-ataque. Amplificar aumenta o valor. Antimagia protege contra o dano." % [magic_cost,necrotic_damage+magic_bonus]})
 if flying:
  entries.append({"name": "Voo","icon":"flying-icon","badge":"Flying", "description": "Ao defender, recebe 1 de dano físico a menos de ataques, exceto de criaturas com Alcance. Contra-ataques e dano mágico não são reduzidos. Seus ataques ignoram Bloqueio; ao atacar um bloqueador, consome uma carga."})
 if magic_damage > 0 and magic_splash>0:
  entries.append({"name":"Mãos Flamejantes %d" % (magic_damage+magic_bonus),"badge":"Arcane","value":magic_damage+magic_bonus,"cost":magic_cost,"tap":true,"icon":"flame-icon","description":"Pague %d mana e esgote: cause %d de dano mágico ao alvo inimigo e %d a cada criatura adjacente a ele. Não atinge castelos. Ignora Armadura e Bloqueio, sem contra-ataque. Amplificar aumenta cada parcela." % [magic_cost,magic_damage+magic_bonus,magic_splash+magic_bonus]})
 elif magic_damage > 0:
  entries.append({"name": "Disparo Arcano %d" % (magic_damage+magic_bonus),"badge":"Arcane","value":magic_damage+magic_bonus, "cost": magic_cost, "tap": true, "icon": "arcane-icon", "description": "Pague %d mana e esgote: cause %d de dano mágico a uma criatura ou ao castelo inimigo. Ignora Armadura e Bloqueio, sem contra-ataque." % [magic_cost, magic_damage+magic_bonus]})
 if spores>0:
  entries.append({"name":"Esporos %d" % spores,"icon":"spores-icon","badge":"Spores","value":spores,"description":"No início do seu turno, todos os OUTROS Monstros e Feras aliados em campo ganham +%d de vida atual e máxima. Não afeta a própria fonte. Cada criatura recebe o bônus uma vez por fonte. Acumula; não é Cura nem Cultivo." % spores})
 if regeneration>0:
  entries.append({"name":"Regeneração %d" % regeneration,"icon":"regeneration-icon","badge":"Regeneration","value":regeneration,"description":"No fim do seu turno, após o Veneno, recupera %d de vida até a vida máxima. Não é Cura: não ativa Devoção nem remove Veneno ou Sangramento." % regeneration})
 if resonance > 0:
  entries.append({"name":"Ressonância %d" % resonance,"icon":"resonance-icon","badge":"Resonance","value":resonance,"description":"Sempre que você conjurar uma magia ou usar uma habilidade de dano mágico ou necrótico, ganha +%d/+%d até o início do seu próximo turno. Os bônus acumulam e expiram juntos, preservando no mínimo 1 de vida atual. Ativa uma vez por ação, inclusive se o dano for anulado." % [resonance,resonance]})
 if rural_pride > 0:
  entries.append({"name":"Brio %d" % rural_pride,"icon":"pride-icon","badge":"Pride","value":rural_pride,"description":"No início do seu turno, se todas as suas criaturas em campo forem da Aldeia, ganha +%d de ataque permanente." % rural_pride})
 if growth > 0:
  entries.append({"name": "Cultivo %d" % growth,"icon":"growth-icon","badge":"Growth","value":growth, "description": "No início do seu turno, ganha +%d de vida atual e máxima." % growth})
 if devotion > 0:
  entries.append({"name":"Devoção %d" % devotion,"icon":"devotion-icon","badge":"Devotion","value":devotion,"description":"Quando sua Cura recuperar vida de um aliado ou causar dano a um Morto-vivo, ganha +%d/+%d permanentemente. Também vale para seu castelo. Ativa uma vez por alvo afetado; sem recuperar vida ou causar dano, não ativa." % [devotion,devotion]})
 if harvest > 0:
  entries.append({"name":"Colheita %d" % harvest,"icon":"harvest-icon","badge":"Harvest","value":harvest,"description":"Sempre que o Cultivo de um aliado for ativado, ganha +%d/+%d permanentemente. Conta uma vez por ativação, independentemente do valor de Cultivo. Inclui seu próprio Cultivo, se receber essa habilidade." % [harvest,harvest]})
 if commerce > 0:
  entries.append({"name":"Comércio %d" % commerce,"icon":"commerce-icon","badge":"Commerce","value":commerce,"description":"Sempre que o Cultivo de um aliado for ativado, receba +%d mana temporária neste turno. Conta uma vez por ativação de Cultivo; a mana temporária é gasta antes da mana normal e desaparece ao fim do turno." % commerce})
 if heal_amount > 0:
  entries.append({"name": "Cura %d" % heal_amount,"badge":"Heal","value":heal_amount, "cost": heal_cost, "tap": true, "icon": "heal-icon", "description": "Pague %d mana e esgote: cure %d de vida de um aliado ou do seu castelo. Remove Veneno dos vivos. Em Mortos-vivos de qualquer lado, causa esse valor de dano mágico, ignorando Armadura, sem curar ou remover Veneno; Antimagia pode anular." % [heal_cost, heal_amount]})
 if quick_heal_amount>0:
  entries.append({"name":"Cura Célere %d" % quick_heal_amount,"badge":"QuickHeal","value":quick_heal_amount,"cost":quick_heal_cost,"icon":"heal-icon","description":"Uma vez por turno, pague %d mana para curar %d de vida de uma criatura, sem esgotar. Remove Veneno e Sangramento de aliados vivos; causa dano mágico a Mortos-vivos de qualquer lado. Não atinge castelos." % [quick_heal_cost,quick_heal_amount]})
 if loot > 0:
  entries.append({"name":"Punga %d" % loot,"badge":"Loot","value":loot,"icon":"draw-icon","description":"Ao atacar o castelo inimigo, compre %d carta(s)." % loot})
 if dragon_breaths:
  entries.append({"name":"Sopro Venenoso 2","cost":3,"tap":true,"icon":"poison-icon","description":"Pague 3 mana e esgote: aplique Veneno 2 a até três criaturas inimigas consecutivas. Exige estar pronto e não ter atacado neste turno. Não permite atacar depois do sopro."})
  entries.append({"name":"Sopro Ácido 3","cost":4,"tap":true,"icon":"arcane-icon","description":"Pague 4 mana e esgote: cause 3 de dano mágico a até três criaturas inimigas consecutivas, ou 6 ao castelo. Exige estar pronto e não ter atacado neste turno. Não permite atacar depois do sopro."})
 if envenom > 0:
  entries.append({"name":"Envenenar %d" % envenom,"badge":"Envenom","value":envenom,"icon":"envenom-icon","description":"Ataques e contra-ataques físicos aplicam %d de Veneno a criaturas, mesmo se Armadura absorver o dano. No fim do turno do alvo, causa dano ignorando Armadura e termina. Magia não aplica Veneno." % envenom})
 if bleed > 0:
  entries.append({"name":"Sangrar %d" % bleed,"badge":"Bleed","value":bleed,"icon":"bleed-icon","description":"Ao atacar ou contra-atacar, aplica %d de Sangramento à criatura adversária. Acumula. Após cada ação da criatura, ela perde essa quantidade de vida, ignorando Armadura. Dura até o fim do turno do dono; Cura remove. Muralhas são imunes." % bleed})
 if received_aura_attack>0:
  entries.append({"name":"Bônus de Aura","icon":"aura-icon","badge":"AuraBonus","value":"+%d" % received_aura_attack,"runtime":true,"description":"Recebe +%d de ataque de Auras aliadas. Esse bônus é temporário e desaparece quando as fontes correspondentes saem do campo." % received_aura_attack})
 if poison_stacks > 0:
  entries.append({"name":"Envenenado %d" % poison_stacks,"badge":"Poison","value":poison_stacks,"icon":"poison-icon","runtime":true,"description":"No fim do seu turno, perde %d de vida ignorando Armadura. Depois o Veneno termina. Curar seres vivos remove todo o Veneno; em Mortos-vivos, Cura causa dano e mantém o Veneno." % poison_stacks})
 if entries.is_empty() and not ability_text.is_empty():
  entries.append({"name": "Habilidade", "description": ability_text})
 if not entries.is_empty():
  if not ability_name_override.is_empty():
   entries[0].name = ability_name_override
  if not ability_help_override.is_empty():
   entries[0].description = ability_help_override
 if legendary:entries.append({"name":"Lendária","description":"Você pode usar apenas uma cópia desta carta no deck.","runtime":true})
 return entries

func entry_bonus_description() -> String:
 var bonuses: PackedStringArray=[]
 if entry_attack!=0:bonuses.append("+%d de ataque" % entry_attack)
 if entry_health!=0:bonuses.append("+%d de vida" % entry_health)
 return " e ".join(bonuses)

func entry_needs_target() -> bool:
 return entry_effect in [EntryEffect.BUFF_ALLY,EntryEffect.ARMOR_ALLY,EntryEffect.POISON_ENEMY,EntryEffect.BUFF_MONSTER_UNDEAD,EntryEffect.GRANT_ROGUE_CHOICE,EntryEffect.WHIP_ALLY,EntryEffect.DAMAGE_ENEMY]

func entry_summary() -> String:
 match entry_effect:
  EntryEffect.BUFF_ALLY:
   var target: String="aliado humano" if entry_human_only else "aliado"
   if entry_attack==0:return "+%d vida %s" % [entry_health,target]
   if entry_health==0:return "+%d ataque %s" % [entry_attack,target]
   return "+%d/+%d %s" % [entry_attack,entry_health,target]
  EntryEffect.DAMAGE_ENEMY:return "%d dano físico a um inimigo" % entry_value
  EntryEffect.WHIP_ALLY:return "+%d ataque e %d dano a outro aliado" % [entry_attack,entry_value]
  EntryEffect.HEAL_ALLIES:return "Cure %d de todos os aliados" % entry_value
  EntryEffect.BUFF_OTHER_ALLIES:return "+%d vida outros aliados" % entry_health if entry_attack==0 else "+%d/+%d outros aliados" % [entry_attack,entry_health]
  EntryEffect.GRANT_ROGUE_CHOICE:return "Aliado ganha Punga %d ou Envenenar %d" % [entry_value,entry_secondary]
  EntryEffect.ARMOR_ALLY:return "+%d armadura aliado" % entry_value
  EntryEffect.BUFF_MONSTER_UNDEAD:return "+%d/+%d aliado monstro ou morto-vivo" % [entry_attack,entry_health]
  EntryEffect.SUMMON:
   var summon_path: String="res://cards/%s.tres" % entry_summon_key
   var companion: CardData=load(summon_path) if ResourceLoader.exists(summon_path) else null
   if companion==null:return "invoca um aliado"
   return "invoca %s %d/%d%s" % [companion.title,companion.attack,companion.health," com Bloqueio %d" % companion.block if companion.block>0 else ""]
  EntryEffect.SUMMON_AFTER_ENEMY_HUMAN_DEATH:return "Carniçal 2/2 se morreu humano inimigo"
  EntryEffect.POISON_ENEMY:return "Veneno %d inimigo" % entry_value
  EntryEffect.POISON_ALL_ENEMIES:return "Veneno %d todos os inimigos" % entry_value
 return ""

func entry_prompt() -> String:
 if entry_effect==EntryEffect.BUFF_ALLY and entry_human_only:
  return "Chamado: escolha outro Humano aliado para receber +%d/+%d." % [entry_attack,entry_health]
 if entry_effect==EntryEffect.WHIP_ALLY:
  return "Chamado: escolha outro aliado para ganhar +%d de ataque e receber %d de dano físico." % [entry_attack,entry_value]
 if entry_effect==EntryEffect.GRANT_ROGUE_CHOICE:
  return "Chamado: escolha outro aliado; depois escolha Punga %d ou Envenenar %d." % [entry_value,entry_secondary]
 if entry_effect==EntryEffect.DAMAGE_ENEMY:
  return "Chamado: escolha uma criatura inimiga para sofrer %d de dano físico." % entry_value
 if entry_effect==EntryEffect.POISON_ENEMY:
  return "Chamado: escolha uma criatura inimiga para aplicar %s." % entry_summary()
 return "Chamado: escolha outro aliado para receber %s antes de invocar." % entry_summary()

func aura_summary() -> String:
 if aura_effect==AuraEffect.ATTACK and aura_targets==AuraTargets.ALLIED_WASTES:return "%s: ataque +%d" % ["Ermos" if aura_includes_self else "Outros Ermos",aura_value]
 match aura_effect:
  AuraEffect.ATTACK:return "%s: ataque +%d" % [("Outras Feras" if creature_type==CreatureType.BEAST and not aura_includes_self else "Feras") if aura_targets==AuraTargets.ALLIED_BEASTS else ("Aldeia" if aura_targets==AuraTargets.ALLIED_VILLAGERS else ("Aliados" if aura_includes_self else "Outros aliados")),aura_value]
 return ""





