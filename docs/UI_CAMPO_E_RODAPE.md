# Campo ampliado e rodapé do duelo

O campo deixa de reservar duas faixas horizontais para os castelos. As cinco posições de cada lado passam a dividir a largura disponível e a crescer em altura com a janela. O mínimo da carta em campo sobe de 176 para 224 unidades; na resolução padrão ela pode chegar a cerca de 256 unidades. Mensagens e ações ficam na mesma faixa central, com texto que se ajusta ao espaço.

O rodapé reúne três áreas: vida e botão do seu castelo à esquerda, mão do jogador no centro, reservas de mana à direita. O castelo da IA fica centralizado acima da fileira adversária, com a identificação IA — facção no canto superior esquerdo; a mana da IA aparece acima da sua no painel direito. Castelos ampliados mostram somente o número da vida atual, sem barra de HP. A mana mantém atual/máxima e gemas. Os contadores de cartas da IA ficam no canto superior esquerdo; os seus aparecem no título da mão. Os castelos continuam alvos para ataques, cura e efeitos, respeitando Bloqueio. As cartas da mão são jogadas por clique, sem botões abaixo delas. A engrenagem e Esc abrem as opções do combate.

Chamado, Disparada e bônus recebido de Aura não geram marcadores no campo. A fonte da Aura mantém o próprio ícone; os beneficiados mostram somente os atributos alterados. Habilidades e efeitos persistentes continuam visíveis, inclusive cargas esgotadas que vão recarregar, e habilidades ativáveis temporariamente indisponíveis.

`tests/test_battle_footer.gd` verifica uma mão de oito cartas, limites do rodapé, tamanho das cartas, orientação vida/esquerda e mana/direita, estados de seleção de ataque/cura e castelos envenenados. `tests/test_field_ability_icons.gd` confere os marcadores persistentes.
