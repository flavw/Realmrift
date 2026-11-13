# Simulação solicitada — Guerreiro × Ladina, Clérigo e Mago

> Histórico da primeira rodada, antes de Vigor ofensivo e da redução de custo de Disparo Arcano 2. Veja a segunda rodada em SIMULACAO_GUERREIRO_RODADA_2.md.

Foram executadas **exatamente 15 partidas completas**, cinco de cada confronto, com o motor real do Godot. Nenhum atributo de balanceamento foi modificado durante as simulações. O Guardião da Aurora já estava com **Bloqueio 1**, mantendo custo 4, 2/5, Vigor e Cura 2.

| Confronto | Vitórias Guerreiro | Vitórias rival | Empates |
| --- | ---: | ---: | ---: |
| Guerreiro × Ladina | 3 | 2 | 0 |
| Guerreiro × Clérigo | 5 | 0 | 0 |
| Guerreiro × Mago | 4 | 1 | 0 |

## Método

- Decks de 12 cartas, apenas uma facção + aldeões, até duas cópias. Mesmas listas durante as cinco partidas de cada confronto.
- IA de produção do próprio jogo nos dois lados. Ao controlar Guerreiro, a visão do motor é espelhada, usando as mesmas regras e decisões da IA adversária.
- Quem começa alterna a cada partida: Guerreiro começa três, o rival começa duas (cinco é um número ímpar). Mão inicial 3/4, mulligan grátis para ambos, devolvendo cartas de custo 4 ou mais, igual à IA do jogo.
- Regras atuais: Vigor, Bloqueio renovando uma carga, Veneno acumulativo e decrescente, magia ignorando Armadura, Descarga Condutora e Amplificar.
- Seeds e registros de cada ação estão no JSON; tabela por partida no CSV. Turno na tabela significa um turno individual, não uma rodada dos dois jogadores.
- Cinco partidas por confronto permitem observar problemas, mas não estimam com segurança a taxa de vitória da facção. Os resultados também dependem dessas listas, da ordem inicial e das decisões da IA.

## O que apareceu nas partidas

**Ladina — 2 vitórias em 5.** Houve 15 resoluções de Veneno em criaturas/castelos. Uma vitória da Ladina terminou por Veneno e outra por fadiga. A Ladina venceu as duas partidas em que começou, e o Guerreiro venceu as três em que começou: nesta pequena amostra, a iniciativa ficou muito associada ao resultado.

**Clérigo — 0 vitórias em 5.** Foram invocados 8 Guardiões da Aurora, ocorreram 32 defesas com Vigor e 4 conjurações de Voto de Vigor. As mecânicas novas participaram das partidas. Ainda assim, ataques do Clérigo causaram zero dano físico por Armadura em 7 combates. Vigor melhora o contra-ataque, mas não ajuda essas criaturas a remover inimigos ao atacar. O resultado sugere que só reforçar defesa não resolve o confronto desta lista contra Guerreiro. Uma derrota foi por fadiga.

**Mago — 1 vitória em 5.** Descarga Condutora foi conjurada 5 vezes, uma por partida. A magia funcionou, porém a lista ainda perdeu quatro partidas. A vitória do Mago terminou por fadiga.

## Próximos ajustes sugeridos, ainda não aplicados

1. Priorizar o Clérigo: experimentar uma remoção própria ou uma forma limitada de converter vida em pressão ofensiva, em vez de aumentar novamente a defesa. Também vale melhorar a IA para reconhecer quando precisa pressionar o castelo.
2. Mago: testar uma lista com duas Descargas e avaliar a eficiência de Disparo Arcano; evitar reduzir custos de várias cartas ao mesmo tempo.
3. Guerreiro: investigar Postura de Ferro e a combinação de Armadura permanente com Bloqueio. Se permanecer dominante numa amostra maior, testar apenas um ajuste de cada vez, como Armadura concedida de 2 para 1.
4. Ladina: conservar os atributos por enquanto e repetir jogos com seeds emparelhadas e troca de iniciativa antes de tirar conclusões sobre equilíbrio.

## Partidas

| Confronto | Jogo | Começou | Vencedor | Turnos | Vida final Guerreiro / rival | Fim |
| --- | ---: | --- | --- | ---: | --- | --- |
| Guerreiro × Ladina | 1 | Guerreiro | Guerreiro | 17 | 10 / -2 | Combate |
| Guerreiro × Ladina | 2 | Ladina | Ladina | 19 | -1 / 7 | Fadiga |
| Guerreiro × Ladina | 3 | Guerreiro | Guerreiro | 21 | 11 / 0 | Combate |
| Guerreiro × Ladina | 4 | Ladina | Ladina | 10 | 0 / 17 | Veneno |
| Guerreiro × Ladina | 5 | Guerreiro | Guerreiro | 13 | 18 / 0 | Combate |
| Guerreiro × Clérigo | 1 | Guerreiro | Guerreiro | 21 | 17 / -3 | Combate |
| Guerreiro × Clérigo | 2 | Clérigo | Guerreiro | 20 | 17 / -2 | Combate |
| Guerreiro × Clérigo | 3 | Guerreiro | Guerreiro | 15 | 15 / 0 | Combate |
| Guerreiro × Clérigo | 4 | Clérigo | Guerreiro | 24 | 4 / -3 | Fadiga |
| Guerreiro × Clérigo | 5 | Guerreiro | Guerreiro | 15 | 20 / 0 | Combate |
| Guerreiro × Mago | 1 | Guerreiro | Guerreiro | 19 | 19 / 0 | Combate |
| Guerreiro × Mago | 2 | Mago | Mago | 23 | 0 / 13 | Fadiga |
| Guerreiro × Mago | 3 | Guerreiro | Guerreiro | 17 | 18 / -2 | Combate |
| Guerreiro × Mago | 4 | Mago | Guerreiro | 18 | 18 / 0 | Combate |
| Guerreiro × Mago | 5 | Guerreiro | Guerreiro | 19 | 18 / -1 | Combate |

Vida zero ou negativa significa castelo destruído; o motor preserva o excedente de dano.

## Decks usados

**Clérigo:** 2× cleric, 2× dawn_warden, 2× life_pilgrim, 2× farmer, 2× squire, 1× restoring_light, 1× vigor_vow.

**Guerreiro:** 2× warrior, 2× squire, 2× sentinel, 1× wall_guard, 2× gate_watcher, 2× iron_stance, 1× wolf.

**Ladina:** 2× rogue, 2× dusk_scout, 2× raven, 2× messenger_hawk, 2× wolf, 2× shadow_step.

**Mago:** 2× mage, 1× fire_mage, 2× eclipse_channeler, 2× runic_familiar, 1× astral_flame, 1× conductive_bolt, 2× squire, 1× farmer.

Reprodução: execute `tools/simulate_warrior_matchups.gd` no Godot com `BALANCE_OUTPUT` apontando para o JSON desejado. O script gera somente estas 15 partidas, com as seeds registradas.

Tudo foi salvo localmente. GitHub não foi atualizado.
