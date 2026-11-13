# Revisão dos decks e 50 partidas contra Guerreiro

Data: 25/10/2026. As sugestões foram removidas do editor: não há seletor nem botão para carregar uma lista pronta. Novos decks continuam começando pela escolha da facção base. As listas iniciais e da IA permanecem no jogo.

## Alterações de composição

- **Muralha Lunar:** troca de um Vigia do Portão por uma Muralha da Aldeia. Mantém pressão e adiciona uma defesa resistente; apenas uma Muralha para não ocupar muitos espaços com criaturas que não atacam.
- **Caçada das Brumas:** mantida. Disparada, Voo e Veneno favorecem agressão; a Muralha não combina com essa proposta.
- **Círculo Arcano:** dois Vigias do Portão substituídos por duas Bolas de Fogo. Amplificar também melhora a nova limpeza de campo.
- **Aurora Vital:** mantida. Vigor, ganhos de vida e cura continuam sendo o núcleo; a Muralha não pode ser curada nem atacar.
- **União da Aldeia:** volta a ser exclusivamente aldeã, conforme escolha do jogador. Feiticeira das Brasas e Canalista do Eclipse saem; entram uma Muralha da Aldeia e a segunda Reconstrução da Aldeia. Mantém uma Peregrina da Vida.

Todos têm 20 cartas, até duas cópias. Nomes, capas, seleção ativa e quatro espaços vazios foram preservados. Não foram alterados custos, atributos ou habilidades das cartas.

## Método

50 partidas completas no motor real do jogo, sem interface, com a mesma IA de produção nos dois lados. Cada uma das cinco listas enfrenta a Muralha Lunar revisada dez vezes, incluindo o espelho Guerreiro × Guerreiro. São cinco sementes por confronto, repetidas alternando quem começa; cinco partidas começando para cada lado. O embaralhamento é determinístico por semente e posição. O mulligan troca cartas de custo 4 ou maior; o segundo jogador tem quatro cartas iniciais e uma segunda rodada opcional limitada a uma carta. Não há vitória artificial por limite de turnos.

Aplicadas as regras atuais de Veneno que termina após causar dano, Vigor ofensivo/defensivo, Bloqueio, Muralha, Aura, Chamado e dano em área. As verificações conferem limites de campo/mão, mana não negativa, sobreviventes com vida positiva e encerramento do veneno.

## Resultado

| Deck avaliado | Vitórias | Derrotas | Empates | Vitórias começando / 5 | Vitórias em segundo / 5 | Média de turnos individuais |
|---|---:|---:|---:|---:|---:|---:|
| Muralha Lunar | 8 | 2 | 0 | 4 | 4 | 21.9 |
| Caçada das Brumas | 5 | 5 | 0 | 5 | 0 | 14.7 |
| Círculo Arcano | 8 | 2 | 0 | 5 | 3 | 29.5 |
| Aurora Vital | 2 | 8 | 0 | 2 | 0 | 21.5 |
| União da Aldeia | 3 | 7 | 0 | 3 | 0 | 20.2 |

Cada vitória/derrota é da perspectiva do deck avaliado, na posição 0. No espelho, os dois lados usam exatamente a mesma lista; o 8–2 não representa diferença de força entre decks.

O Mago teve o melhor resultado contra Guerreiro nesta amostra. Clérigo e aldeões tiveram dificuldade. Ladino mostrou forte dependência de iniciativa: venceu as cinco em que começou e perdeu as cinco em que foi segundo. Dez jogos por confronto e uma única política de IA não bastam para concluir que uma facção precisa de mudanças de atributos. Não houve ajuste automático de balanceamento a partir desta amostra.

## Uso das novas cartas

| Confronto | Bolas de Fogo usadas pelo avaliado | Muralhas usadas pelo avaliado | Reconstruções usadas pelo avaliado |
|---|---:|---:|---:|
| Muralha Lunar | 0 | 6 | 0 |
| Caçada das Brumas | 0 | 0 | 0 |
| Círculo Arcano | 11 | 0 | 0 |
| Aurora Vital | 0 | 0 | 0 |
| União da Aldeia | 0 | 7 | 13 |

## Partidas individuais

| Deck | Jogo | Semente | Começa | Vencedor | Vida final avaliado / referência | Turnos individuais |
|---|---:|---:|---|---|---:|---:|
| Muralha Lunar | 1 | 2026102500 | Avaliado | Avaliado | 18 / 0 | 21 |
| Muralha Lunar | 2 | 2026102500 | Referência | Avaliado | 8 / -2 | 22 |
| Muralha Lunar | 3 | 2026102501 | Avaliado | Referência | 0 / 10 | 28 |
| Muralha Lunar | 4 | 2026102501 | Referência | Avaliado | 5 / -1 | 26 |
| Muralha Lunar | 5 | 2026102502 | Avaliado | Avaliado | 19 / -1 | 23 |
| Muralha Lunar | 6 | 2026102502 | Referência | Avaliado | 6 / 0 | 24 |
| Muralha Lunar | 7 | 2026102503 | Avaliado | Avaliado | 20 / -1 | 19 |
| Muralha Lunar | 8 | 2026102503 | Referência | Referência | -2 / 20 | 17 |
| Muralha Lunar | 9 | 2026102504 | Avaliado | Avaliado | 13 / 0 | 21 |
| Muralha Lunar | 10 | 2026102504 | Referência | Avaliado | 12 / -1 | 18 |
| Caçada das Brumas | 1 | 2026102600 | Avaliado | Avaliado | 20 / -1 | 11 |
| Caçada das Brumas | 2 | 2026102600 | Referência | Referência | 0 / 16 | 21 |
| Caçada das Brumas | 3 | 2026102601 | Avaliado | Avaliado | 20 / -2 | 11 |
| Caçada das Brumas | 4 | 2026102601 | Referência | Referência | -1 / 7 | 19 |
| Caçada das Brumas | 5 | 2026102602 | Avaliado | Avaliado | 20 / -2 | 11 |
| Caçada das Brumas | 6 | 2026102602 | Referência | Referência | -2 / 10 | 17 |
| Caçada das Brumas | 7 | 2026102603 | Avaliado | Avaliado | 19 / -1 | 10 |
| Caçada das Brumas | 8 | 2026102603 | Referência | Referência | -2 / 18 | 17 |
| Caçada das Brumas | 9 | 2026102604 | Avaliado | Avaliado | 19 / -1 | 15 |
| Caçada das Brumas | 10 | 2026102604 | Referência | Referência | 0 / 15 | 15 |
| Círculo Arcano | 1 | 2026102700 | Avaliado | Avaliado | 8 / -1 | 25 |
| Círculo Arcano | 2 | 2026102700 | Referência | Avaliado | 6 / 0 | 30 |
| Círculo Arcano | 3 | 2026102701 | Avaliado | Avaliado | 18 / 0 | 23 |
| Círculo Arcano | 4 | 2026102701 | Referência | Avaliado | 10 / -2 | 38 |
| Círculo Arcano | 5 | 2026102702 | Avaliado | Avaliado | 12 / 0 | 33 |
| Círculo Arcano | 6 | 2026102702 | Referência | Referência | 0 / 20 | 21 |
| Círculo Arcano | 7 | 2026102703 | Avaliado | Avaliado | 13 / 0 | 33 |
| Círculo Arcano | 8 | 2026102703 | Referência | Referência | 0 / 11 | 33 |
| Círculo Arcano | 9 | 2026102704 | Avaliado | Avaliado | 8 / 0 | 31 |
| Círculo Arcano | 10 | 2026102704 | Referência | Avaliado | 16 / -1 | 28 |
| Aurora Vital | 1 | 2026102800 | Avaliado | Referência | -1 / 20 | 20 |
| Aurora Vital | 2 | 2026102800 | Referência | Referência | 0 / 20 | 15 |
| Aurora Vital | 3 | 2026102801 | Avaliado | Avaliado | 19 / -8 | 21 |
| Aurora Vital | 4 | 2026102801 | Referência | Referência | 0 / 20 | 23 |
| Aurora Vital | 5 | 2026102802 | Avaliado | Referência | 0 / 10 | 32 |
| Aurora Vital | 6 | 2026102802 | Referência | Referência | 0 / 19 | 19 |
| Aurora Vital | 7 | 2026102803 | Avaliado | Avaliado | 12 / 0 | 25 |
| Aurora Vital | 8 | 2026102803 | Referência | Referência | 0 / 16 | 25 |
| Aurora Vital | 9 | 2026102804 | Avaliado | Referência | -1 / 16 | 20 |
| Aurora Vital | 10 | 2026102804 | Referência | Referência | 0 / 19 | 15 |
| União da Aldeia | 1 | 2026102900 | Avaliado | Avaliado | 15 / -1 | 23 |
| União da Aldeia | 2 | 2026102900 | Referência | Referência | 0 / 20 | 19 |
| União da Aldeia | 3 | 2026102901 | Avaliado | Avaliado | 14 / 0 | 25 |
| União da Aldeia | 4 | 2026102901 | Referência | Referência | 0 / 16 | 19 |
| União da Aldeia | 5 | 2026102902 | Avaliado | Avaliado | 14 / -3 | 17 |
| União da Aldeia | 6 | 2026102902 | Referência | Referência | 0 / 18 | 19 |
| União da Aldeia | 7 | 2026102903 | Avaliado | Referência | 0 / 5 | 22 |
| União da Aldeia | 8 | 2026102903 | Referência | Referência | 0 / 14 | 21 |
| União da Aldeia | 9 | 2026102904 | Avaliado | Referência | -1 / 11 | 20 |
| União da Aldeia | 10 | 2026102904 | Referência | Referência | 0 / 11 | 17 |

## Reproduzir e inspecionar

`Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/simulate_reviewed_decks.gd`

[Composições revisadas](decks-revisados.json) · [Resultados e ações das 50 partidas](simulacao-decks-50-partidas.json). O arquivo de ações identifica os lados numericamente: 0 é o deck avaliado, 1 é a referência Guerreiro. Cada partida registra mão inicial, três rodadas totais de mulligan, cartas usadas, ações, vidas finais e fadiga.
