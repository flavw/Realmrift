# Decks de 20 cartas e Reconstrução da Aldeia

Todos os decks agora exigem **20 cartas**, com até duas cópias de cada. Continuam nove espaços; as cinco sugestões e as listas da IA foram ampliadas. Campo com cinco criaturas, mão com oito e castelo com 20 de vida permanecem iguais.

## Reconstrução da Aldeia

- Magia neutra, **2 mana**.
- **Restaure 2 de vida do seu castelo ou de uma Muralha aliada. Se todas as suas criaturas em campo forem neutras, compre 1 carta.**
- Pode entrar em decks de qualquer classe. A compra depende só do campo aliado atual; campo vazio também ativa. Mão, baralho e criaturas inimigas não interferem.
- Com Muralhas aliadas em campo, escolha o castelo ou uma delas. Sem Muralhas aliadas, conjura automaticamente no castelo. Reconstrução pode reparar Muralhas; outras curas continuam proibidas. Pode ser usada com vida cheia. Se houver uma criatura de classe no seu campo, cura normalmente sem comprar.
- Resolve primeiro a cura e depois a compra condicional. Uma compra sem cartas causa fadiga normalmente. Não ocupa campo e Amplificar não aumenta os efeitos.
- Texto resumido: Restaurar 2 / Campo neutro: compre 1. A ajuda usa explicações curtas. Todas as sete magias mostram o custo apenas na gema do topo; habilidades de criaturas mantêm o custo de ativação.

Recurso editável: `cards/village_reconstruction.tres`. Arte: `assets/art/village_reconstruction.webp`, gerada com image_gen integrado. [Prompt](art-prompts/village-reconstruction.md).

## União da Aldeia

Duas cópias de cada: Falcão Mensageiro, Escudeiro da Lua, Lobo da Noite, Fazendeiro, Líder da Aldeia, Camponesa Generosa, Vigia do Portão, Peregrina da Vida, Arauto da Lua e Reconstrução da Aldeia. Total: 20 cartas, somente neutras.

## Migração

A versão 6 do arquivo de decks amplia listas antigas de 12 para 20 cartas. Preserva todas as cartas originais e suas quantidades, nomes, capas, deck ativo e espaços vazios. Acrescenta cartas da sugestão correspondente, respeitando a classe e até duas cópias. Reabrir não reaplica a ampliação.

As cinco listas salvas desta instalação foram ampliadas, incluindo União da Aldeia no espaço 5 com duas Reconstruções. A seleção ativa e os quatro espaços vazios foram preservados. O arquivo anterior foi guardado no workspace de trabalho antes da migração.

## Validação

`tests/test_twenty_reconstruction.gd` cobre as cinco listas, liberdade de classe no editor e condição pelo campo aliado, cura, compra com castelo cheio, mana/alvo inválidos, mão/campo cheios, fadiga, IA e migração idempotente. Regressões de magias, Aura, Chamados, Vigor/Veneno/mulligan, editor, biblioteca e nove espaços aprovadas. Capturas estáticas conferidas no Godot.

Coleção: 32 cartas, sendo 25 criaturas e sete magias. GitHub não atualizado.
