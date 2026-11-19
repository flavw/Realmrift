# Da Vila à Fenda — ponte, rio e mapa

A aventura agora tem 14 etapas: seis duelos comuns, o dragão final, a travessia obrigatória, um encontro de sorte/revés, duas etapas com loja, o poder intermediário e dois encontros de reforço antes do chefe. Os duelos opcionais de bandidos e mímico continuam possíveis. A dificuldade dos decks inimigos acompanha o número de duelos, e não o índice bruto da etapa.

## Ponte e rio

O nodo da ponte foi posicionado sobre a ponte na nova arte, com o vau como alternativa abaixo dela. A tela do encontro tem uma ilustração própria dos bandidos cobrando o pedágio. Pagar todo o ouro mantém a recuperação de 10% da vida; lutar mantém o prêmio extra. Sem ouro, o pagamento fica indisponível.

O desvio pelo rio é decidido apenas depois do clique, por um único sorteio inteiro de 0 a 99:

- 0–49: contratempo. Perde 1–2 ouro ou até 15% da vida máxima, arredondado para cima. A perda de ouro é limitada ao disponível e o dano não mata.
- 50–74: um companheiro. Escolha entre Peixe da Correnteza e Tartaruga do Remanso.
- 75–99: tesouro. Recebe 4–6 ouro e um item, aplicado a uma das três cartas oferecidas do deck.

A resolução não pode ser repetida para sortear outro resultado ou duplicar a recompensa. Resultado, recrutamento, item e posição do mapa são salvos pelo sistema normal da expedição.

## Criaturas sem facção

| Carta | Mana | Ataque/vida | Habilidade |
|---|---:|---:|---|
| Peixe da Correnteza | 1 | 1/1 | Matilha 1 |
| Tartaruga do Remanso | 2 | 0/4 | Bloqueio 1 |

Ambas são Feras exclusivas da aventura. Podem integrar o deck da expedição e receber itens que beneficiam todas as cópias. Não aparecem na coleção, no draft inicial, nos decks comuns nem no multiplayer. `Faction.UNALIGNED` é uma categoria técnica sem facção; não é uma nova origem selecionável.

## Mapa e serviços

A arte ampliada oferece mais terreno, duas caravanas e rotas irregulares. O mapa ocupa 3240×1080 unidades, com nodos em posições assimétricas e caminhos curvos. Ponte, vau e lojas foram alinhados aos marcos da ilustração. É possível arrastar horizontal e verticalmente; o mapa acompanha a etapa e o botão Localizar caminho recentra as escolhas disponíveis. A exploração continua iluminando o cenário progressivamente.

Há exatamente dois nodos de loja, nas etapas 4 e 9. Ambos podem ser alcançados na mesma expedição; a curandeira permanece como alternativa. O estoque e a oferta especial são renovados entre lojas. As oito ofertas comuns são selecionadas por facção e exibidas em duas fileiras de quatro. O preço aparece sobre a carta, com uma moeda. Os dois reforços finais continuam oferecendo poder/item ou cura.

Cartas de 0 a 2 mana custam 1 ouro. De 3 a 4 mana, custam 2 ouro. A partir de 5 mana, custam 3 ouro. A oferta com equipamento acrescenta 2 ouro ao preço da carta.

## Verificação

`tests/test_adventure_river_polish.gd` verifica a divisão exata de probabilidades, resolução única, recrutamento, Matilha, isolamento do duelo comum, recompensa de item, duas lojas, conexões e salvamento com item na criatura exclusiva. Os testes de progressão, encontros, loja, fazenda e arraste cobrem os fluxos existentes.

O simulador usa o estoque e os preços reais das lojas. O relatório em `docs/SIMULACAO_AVENTURA.md` registra as tentativas até o dragão, resolvidas pelo motor de combate.
