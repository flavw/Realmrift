# Simulação de balanceamento — 25/10/2026

> Registro histórico: estas partidas antecedem Vigor, Veneno, Descarga Condutora e a abertura 3/4 com mulligan. Os percentuais abaixo não medem a versão atual.

## Resultado principal

Foram executadas 480 partidas válidas com as cartas atuais, sem alterar os recursos do jogo. Todas usaram decks de 12 cartas de uma única facção jogável + aldeões, com até duas cópias. Cada facção participou de 240 jogos. Não houve empates.

| Facção | Vitórias | Partidas | Taxa de vitória |
| --- | ---: | ---: | ---: |
| Guerreiro | 204 | 240 | 85.0% |
| Ladina | 141 | 240 | 58.8% |
| Mago | 80 | 240 | 33.3% |
| Clérigo | 55 | 240 | 22.9% |

O Guerreiro venceu 80 de 80 partidas contra Clérigo nos cenários testados. Clérigo e Mago ficaram próximos entre si, mas ambos perderam frequentemente para Guerreiro e Ladina. Isso aponta um problema de balanceamento do conjunto atual, além de diferenças entre as listas.

## Método e limites

- Motor real `DuelMatch`, em Godot headless, sem animações ou regras reimplementadas.
- Todos os seis confrontos entre facções foram testados.
- Dez sementes por confronto, cada uma repetida invertendo quem começa. A ordem de cada deck é fixada por facção/semente, independentemente do lado.
- Dois conjuntos de decks: sugestões de arquétipo e um controle com os mesmos seis aldeões para todas as facções (2 Escudeiros, 2 Lobos, 2 Fazendeiros).
- Dois pilotos: IA atual aplicada simetricamente aos dois lados e um piloto tático de avaliação imediata. O segundo enumera ações legais, aplica cada opção em cópias do estado pelo próprio motor e escolhe o maior ganho heurístico.
- O piloto tático não faz busca de vários turnos, não é um jogador humano e sua avaliação não foi otimizada por facção. A amostra tem somente duas listas por facção e dez sementes por cenário. Resultados repetidos entre pilotos/listas são correlacionados; as taxas não representam uma previsão estatística de partidas humanas.
- Espelhamentos de assento, limites de cópias e legalidade de facção foram verificados pelo simulador. Arquivos com erros de execução foram descartados; uma execução preliminar tática inválida e a bateria curta de verificação não entram nas contagens.

O primeiro jogador venceu 324/480 jogos (67.5%). Houve 87 finais por fadiga (18.1%). A duração média foi 17.4 turnos individuais (um turno por jogador, não uma rodada completa).

## Sensibilidade ao piloto e à lista

| Piloto/lista | Guerreiro | Ladina | Mago | Clérigo |
| --- | ---: | ---: | ---: | ---: |
| IA atual / arquétipo | 83.3% | 63.3% | 30.0% | 23.3% |
| IA atual / aldeões iguais | 83.3% | 68.3% | 35.0% | 13.3% |
| Tático / arquétipo | 86.7% | 51.7% | 30.0% | 31.7% |
| Tático / aldeões iguais | 86.7% | 51.7% | 38.3% | 23.3% |

## Confrontos agregados

Cada confronto soma 80 partidas (2 pilotos × 2 listas × 10 sementes × 2 assentos).

| Facção A | Facção B | Vitórias A | Vitórias B |
| --- | --- | ---: | ---: |
| Guerreiro | Mago | 58 | 22 |
| Guerreiro | Ladina | 66 | 14 |
| Guerreiro | Clérigo | 80 | 0 |
| Mago | Ladina | 19 | 61 |
| Mago | Clérigo | 39 | 41 |
| Ladina | Clérigo | 66 | 14 |

## Diagnóstico

1. **Guerreiro forte demais contra dano físico.** Armadura permanente reduz cada ataque; unidades com 1–2 de ataque frequentemente causam zero dano, especialmente após Postura de Ferro. Bloqueio força trocas contra esses defensores. O poder não vem apenas de Postura: reduzir somente seu bônus de Armadura não melhorou o resultado nesta amostra.
2. **Clérigo é a prioridade de reforço.** Cura e crescimento prolongam a partida, mas o ataque baixo e a falta de remoção dificultam converter essa sobrevivência em vitória. Contra Armadura, curar não ajuda a remover o bloqueador. A facção precisa de acesso a dano/remoção ou de uma mecânica que transforme cura em pressão ofensiva.
3. **Mago também precisa de reforço.** A remoção mágica responde à Armadura, mas muitas cartas exigem mana para invocar e novamente para ativar. Ao esgotar para remover, ainda deixam pouca pressão no castelo. Reduzir somente o custo de Chama Astral teve efeito pequeno e dependente da lista.
4. **Ladina não é a primeira candidata a receber bônus.** Ficou entre 51,7% e 68,3% por cenário. Sua relação com Guerreiro/Clérigo muda bastante após ajustes das outras facções.
5. **Iniciativa tem sinal de vantagem.** Mesmo alternando os assentos, o primeiro jogador ganhou 67,5%. Vale testar uma compensação ao segundo jogador (por exemplo, recurso temporário), separadamente dos ajustes de facção.

## Ensaios de ajustes — somente em memória

Além da linha de base, foram realizadas 1.200 partidas experimentais: cinco variantes, 240 jogos por variante, com o piloto tático e as mesmas listas/sementes/assentos. Nenhum `.tres` foi salvo ou alterado; hashes SHA-256 dos 22 recursos foram comparados antes e depois.

| Variante | Alteração | Guerreiro (arquétipo/controle) | Ladina | Mago | Clérigo |
| --- | --- | ---: | ---: | ---: | ---: |
| posture | Postura: Armadura +2 → +1 | 86.7%/88.3% | 51.7%/51.7% | 30.0%/36.7% | 31.7%/23.3% |
| warrior | Guerreira Audaciosa: Armadura 2 → 1 | 76.7%/85.0% | 60.0%/53.3% | 31.7%/38.3% | 31.7%/23.3% |
| cleric | Guardião da Aurora: ataque 2 → 3 | 86.7%/86.7% | 51.7%/50.0% | 28.3%/25.0% | 33.3%/38.3% |
| mage | Chama Astral: custo 3 → 2 | 85.0%/88.3% | 55.0%/50.0% | 28.3%/40.0% | 31.7%/21.7% |
| combined | As quatro alterações acima, juntas | 75.0%/86.7% | 65.0%/50.0% | 26.7%/26.7% | 33.3%/36.7% |

A redução da Armadura da Guerreira ajudou a Ladina em uma lista, mas não corrigiu Guerreiro × Clérigo. O ataque adicional no Guardião da Aurora melhorou Clérigo com aldeões iguais (23,3% → 38,3%), porém quase não mudou o deck de sustento (31,7% → 33,3%) e continuou sem vencer Guerreiro. A combinação testada também não produziu equilíbrio; portanto, não recomendo aplicar esse pacote como solução pronta.

### Próximos testes recomendados

- Guerreiro: testar custo/eficiência das criaturas de Armadura e a soma de Armadura + Bloqueio; preservar a identidade defensiva sem tornar unidades de baixo ataque incapazes de interagir. Não apostar apenas numa redução de Postura de Ferro.
- Clérigo: experimentar uma remoção temática ou um gatilho ofensivo de cura (por exemplo, ganho de ataque quando uma cura efetivamente restaura vida). O aumento de ataque do Guardião pode ser parte do teste, mas não resolve sozinho.
- Mago: testar custo de ativação da Canalista do Eclipse de 2 para 1 e/ou uma condição de vitória com alcance ao castelo. Não alterar o ataque 0 da Maga Arcana sem uma decisão de design. Essas propostas ainda não foram simuladas.
- Repetir a bateria depois de cada mudança, incluindo listas com outros aldeões e testes humanos. Os dois pilotos atuais não esgotam combinações possíveis.

## Listas usadas

### Arquétipos
- Clérigo: cleric ×2, dawn_warden ×2, life_pilgrim ×2, farmer ×2, squire ×2, restoring_light ×2
- Guerreiro: warrior ×2, squire ×2, sentinel ×2, wall_guard ×1, gate_watcher ×2, iron_stance ×2, wolf ×1
- Ladina: rogue ×2, dusk_scout ×2, raven ×2, messenger_hawk ×2, wolf ×2, shadow_step ×2
- Mago: mage ×2, fire_mage ×1, eclipse_channeler ×2, runic_familiar ×2, astral_flame ×2, squire ×2, farmer ×1

### Controle com aldeões iguais
- Clérigo: squire ×2, wolf ×2, farmer ×2, cleric ×2, dawn_warden ×2, restoring_light ×2
- Guerreiro: squire ×2, wolf ×2, farmer ×2, warrior ×2, wall_guard ×2, iron_stance ×2
- Ladina: squire ×2, wolf ×2, farmer ×2, rogue ×2, dusk_scout ×2, shadow_step ×2
- Mago: squire ×2, wolf ×2, farmer ×2, mage ×2, eclipse_channeler ×2, astral_flame ×2

## Amostra de 12 partidas válidas

Piloto tático, listas de arquétipo, semente 1, ambos os assentos de cada confronto. O CSV contém as 480 partidas de linha de base.

| Primeiro | Segundo | Vencedor | Turnos | Final |
| --- | --- | --- | ---: | --- |
| Guerreiro | Mago | Guerreiro | 15 | Combate |
| Mago | Guerreiro | Mago | 23 | Combate |
| Guerreiro | Ladina | Guerreiro | 13 | Combate |
| Ladina | Guerreiro | Guerreiro | 14 | Combate |
| Guerreiro | Clérigo | Guerreiro | 13 | Combate |
| Clérigo | Guerreiro | Guerreiro | 18 | Combate |
| Mago | Ladina | Ladina | 14 | Combate |
| Ladina | Mago | Ladina | 11 | Combate |
| Mago | Clérigo | Clérigo | 16 | Combate |
| Clérigo | Mago | Clérigo | 20 | Fadiga |
| Ladina | Clérigo | Ladina | 11 | Combate |
| Clérigo | Ladina | Clérigo | 19 | Combate |

## Reprodução

Execute `tools/simulate_balance.gd` a partir do projeto com o Godot em headless. Variáveis de ambiente: `BALANCE_POLICY=production` ou `tactical`; `BALANCE_ROUNDS=10`; `BALANCE_OUTPUT` aponta para um JSON de saída. Opcionalmente, `BALANCE_PATCH` seleciona `posture`, `warrior`, `cleric`, `mage` ou `combined`; sem valor, são usadas as cartas atuais. A ferramenta aplica variantes apenas aos recursos carregados em memória.

Estado final: cartas e regras do jogo inalteradas. Nenhuma publicação no GitHub.
