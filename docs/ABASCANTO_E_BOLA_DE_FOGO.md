# Guarda Arcana e Bola de Fogo

Guardião Arcano é um Guerreiro de custo 3, ataque 2 e vida 3, com Guarda Arcana 1. Disponível na coleção e na galeria, com arte própria e borda de Guerreiro. Os decks salvos não recebem cartas novas automaticamente.

Cada carga anula uma magia ofensiva ou uma ocorrência de dano mágico recebido. Todas as magias ofensivas atuais causam dano; a proteção cobre alvos únicos, Descarga Condutora, Bola de Fogo e habilidades de Disparo Arcano, mesmo com Amplificar. A carga é consumida uma única vez pelo acerto inteiro, inclusive pelo dano dobrado da Descarga. Em dano em área, cada criatura resolve sua proteção individualmente. A magia e sua mana são gastas normalmente; habilidades pagam mana e esgotam o usuário, sem contra-ataque.

No início do turno do dono recupera uma carga, até o máximo da habilidade. Guarda Arcana 2, por exemplo, pode anular dois acertos mas recupera somente uma carga por turno. Não recarrega no turno adversário. Dano físico, contra-ataques físicos e Veneno não são impedidos nem gastam cargas. Cura e bônus aliados também não gastam cargas. Zero de dano não gasta uma carga.

A versão reduzida mostra o ícone de Guarda Arcana com suas cargas; o card completo e a caixa de ajuda mostram as cargas atuais e a regra. O atributo `Guarda Arcana` é editável no Inspector de CardData.

## Renomeação

`fireball` é a chave canônica da Bola de Fogo; recurso em `cards/fireball.tres`, arte em `assets/art/fireball.webp`, prompt em `docs/art-prompts/fireball.md`. Custo e efeito permanecem 6 mana e 3 de dano mágico a todas as criaturas inimigas. O carregador de decks versão 8 converte a chave antiga antes de validar cartas e capas, preservando a composição, nomes, espaços vazios e deck ativo. A chave antiga existe apenas no migrador e no teste de compatibilidade.

## Verificação

`tests/test_abascanto.gd` cobre capacidade, consumo e recarga; ataques físicos, Veneno e cura; Disparo Arcano, dano dobrado e dano em área; cargas na UI, disponibilidade na coleção e migração do save.

`tests/test_fireball_extra_mulligan.gd` verifica a magia renomeada e as regras anteriores de mulligan. Nenhum teste de animação foi necessário.
