# Realmrift — Duelo de Cartas

Jogo de cartas de fantasia em Godot, com duelos contra IA e construção de decks. Projeto em desenvolvimento; PvP planejado.

Os antigos Neutros agora são a facção **Aldeia**, complemento de Vanguarda, Arcano, Submundo, Luminares e Selvagem. **Ermos** é o complemento da Ruína e da Necrópole, com Lobo da Noite e Zumbi Serviçal. **Necrópole** reúne Necromante das Cinzas, Necromante do Véu e Sentinela da Cripta. Ruína e Necrópole não aceitam Aldeia. Veja [Ermos e transferências](docs/ERMOS.md) e [Aldeia e Necrópole](docs/ALDEOES_E_NECROPOLE.md).

A coleção reúne criaturas e magias de diferentes facções e cartas aldeãs. Consulte o [manual](MANUAL.txt) para as regras atuais.

## Como jogar

1. Clone ou baixe este repositório.
2. Importe `project.godot` no Godot 4.7 e aguarde a importação dos recursos.
3. Pressione F5 para abrir a tela inicial. Escolha Jogar contra IA, Meus decks ou Como jogar.

Enter, Enter do teclado numérico ou numpad 0 passa o turno. Selecione uma criatura e clique no alvo permitido. Passe o mouse sobre uma carta para ver sua versão completa. O botão Regras abre o [manual](MANUAL.txt).

Facções: Vanguarda (**Vanguard**), Arcano (**Arcane**), Aldeia (**Village**), Luminares (**Luminaries**), Submundo (**Underworld**), Ruína, Selvagem, Necrópole (**Necropolis**) e Ermos (**Wastes**).

## Regras e recursos

- Primeiro jogador sorteado; mão inicial de 3 cartas para quem começa e 4 para o segundo. Uma troca grátis das cartas escolhidas antes da compra normal do turno.
- Vigor usa o maior valor entre ataque e vida atual tanto no ataque físico quanto no contra-ataque. Veneno acumula, causa dano no fim do turno do dono do alvo, ignora Armadura e termina completamente após esse dano.
- Castelos com 20 de vida; mana cresce até 10; campo com até seis criaturas e mão com até sete cartas.
- Dez espaços para decks de 22 cartas, com no máximo duas cópias por carta (uma para lendárias). Cada deck usa uma facção e apenas complementos compatíveis. Aldeia também pode jogar sozinha. A aventura permite recrutar de qualquer facção.
- Armadura reduz cada dano físico, incluindo contra-ataques. Magia ignora armadura e não provoca contra-ataque.
- Bloqueio N exige que os primeiros N ataques físicos tenham uma criatura bloqueadora como alvo. Recupera somente uma carga no início do turno do dono, até o máximo. Voo ignora essa restrição de alvo e reduz em 1 o dano de ataques físicos recebidos ao defender.
- Disparada permite atacar no turno de entrada. Fúria do Lobo custa uma mana, aumenta seu ataque permanentemente, não esgota e pode ser usada uma vez por turno.
- Fazendeiro ganha uma vida atual e máxima no início do turno do dono. Clériga cura dois de vida de um aliado ou do castelo por uma mana e esgotamento.
- Animações de ataque, magia, morte e vitória; seis efeitos sonoros originais; botão para ligar/desligar o som.

## Organização

| Pasta ou arquivo | Conteúdo |
| --- | --- |
| `assets/art/` | As ilustrações de criaturas e magias usadas pelo jogo, sem versões antigas duplicadas |
| `assets/ui/` | Tabuleiro, molduras, ícones e efeitos visuais |
| `assets/audio/` | Seis sons usados na partida |
| `assets/fonts/` | Recurso SystemFont para títulos, usando fontes instaladas no sistema |
| `cards/` | Recursos CardData: atributos, habilidades, arte e enquadramento |
| `scripts/` | Regras, IA, interface, editor de decks e animações |
| `docs/art-prompts/` | Prompts das artes geradas com IA, separados dos recursos do jogo |
| `tests/` | Verificações das regras, decks, interface e apresentação |
| `tools/` | Scripts Python que recriam os sons sintetizados |
| `CARD_MODEL.md` | Instruções para editar as cartas no Godot |
| `MANUAL.txt` | Manual usado também pelo botão Regras |

`start_menu.tscn` é a tela inicial com título, jogar contra IA, editor de decks, regras e sair. PvP aparece como opção futura desabilitada. `main.tscn` inicia a partida diretamente e `deck_editor.tscn` abre o editor. O botão Início do duelo retorna à tela inicial. `card_model.tscn` define a carta completa e `field_card.tscn` a versão reduzida em campo. As galerias `card_gallery.tscn`, `expansion_gallery.tscn` e `support_gallery.tscn` permitem inspecionar as cartas no editor com F6.

A arte é compartilhada entre as duas apresentações. Artwork Zoom e Artwork Focus ajustam o enquadramento da carta completa. Ícones de Armadura e Bloqueio aparecem somente na versão reduzida, sem painel de fundo. A arte escurece e Zzzz flutua no canto superior direito quando a criatura está esgotada.

Os decks são salvos em `user://decks.json`. Salvar aceita um espaço vazio ou um deck completo de 22 cartas. Jogar exige um deck completo. Rascunhos são guardados enquanto o gerenciador de decks fica aberto; salve para persistir entre sessões. Caches `.godot/`, dados locais `.local/`, credenciais e executáveis exportados ficam fora do Git.

## Verificação

Execute a partir da pasta do projeto, usando o executável do Godot no PATH:

```sh
godot --headless --editor --path . --quit
godot --headless --path . --script tests/test_match.gd --quit-after 180
godot --headless --path . --script tests/test_abilities.gd --quit-after 180
godot --headless --path . --script tests/test_expansion.gd --quit-after 180
godot --headless --path . --script tests/test_support.gd --quit-after 180
```

`test_match.gd` verifica combate e 20 partidas completas. `test_abilities.gd`, `test_expansion.gd` e `test_support.gd` cobrem habilidades e cartas. `test_deck_editor.gd` verifica os nove espaços de decks. Os testes de interface e apresentação também ficam em `tests/`.

Todos os arquivos necessários para abrir e continuar o projeto estão neste repositório. As artes foram geradas com IA; os prompts estão em `docs/art-prompts/`. Os sons são sintetizados pelos scripts de `tools/`.

## Visual e trabalho local

A carta completa usa gema de mana de 40 px, nome de 20–24 px na fonte At Dawn, borda fina e degradê suave na base para as habilidades. A faixa do título e o pergaminho foram removidos para dar espaço à arte. Os atributos ficam somente em texto no canto inferior direito. Os ícones gerados de esgotar e fúria aparecem nas habilidades e ações; Bloqueio usa um rótulo textual na versão reduzida. Os prompts estão em `docs/art-prompts/minimal-icons.md`.

A pasta local do projeto se chama `Realmrift`. Atualizações do GitHub exigem pedido explícito do usuário; consulte `AGENTS.md`.

`tests/test_start_menu.gd` verifica o título, decks, regras e navegação entre início e duelo.

## Habilidades resumidas e ajuda lateral

As cartas exibem palavras-chave e valores, como Fúria 1, Bloqueio 1 e Disparo Arcano 1. O círculo claro numerado representa custo de mana e a ampulheta representa esgotar. Disparo Arcano usa o dano mágico existente: ignora Armadura, atinge uma criatura inimiga e não causa contra-ataque.

Ao passar o mouse, uma caixa ao lado da carta explica as habilidades. Funciona no campo com a prévia ampliada, na mão, nas galerias e no editor de decks. A caixa muda de lado perto da borda da tela e não captura cliques. A faixa inferior usa degradê translúcido com transição suave.

Os resumos e explicações padrão são produzidos por `CardData.ability_entries()`. No Inspector, Ability Name Override e Ability Help Override permitem personalizar os textos da primeira habilidade sem alterar suas regras. Ability Text continua disponível como descrição de fallback para uma habilidade não catalogada. Novas mecânicas exigem implementação na lógica da partida. Os prompts de custo e Disparo Arcano originais ficam em `docs/art-prompts/cost-and-arcane.md`.

`tests/test_card_hints.gd` verifica o hover, fechamento da caixa, posição nas bordas, custo e cargas atuais de Bloqueio.

## Estados visuais e arte ampliada

Ataque e vida têm cores independentes: bônus em verde, reduções e dano em vermelho. A vida ferida usa a vida máxima atual como referência e tem prioridade sobre bônus de vida máxima. A cor da facção aparece na borda fina; não há escudos decorativos.

Habilidades ativáveis ganham um ponto verde quando disponíveis. Ficam apagadas quando indisponíveis; a ajuda lateral explica se falta mana, se a criatura está esgotada, se não há alvo válido, se pertence ao adversário ou se é preciso esperar o turno. Fúria continua disponível em criaturas esgotadas se houver mana. Habilidades de cartas na mão exigem invocação primeiro; o editor mostra os símbolos sem simular disponibilidade.

Prévia e ajuda aguardam 250 ms de hover; sair ou trocar de carta cancela a abertura pendente. O custo superior usa gema azul clara de 40 px e número de 26 px com contorno; o custo de habilidade usa gema azul clara de 28 px e número de 20 px.

Botão direito em uma carta da mão, campo, galeria ou editor abre a ilustração original grande, sem recorte ou UI. Clique esquerdo/direito ou Esc fecha. A visualização bloqueia seleção, ataques e atalhos de turno. A ampulheta indica esgotar; a antiga lua está preservada em assets/ui/moon-reserved.webp para uma habilidade futura. Prompt em docs/art-prompts/hourglass.md.

`tests/test_card_polish.gd` verifica cores, disponibilidade, atraso, botão direito, arte sem textos e entrada modal.

## Composição das cartas

Nome e linhas de habilidades ficam centralizados no eixo da carta. Os ícones de custo e esgotar acompanham a mesma linha vertical do texto. O degradê inferior inicia transparente e termina com opacidade de 78%, preservando mais da ilustração. Ataque/vida usam posições explícitas e uma linha de base compartilhada; o grupo permanece alinhado no canto inferior direito, tanto no modelo completo quanto na versão reduzida. `tests/test_card_alignment.gd` verifica os alinhamentos e o degradê.

Os nomes usam a fonte At Dawn Regular fornecida pelo usuário, incorporada em `assets/fonts/At-Dawn-Regular.otf`; não é necessário instalar a fonte no sistema. O tamanho se ajusta entre 20 e 24 px para nomes longos. Os nomes usam sombra sutil, sem contorno pesado. Vanguarda, Arcano, Aldeão, Submundo e Luminares são identificados pela borda fina vermelha, roxa, cinza, verde e branca/dourada. Ataque/vida continuam coloridos por bônus/dano, mas sem escudos.

## Expansão de arquétipos e magias

A coleção tem 46 cartas: 37 criaturas e nove magias. A galeria inclui também o Carniçal invocado, totalizando 47 recursos. Veja [a lista com atributos e regras](docs/EXPANSAO_ARQUETIPOS.md). Amplificar aumenta dano mágico aliado enquanto a fonte estiver em campo. Magias usam clique na carta + escolha de alvo, são consumidas após uso válido e não ocupam espaço no campo. O editor identifica o tipo e a facção das cartas. Os decks iniciais incluem cartas novas; decks salvos são preservados.

A restrição futura de uma facção + aldeões não é imposta ainda. Mana e esgotar agora usam SVGs simples: círculo claro com número preto em negrito e ampulheta. O nome foi elevado para se alinhar visualmente ao custo. As 12 novas artes ficam em assets/art/ e seus prompts em docs/art-prompts/archetype-expansion.md.

As regras detalhadas de Vigor, Veneno, Descarga Condutora e mulligan estão em [docs/REGRAS_VIGOR_VENENO.md](docs/REGRAS_VIGOR_VENENO.md).

Simulação anterior a esta expansão: [15 partidas de Guerreiro contra as outras facções](docs/SIMULACAO_GUERREIRO_15_PARTIDAS.md), já com Guardião da Aurora recebendo Bloqueio 1. Custo de mana usa arte PNG de gema azul clara, mantendo os números editáveis.

Atualização: Vigor passa a funcionar no ataque e na defesa. Disparo Arcano 2 da Feiticeira/Canalista custa 1 mana + esgotar. Veja a [segunda rodada de 15 partidas](docs/SIMULACAO_GUERREIRO_RODADA_2.md).


Chamado: [Arauto da Lua](cards/moon_herald.tres), aldeão de 2 mana e 1/2. Ao entrar pela mão, outro Humano aliado escolhido ganha +1/+1 permanente; sem alvo válido entra sem bônus. O alvo é confirmado antes do gasto. A gema é menor (40 px no topo, 28 px nas habilidades) e aparece também na lista do editor. Agora o editor e a validação de partida permitem somente uma facção + aldeões por deck; drafts só de aldeões também são válidos. Nesta atualização, os decks antigos são substituídos uma vez pelas novas receitas. Edições futuras são preservadas, respeitando uma facção + aldeões.

Chamado é um gatilho genérico de entrada pela mão; o efeito é definido por carta. Arauto da Lua usa `BUFF_ALLY` e concede +1 de ataque, +1 de vida atual e +1 de vida máxima a outro Humano aliado. O resumo é **Chamado — Humano: +1/+1**.


Quatro novos Chamados por facção: Ferreiro da Muralha (Armadura +1), Conjuradora do Éter (invoca Familiar Rúnico), Alquimista das Brumas (Veneno 2 em inimigo) e Oráculo da Aurora (+2 vida a aliado, com Vigor). Os decks antigos foram substituídos por novas listas; os nove espaços permanecem e cada novo deck começa pela escolha da facção base. Detalhes em [CHAMADOS_POR_FACÇÃO.md](docs/CHAMADOS_POR_CLASSE.md).

O editor agora tem nove espaços em três linhas: os três decks existentes, Aurora Vital no quarto e os espaços 5/6 vazios. A migração de versão 2 para 3 preserva os decks e o ativo; espaços vazios são persistidos e não podem iniciar partida.

A tela **Meus decks** agora separa a seleção da montagem de cartas. Cada deck tem capa personalizável a partir de uma carta de sua lista; Na edição, o campo de nome e **Alterar capa** personalizam o rascunho; salvar o deck grava as alterações. O formato versão 4 preserva cartas/nomes/ativo anteriores e adiciona o campo `cover` por espaço. Veja [BIBLIOTECA_DE_DECKS.md](docs/BIBLIOTECA_DE_DECKS.md).

Meus decks agora usa capas verticais 3:4 à esquerda e um painel único à direita com Editar cartas e Jogar. A montagem exibe a curva de mana por custo. Clicar em uma capa apenas seleciona o deck. Pequenos símbolos SVG substituem os rótulos de facção do deck, incluindo Aldeão para listas somente de aldeões. A composição de decks e os dados salvos foram preservados.


Em uma atualização anterior os decks passaram a **20 cartas**, até duas cópias. Os cinco decks iniciais e decks salvos foram ampliados, mantendo cartas, nomes, capas, seleção ativa e espaços vazios. **Reconstrução da Aldeia** (magia aldeã, 2 mana) restaura 2 do seu castelo ou de uma Muralha aliada e compra uma carta se todas as suas criaturas em campo forem aldeãs. Pode ser usada em qualquer facção; campo vazio também ativa a compra. [Regras e migração](docs/DECKS_20_RECONSTRUCAO.md).

O editor agora tem filtros por facção e tipo, busca por nome/habilidade e localização da carta na coleção com botão direito na lista. Veja docs/FACÇÃO_BASE_E_CLIQUES.md.

Muralha da Aldeia: aldeão de 4 mana, 0/4, Armadura 1, Bloqueio 4 e habilidade Muralha. Cards maiores no editor, destaque mais forte e Vigor sem converter vida no ataque exibido. [Regras e validação](docs/MURALHA_E_EDITOR.md).

Reconstrução pede alvo se houver Muralhas aliadas; caso contrário, é automática no castelo. Bloqueio tem aviso visual/sonoro para alvos protegidos; cura e aplicação/dano de Veneno têm efeitos próprios. Os dez sons usam Ogg Vorbis. Para regenerar os sons sintetizados, use os scripts de tools/ com Python e ffmpeg no PATH.

Novos decks começam com a escolha da facção base ou Aldeia. A coleção mostra somente cartas compatíveis. Clique para adicionar na coleção e remover na lista, sem botões +/−; adicionar usa uma animação curta. A base é preservada no formato de decks versão 7.

Cada jogador faz um mulligan; quem joga em segundo recebe uma carta inicial extra e 1 mana temporária no primeiro turno. Fazendeiro é 1/3. Bola de Fogo é uma magia de Mago de 6 mana que causa 3 de dano mágico a todas as criaturas inimigas. Artes incluem dia e noite.

Revisão atual: editor sem sugestões prontas, decks atualizados e 50 partidas contra Guerreiro. [Resultados e composições](docs/SIMULACAO_DECKS_50_PARTIDAS.md).

Guardião Arcano: Guerreiro 3 mana, 2/3, Resistência a Magia 1. Anula uma ocorrência de dano mágico por carga e recupera uma no início do próprio turno. Bola de Fogo substitui o nome e identificador da antiga magia de dano em área. [Regras e validação](docs/ANTIMAGIC_E_BOLA_DE_FOGO.md).

[Ícones de habilidades no campo](docs/ICONES_NO_CAMPO.md): símbolos compactos, valores/cargas atuais e estados de disponibilidade.

[Controles do combate](docs/CONTROLES_COMBATE.md): clique na mão, aviso de ações restantes, castelo inimigo central e menu Esc/engrenagem.

[Primeira lendária: Levante da Aldeia](docs/LEVANTE_DA_ALDEIA.md), aldeã de 5 mana, */*, com herança dinâmica de habilidades aldeãs aliadas sem Chamados. Lendárias têm limite de uma cópia por deck. Ladina Relâmpago agora é 3/2.

[Boi da Colheita e revisão das regras da aldeia](docs/COLHEITA_E_REPARO.md): Colheita por ativação de Cultivo aliado, reparo de Muralhas, castelos imunes a Veneno e suporte para outros aliados de qualquer facção.

[Atacar com todos, artes de castelo e trilha](docs/ATAQUE_EM_GRUPO_E_TRILHA.md). O menu usa “Moonlit Tavern”, de flavioj, criada com o Suno, e os combates usam “Chariots Of War”, de Aakash Gandhi; ambas respeitam o controle de som e o crédito aparece no menu.

Layout 1920×1080 em tela cheia, com F11 para modo janela. Campo com seis criaturas por lado e [Devota do Alvorecer, novos cliques e revisão da herança aldeã](docs/SEIS_CRIATURAS_E_DEVOCAO.md).

Curas agora removem Veneno, inclusive em criaturas com vida cheia. Devota do Alvorecer: 3 mana, 1/4, Devoção 1 e Cura 1 por 0 mana + esgotar. Limpar apenas Veneno não ativa Devoção.

Necromante do Véu (4 mana, 2/4, Humana da Necrópole) possui Chamado condicional de Carniçal 2/2. Cura agora causa dano mágico em Mortos-vivos. Veja [regras de Necromancia](docs/NECROMANCIA.md).

A facção Ruína mantém o tipo Monstro separado da facção. Clamor da Ruína (3 mana) dá +2 de ataque aos Monstros aliados em campo até o fim do turno atual. Veja [regras e validação](docs/CLAMOR_DA_HORDA.md).

Goblin agora é 1 mana 1/1 com Disparada. Fungo da Ninhada (aldeão Monstro, 3 mana, 0/3) fortalece a vida de Monstros com Esporos 1; Troll do Brejo (Ruína Monstro, 4 mana, 3/5) tem Regeneração 1. Monstros aldeões ficam restritos à Ruína ou decks só de aldeões. Veja [regras e validação](docs/ESPOROS_E_REGENERACAO.md).

Créditos de criação, fonte e música: [CREDITS.md](CREDITS.md).

## Aventura — primeira versão jogável

No menu inicial, escolha **Modo Aventura** e abra a aventura **Da Vila à Fenda**. Selecione uma facção, monte 15 cartas em escolhas de três e escolha seu primeiro poder. A jornada oferece sete duelos (incluindo o chefe), cinco etapas de encontros, incluindo dois reforços finais, loja, segundo poder no meio do caminho e melhorias após os encontros. Recrutas de outras facções são permitidos somente na aventura. Uma derrota encerra a expedição.

A expedição atual fica guardada durante a sessão do jogo; fechar o jogo perde a expedição, mas preserva o nível, o XP e as melhorias permanentes do perfil. Itens agora são escolhidos em nodos próprios e melhoram somente uma cópia da carta selecionada durante a campanha. O chefe final é o Dragão Negro da Fenda, uma criatura única com arte própria, sem castelo. A interface é funcional e o balanceamento é inicial.

Verificações: `tests/test_adventure_state.gd`, `tests/test_adventure_combat.gd` e `tests/test_adventure_flow.gd`. O último percorre as escolhas e simula os resultados dos confrontos para verificar a progressão; não substitui uma campanha jogada manualmente.


### Mapa, economia e recuperação

A jornada tem nodos circulares ligados por caminhos, com retratos de criaturas dos decks inimigos. Os inimigos começam com listas de 15 cartas de baixo custo/atributos, passam por listas de 18 e 20 e chegam aos decks padrão de 22; o chefe mantém suas cartas exclusivas. O percurso é sorteado uma vez por expedição.

O jogador começa com 1 ouro e recebe 1 por vitória, além da escolha de uma carta (Tesouro de Guerra acrescenta seu bônus). A vida é persistente: cada vitória recupera 20% da vida máxima, arredondados para cima, até o máximo. Após a segunda, quarta e sexta lutas, a rota oferece uma curandeira em alternativa ao encontro de tesouro ou loja: cura grátis de 25% do máximo ou cura total por ouro igual a 10% do máximo, sempre arredondando para cima. O tesouro dá uma rolagem de 1d6 ouro, realizada uma única vez ao entrar no nodo.

Mana temporária aparece como gemas douradas na mesma barra de reservas e continua sendo gasta antes da mana normal, incluindo a prévia do custo ao passar o mouse.


### Itens, ponte dos bandidos e baús

Nodos de itens oferecem três cartas do deck atual para aplicar um item sorteado: Amuleto vital (+2 vida), Lâmina afiada (+1 ataque) ou Broquel de ferro (+1 Armadura). Se não houver três criaturas distintas, o encontro oferece um Talismã de mana (-1 custo, mínimo zero) e permite escolher também magias. O aprimoramento vale somente para uma cópia; as outras permanecem iguais. Ícones aparecem à direita das cartas na mão e no campo e a ajuda de habilidades descreve os bônus. Essas versões de cartas ficam fora da coleção e dos decks do duelo comum.

A ponte oferece pagar todo o ouro e curar 10% do máximo (arredondado para cima), enfrentar um deck mediano de bandidos por +2 ouro e um item extras além da recompensa normal, ou fugir. Fugir tem 50% de chance de causar 10% de dano não letal e, independentemente, 50% de conceder +1 ouro ou +1 vida máxima.

Baús têm 50% de chance de revelar um Mímico Devorador; nos demais casos, dividem igualmente a chance entre item e 1d6 ouro. O resultado é resolvido uma única vez. O mímico tem 1 de ataque, 14 de vida, Fúria 1 e Armadura 1, sem Regeneração ou Bloqueio. Ele aparece maior no centro do campo, sem castelo inimigo, com a condição de vitória escrita na tela. Ataques automáticos do jogador apontam para ele. Sua mana começa em zero no primeiro turno dele e cresce até três, com três espaços na barra. Sua mão fixa contém três Raízes Enredantes e dois Clamores da Ruína. O adversário não compra cartas e não sofre fadiga nesse encontro. A criatura deve ser derrotada: destruir o castelo inimigo não vence a luta; o jogador ainda perde se sua própria vida chegar a zero. Vencer o mímico concede a recompensa normal e +3 ouro e um item extras: 4 ouro no total, uma carta e um aprimoramento garantido (mais o bônus de Tesouro de Guerra, se houver).

O mapa abre até quatro rotas em algumas etapas e volta a duas entre as seções finais. Somente nodos ligados ao caminho anterior podem ser escolhidos. As artes novas e seus prompts ficam em `assets/ui/adventure-chest.webp`, `assets/art/adventure-mimic.webp` e `docs/art-prompts/adventure-chest-mimic.md`.




### Nível permanente do aventureiro

O perfil começa no nível 1, com zero XP. Cada vitória em combate (inclusive bandidos e mímicos) concede 1 XP; vencer o chefe final concede 3 XP no total. Derrotas e novas expedições não removem o XP já obtido. O perfil é salvo em `user://adventure_profile.json`, separado dos decks comuns e da expedição em andamento.

Os primeiros marcos acumulados são nível 2 em 5 XP, nível 3 em 13 XP, nível 4 em 25 XP e nível 5 em 42 XP. O custo do próximo nível cresce em cada etapa. Nos níveis comuns, o jogador escolhe uma entre duas melhorias permanentes: +1 vida máxima inicial, +1 ouro inicial, +1 vida em uma criatura aleatória do deck ou +1 ataque em uma criatura aleatória do deck. As escolhas são salvas e se acumulam para as expedições seguintes. Os bônus de criatura são aplicados depois das 15 escolhas iniciais, em uma cópia aleatória, uma vez por melhoria desbloqueada. Se não houver criaturas, o bônus fica pendente até a primeira criatura ser recrutada.

O nível 3 desbloqueia automaticamente uma vida extra por expedição e substitui a escolha de melhoria menor. Ao perder um combate, é possível consumi-la para repetir o mesmo encontro com a vida que havia antes da luta e o mesmo deck. A segunda derrota encerra a expedição. A vida extra é renovada na expedição seguinte; ao atingir o nível 3 durante uma expedição, ela já fica disponível. Os bônus comuns escolhidos ao subir de nível começam na próxima expedição.

Voltar ao menu durante um duelo preserva a partida em memória; retomar não reinicia o combate nem evita o consumo de vida extra após uma derrota.

Verificação específica: `tests/test_adventure_levels.gd` cobre XP, persistência, derrotas, curva de nível, escolhas, melhorias por cópia e vida extra.


### Dragão Negro, preparativos finais e nível 5

O 6º duelo usa um deck padrão completo de 22 cartas. Depois dele há duas etapas consecutivas de reforço, seguidas pelo chefe. A primeira oferece poder bônus, cura total grátis ou loja (com 3 ouro de apoio); a segunda oferece item ou cura total grátis. São rotas benéficas, sem bandidos ou mímicos nessas duas etapas. O mapa converge para um único nodo final de dragão. A aventura mantém sete combates fixos e pode ter até duas lutas opcionais adicionais (ponte e um baú-mímico).

Dragão Negro da Fenda: 3 de ataque, 24 de vida, Envenenar 2, Voo, Armadura 1 e Resistência a Magia 1. Não tem castelo, mão ou compras, nem sofre fadiga. Começa com zero mana no primeiro turno e cresce até quatro, com uma barra de quatro gemas. Sua representação central é maior que a do mímico. A vitória exige derrotar a criatura, e os ataques automáticos válidos do jogador têm ela como alvo.

- Sopro Venenoso 2: 3 mana e esgotar; aplica Veneno 2 a até três criaturas consecutivas do campo inimigo. A janela é ajustada nas bordas para incluir três criaturas quando possível. Resistência a Magia, imunidades e as regras de Veneno são respeitadas.
- Sopro Ácido 3: 4 mana e esgotar; causa 3 de dano mágico em até três criaturas consecutivas ou 6 de dano ao castelo. Os valores iniciais do ácido foram escolhidos para o primeiro balanceamento.

Ambos são habilidades mágicas reutilizáveis do dragão: exigem que esteja pronto e não tenha atacado no turno. Usar um sopro o esgota, impedindo ataque ou outro sopro naquele turno. A IA escolhe entre soprar e atacar. O nome público Guarda Arcana passou a Resistência a Magia; a propriedade interna `antimagic` é preservada por compatibilidade.

No nível 5 (42 XP acumulados), uma melhoria fixa libera um item inicial aleatório em cada expedição futura. Depois de montar as 15 cartas, o jogador escolhe qual de três cartas do deck recebe o item, antes da escolha de poder inicial. Esse aprimoramento não avança o mapa. Níveis 3 e 5 não oferecem melhorias menores; escolhas antigas desses níveis deixam de ser aplicadas. Os outros níveis continuam oferecendo duas alternativas.

Verificação específica: `tests/test_black_dragon.gd` cobre sopros, adjacência, custos e esgotamento, resistência, mana, sexto duelo, preparativos, marcos fixos e item inicial.

### Fazenda, introdução e retorno dos confrontos

A expedição começa com um texto contínuo em uma única tela, ilustrada por uma arte própria da partida da Vila do Vale. O texto apresenta o dom de recrutar aliados de outras facções e a missão de enfrentar o Dragão Negro.

A Fazenda do Vale é uma alternativa benéfica no meio do mapa, com a arte existente da Camponesa Generosa. O jogador pode recrutar gratuitamente uma entre três criaturas aldeãs elegíveis ou presentear a filha do fazendeiro com 2 ouro. O presente concede +1 vida atual e máxima a todas as suas criaturas no próximo combate, incluindo as invocadas durante a luta. Não altera permanentemente os cards. O bônus termina após esse confronto; se uma vida extra for usada para repetir a mesma luta, o bônus continua nela. A ajuda das cartas em combate descreve a bênção.

No encontro do baú, Ir embora sem abrir avança sem sortear o conteúdo nem conceder recompensa. Após uma vitória na aventura, o efeito sonoro existente de vitória toca em um reprodutor persistente, respeitando as opções de áudio, para continuar audível durante a mudança de cena.

Verificação: `tests/test_adventure_farm.gd` cobre as opções da fazenda, o bônus temporário, a introdução, o abandono do baú e a reprodução de áudio.


### Botas, mercador aprimorado e mapa ilustrado

Botas da Disparada concedem Disparada à cópia escolhida. Se ela já tiver Disparada, recebem +1 de ataque em vez de repetir a habilidade. O ícone das botas e a ajuda mostram o efeito aplicado. O item participa dos sorteios de itens, inclusive do item inicial e das ofertas do mercador.

Cada visita ao mercador mantém seis ofertas comuns de 3 ouro e uma oferta especial de 6 ouro: uma criatura já aprimorada com um item aleatório. A oferta especial respeita o limite de cópias e só pode ser comprada uma vez naquela loja; voltar à tela não sorteia outra. Preços e disponibilidade aparecem junto das cartas, e as versões aprimoradas são identificadas também na lista lateral.

O mapa tem um fundo panorâmico próprio, da Vila do Vale, fazendas e ponte, passando pelos bosques e ruínas, até as montanhas da fenda. Trilhas percorridas/disponíveis usam dourado, encontros benéficos têm bordas verdes e o chefe tem destaque vermelho quando ainda está adiante. A tela ganhou títulos de fantasia, barra de XP e uma disposição própria para a oferta aprimorada do mercador.

Asset e prompt: `assets/ui/adventure-world-map.webp` e `docs/art-prompts/adventure-world-map.md`. Ícone vetorial: `assets/ui/item-boots.svg`. Verificação específica: `tests/test_adventure_merchant_items.gd`.


### Iluminação da viagem, presentes da fazenda e Valéria

O fundo do mapa começa com a vila iluminada e as regiões futuras escurecidas. A faixa iluminada avança a cada etapa, mantendo as áreas anteriores claras; ao chegar à fenda, todo o mapa está revelado. Os nodos e a navegação continuam visíveis e funcionais sobre a iluminação.

Na fazenda há três opções: conversar com os moradores, dar um presente de 2 ouro ou um grande presente de 4 ouro. Os efeitos e a arte do banquete só aparecem depois que o presente é pago. O de 2 ouro concede +1 vida atual e máxima às criaturas aliadas no próximo combate; o de 4 ouro concede o mesmo bônus em todos os combates restantes da expedição. Não é um bônus permanente do perfil. Os dois presentes são alternativas e não acumulam mais de +1 vida. A arte do banquete mantém a identidade da Camponesa Generosa. Artes e prompts: `assets/ui/adventure-opening.webp`, `assets/ui/adventure-farm-banquet.webp`, `docs/art-prompts/adventure-opening-and-banquet.md`.

Valéria, a Implacável: nova criatura Humana lendária da Vanguarda, custo 6, ataque/vida 5/4, Armadura 2 e Sangrar 3. Está na coleção, editor e galeria, e participa das ofertas elegíveis da aventura; não altera automaticamente os decks salvos. Usa as regras existentes de Sangramento e de lendárias (uma cópia por deck). O modelo visual identifica a raridade e a ajuda explica o limite. Arte em `assets/art/valeria_implacavel.webp`; prompt em `docs/art-prompts/valeria-implacavel.md`.

Verificações: `tests/test_adventure_reveal_banquet.gd` e `tests/test_valeria.gd`.
