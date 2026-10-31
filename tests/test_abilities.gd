extends SceneTree
const Match = preload("res://scripts/match.gd")

func creature(key: String) -> Dictionary:
 var unit: Dictionary = Match.CARDS[key].duplicate(true)
 unit.merge({"key": key, "ready": true, "id": 0})
 return unit

func _init() -> void:
 var m = Match.new()
 m.players[0].mana = 5
 m.players[0].board = [creature("wolf"), creature("mage"), creature("wolf")]
 m.players[1].board = [creature("squire"), creature("wolf")]
 assert(m.players[0].board[1].attack == 0)
 assert(not m.act(0, 1, -1), "Maga não ataca fisicamente")
 assert(not m.act(0, 0, -1), "Bloqueio protege o castelo")
 assert(not m.act(0, 0, 1), "Bloqueio protege outras criaturas")
 assert(m.players[0].board[0].ready and m.players[0].mana == 5)
 assert(m.act(0, 1, 1, true), "Magia pode ignorar Escudeiro")
 assert(m.players[1].board[0].block == 1)
 assert(m.players[0].board[1].health == 2)
 m.players[1].board[0].armor = 10
 assert(m.act(0, 0, 0), "Primeiro ataque atinge Escudeiro")
 assert(m.players[1].board[0].block == 0)
 assert(m.players[1].board[0].health == 2, "Mesmo ataque absorvido consome Bloqueio")
 assert(m.act(0, 2, -1), "Depois da carga consumida o castelo fica livre")
 assert(m.players[1].hp == 18)
 m.end_turn(0)
 m.end_turn(1)
 assert(m.players[1].board[0].block == 1, "Bloqueio renova no início do turno do dono")
 m.players[1].board[0].block = 0
 assert(m.end_turn(0))
 assert(m.players[1].board[0].block == 1)
 assert(m.end_turn(1))
 assert(m.players[1].board[0].block == 1, "Renovação não acumula cargas")
 m.players[0].board = [creature("wolf")]
 m.players[0].mana = 1
 assert(m.fury(0, 0))
 assert(m.players[0].board[0].attack == 3)
 assert(m.players[0].mana == 0 and m.players[0].board[0].ready, "Fúria não esgota")
 assert(not m.fury(0, 0), "Sem mana não pode ativar novamente")
 assert(m.players[1].hp == 18, "Fúria não causa dano")
 m.end_turn(0)
 m.end_turn(1)
 assert(m.players[0].board[0].attack == 3)
 assert(m.fury(0, 0))
 assert(m.players[0].board[0].attack == 4, "Bônus acumula")
 m.players[0].board[0].ready = true
 m.players[0].mana = 0
 assert(not m.fury(0, 0) and m.players[0].board[0].ready)
 m.players[0].board[0].ready = false
 m.players[0].mana = 2
 assert(m.fury(0, 0), "Pode ativar uma vez no turno")
 assert(not m.fury(0, 0), "Fúria não pode repetir no mesmo turno")
 m.end_turn(0)
 m.end_turn(1)
 m.players[0].mana = 2
 assert(m.fury(0, 0), "Fúria recarrega no próximo turno")
 assert(not m.players[0].board[0].ready and m.players[0].board[0].attack == 6, "Fúria não muda esgotamento existente")
 m.players[0].board[0].ready = true
 m.players[1].board = [creature("squire"), creature("squire"), creature("wolf")]
 m.players[0].board[0].health = 10
 assert(m.act(0, 0, 1), "Pode escolher qualquer Escudeiro ativo")
 m.players[0].board[0].ready = true
 assert(not m.act(0, 0, -1), "Outro Escudeiro continua bloqueando")
 assert(m.act(0, 0, 0))
 m.players[0].board[0].ready = true
 assert(m.can_target(0, 0, -1))
 m.players[0].board = [creature("squire")]
 m.players[1].board = [creature("wolf")]
 assert(m.act(0, 0, 0))
 # Escudeiro is killed by the counter; a survivor keeps its block charge.
 m.players[0].board = [creature("squire")]
 m.players[0].board[0].health = 10
 m.players[1].board = [creature("wolf")]
 assert(m.act(0, 0, 0))
 assert(m.players[0].board[0].block == 1, "Contra-ataque não consome Bloqueio")
 # Bloqueio 2 starts with two charges but only recovers one per owner turn.
 var squire_data = Match.CARD_DATA.squire
 var original_block: int = squire_data.block
 squire_data.block = 2
 var recovery = Match.new()
 recovery.players[0].board = [creature("squire")]
 recovery.players[0].board[0].block = 2
 recovery.players[0].board[0].health = 20
 recovery.players[1].board = [creature("wolf"), creature("wolf"), creature("wolf")]
 recovery.end_turn(0)
 assert(not recovery.act(1, 0, -1))
 assert(recovery.act(1, 0, 0))
 assert(recovery.players[0].board[0].block == 1)
 assert(not recovery.act(1, 1, -1), "Segunda carga ainda exige ser alvo")
 assert(recovery.act(1, 1, 0))
 assert(recovery.players[0].board[0].block == 0)
 assert(recovery.act(1, 2, -1), "Terceiro ataque pode ser direto")
 recovery.end_turn(1)
 assert(recovery.players[0].board[0].block == 1, "Bloqueio 2 recupera só 1 carga")
 recovery.end_turn(0)
 assert(recovery.players[0].board[0].block == 1, "Só recupera no turno do dono")
 recovery.end_turn(1)
 assert(recovery.players[0].board[0].block == 2)
 recovery.end_turn(0)
 recovery.end_turn(1)
 assert(recovery.players[0].board[0].block == 2, "Não excede o máximo")
 squire_data.block = original_block
 print("OK: Maga 0 ATQ, Bloqueio obrigatório/carga única/magia/múltiplos e Fúria custo/esgotamento/bônus permanente.")
 quit()
