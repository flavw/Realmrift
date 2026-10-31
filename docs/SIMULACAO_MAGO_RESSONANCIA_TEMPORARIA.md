# Mago após Ressonância temporária — 200 partidas

Repetição dos cinco confrontos do Mago do ensaio de 600 partidas, com as mesmas listas salvas, sementes, lados e iniciativa. A comparação altera a regra de Ressonância: os bônus expiram no início do próximo turno do dono, preservando no mínimo 1 de vida atual. As listas salvas foram conferidas e são idênticas às usadas anteriormente.

## Método

- 40 partidas por adversário, 200 no total.
- IA atual nos dois lados; mulligan troca cartas de custo 4 ou mais.
- Cada confronto equilibra o lado e quem começa.
- Mão máxima 6; Mãos Flamejantes por 2 mana; Familiar 0/3; demais regras atuais.
- O ensaio não altera os decks nem aplica outro balanceamento.

## Resultados do Mago

| Adversário | Antes | Agora | Placar atual |
|---|---:|---:|---:|
| Baluarte das Cicatrizes — Guerreiro | 85.0% | 77.5% | 31–9 |
| Caçada das Brumas — Ladino | 90.0% | 87.5% | 35–5 |
| Aurora Vital — Clérigo | 60.0% | 45.0% | 18–22 |
| Horda dos Ermos — Horda | 77.5% | 65.0% | 26–14 |
| União da Colheita — Neutros | 77.5% | 72.5% | 29–11 |

O Mago caiu de 156/200 (78%) para 139/200 (69.5%), uma redução de 8,5 pontos percentuais.

Todas as partidas terminaram. Empates: 0. Sem conclusão: 0. Duração média: 21.04 turnos individuais, aproximadamente 10.5 rodadas.

## Interpretação

A Ressonância temporária reduziu o desempenho do Mago em todos os confrontos. Clérigo passou a vencê-lo por 22–18. Ainda há um sinal forte de vantagem do Mago contra Ladino (35–5), Guerreiro (31–9) e Neutros (29–11). Contra Horda, o Mago venceu 26–14.

O ajuste ajudou, mas ainda não deixou o Mago próximo de 50% no conjunto. A próxima hipótese de teste é o Disparo Arcano gratuito, mantendo as demais regras fixas. Também permanece relevante rever como a IA do Ladino escolhe entre Saquear e Envenenar. Os resultados são específicos destas listas e da estratégia da IA, com somente 40 partidas por confronto; não devem ser interpretados como taxas exatas entre jogadores humanos.

## Artefatos

- `decks-mago-ressonancia-temporaria.json`: listas salvas e hash da origem.
- `simulacao-mago-ressonancia-temporaria.json`: partidas individuais, sementes e métricas.
- `tools/simulate_mage_temporary_resonance.gd`: execução reproduzível.
