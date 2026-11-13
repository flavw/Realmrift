# Segunda rodada — Vigor ofensivo e Disparo Arcano 2 por 1 mana

**Mais 15 partidas completas: cinco de Guerreiro contra cada facção.** Executadas no motor real do Godot, depois das mudanças solicitadas. Sem ajustes adicionais de atributos ou decks entre partidas.

Mudanças aplicadas: número da gema subiu 3 px no custo superior e 2 px nas habilidades; Vigor vale para ataques físicos e contra-ataques, usando o maior valor entre ataque base e vida atual; Feiticeira das Brasas e Canalista do Eclipse pagam 1 mana + esgotar por Disparo Arcano 2. Clériga/Guardião e criaturas que recebem Voto de Vigor usam a mesma regra, inclusive contra castelos. O Guardião mantém Bloqueio 1.

| Confronto | Guerreiro | Rival | Empates | Rodada anterior (Guerreiro/rival) |
| --- | ---: | ---: | ---: | --- |
| Guerreiro × Ladina | 4 | 1 | 0 | 3/2 |
| Guerreiro × Clérigo | 4 | 1 | 0 | 5/0 |
| Guerreiro × Mago | 3 | 2 | 0 | 4/1 |

Mesmos decks de 12 cartas da rodada anterior, cada um com uma facção + aldeões e até duas cópias. IA de produção nos dois lados. Início alternado: Guerreiro começa três e o rival duas; mulligan grátis para ambos, trocando cartas de custo 4 ou mais, e mão inicial 3/4. **Seeds novas** nesta rodada (2026103501–3505, 2026103601–3605 e 2026103701–3705). Como as ordens iniciais são diferentes e são apenas cinco jogos por confronto, a comparação não isola o efeito das mudanças e não determina uma taxa de vitória confiável.

## Mecânicas exercitadas

- Ladina teve 14 resoluções de Veneno em criaturas/castelos.
- Clérigo realizou 17 ataques físicos com Vigor, teve 25 defesas com Vigor e invocou 8 Guardiões da Aurora. Voto de Vigor foi usado 5 vezes.
- Mago usou Disparo Arcano 25 vezes e Descarga Condutora 5 vezes.

## Leitura dos resultados

Clérigo venceu uma partida e Mago venceu duas nesta rodada, enquanto Guerreiro ainda venceu a maioria dos confrontos. Vigor ofensivo passou a dar pressão às criaturas de vida alta e o custo menor de Disparo permite usar dano mágico com menos mana. As mecânicas foram exercitadas nos registros, mas a amostra e as novas seeds não permitem atribuir a diferença de placar somente a essas mudanças. Nenhum balanceamento extra foi aplicado.

## Cada partida

| Rival | Jogo | Seed | Começou | Vencedor | Turnos individuais | Vida final Guerreiro/rival | Fim |
| --- | ---: | ---: | --- | --- | ---: | --- | --- |
| Ladina | 1 | 2026103501 | Guerreiro | Guerreiro | 17 | 17/-1 | Combate |
| Ladina | 2 | 2026103502 | Ladina | Guerreiro | 16 | 13/-2 | Combate |
| Ladina | 3 | 2026103503 | Guerreiro | Guerreiro | 13 | 20/0 | Combate |
| Ladina | 4 | 2026103504 | Ladina | Ladina | 12 | 0/20 | Veneno |
| Ladina | 5 | 2026103505 | Guerreiro | Guerreiro | 17 | 16/-2 | Combate |
| Clérigo | 1 | 2026103601 | Guerreiro | Guerreiro | 13 | 19/-1 | Combate |
| Clérigo | 2 | 2026103602 | Clérigo | Guerreiro | 24 | 5/-3 | Fadiga |
| Clérigo | 3 | 2026103603 | Guerreiro | Guerreiro | 19 | 18/0 | Combate |
| Clérigo | 4 | 2026103604 | Clérigo | Clérigo | 21 | -1/15 | Combate |
| Clérigo | 5 | 2026103605 | Guerreiro | Guerreiro | 15 | 17/0 | Combate |
| Mago | 1 | 2026103701 | Guerreiro | Guerreiro | 21 | 12/-1 | Fadiga |
| Mago | 2 | 2026103702 | Mago | Mago | 21 | 0/14 | Combate |
| Mago | 3 | 2026103703 | Guerreiro | Guerreiro | 15 | 20/0 | Combate |
| Mago | 4 | 2026103704 | Mago | Mago | 21 | 0/17 | Combate |
| Mago | 5 | 2026103705 | Guerreiro | Guerreiro | 17 | 20/0 | Combate |

## Decks

**Clérigo:** 2× cleric, 2× dawn_warden, 2× life_pilgrim, 2× farmer, 2× squire, 1× restoring_light, 1× vigor_vow.

**Guerreiro:** 2× warrior, 2× squire, 2× sentinel, 1× wall_guard, 2× gate_watcher, 2× iron_stance, 1× wolf.

**Ladina:** 2× rogue, 2× dusk_scout, 2× raven, 2× messenger_hawk, 2× wolf, 2× shadow_step.

**Mago:** 2× mage, 1× fire_mage, 2× eclipse_channeler, 2× runic_familiar, 1× astral_flame, 1× conductive_bolt, 2× squire, 1× farmer.

Reprodução: executar `tools/simulate_warrior_matchups.gd` com `SIMULATION_BATCH=2` e `BALANCE_OUTPUT` apontando para o JSON de saída. Registros completos por ação no JSON entregue; tabela resumida no CSV. O script de simulação usa as regras atuais; a primeira rodada preservada nos relatórios corresponde à versão anterior. GitHub não foi atualizado.
