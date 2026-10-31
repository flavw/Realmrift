# Decks em retrato, símbolos e painel de ações

- As seis capas ficam à esquerda, na proporção 3:4 (240 × 320), com mais espaço para a arte e sem botões dentro dos decks.
- Clicar em uma capa apenas seleciona o deck. A borda destaca a seleção; o selo ATIVO continua identificando qual deck será usado no jogo.
- Um único painel à direita mostra o selecionado e os três botões: Editar cartas/Criar deck, Capa e nome, Jogar. Espaços vazios não podem jogar.
- Símbolos pequenos substituem os rótulos de tipo "classe + neutros". Guerreiro usa espadas vermelhas, Mago varinha roxa, Ladino adaga verde, Clérigo sol dourado e Neutro um emblema circular cinza. O nome aparece no tooltip.
- Listas só com neutros recebem o símbolo Neutro; listas com uma classe e neutros mostram apenas o símbolo da classe. Espaços vazios não recebem símbolo. São apenas indicações visuais; o arquétipo neutro futuro não ganhou novas regras nesta atualização.
- Edição e personalização continuam em telas separadas. Nome, capa, cartas, deck ativo e seis espaços foram preservados.

Os símbolos são vetores SVG editáveis em `assets/ui/class-warrior.svg`, `class-mage.svg`, `class-rogue.svg`, `class-cleric.svg` e `class-neutral.svg`, reaproveitando o sistema nativo de ícones. Não houve nova geração de imagens raster.

Validação: proporção das capas, ausência de botões por deck, três ações à direita, seleção real por clique, símbolos das quatro classes e do Neutro, espaço vazio e transição de neutro para classe ao adicionar uma carta de classe. A imagem de demonstração com Aliança Livre não altera nenhum deck salvo do jogador.

GitHub não foi atualizado.
