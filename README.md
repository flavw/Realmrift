# Realmrift — Duelo de Cartas

Jogo de cartas de fantasia em Godot, com duelos contra IA e construção de decks. Projeto em desenvolvimento; PvP planejado.

As criaturas têm tipos próprios. A facção **Horda** possui Goblin Saqueador, Minotauro da Ruína e Lobisomem das Brumas, todos do tipo Monstro. Aceita neutros não humanos; Pacto Sombrio permite a exceção da Necromante humana. Zumbi Serviçal é um neutro de apoio do tipo Morto-vivo. Veja [tipos e regras de composição](docs/MONSTROS_E_TIPOS.md).

A coleção reúne criaturas e magias de diferentes classes e cartas neutras. Consulte o [manual](MANUAL.txt) para as regras atuais.

## Como jogar

1. Clone ou baixe este repositório.
2. Importe `project.godot` no Godot 4.7 e aguarde a importação dos recursos.
3. Pressione F5 para abrir a tela inicial. Escolha Jogar contra IA, Meus decks ou Como jogar.

Enter, Enter do teclado numérico ou numpad 0 passa o turno. Selecione uma criatura e clique no alvo permitido. Passe o mouse sobre uma carta para ver sua versão completa. O botão Regras abre o [manual](MANUAL.txt).

## Regras e recursos

- Primeiro jogador sorteado; mão inicial de 3 cartas para quem começa e 4 para o segundo. Uma troca grátis das cartas escolhidas antes da compra normal do turno.
- Vigor usa o maior valor entre ataque e vida atual tanto no ataque físico quanto no contra-ataque. Veneno acumula, causa dano no fim do turno do dono do alvo, ignora Armadura e termina completamente após esse dano.
- Castelos com 20 de vida; mana cresce até 10; campo com até seis criaturas e mão com até sete cartas.
- Nove espaços para decks de 22 cartas, com no máximo duas cópias por carta (uma para lendárias). Cada deck usa uma única classe + neutros.
- Armadura reduz cada dano físico, incluindo contra-ataques. Magia ignora armadura e não provoca contra-ataque.
- Bloqueio N exige que os primeiros N ataques físicos tenham uma criatura bloqueadora como alvo. Recupera somente uma carga no início do turno do dono, até o máximo. Voo ignora essa restrição de alvo e reduz em 1 o dano de ataques físicos recebidos ao defender.
- Arrancada permite atacar no turno de entrada. Fúria do Lobo custa uma mana, aumenta seu ataque permanentemente, não esgota e pode ser usada uma vez por turno.
- Fazendeiro ganha uma vida atual e máxima no início do turno do dono. Clériga cura dois de vida de um aliado ou do castelo por uma mana e esgotamento.
- Animações de ataque, magia, morte e vitória; seis efeitos sonoros originais; botão para ligar/desligar o som.

## Organização

| Pasta ou arquivo | Conteúdo |
| --- | --- |
| `assets/art/` | As ilustrações de criaturas e magias usadas pelo jogo, sem versões antigas duplicadas |
| `assets/ui/` | Tabuleiro, molduras, ícones e efeitos visuais |
| `assets/audio/` | Seis sons usados na partida |
| `assets/fonts/` | Recurso SystemFont para títulos, usando fontes instaladas no sistema |
| `cards/` | 38 recursos CardData: atributos, habilidades, arte e enquadramento |
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

Ataque e vida têm cores independentes: bônus em verde, reduções e dano em vermelho. A vida ferida usa a vida máxima atual como referência e tem prioridade sobre bônus de vida máxima. A cor da classe aparece na borda fina; não há escudos decorativos.

Habilidades ativáveis ganham um ponto verde quando disponíveis. Ficam apagadas quando indisponíveis; a ajuda lateral explica se falta mana, se a criatura está esgotada, se não há alvo válido, se pertence ao adversário ou se é preciso esperar o turno. Fúria continua disponível em criaturas esgotadas se houver mana. Habilidades de cartas na mão exigem invocação primeiro; o editor mostra os símbolos sem simular disponibilidade.

Prévia e ajuda aguardam 250 ms de hover; sair ou trocar de carta cancela a abertura pendente. O custo superior usa gema azul clara de 40 px e número de 26 px com contorno; o custo de habilidade usa gema azul clara de 28 px e número de 20 px.

Botão direito em uma carta da mão, campo, galeria ou editor abre a ilustração original grande, sem recorte ou UI. Clique esquerdo/direito ou Esc fecha. A visualização bloqueia seleção, ataques e atalhos de turno. A ampulheta indica esgotar; a antiga lua está preservada em assets/ui/moon-reserved.webp para uma habilidade futura. Prompt em docs/art-prompts/hourglass.md.

`tests/test_card_polish.gd` verifica cores, disponibilidade, atraso, botão direito, arte sem textos e entrada modal.

## Composição das cartas

Nome e linhas de habilidades ficam centralizados no eixo da carta. Os ícones de custo e esgotar acompanham a mesma linha vertical do texto. O degradê inferior inicia transparente e termina com opacidade de 78%, preservando mais da ilustração. Ataque/vida usam posições explícitas e uma linha de base compartilhada; o grupo permanece alinhado no canto inferior direito, tanto no modelo completo quanto na versão reduzida. `tests/test_card_alignment.gd` verifica os alinhamentos e o degradê.

Os nomes usam a fonte At Dawn Regular fornecida pelo usuário, incorporada em `assets/fonts/At-Dawn-Regular.otf`; não é necessário instalar a fonte no sistema. O tamanho se ajusta entre 20 e 24 px para nomes longos. Os nomes usam sombra sutil, sem contorno pesado. Guerreiro, mago, neutro, ladino e clérigo são identificados pela borda fina vermelha, roxa, cinza, verde e branca/dourada. Ataque/vida continuam coloridos por bônus/dano, mas sem escudos.

## Expansão de arquétipos e magias

A coleção tem 46 cartas: 37 criaturas e nove magias. A galeria inclui também o Carniçal invocado, totalizando 47 recursos. Veja [a lista com atributos e regras](docs/EXPANSAO_ARQUETIPOS.md). Amplificar aumenta dano mágico aliado enquanto a fonte estiver em campo. Magias usam clique na carta + escolha de alvo, são consumidas após uso válido e não ocupam espaço no campo. O editor identifica o tipo e a classe das cartas. Os decks iniciais incluem cartas novas; decks salvos são preservados.

A restrição futura de uma classe + neutros não é imposta ainda. Mana e esgotar agora usam SVGs simples: círculo claro com número preto em negrito e ampulheta. O nome foi elevado para se alinhar visualmente ao custo. As 12 novas artes ficam em assets/art/ e seus prompts em docs/art-prompts/archetype-expansion.md.

As regras detalhadas de Vigor, Veneno, Descarga Condutora e mulligan estão em [docs/REGRAS_VIGOR_VENENO.md](docs/REGRAS_VIGOR_VENENO.md).

Simulação anterior a esta expansão: [15 partidas de Guerreiro contra as outras classes](docs/SIMULACAO_GUERREIRO_15_PARTIDAS.md), já com Guardião da Aurora recebendo Bloqueio 1. Custo de mana usa arte PNG de gema azul clara, mantendo os números editáveis.

Atualização: Vigor passa a funcionar no ataque e na defesa. Disparo Arcano 2 da Feiticeira/Canalista custa 1 mana + esgotar. Veja a [segunda rodada de 15 partidas](docs/SIMULACAO_GUERREIRO_RODADA_2.md).


Chamado: [Arauto da Lua](cards/moon_herald.tres), neutro de 2 mana e 1/2. Ao entrar pela mão, outro aliado escolhido ganha +1/+1 permanente; sozinho entra sem bônus. O alvo é confirmado antes do gasto. A gema é menor (40 px no topo, 28 px nas habilidades) e aparece também na lista do editor. Agora o editor e a validação de partida permitem somente uma classe + neutros por deck; drafts só de neutros também são válidos. Nesta atualização, os decks antigos são substituídos uma vez pelas novas receitas. Edições futuras são preservadas, respeitando uma classe + neutros.

Chamado é um gatilho genérico de entrada pela mão; o efeito é definido por carta. Arauto da Lua usa `BUFF_ALLY` e concede +1 de ataque, +1 de vida atual e +1 de vida máxima a outro aliado. O resumo é **Chamado — +1/+1**.


Quatro novos Chamados por classe: Ferreiro da Muralha (Armadura +1), Conjuradora do Éter (invoca Familiar Rúnico), Alquimista das Brumas (Veneno 2 em inimigo) e Oráculo da Aurora (+2 vida a aliado, com Vigor). Os decks antigos foram substituídos por novas listas; os nove espaços permanecem e cada novo deck começa pela escolha da classe base. Detalhes em [CHAMADOS_POR_CLASSE.md](docs/CHAMADOS_POR_CLASSE.md).

O editor agora tem nove espaços em três linhas: os três decks existentes, Aurora Vital no quarto e os espaços 5/6 vazios. A migração de versão 2 para 3 preserva os decks e o ativo; espaços vazios são persistidos e não podem iniciar partida.

A tela **Meus decks** agora separa a seleção da montagem de cartas. Cada deck tem capa personalizável a partir de uma carta de sua lista; Na edição, o campo de nome e **Alterar capa** personalizam o rascunho; salvar o deck grava as alterações. O formato versão 4 preserva cartas/nomes/ativo anteriores e adiciona o campo `cover` por espaço. Veja [BIBLIOTECA_DE_DECKS.md](docs/BIBLIOTECA_DE_DECKS.md).

Meus decks agora usa capas verticais 3:4 à esquerda e um painel único à direita com Editar cartas e Jogar. A montagem exibe a curva de mana por custo. Clicar em uma capa apenas seleciona o deck. Pequenos símbolos SVG substituem os rótulos de classe do deck, incluindo Neutro para listas somente de neutros. A composição de decks e os dados salvos foram preservados.


Em uma atualização anterior os decks passaram a **20 cartas**, até duas cópias. Os cinco decks iniciais e decks salvos foram ampliados, mantendo cartas, nomes, capas, seleção ativa e espaços vazios. **Reconstrução da Aldeia** (magia neutra, 2 mana) restaura 2 do seu castelo ou de uma Muralha aliada e compra uma carta se todas as suas criaturas em campo forem neutras. Pode ser usada em qualquer classe; campo vazio também ativa a compra. [Regras e migração](docs/DECKS_20_RECONSTRUCAO.md).

O editor agora tem filtros por classe e tipo, busca por nome/habilidade e localização da carta na coleção com botão direito na lista. Veja docs/CLASSE_BASE_E_CLIQUES.md.

Muralha da Aldeia: neutro de 4 mana, 0/4, Armadura 1, Bloqueio 4 e habilidade Muralha. Cards maiores no editor, destaque mais forte e Vigor sem converter vida no ataque exibido. [Regras e validação](docs/MURALHA_E_EDITOR.md).

Reconstrução pede alvo se houver Muralhas aliadas; caso contrário, é automática no castelo. Bloqueio tem aviso visual/sonoro para alvos protegidos; cura e aplicação/dano de Veneno têm efeitos próprios. Os dez sons usam Ogg Vorbis. Para regenerar os sons sintetizados, use os scripts de tools/ com Python e ffmpeg no PATH.

Novos decks começam com a escolha da classe base ou Neutros. A coleção mostra somente cartas compatíveis. Clique para adicionar na coleção e remover na lista, sem botões +/−; adicionar usa uma animação curta. A base é preservada no formato de decks versão 7.

Cada jogador faz um mulligan; quem joga em segundo recebe uma carta inicial extra e 1 mana temporária no primeiro turno. Fazendeiro é 1/3. Bola de Fogo é uma magia de Mago de 6 mana que causa 3 de dano mágico a todas as criaturas inimigas. Artes incluem dia e noite.

Revisão atual: editor sem sugestões prontas, decks atualizados e 50 partidas contra Guerreiro. [Resultados e composições](docs/SIMULACAO_DECKS_50_PARTIDAS.md).

Guardião Arcano: Guerreiro 3 mana, 2/3, Guarda Arcana 1. Anula uma ocorrência de dano mágico por carga e recupera uma no início do próprio turno. Bola de Fogo substitui o nome e identificador da antiga magia de dano em área. [Regras e validação](docs/ABASCANTO_E_BOLA_DE_FOGO.md).

[Ícones de habilidades no campo](docs/ICONES_NO_CAMPO.md): símbolos compactos, valores/cargas atuais e estados de disponibilidade.

[Controles do combate](docs/CONTROLES_COMBATE.md): clique na mão, aviso de ações restantes, castelo inimigo central e menu Esc/engrenagem.

[Primeira lendária: Levante da Aldeia](docs/LEVANTE_DA_ALDEIA.md), neutra de 5 mana, */*, com herança dinâmica de habilidades neutras aliadas sem Chamados. Lendárias têm limite de uma cópia por deck. Ladina Relâmpago agora é 3/2.

[Boi da Colheita e revisão das regras da aldeia](docs/COLHEITA_E_REPARO.md): Colheita por ativação de Cultivo aliado, reparo de Muralhas, castelos imunes a Veneno e suporte para outros aliados de qualquer classe.

[Atacar com todos, artes de castelo e trilha](docs/ATAQUE_EM_GRUPO_E_TRILHA.md). O menu usa a trilha ambiente e os combates usam “Chariots Of War”, de Aakash Gandhi; ambas respeitam o controle de som e o crédito aparece no menu.

Layout 1920×1080 em tela cheia, com F11 para modo janela. Campo com seis criaturas por lado e [Devota do Alvorecer, novos cliques e revisão da herança neutra](docs/SEIS_CRIATURAS_E_DEVOCAO.md).

Curas agora removem Veneno, inclusive em criaturas com vida cheia. Devota do Alvorecer: 3 mana, 1/4, Devoção 1 e Cura 1 por 0 mana + esgotar. Limpar apenas Veneno não ativa Devoção.

Necromante do Véu (4 mana, 2/4, Humana de Horda) possui Pacto Sombrio e Chamado condicional de Carniçal 2/2. Cura agora causa dano mágico em Mortos-vivos. Veja [regras de Necromancia](docs/NECROMANCIA.md).

A facção Horda mantém o tipo Monstro separado da classe. Clamor da Horda (3 mana) dá +2 de ataque aos Monstros aliados em campo até o fim do turno atual. Veja [regras e validação](docs/CLAMOR_DA_HORDA.md).

Goblin agora é 1 mana 1/1 com Arrancada. Fungo da Ninhada (neutro Monstro, 3 mana, 0/3) fortalece a vida de Monstros com Esporos 1; Troll do Brejo (Horda Monstro, 4 mana, 3/5) tem Regeneração 1. Monstros neutros ficam restritos à Horda ou decks só de neutros. Veja [regras e validação](docs/ESPOROS_E_REGENERACAO.md).

Créditos de criação, fonte e música: [CREDITS.md](CREDITS.md).
