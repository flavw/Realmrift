# Impulsivo — Esqueleto Inquieto

O Esqueleto Inquieto mantém custo 1, tipo Morto-vivo, 1/1 e Disparada; recebe **Impulsivo**.

Ao encerrar o turno de seu dono, se ainda estiver vivo, pronto, apto a atacar e não tiver atacado naquele turno, realiza um ataque físico automático. Usa `preferred_attack_target`, a mesma escolha do botão Atacar com todos: castelo quando permitido, defensor obrigatório por Bloqueio quando necessário e criatura-chefe nos encontros sem castelo.

Não deixa a criatura pronta e não concede ataques extras. Criaturas esgotadas, enraizadas, Muralhas ou sem força física não atacam. O ataque acontece antes de remover bônus/restrições temporários e antes do Veneno de fim do turno, respeitando as regras normais de combate, contra-ataque, Sangramento, armadilhas e morte. Cada próximo atacante reavalia o campo depois da ação anterior. Vitória interrompe a sequência e a troca de turno.

O motor executa o efeito em `perform_impulsive_attack` e o aciona em `end_turn`, inclusive fora da interface. A interface resolve e anima cada ataque antes de passar o turno. O atributo `CardData.impulsive` está em ordem alfabética, depois de `heal_cost`, é copiado nos equipamentos da aventura e tem ícone próprio (`assets/ui/impulsive-icon.svg`) no card e na miniatura.

Validação: `tests/test_impulsive.gd`, `tests/test_necropolis_crypt_skeleton.gd` e `tests/test_single_creature_type.gd`.
