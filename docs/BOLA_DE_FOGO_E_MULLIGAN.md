# Bola de Fogo e mulligan extra

## Abertura

Quem começa recebe três cartas e pode fazer um mulligan gratuito de qualquer quantidade. Quem joga em segundo recebe quatro cartas, faz a mesma primeira troca e depois pode fazer **uma segunda troca de até uma carta**. Também pode manter a mão em qualquer etapa.

A segunda troca usa a mão atual, incluindo cartas recebidas na primeira. As substituições são compradas antes de devolver as cartas escolhidas ao baralho. Não há compras normais, mana nem ações até terminar todas as etapas dos dois jogadores. O primeiro turno começa uma única vez, com a compra e a mana normais. A IA recebe o mesmo direito quando joga em segundo.

A interface mostra MULLIGAN EXTRA · 1 CARTA. Selecionar uma nova carta nessa etapa substitui a seleção anterior. A validação rejeita duas cartas, índices repetidos/inválidos ou uma terceira troca sem modificar a mão.

## Fazendeiro

Continua neutro de custo 2, agora **1/3**. Cultivo 1 permanece: ganha +1 vida atual e máxima no início de cada turno do dono.

## Bola de Fogo

Magia de Mago, **6 mana**. Causa **3 de dano mágico a todas as criaturas inimigas**. Amplificar aumenta o dano de cada alvo. Ignora Armadura e Bloqueio, não atinge aliados ou castelos e não provoca contra-ataques.

Conjura diretamente, sem escolher um alvo individual. Exige pelo menos uma criatura inimiga. O dano é aplicado a todas antes de remover as mortas e recalcular Auras. Tem efeito dourado nos alvos e usa o som mágico em Ogg existente. A IA considera os alvos atingidos e as eliminações ao escolher a magia.

Disponível na coleção de Mago, na galeria e no construtor. Os decks salvos e as sugestões não foram substituídos. Recurso: `cards/fireball.tres`; arte: `assets/art/fireball.webp`, gerada com image_gen integrado. [Prompt](art-prompts/fireball.md).

## Direção de arte

Realmrift inclui cenas diurnas e noturnas. A arte atual de Bola de Fogo mostra uma bola de fogo em uma vila noturna, com silhuetas de criaturas envoltas nas chamas. O horário da ilustração é uma escolha de ambientação e não cria uma regra de ciclo de dia/noite.

Coleção: **34 cartas, 26 criaturas e oito magias**.

Validação: `tests/test_fireball_extra_mulligan.gd` cobre as duas posições iniciais, conservação do deck, limites e recusa da troca, Fazendeiro/Cultivo, custo e dano da magia, Armadura/Bloqueio/Vigor/Amplificar, aliados/castelos preservados, campo vazio, IA, UI do mulligan e conjuração imediata. Regressões de abertura, cura, magias, Aura e Chamados aprovadas. Arte e telas conferidas no Godot.
