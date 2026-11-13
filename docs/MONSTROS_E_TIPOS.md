# Tipos de criaturas e facção Horda

Tipo e facção/facção são campos independentes e editáveis no Inspector de cada recurso CardData. Toda criatura recebeu um tipo: Humano, Fera, Artefato, Monstro ou Morto-vivo. Magias continuam sem tipo de criatura na interface. O tipo aparece discretamente na base da carta completa e pode ser pesquisado ou filtrado na coleção.

A facção Horda usa borda cobre e símbolo de cabeça com chifres. Seus decks permitem somente cartas da própria facção: **nenhum Aldeão é permitido**, incluindo Feras e magias. Cada criatura possui apenas um tipo; a composição dos decks depende da facção. A Aldeia complementa Vanguarda, Arcano, Submundo, Luminares e Selvagem. Veja [Aldeia e Necrópole](ALDEOES_E_NECROPOLE.md) para composição e migração atuais.

| Carta | Facção | Tipo | Mana | Ataque/vida | Habilidade |
| --- | --- | --- | --- | --- | --- |
| Goblin Saqueador | Horda | Monstro | 1 | 1/1 | Disparada |
| Minotauro da Ruína | Horda | Monstro | 5 | 5/5 | Bloqueio 1, Atropelar |
| Lobisomem das Brumas | Horda | Monstro | 4 | 3/4 | Fúria 1, ativação por 1 mana sem esgotar |
| Zumbi Serviçal | Horda | Morto-vivo | 2 | 2/1 | Chamado: +1/+1 permanente a outro Monstro ou Morto-vivo aliado |

O Lobisomem corresponde à silhueta lupina da arte de Bola de Fogo. Os três membros da nova facção são do tipo Monstro, conforme solicitado, mesmo quando têm aparência animal ou humanoide. O Zumbi é Morto-vivo, portanto não conta como Humano.

Classificação dos aldeões existentes: Falcão Mensageiro e Boi da Colheita são Feras; Muralha da Aldeia é Artefato; os camponeses, escudeiros, vigias, arauto, peregrino e Levante da Aldeia são Humanos. O Familiar Rúnico é Fera de Arcano; Lobo da Noite é Fera dos Ermos. O Corvo das Brumas é Fera de Submundo. As demais criaturas anteriores são Humanas.

Horda dos Ermos tem 22 cartas: duas cópias de Goblin Saqueador, Minotauro da Ruína, Lobisomem das Brumas, Troll do Brejo, Lobo dos Ermos, Necromante do Véu, Fungo da Ninhada, Clamor da Horda, Zumbi Serviçal, Kobold dos Escorpiões e Uivo de Guerra. O carregamento migra Lobo da Noite e Reconstrução da Vila para as alternativas próprias da Horda, preservando espaços, nomes e seleção ativa.

Validação: `tests/test_monsters_and_types.gd` cobre tipos, composição em ambas as ordens de adição, limites, persistência da nova facção, filtros, pesquisa e funcionamento das habilidades. Artes geradas com a ferramenta integrada imagegen; prompts completos em `art-prompts/monsters-and-zombie.md`.

Atualização: Necromante do Véu é Humana da Necrópole e não conta como Monstro. Cura causa dano mágico em Mortos-vivos. Veja [Necromancia](NECROMANCIA.md).

Monstros da Aldeia, caso existam, são exclusivos de decks só da Aldeia. Fungo da Ninhada agora pertence à Horda. Veja [Esporos e Regeneração](ESPOROS_E_REGENERACAO.md).
