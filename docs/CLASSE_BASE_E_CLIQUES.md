# Classe base e montagem por clique

Ao criar um deck em um espaço novo, escolha Guerreiro, Mago, Ladino, Clérigo ou Neutros. A escolha limita toda a coleção: uma classe mostra apenas suas cartas e neutros; Neutros mostra somente neutros. Filtros e busca nunca revelam cartas incompatíveis.

- Clique na carta da coleção para adicionar uma cópia. Enter ou Espaço também funciona com a carta focada.
- Clique na linha da lista à direita para retirar uma cópia.
- Botão direito na lista localiza e destaca a carta na coleção. Botão direito na coleção continua abrindo a arte.
- Não há controles +/−. A coleção indica a quantidade de cópias e informa quando o deck está cheio ou já contém duas cópias.
- Ao adicionar por clique, uma miniatura voa da coleção até a linha correspondente, em cerca de 0,28 segundo. A linha é revelada pela rolagem quando necessário.
- As linhas têm cores e bordas discretas da classe. Neutros mantêm o texto dourado anterior.

A classe base continua definida mesmo se retirar todas as cartas de classe e restarem apenas neutros. Para trocá-la, esvazie o rascunho e use Trocar classe base. Decks antigos com mistura podem ser corrigidos retirando as cartas incompatíveis; salvar e jogar continuam bloqueados até corrigir.

## Persistência

`DeckStore` versão 7 acrescenta `base_class` a cada espaço. Arquivos antigos inferem a base pelas cartas, preservando cartas, nomes, capas, seleção ativa e espaços vazios. Decks antigos só de neutros recebem a base Neutros; espaços novos ficam sem base até escolher. Uma base escolhida com rascunho vazio pode ser salva. Rascunhos incompletos continuam limitados à sessão do editor; deck jogável requer 20 cartas, até duas cópias.

A escolha é preservada no rascunho ao navegar entre as telas. Editar cartas, filtros ou capa não salva automaticamente a composição. Nenhuma lista existente foi substituída por esta mudança.

## Validação

`tests/test_base_deck_builder.gd` cobre escolha obrigatória, persistência da base mesmo sem cartas de classe, cliques reais para adicionar/remover, animação e limpeza da miniatura, cores de classe, limite de composição e migração da versão 6 sem perda de dados. Regressões do editor, filtros, biblioteca, nove espaços, receitas, Chamados e neutros aprovadas. Layout conferido no Godot.
