# Esporos, Regeneração e composição

Goblin Saqueador agora custa **1 mana**, possui **1/1** e mantém **Disparada**.

**Fungo da Ninhada**: aldeão, tipo Monstro, **3 mana, 0/3, Esporos 1**. No início do turno de seu dono, todos os Monstros aliados em campo ganham +1 de vida atual e máxima permanentemente, incluindo o próprio Fungo. Fontes acumulam. Não afeta Humanos, Feras, Artefatos ou Mortos-vivos. Não é Cura nem Cultivo: não remove Veneno, não ativa Devoção nem Colheita. Levante da Aldeia pode herdar Esporos de Fungos aldeões aliados; o efeito herdado continua beneficiando apenas Monstros.

**Troll do Brejo**: Horda, tipo Monstro, **4 mana, 3/5, Bloqueio 1 e Regeneração 2**. Ao fim do turno de seu dono, depois de resolver Veneno e remover as criaturas mortas, recupera 2 de vida até o máximo atual. Funciona esgotado e não custa mana. Não é Cura: não ativa Devoção, não remove Veneno ou Sangramento e recupera vida normalmente em Muralhas e Mortos-vivos. Não revive uma criatura morta pelo Veneno nem aumenta sua vida máxima.

A composição foi atualizada: **Horda não aceita Aldeia**, independentemente do tipo. O Fungo da Ninhada pertence agora à Horda (1/3, custo 3, Esporos 1), e não pode mais transmitir Esporos ao Levante da Aldeia como fonte da Aldeia. As descrições de implementação e contagens abaixo registram a versão original; consulte [Aldeia e Necrópole](ALDEOES_E_NECROPOLE.md) para as regras atuais.

Horda das Brumas da IA recebe duas cópias do Fungo no lugar das Muralhas e duas do Troll no lugar dos Lobos. Os decks salvos do jogador são preservados. Há 46 cartas colecionáveis (37 criaturas e 9 magias), mais um Carniçal apenas invocado: 47 recursos na galeria.

Esporos e Regeneração têm ícones SVG próprios e aparecem na versão de campo. Os recursos e valores são editáveis no Inspector de CardData. Artes em `assets/art/brood_fungus.webp` e `assets/art/marsh_troll.webp`, criadas com imagegen. Prompts em `art-prompts/fungus-and-troll.md`.

Validação: `tests/test_fungus_troll.gd` e regressões de Clamor, tipos, Necromancia, Cura e ícones de campo.
