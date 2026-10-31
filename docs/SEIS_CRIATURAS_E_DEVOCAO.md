# Campo de seis e Devoção

- **Campo:** até seis criaturas por jogador, tanto por carta da mão quanto por invocações geradas. `DuelMatch.MAX_BOARD` centraliza o limite; o tabuleiro exibe seis vagas e a IA respeita o mesmo valor.
- **Castelos:** a arte preenche uma região horizontal, com recorte proporcional da imagem original. O número de vida fica à direita, sem barra nem denominador. Os botões continuam válidos para ataque direto, cura e Reconstrução.
- **Guardião da Aurora:** custo 4, 2/5, Vigor e Bloqueio 3; não possui Cura.
- **Editor:** primeiro clique na lista direita localiza e destaca a carta; segundo clique na mesma linha remove uma cópia. Mudar a linha troca a seleção. Na biblioteca, o primeiro clique seleciona; segundo clique ou duplo clique abre. Espaço vazio abre a escolha de classe. Os botões laterais continuam funcionando.

## Devota do Alvorecer

Clérigo de custo 3, 1/4, **Cura 1** (0 mana + esgotar) e **Devoção 1**. Cada Cura aliada que recuperar vida de uma criatura aliada ou do próprio castelo, ou causar dano a um Morto-vivo, dá +1/+1 permanente, incluindo à própria Devota. O valor de vida recuperada não multiplica o gatilho; curas que restauram zero não contam. Reparos de Reconstrução contam se restaurarem vida. Ganho de vida máxima/atual por Chamado, Cultivo ou Colheita é bônus de atributos e não é cura.

Apenas as Devotas do lado que usou a Cura respondem à recuperação de vida aliada ou ao dano efetivo em um Morto-vivo. Os bônus não são curas e não criam ciclos. O atributo `devotion` e o ícone correspondente estão disponíveis no CardData e no card reduzido. Multidão só copia neutros aliados; portanto não herda a habilidade desta Clériga. Um eventual neutro que tenha Devoção pode servir de fonte normalmente.

## Resolução

Base 1920×1080, proporção 16:9, tela cheia por padrão. F11 e o menu alternam para janela de até 1600×900, ajustada ao espaço do monitor. A resolução base permanece e o conteúdo escala proporcionalmente. Biblioteca e coleção usam cinco colunas na base Full HD. O campo e a mão cheia foram verificados nessa resolução.

## Validação

`test_six_field_devotion.gd` cobre sexta/sétima vaga, invocação gerada, IA, Devoção nas curas aliadas, cura zero, ausência de gatilhos por bônus, restrição de Multidão, cliques reais na lista/biblioteca e castelos largos. `test_peasant_uprising.gd` confirma que habilidades de aliados de classe e de inimigos são ignoradas. `test_full_hd_layout.gd` verifica encaixe das telas; o F11 foi verificado com o renderizador de janela.

Curas também removem todo o Veneno. Um alvo envenenado com vida cheia é válido para a limpeza; a limpeza sem recuperação não ativa Devoção. A própria Cura 1 da Devota pode ativar sua Devoção se recuperar vida.
