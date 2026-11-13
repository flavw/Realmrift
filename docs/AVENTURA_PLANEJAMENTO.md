# Aventura: Da Vila à Fenda

Planejamento original da aventura. A primeira versão jogável está disponível pelo menu inicial; consulte a seção Aventura do README para o estado implementado e suas limitações.

## Jornada

O protagonista parte de uma pequena cidade ameaçada por uma fenda. A trilha tem seis confrontos comuns e um chefe final. Entre os confrontos há quatro etapas de encontros, incluindo uma loja. Cada etapa oferece pelo menos dois caminhos; o chefe encerra ambas as rotas.

1. Vila: escolher uma facção e formar o deck inicial.
2. Estrada: duelo 1; depois, escolher entre dois encontros.
3. Passagem: duelo 2; depois, duelo 3; adversários sorteados de facções variadas.
4. Encruzilhada: escolher entre dois eventos; depois, duelo 4.
5. Entrepostos: escolher entre a loja e outro encontro benéfico; depois, duelo 5.
6. Ruínas: escolher entre dois eventos; depois, duelo 6.
7. Fenda: chefe final com deck próprio e criaturas exclusivas mais fortes.

Cada etapa de duelo também oferece ao menos dois adversários possíveis, mostrando suas facções antes da escolha. Eventos e oponentes são sorteados por campanha e persistem quando apresentados, para impedir que voltar à tela altere as opções.

## Recrutamento

O jogador escolhe uma facção inicial e realiza 15 escolhas sucessivas entre três cartas aleatórias dessa facção ou aldeãs. Cada opção mostra custo, atributos e habilidade. As escolhas seguintes consideram a curva já escolhida, favorecendo custos baixos e médios sem impor uma escolha única. Meta inicial para 15 cartas: 2 de custo 1, 4 de custo 2, 4 de custo 3, 3 de custo 4 e 2 de custo 5 ou mais. Se uma faixa não tiver opções elegíveis suficientes, incluir custos próximos. As três opções devem ser distintas e respeitar os limites de cópias.

Após cada vitória, oferecer três cartas distintas, incluindo pelo menos uma carta coletável da facção enfrentada. O jogador recruta uma delas. Cartas de qualquer facção podem coexistir no deck da aventura; restrições específicas de cartas continuam explícitas. A loja apresenta cartas de várias facções e usa ouro ganho em confrontos e eventos. Exibir preço e saldo antes da compra.

## Encontros

- Mercado: gastar ouro em cartas de qualquer facção.
- Curandeira: receber ouro ou uma carta aldeã.
- Caravana: escolher uma carta de outra facção ou receber ouro.
- Santuário: escolher entre duas recompensas aleatórias reveladas.
- Exploradores: receber ouro ou trocar uma carta por outra dentre três opções.

Valores de ouro, preços, distribuição de oponentes e atributos das cartas exclusivas exigem balanceamento por partidas. Uma derrota encerra a expedição; uma vitória contra o chefe conclui a campanha.

## Integração necessária

- Introduzir um estado separado da aventura com fase, rota, deck, ouro, opções sorteadas e adversário; persistir o progresso para retomar a campanha.
- Aceitar deck de 15 ou mais cartas e múltiplas facções somente em partidas de aventura, sem alterar a validação dos decks comuns. Revisar efeitos dependentes de deck aldeão e restrições próprias de cartas.
- Ligar o menu inicial ao mapa, o mapa ao duelo e o resultado do duelo à recompensa ou à derrota. Evitar que reiniciar ou abrir o editor de decks comuns substitua o deck da aventura.
- Criar decks inimigos e cartas exclusivas, mantendo-as fora da coleção, dos decks comuns, das recompensas e da loja.
- Verificar montagem, curva, opções sem duplicatas, limites, caminhos, progressão, persistência, resultados e isolamento das regras dos duelos normais. Testar o fluxo inteiro no Godot.

## Poderes e melhorias persistentes

Na vila, antes do primeiro duelo, o jogador escolhe um entre três poderes aleatórios. No meio da jornada, um encontro especial oferece outra escolha entre três poderes ainda não escolhidos. Exemplos: uma mana temporária no primeiro turno de cada duelo; +1 de ataque até o fim do turno para criaturas aliadas ao comprar uma carta; +5 de vida inicial em cada duelo; ou +1 de ouro por vitória. Poderes duram toda a campanha. Os números são iniciais e precisam de balanceamento.

Ao concluir cada evento, oferecer uma pequena melhoria permanente para a expedição: um equipamento aplicado a uma carta escolhida, +1 de vida inicial em duelos futuros, ou outra recompensa pequena. Equipamentos devem identificar a cópia da carta, exibir seu efeito e ser aplicados a ela em cada duelo; não modificam a coleção nem decks comuns. A escolha, a melhoria e os poderes precisam ser salvos junto com a campanha.

