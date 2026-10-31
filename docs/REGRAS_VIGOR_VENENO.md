# Vigor, Veneno e abertura

Implementado localmente em 25/10/2026. Catálogo: **29 cartas — 23 criaturas e 6 magias**.

| Carta | Alteração |
| --- | --- |
| Clériga da Aurora · 3 mana · 1/4 | Vigor, mantém Cura 2 por 1 mana + esgotar |
| Guardião da Aurora · 4 mana · 2/5 | Vigor e Bloqueio 3, sem Cura |
| Voto de Vigor · Clérigo · 2 mana | Concede Vigor a uma criatura aliada de qualquer classe, não cumulativo |
| Descarga Condutora · Mago · 3 mana | 2 de dano mágico; dobra contra criatura com Armadura |
| Ladina Relâmpago · 4 mana · 4/2 | Arrancada + Envenenar 1 |
| Corvo das Brumas · 3 mana · 2/3 | Voo + Envenenar 1 |

**Vigor:** ao atacar ou defender, usa `máximo(ataque base, vida atual)` antes dos danos simultâneos. Também vale em ataques ao castelo. Cura e crescimento atualizam essa força; o atributo base é preservado e a conversão de vida não altera o ataque exibido. Atacar exige estar pronto e esgota; defender funciona mesmo esgotado. Não aumenta dano mágico nem Veneno.

**Descarga:** `(2 + Amplificar) × 2` se houver Armadura maior que zero; caso contrário `2 + Amplificar`. Ignora Armadura, sem reduzi-la ou removê-la. Alvo: criatura inimiga.

**Envenenar:** aplica em ataque e contra-ataque físico (inclusive se Armadura absorver tudo). Não aplica por magia. Acumula no alvo, criatura; castelos são imunes. No fim do turno do dono do alvo, sofre N uma vez e o Veneno termina completamente. Cura remove todo o Veneno, mesmo em alvo com vida cheia. A morte da fonte não cancela cargas já aplicadas.

**Abertura:** primeiro jogador sorteado recebe 3 cartas; segundo recebe 4. Cada um tem uma primeira troca gratuita de qualquer subconjunto da mão. O segundo jogador também recebe uma segunda troca de até uma carta. Compram-se substituições antes de devolver e embaralhar as cartas escolhidas; outra cópia pode aparecer. Depois começa a compra normal de cada turno. IA troca cartas de custo 4 ou mais. Nove espaços salvos e limite de duas cópias continuam valendo.

**Interface:** tela de escolha da mão, palavras-chave com explicações ao passar o mouse, força de Vigor e cargas de Veneno em campo e contador no castelo. Duas ilustrações novas geradas com image_gen integrado, salvas em `assets/art/vigor_vow.webp` e `assets/art/conductive_bolt.webp`. Prompts em `docs/art-prompts/vigor-and-venom.md`.

**Validação:** cenários de combate simultâneo, concessão não cumulativa, Vigor sem efeito ofensivo ou contra magia, Amplificar + Armadura, Veneno acumulado com dano único, cura sem limpeza, morte da fonte, fim da partida antes da compra, conservação do deck no mulligan e abertura com qualquer jogador começando. Ver `tests/test_vigor_venom_opening.gd` e `tests/test_opening_ui.gd`.

O relatório de balanceamento anterior corresponde às regras anteriores a esta atualização; seus percentuais não representam as novas habilidades. Esta alteração não inclui uma nova rodada de balanceamento nem publicação no GitHub.
