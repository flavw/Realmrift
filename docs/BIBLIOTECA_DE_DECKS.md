# Meus decks — seleção, edição e personalização

O gerenciador de decks foi dividido em três telas:

- **Meus decks:** seis capas em uma grade, com nome, facção, cartas, deck ativo, Editar cartas, Capa e nome e Jogar. Os espaços 5/6 continuam vazios se ainda não receberam cartas.
- **Editar cartas:** coleção e lista do deck escolhido, sem os seis seletores no topo. O botão Meus decks retorna à biblioteca. Um rascunho não salvo fica guardado enquanto esse gerenciador permanece aberto.
- **Capa e nome:** escolha a arte de uma carta já presente no deck e altere o nome, sem modificar as cartas ou o deck ativo. A seleção é confirmada em Salvar capa e nome. Cartas repetidas aparecem uma só vez. Voltar sem salvar cancela a personalização.

Capas automáticas usam cartas do próprio deck. Retirar a carta usada como capa faz voltar ao modo automático após salvar a nova lista. Deck vazio permite renomear, mas não escolher arte sem ter cartas nem jogar. Magias também podem ser usadas como capa.

O arquivo de decks passa à versão 4, com o campo `cover` por espaço. Nomes, listas e deck ativo anteriores são preservados na migração; não há reset dos seis decks. Nome e capa persistem após reabrir o jogo. O nome continua limitado a 24 caracteres e o deck mantém 12 cartas, até duas cópias e uma facção + aldeões.

Testes cobrem clique real na capa para abrir a montagem, telas separadas, escolha/cancelamento/persistência, rejeição de arte fora do deck, espaços vazios, cache de rascunho, retirada da carta de capa, migração e início de partida pela biblioteca. As artes já existentes foram reaproveitadas, sem nova geração de imagens. GitHub não foi atualizado.
