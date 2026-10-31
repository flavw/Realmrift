# Horda e Clamor da Horda

A facção antes chamada Monstros passa a se chamar **Horda**. Seu ID numérico permanece 5, preservando decks salvos e suas capas. O tipo de criatura **Monstro** permanece independente da facção. Pacto Sombrio continua permitindo a Necromante Humana na Horda; outros Humanos seguem proibidos.

**Clamor da Horda** é uma magia da Horda de **3 mana**: todos os aliados do tipo **Monstro** que já estiverem em campo ganham **+2 de ataque até o fim do turno atual**.

- Afeta Goblin Saqueador, Minotauro da Ruína e Lobisomem das Brumas pelo tipo, não pela facção.
- Não afeta a Necromante Humana, Zumbi/Carniçal Mortos-vivos nem Feras como Lobo da Noite.
- Não exige selecionar alvo: clicar na carta conjura o efeito no próprio campo. Precisa existir ao menos um Monstro aliado vivo.
- Não deixa criaturas prontas nem afeta criaturas que entrarem depois.
- Duas conjurações dão +4 no mesmo turno. Os bônus temporários terminam ao encerrar esse turno; Fúria, bônus permanentes e Auras são preservados.
- O ataque aumentado aparece em verde e o foco informa a duração temporária.

A receita Horda das Brumas da IA recebe duas cópias no lugar dos Bois da Colheita. Decks salvos do jogador são preservados. Há 46 cartas colecionáveis (37 criaturas e 9 magias), mais o Carniçal invocado, totalizando 47 recursos na galeria.

Validação: `tests/test_horde_roar.gd`, tipos/composição, Necromancia e magias. Arte em `assets/art/horde_roar.webp`, criada com imagegen; prompt em `art-prompts/horde-roar.md`.
