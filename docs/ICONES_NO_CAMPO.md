# Ícones de habilidades no campo

As cartas em campo mostram ícones compactos na base esquerda, sem placa de fundo. Ataque/vida continuam na base direita e o indicador Zzzz permanece no alto quando esgotadas. Valores aparecem ao lado dos símbolos; habilidades sem valor, como Voo, Arrancada, Chamado e Muralha, exibem somente o ícone.

Novos símbolos SVG: Aura (círculo irradiando), Chamado (trombeta), Muralha (muro), Arrancada (raio em movimento), Voo (asas), Cultivo (broto), Amplificar (estrela expandindo), Envenenar (presas) e Bloqueio (escudo). Os ícones de Armadura, Guarda Arcana, Fúria, Disparo Arcano, Vigor, Cura e Veneno recebido também aparecem no campo. Aura aparece somente na fonte. Aliados beneficiados não mostram o símbolo: seus atributos já refletem o bônus.

Bloqueio e Guarda Arcana continuam visíveis quando ficam sem cargas, com `0` e menor opacidade. Habilidades ativáveis ficam apagadas quando falta mana, quando o usuário precisa estar pronto e está esgotado, ou quando não há alvo. Fúria não é apagada apenas por esgotamento. Os marcadores se atualizam ao consumir/recuperar cargas, curar, receber Veneno ou perder uma Aura.

Passo Sombrio, Reconstrução e compra de carta também receberam SVGs, usados nas descrições das magias. Magias não permanecem como criaturas em campo.

Os símbolos estão em `assets/ui/`. As entradas de habilidade de `CardData` fornecem ícone, valor e identidade dos marcadores; `field_card.gd` monta a faixa a partir desses dados. Armadura e Bloqueio continuam com texto nas regras do card completo e ícones apenas na versão de campo.

Verificação: `tests/test_field_ability_icons.gd` percorre as criaturas, confere texturas e espaço dos marcadores, estados de carga, Vigor, Veneno, bônus de Aura e disponibilidade de Cura. Os testes de Guarda Arcana, suporte e abertura também verificam os novos nós de ícone/valor.
