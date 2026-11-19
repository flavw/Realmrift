# Sorte, recompensas e polimento da interface

- **Postura de Ferro** mantém +1 ataque e +1 Armadura permanentes e deixa de conceder Bloqueio. Bloqueio já existente, capacidade e cargas não são alterados. A mudança se aplica ao motor de duelos, aventura e multiplayer, e ao texto curto e ajuda da carta.
- A travessia da etapa 3 tem somente duas saídas: **ponte ou rio**. Qualquer caminho anterior permite escolher uma delas. Não há curandeira nem item nessa etapa para contornar o encontro.
- O **Santuário dos dois destinos** ocupa a clareira inferior entre as ruínas e o segundo entreposto, na etapa 8. Uma oferenda de **1 ouro** dá 50% de sorte e 50% de revés. Sorte pode conceder ouro, cura e um dado ou equipamento. Revés pode causar ferimentos, consumir um dado ou iniciar o duelo contra os Guardiões do Santuário, que usam um deck de 16 cartas e um castelo com 16 de vida. Na mesma etapa é possível visitar a curandeira ou recolher um tesouro de 1 a 6 ouro.
- O sorteio é feito ao pagar, e o encontro salva o resultado imediatamente. Sair do santuário antes de pagar não custa ouro. Uma emboscada exige enfrentar os guardiões. A vitória concede a recompensa normal de combate e inclui uma opção de Necrópole.
- A aventura tem **14 etapas**, preservando seis duelos comuns e o dragão. Há duas lojas (etapas 4 e 9) e dois reforços imediatamente antes do chefe.

## Níveis

A tela de XP agora mostra uma ficha para cada nível alcançado durante a animação, com ícone, título e descrição do que foi desbloqueado. A lista cresce quando vários níveis são ganhos de uma vez. O botão indica **Escolher melhoria** quando há uma escolha pendente.

Os marcos mantêm as regras existentes: nível 3 dá uma tentativa extra por expedição, níveis 4 e 8 dão +1 dado inicial e nível 5 dá um item inicial após o draft. Esses níveis não oferecem melhorias menores. Os demais níveis mostram as duas melhorias disponíveis ou o bônus já escolhido. Escolher uma melhoria também exibe um recibo temporário com seu nome e efeito.

## Interface

No menu, **vs IA** e **Multiplayer** ficam lado a lado em botões iguais e fontes menores. Modo Aventura recebe um ícone de mapa/rota próprio. Os ícones são SVGs nativos, no estilo do menu.

Os encontros dividem a tela em um painel para a arte inteira e outro para texto e escolhas. Elara da Ponte e Orun, o Peregrino, têm retratos e saudações individuais. Cada retrato também aparece no mapa. A loja mostra o ouro, mantém as ofertas vendidas visíveis na posição original e preserva a rolagem durante as compras.

Os equipamentos incluem Adaga envenenada (+1 de Envenenar), Manto rúnico (+1 de Antimagia) e Broche da renovação (+1 de Regeneração). Eles podem sair em recompensas de equipamento ou na oferta especial das lojas e se aplicam a todas as cópias da carta.

As vitórias mostram o ouro e a vida efetivamente ganhos. O encerramento lista vitórias, cartas, equipamentos e XP. Derrotar o Dragão Negro abre o epílogo ilustrado na Vila do Vale. As origens iniciais são Vanguarda, Arcano, Submundo, Luminares e Selvagem. Ruína, Ermos e Necrópole podem aparecer nas lojas e nas recompensas.

Novas distribuições de nodos são criadas ao iniciar uma expedição nova.

Verificações: `tests/test_adventure_second_polish.gd`, testes do rio, progressão, salvamento/XP, itens e loja. A revisão visual inclui menu, encontro, mapa e subida de vários níveis.
