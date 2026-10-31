# Simulação dos decks salvos — 600 partidas

Foram usadas as seis listas completas do arquivo de decks salvo pelo jogador, sem alterar sua composição. O snapshot das listas e dos atributos atuais acompanha os resultados.

## Método

- 40 partidas por confronto entre decks diferentes: 15 confrontos, 600 partidas; cada deck participou de 200.
- IA atual do jogo nos dois lados, com os lados e a iniciativa equilibrados por confronto.
- Mulligan troca cartas com custo 4 ou superior. Regras atuais: mão máxima de 6, segundo jogador com mana temporária, Mãos Flamejantes por 2 mana, Familiar 0/3, Esporos sem afetar a fonte e Negociante 2/1 com Saquear 1 ou Envenenar 2.
- Sementes reproduzíveis registradas no JSON. Limites: 180 turnos individuais ou 4.000 ações; nenhum jogo atingiu esses limites.
- Cada turno individual corresponde à vez de um dos jogadores; duas vezes consecutivas formam aproximadamente uma rodada.

## Desempenho

| Deck | Classe | Vitórias / 200 | Taxa | Turnos individuais médios |
|---|---|---:|---:|---:|
| Círculo Arcano | Mago | 156 | 78.0% | 19.7 |
| Baluarte das Cicatrizes | Guerreiro | 114 | 57.0% | 18.1 |
| União da Colheita | Neutros | 89 | 44.5% | 16.8 |
| Aurora Vital | Clérigo | 88 | 44.0% | 17.6 |
| Horda dos Ermos | Horda | 83 | 41.5% | 17.3 |
| Caçada das Brumas | Ladino | 70 | 35.0% | 16.2 |

## Confrontos

| Deck A | Deck B | Vitórias A–B |
|---|---|---:|
| Baluarte das Cicatrizes | Caçada das Brumas | 30–10 |
| Baluarte das Cicatrizes | Círculo Arcano | 6–34 |
| Baluarte das Cicatrizes | Aurora Vital | 26–14 |
| Baluarte das Cicatrizes | Horda dos Ermos | 23–17 |
| Baluarte das Cicatrizes | União da Colheita | 29–11 |
| Caçada das Brumas | Círculo Arcano | 4–36 |
| Caçada das Brumas | Aurora Vital | 21–19 |
| Caçada das Brumas | Horda dos Ermos | 22–18 |
| Caçada das Brumas | União da Colheita | 13–27 |
| Círculo Arcano | Aurora Vital | 24–16 |
| Círculo Arcano | Horda dos Ermos | 31–9 |
| Círculo Arcano | União da Colheita | 31–9 |
| Aurora Vital | Horda dos Ermos | 20–20 |
| Aurora Vital | União da Colheita | 19–21 |
| Horda dos Ermos | União da Colheita | 19–21 |

## Ritmo e iniciativa

- Média: 17.62 turnos individuais (cerca de 8.8 rodadas). Mediana: 17. Máximo: 35.
- Quem começou venceu 328/600 (54.7%).
- Empates: 0. Sem conclusão: 0.
- Compras destruídas por mão cheia: 22. Partidas que chegaram à fadiga: 5.

## Leitura dos resultados

O Mago é o principal sinal de desequilíbrio: venceu 156/200 partidas (78%) e todos os cinco confrontos. Contra Guerreiro venceu 34/40 e contra Ladino 36/40. A hipótese a investigar primeiro é a combinação de Disparo Arcano gratuito, crescimento por Ressonância e dano mágico que ignora Armadura/Bloqueio; este teste não isola causalmente cada carta.

O Ladino ficou em 70/200 (35%). Além do resultado contra Mago, perdeu 30/40 contra Guerreiro. A IA escolheu Saquear 148 vezes e Envenenar 18 vezes no Chamado da Negociante, um possível viés estratégico que merece comparação antes de aumentar atributos do deck inteiro. Isso não prova que escolher Envenenar mais vezes melhoraria os resultados.

Horda (41,5%), Clérigo (44%) e Neutros (44,5%) ficaram próximos entre si. Contra os quatro oponentes que não são Mago, Guerreiro venceu 67,5%, Neutros 50%, Horda 46,3%, Clérigo 45% e Ladino 41,3%. Portanto, o Guerreiro também merece atenção após a revisão do Mago.

Prioridades sugeridas: experimentar um ajuste por vez no motor de Ressonância/Disparo Arcano do Mago; comparar a escolha de veneno/compra da IA do Ladino; depois rever Ladino versus Guerreiro. Os resultados são de IA contra IA e dessas listas específicas, não uma estimativa direta de partidas entre humanos ou de todas as listas possíveis da classe. Nenhum balanceamento foi aplicado nesta etapa.

## Arquivos

- `decks-simulacao-600-atual.json`: snapshot dos seis decks salvos e hash do arquivo de origem.
- `simulacao-600-decks-atuais.json`: resultados individuais, sementes, atributos, duração, fadiga e métricas de habilidades.
- `tools/simulate_saved_600.gd`: execução reproduzível usando o snapshot.

## Composição dos decks

### Baluarte das Cicatrizes

- 2× Escudeiro da Lua (custo 1)
- 2× Sentinela de Ferro (custo 2)
- 2× Ferreiro da Muralha (custo 3)
- 2× Guerreira Audaciosa (custo 3)
- 2× Guardião da Muralha (custo 4)
- 2× Arauto da Lua (custo 2)
- 2× Postura de Ferro (custo 2)
- 2× Espadachim das Cicatrizes (custo 3)
- 2× Guardião Arcano (custo 3)
- 2× Camponesa Generosa (custo 2)

### Caçada das Brumas

- 2× Batedora do Crepúsculo (custo 2)
- 2× Corvo das Brumas (custo 2)
- 2× Ladina Relâmpago (custo 4)
- 2× Alquimista das Brumas (custo 3)
- 2× Passo das Sombras (custo 1)
- 2× Arauto da Lua (custo 2)
- 1× Falcão Mensageiro (custo 1)
- 2× Trombadinha (custo 1)
- 1× O Sombra (custo 5)
- 2× Saltador dos Telhados (custo 3)
- 2× Negociante de Segredos (custo 2)

### Círculo Arcano

- 2× Maga Arcana (custo 2)
- 2× Conjuradora do Éter (custo 4)
- 2× Familiar Rúnico (custo 2)
- 2× Canalista do Eclipse (custo 3)
- 2× Descarga Condutora (custo 2)
- 2× Chama Astral (custo 3)
- 2× Escudeiro da Lua (custo 1)
- 2× Feiticeira das Brasas (custo 4)
- 1× Bola de Fogo (custo 6)
- 2× Mísseis Mágicos (custo 3)
- 1× Aprendiz de Feiticeiro (custo 1)

### Aurora Vital

- 2× Clériga da Aurora (custo 3)
- 2× Guardião da Aurora (custo 4)
- 2× Oráculo da Aurora (custo 2)
- 2× Fazendeiro (custo 2)
- 2× Luz Restauradora (custo 2)
- 2× Voto de Vigor (custo 2)
- 2× Arauto da Lua (custo 2)
- 1× Peregrina da Vida (custo 3)
- 2× Devota do Alvorecer (custo 3)
- 2× Acólita da Aurora (custo 1)
- 1× Paladino da Alvorada (custo 5)

### Horda dos Ermos

- 2× Clamor da Horda (custo 3)
- 2× Zumbi Serviçal (custo 2)
- 2× Lobisomem das Brumas (custo 4)
- 2× Troll do Brejo (custo 4)
- 2× Minotauro da Ruína (custo 5)
- 2× Necromante do Véu (custo 4)
- 2× Goblin Saqueador (custo 1)
- 2× Lobo da Noite (custo 2)
- 2× Fungo da Ninhada (custo 3)
- 2× Kobold do Ferrão (custo 2)

### União da Colheita

- 2× Arauto da Lua (custo 2)
- 2× Camponesa Generosa (custo 2)
- 2× Fazendeiro (custo 2)
- 2× Comerciante Astuta (custo 2)
- 2× Boi da Colheita (custo 3)
- 1× Levante da Aldeia (custo 5)
- 2× Líder da Aldeia (custo 4)
- 2× Vigia do Portão (custo 2)
- 2× Escudeiro da Lua (custo 1)
- 2× Peregrina da Vida (custo 3)
- 1× Reconstrução da Aldeia (custo 2)

