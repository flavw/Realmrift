# Veneno, cura e áudio

Veneno acumula no alvo e causa esse total de dano no fim do turno do dono do alvo, ignorando Armadura. Depois é removido completamente. Não reaparece no turno seguinte sem nova aplicação. A imunidade de Muralha permanece válida.

Reconstrução da Aldeia resolve ao clicar em Conjurar, diretamente no seu castelo. Cura 2; compra uma carta quando o campo aliado contém somente aldeões, incluindo campo vazio. Não pede seleção de alvo.

Tentar atacar uma criatura protegida ou o castelo com Bloqueio ativo faz as criaturas com cargas brilharem brevemente e toca um impacto de escudo. A tentativa não gasta ataque, prontidão, mana ou cargas. Voo e magia mantêm suas exceções. Tentativas repetidas têm um intervalo curto para evitar sobreposição do som.

Cura usa partículas em forma de cruz, brilho verde, valor recuperado e som próprio. Veneno usa bolhas e sons distintos na aplicação e no dano. A aplicação é sinalizada em ataques, contra-ataques, castelos e Chamado; alvos imunes não recebem esse efeito. Registros em `last_action.healed` e `last_action.poisoned` fornecem os alvos e valores à interface.

Os dez sons do jogo agora estão em **Ogg Vorbis**. Os seis sons anteriores passaram de 392.754 para 51.594 bytes, redução de 86,9%, antes de somar os quatro novos. Os WAV e seus arquivos de importação foram removidos. O controle de som também silencia os efeitos novos.

Os sons novos foram sintetizados localmente com Python. `tools/generate_status_sounds.py` gera escudo, cura, aplicação de Veneno e dano de Veneno. Os outros dois geradores também passaram a produzir Ogg. A ferramenta de geração requer ffmpeg no PATH; o jogo reproduz os arquivos prontos usando o próprio Godot.

`scripts/status_vfx.gd` desenha os efeitos sem imagens externas. A aplicação aguarda o posicionamento dos containers antes de localizar os alvos, evitando efeitos deslocados após redesenhar o campo.

Validação: `tests/test_status_feedback.gd` cobre cliques reais em criatura/castelo protegidos, ataque preservado, Reconstrução imediata, efeitos e sons de cura/aplicação/dano, dez streams Ogg e mudo. Regressões de Veneno, Vigor, Muralha, Chamados, Aura e magias aprovadas. Efeitos conferidos em uma passagem visual focada no Godot.
