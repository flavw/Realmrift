# Tipos de criaturas e facção Horda

Tipo e classe/facção são campos independentes e editáveis no Inspector de cada recurso CardData. Toda criatura recebeu um tipo: Humano, Fera, Artefato, Monstro ou Morto-vivo. Magias continuam sem tipo de criatura na interface. O tipo aparece discretamente na base da carta completa e pode ser pesquisado ou filtrado na coleção.

A facção Horda usa borda cobre e símbolo de cabeça com chifres. Seus decks permitem somente cartas de Horda e neutras **não humanas**, com exceção de Humanos que possuam **Pacto Sombrio**, como Necromante do Véu. Magias neutras são permitidas. Essa restrição vale para adicionar, salvar, ativar e iniciar uma partida, inclusive quando os Humanos são adicionados antes da primeira carta de Horda. Outras classes e decks só de neutros continuam podendo usar Humanos.

| Carta | Classe | Tipo | Mana | Ataque/vida | Habilidade |
| --- | --- | --- | --- | --- | --- |
| Goblin Saqueador | Horda | Monstro | 1 | 1/1 | Arrancada |
| Minotauro da Ruína | Horda | Monstro | 5 | 5/5 | Bloqueio 1 |
| Lobisomem das Brumas | Horda | Monstro | 4 | 3/4 | Fúria 1, ativação por 1 mana sem esgotar |
| Zumbi Serviçal | Neutro | Morto-vivo | 2 | 1/3 | Chamado: dê Armadura 1 a outro aliado alvo; sem aliados, entra sem efeito |

O Lobisomem corresponde à silhueta lupina da arte de Bola de Fogo. Os três membros da nova facção são do tipo Monstro, conforme solicitado, mesmo quando têm aparência animal ou humanoide. O Zumbi é Morto-vivo, portanto não conta como Humano.

Classificação dos neutros existentes: Lobo da Noite, Falcão Mensageiro, Familiar Rúnico e Boi da Colheita são Feras; Muralha da Aldeia é Artefato; os camponeses, escudeiros, vigias, arauto, peregrino e Levante da Aldeia são Humanos. O Corvo das Brumas é Fera da classe Ladino. As demais criaturas anteriores são Humanas.

Horda das Brumas é uma receita legal de 20 cartas da IA: duas cópias de Goblin Saqueador, Minotauro da Ruína, Lobisomem das Brumas, Troll do Brejo, Falcão Mensageiro, Necromante do Véu, Fungo da Ninhada, Clamor da Horda, Zumbi Serviçal e Reconstrução. Nenhum espaço salvo do jogador é substituído automaticamente.

Validação: `tests/test_monsters_and_types.gd` cobre tipos, composição em ambas as ordens de adição, limites, persistência da nova classe, filtros, pesquisa e funcionamento das habilidades. Artes geradas com a ferramenta integrada imagegen; prompts completos em `art-prompts/monsters-and-zombie.md`.

Atualização: Necromante do Véu é Humana da facção Horda com Pacto Sombrio. Cura causa dano mágico em Mortos-vivos. Veja [Necromancia](NECROMANCIA.md).

Monstros neutros são permitidos apenas na Horda ou em decks só de neutros, ficando proibidos em Guerreiro, Mago, Ladino e Clérigo. Veja [Esporos e Regeneração](ESPOROS_E_REGENERACAO.md).
