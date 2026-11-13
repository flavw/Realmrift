# Ermos

Facção complementar de Horda e Necrópole, identificador 8. Possui cor de pedra e terra, com símbolo de montanhas áridas (`assets/ui/faction-wastes.svg`). O nome em inglês é Wastes. A identidade permite Monstros, Mortos-vivos, Feras e alguns Humanos, sem confundir tipo de criatura com facção.

## Transferências

| Card | Origem | Destino | Atributos e habilidades |
| --- | --- | --- | --- |
| Lobo da Noite | Aldeia | Ermos | Custo 2, Fera 2/2, Fúria 1 |
| Zumbi Serviçal | Horda | Ermos | Custo 2, Morto-vivo 2/1, Chamado de +1/+1 para outro Monstro ou Morto-vivo aliado |
| Necromante do Véu | Horda | Necrópole | Custo 4, Humana 2/4, Chamado de invocação do Carniçal |

As transferências mantêm chaves de recursos, artes, atributos e habilidades. Lobo dos Ermos (`horde_wolf`) é outro card já existente, continua na Horda e não é o Lobo da Noite transferido pelo pedido.

## Novos cards: Carniçal Faminto e Ogro Errante

| Card | Tipo | Custo | Ataque/vida | Habilidade |
| --- | --- | --- | --- | --- |
| Carniçal Faminto | Morto-vivo | 3 | 3/3 | Carniceiro 1 |
| Ogro Errante | Monstro | 4 | 4/4 | Atropelar |
| Hiena dos Ermos | Fera | 3 | 3/2 | Envenenar 1 |

**Carniceiro N:** quando outra criatura morre, aliada ou inimiga, recupera N de vida até o máximo atual. Cada morte conta uma vez para cada fonte viva. Não é Cura: funciona nos Mortos-vivos, não ativa Devoção e mantém Veneno/Sangramento. Não aumenta a vida máxima, não revive a fonte e não a salva se morrer simultaneamente com outra vítima. Tem ícone próprio, descrição ao inspecionar, registro e efeito visual de recuperação em combate.

As duas cartas são colecionáveis, elegíveis em Horda/Necrópole + Ermos e no draft/recompensas/loja da aventura. Os decks padrão existentes não são substituídos. Artes em `assets/art/hungry_ghoul.png` e `assets/art/wandering_ogre.png`; prompts em [Carniçal e Ogro](art-prompts/wastes-ghoul-ogre.md). Teste específico: `tests/test_wastes_new_cards.gd`.

## Regras de composição

Diretriz de balanceamento: Aldeia e Ermos oferecem apoio flexível, mas seus cards devem, em geral, ser um pouco menos eficientes que os das facções principais de custo semelhante. A comparação considera atributos, habilidades e sinergias; não é uma penalidade automática aplicada no combate.

- Horda + Ermos.
- Necrópole + Ermos.
- Vanguarda, Arcano, Submundo, Luminares e Selvagem + Aldeia.
- Decks apenas da Aldeia ou apenas de Ermos podem ser montados, se houver cartas suficientes para os 22 espaços e limites de cópias.
- Ermos não complementa as cinco facções da Aldeia; Aldeia não complementa Horda ou Necrópole. Uma lista não pode misturar Horda e Necrópole.
- Humanos dos Ermos podem complementar a Horda. A composição é definida pela facção; cada criatura possui somente seu tipo declarado.
- A aventura mantém o recrutamento livre após o draft. No draft inicial e nos decks inimigos, a Horda usa Ermos como complemento.

O construtor oferece as nove facções, filtros separados para base/complemento e seus símbolos. Os Ermos são tratados como complemento nas ofertas da loja da aventura, sem contar como uma facção principal extra recrutada.

## Decks salvos

O formato passa à versão 13. Listas da Horda substituem a Necromante do Véu por cartas compatíveis; listas de Submundo, Selvagem ou outras bases da Aldeia substituem o Lobo da Noite transferido por cartas compatíveis. A migração altera apenas os três cards transferidos quando incompatíveis com a base anterior; preserva quantidade, nome, espaço, seleção ativa e capa válida, respeitando limites de cópias. Migrações das versões anteriores continuam funcionando. Expedições existentes mantêm seus cards, pois podem recrutar de qualquer facção.

Os sete decks padrão permanecem legais com 22 cartas. Com a Cripta, o Esqueleto e a Maré Sepulcral, a Necrópole possui seis cartas próprias e cinco complementos dos Ermos: é possível montar um deck de 22 cartas com duas cópias de cada uma dessas onze cartas.

Validação: `tests/test_wastes_faction.gd`, `tests/test_villagers_necropolis.gd`, `tests/test_faction_names.gd` e `tests/test_adventure_shop_groups.gd`.
