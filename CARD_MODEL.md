# Modelo editável de cartas

Abra `card_gallery.tscn` para ver os 47 recursos, incluindo o Carniçal invocado, `expansion_gallery.tscn` para as quatro cartas da expansão ou `support_gallery.tscn` para os exemplos de suporte. Execute com F6. Abra `card_model.tscn` para editar as camadas comuns.

Aura: `aura_effect`, `aura_value`, `aura_targets` e `aura_includes_self` definem o efeito contínuo. O primeiro tipo implementado é ATTACK. Exemplo: `cards/village_leader.tres`. O ataque recebido fica em `aura_attack`, recalculado a partir das fontes vivas, separado de bônus permanentes. A interface recebe o total uma única vez e compara com o ataque base para colorir. Adicione tipos de efeito e sua resolução para futuras Auras.

Chamado coletivo: `EntryEffect.BUFF_NEUTRAL_ALLIES` concede `entry_attack`/`entry_health` a todos os seus neutros presentes, inclusive a fonte. Exemplo: `cards/generous_peasant.tres`, com +0/+1. Não pede alvo; a vida atual e máxima aumentam permanentemente. Confira [União da Aldeia](docs/UNIAO_DA_ALDEIA.md).

Selecione uma carta e expanda Card Data no Inspector. Nome, custo, ataque, vida, armadura, classe, habilidades e ilustração são recursos compartilhados com a partida. Salve e reinicie a partida para aplicar mudanças nas regras. O texto da habilidade é uma descrição; novas mecânicas precisam de implementação.

## Arte e enquadramento

Todas as ilustrações de criaturas e magias usadas pelo jogo ficam em `assets/art/`. Não há versões antigas duplicadas. Os recursos em `cards/` apontam para essas imagens. Os prompts de geração ficam em `docs/art-prompts/`.

A camada Artwork preenche todo o fundo da carta completa. Nome, custo, regras e atributos são sobrepostos à ilustração. O círculo de custo ocupa 40 × 40 px, com número de 26 px, contorno escuro e fonte sem serifa centralizada, e o nome usa 20–24 px na fonte At Dawn, com sombra discreta. Não há faixa atrás do título; a base usa um degradê suave para preservar a leitura das habilidades sem um painel de pergaminho. Artwork Zoom amplia a arte (1 = enquadramento mínimo que preenche a carta) e Artwork Focus define o centro do recorte em coordenadas entre 0 e 1. X controla esquerda/direita e Y cima/baixo. O enquadramento é limitado para nunca revelar áreas vazias. Para mover o recorte, pode ser necessário aumentar um pouco o zoom. Cada recurso guarda seu próprio enquadramento, com atualização no editor.

`field_card.tscn` é a versão quadrada usada em campo. Ela compartilha a ilustração da carta completa e mostra ataque/vida atuais. O enquadramento do modelo completo não muda o recorte quadrado do campo. Passe o mouse para abrir a carta completa. As cartas completas também são usadas na mão e no editor de decks.

## Camadas e indicadores

Camadas em CardCanvas: Frame, Artwork, Title, CostGem, Cost, RulesPanel (degradê), Ability (linhas de resumo, ícone de habilidade, círculo numérico e esgotar), Stats. O conteúdo dos Labels é alimentado por Card Data. Molduras, ícones e efeitos ficam em `assets/ui/`.

StatusIcons fica exclusivamente em `field_card.tscn`, como HBoxContainer sem fundo, no canto inferior esquerdo da versão reduzida. O peitoral mostra Armadura e o rótulo Bloq. mostra as cargas atuais de Bloqueio, incluindo zero quando consumidas. A carta completa não contém esses ícones nem a propriedade Inspect Mode. Esgotado escurece a arte e mostra Zzzz animado no canto superior direito.

## Classes e novas cartas

Classes: Warrior vermelho, Mage roxo, Neutral cinza, Rogue verde e Cleric branco/dourado. Growth, Heal Amount e Heal Cost também são editáveis no Inspector.

Para criar uma carta independente, duplique um recurso em `cards/` antes de editar. Salve a ilustração em `assets/art/`, selecione-a em Artwork e ajuste o enquadramento. Registre o novo recurso em CARD_DATA, em `scripts/match.gd`, para incluí-lo na coleção e no editor de decks. Habilidades novas precisam de regras na lógica da partida.

Os ícones `tap-icon.webp`, `block-icon.webp` e `fury-icon.webp` foram gerados com imagegen e ficam em `assets/ui/`. Esgotar aparece em magia/cura e Fúria no Lobo e nos botões de ações; Bloqueio permanece exclusivo da versão reduzida. Fúria pode ser ativada uma vez por turno por criatura. Os textos continuam editáveis.

## Resumos e explicações ao passar o mouse

O nó Ability agora é um VBoxContainer de linhas compactas. O exemplo da Maga é Disparo Arcano 1 — círculo numerado 1 + esgotar. Cada habilidade usa atributos do Card Data para gerar nome, valor, custo e explicação na caixa lateral. Bloqueio considera as cargas atuais na prévia.

Ability Name Override e Ability Help Override são campos opcionais do Inspector para personalizar o resumo e a explicação da primeira habilidade. Valores vazios usam o texto padrão de `ability_entries()` em `scripts/card_data.gd`. Ability Text é fallback para uma habilidade não catalogada. Esses textos não mudam as regras.

A caixa flutuante é criada pelo CardView numa CanvasLayer, tem tamanho independente da miniatura, evita as bordas da tela e ignora o mouse para preservar seleção e ataques. Na partida, a carta original delega essa caixa à prévia ampliada para evitar explicações duplicadas. Os símbolos novos ficam em `assets/ui/mana-cost-symbol.webp` e `assets/ui/arcane-icon.webp`.

O nó Stats usa `scripts/stat_line.gd`: ataque e vida são Labels separados para cores independentes. `ability_context` carrega turno, mana, prontidão, alvos válidos e vida máxima para mostrar os estados reais. Sem contexto, as galerias e o editor mostram as habilidades como referência. `scripts/art_viewer.gd` abre a imagem original sem molduras, textos, escudos ou recorte.

A ampulheta substitui a lua no custo de esgotar. A imagem anterior fica reservada em assets/ui/moon-reserved.webp, sem habilidade atribuída.

## Alinhamento e degradê

Title e Ability têm centro horizontal em X=180 no canvas de 360 px. Cada linha de habilidade é centralizada e usa alinhamento vertical comum entre texto, custo e símbolos. RulesPanel cobre Y=320..477, com opacidades 0%, 23%, 53% e 78% ao longo do degradê.

Stats é um Control com três Labels. O script mede as larguras usando a mesma fonte/tamanho, centra o grupo inteiro e posiciona as Labels com a mesma altura. O grupo usa uma área fixa com margem no canto inferior direito, sem placa de fundo ou escudo. Cores de bônus/dano são preservadas.

## Tipos de carta e SVGs

Card Type seleciona Creature ou Spell. Magias escondem Stats e mostram TypeLabel como MAGIA. Spell Effect, Spell Value e Spell Secondary configuram efeitos existentes. Magic Power controla Amplificar; Affinity identifica a sinergia de um neutro. O editor e a galeria usam a mesma apresentação, e a partida direciona cartas de magia para Conjurar.

Mana Cost Symbol é uma gema PNG azul clara; Tap Icon é uma ampulheta SVG em assets/ui/. CardSkin prefere SVG quando existe. O número de mana usa fonte sem serifa preta de peso 800, separado da gema. Seu Label sobe 3 px no custo superior e 2 px no custo de habilidade para centralização óptica. O nome At Dawn usa Y=15..42 para compensar sua linha de base e alinhar o texto ao custo superior.


### Vigor, Veneno e magias novas
- `vigor`: usa o maior valor entre ataque base e vida atual ao atacar e defender. Preserva o atributo base; Stats mostra a força efetiva atual, com bônus verde.
- `envenom`: valor de Envenenar aplicado por ataque/contra-ataque físico. Veneno recebido é um estado de partida separado, não um atributo salvo da carta.
- `SpellEffect.VIGOR`: concede Vigor a uma criatura aliada que ainda não tenha a habilidade. O custo fica em `cost`.
- `SpellEffect.CONDUCTIVE`: dano mágico de `spell_value`, dobrado se o alvo tiver Armadura. Recebe Amplificar antes de dobrar.
- Os recursos `vigor_vow.tres` e `conductive_bolt.tres` já são exemplos editáveis. Suas artes ficam em `assets/art/`. A galeria inclui os 47 recursos, incluindo o Carniçal invocado.
- A tela de mulligan é construída por `scripts/mulligan_view.gd`; a abertura é controlada pelo motor e bloqueia ações até ambas as mãos serem confirmadas.


### Chamado e classe única
`entry_effect` define o efeito de Chamado; Chamado é apenas o gatilho de entrada. Atualmente há NONE, BUFF_ALLY, ARMOR_ALLY, SUMMON e POISON_ENEMY. No efeito BUFF_ALLY, `entry_attack` e `entry_health` definem os bônus separados. O Arauto usa valor 1 em ambos (+1/+1); vida aumenta tanto atual quanto máxima, preservando o dano sofrido. Para futuros efeitos, acrescente um tipo em EntryEffect, suas regras de alvo, resolução, descrição e decisão da IA. SUMMON cria a criatura indicada por `entry_summon_key` se houver espaço; ARMOR_ALLY e POISON_ENEMY usam `entry_value`. A IA e a interface consultam o lado do alvo definido pelo tipo de efeito. `match.can_play(side, hand_index, target)` valida a escolha sem consumir nada; `play` recebe o mesmo alvo para resolver a invocação e o bônus juntos. Alvo -1 é usado se não houver outro aliado. O efeito é único por invocação e não se repete no turno.
A gema de custo mede 40 px no topo e 28 px em habilidades e lista do deck; o número continua separado e editável. DeckStore substitui arquivos de decks com versão anterior a 2 pelas novas listas uma única vez; depois preserva as edições. Match.valid_deck exige uma única classe + neutros para jogo e salvamento. O campo de afinidade foi removido dos neutros.

DeckStore versão 3 usa seis slots. A versão 2 com três slots é ampliada preservando seu conteúdo e ativo; Aurora Vital é acrescentado na posição 4 e os últimos dois ficam vazios. A grade de seleção tem três colunas e duas linhas. Um slot vazio pode ser persistido, mas `activate` e Jogar exigem um deck completo.


### Biblioteca de decks e capas
`deck_editor.gd` tem três estados de tela: library, edit e personalize. A biblioteca mostra seis capas e ações; a montagem mostra apenas um deck e a coleção; a personalização edita nome e capa sem alterar as cartas. As capas usam as Texture2D já existentes, com o shader de enquadramento e foco no terço superior; não há novas imagens duplicadas.
DeckStore versão 4 adiciona `cover` (chave de CardData, não caminho externo). `cover_for` usa a chave escolhida se ainda pertencer ao deck, ou `automatic_cover` como fallback. `save_metadata` altera só nome e cover; `save_slot` preserva a capa até que a carta correspondente seja retirada da lista. Campos antigos são migrados sem trocar decks ou ativo. `draft_cache` retém alterações de cartas enquanto a biblioteca permanece aberta, separado das versões salvas.


### Decks em retrato e símbolos
A biblioteca monta capas fixas de 240 × 320, com arte de 236 × 316, nome e contagem sobre um degradê inferior. `library_selected` é independente do deck ativo; os três botões ficam em LibraryActions à direita. `class_badge` classifica listas só de neutros como NEUTRAL e não marca espaços vazios. Os cinco símbolos SVG ficam em assets/ui/class-*.svg, via CardSkin.class_symbol; a regra de composição não mudou. Nenhum campo novo de salvamento foi necessário.

DeckStore versão 5 amplia para nove espaços e aceita arquivos anteriores de três ou seis, preservando o conteúdo existente. Os novos 7–9 são vazios. A biblioteca tem rolagem e mantém a seleção visível; o painel direito permanece fixo.


`cards/village_reconstruction.tres`: magia neutra de 2 mana, `SpellEffect.RECONSTRUCT`, `spell_secondary=2` (cura) e sem restrição de classe do deck. Cura o próprio castelo e compra uma carta se `neutral_field(side)` confirmar apenas criaturas neutras no campo aliado, incluindo campo vazio. O custo das magias fica somente na gema superior; o campo cost da entrada ainda alimenta os estados de disponibilidade, sem gerar outra gema nas regras. A galeria tem 47 recursos, incluindo o Carniçal invocado. Decks usam 22 cartas; a versão 10 do DeckStore amplia listas anteriores preservando cartas e metadados sempre que possível. Veja `docs/DECKS_20_RECONSTRUCAO.md`.

`cards/village_wall.tres` usa `wall=true` para o subtipo Muralha: imunidade a Veneno, cura recusada e nenhum ataque declarado. `block=4` usa as cargas de Bloqueio existentes. O campo affinity foi removido. Vigor não altera o ataque desenhado em card_view/field_card; Match.physical_attack continua resolvendo sua força no combate. O editor amplia os cards para a largura das quatro colunas.

`cards/fireball.tres` usa SpellEffect.AREA_ARCANE, custo 6, valor 3. A conjuração resolve diretamente contra o grupo de criaturas inimigas. CardData é compatível com arte diurna e noturna. O mulligan usa mulligan_rounds por jogador: uma etapa para o primeiro, duas para o segundo; a segunda aceita até um índice.

Tipos de criatura: edite creature_type no recurso CardData (Humano, Fera, Artefato, Monstro ou Morto-vivo). card_class permanece independente; Horda é a nova facção. Recursos de magia ignoram creature_type. Decks de Horda proíbem criaturas Humanas, inclusive neutras, exceto quando human_and_monster (Pacto Sombrio) é verdadeiro. Veja docs/MONSTROS_E_TIPOS.md.

O campo editável `lore` contém o texto de ambientação mostrado à direita da arte ampliada ao clicar com o botão direito. Ele não altera as regras da carta.

Necromancia: human_and_monster permite a exceção de Humano em Horda. EntryEffect.SUMMON_AFTER_ENEMY_HUMAN_DEATH consulta human_deaths do adversário e invoca entry_summon_key se houver espaço. collectible=false torna o Carniçal apenas invocado. creature_type=UNDEAD converte Cura em dano mágico; bônus de atributos não são Cura.

Campos editáveis: spores aumenta vida atual/máxima dos Monstros aliados no início do próprio turno; regeneration aplica Cura a si no fim do próprio turno após Veneno. Ambos acumulam quando herdados por Multidão a partir de fontes neutras. Monstros neutros são filtrados das quatro outras facções atuais por neutral_monster_forbidden.
