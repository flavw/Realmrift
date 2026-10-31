# Necromancia e Cura contra Mortos-vivos

Zumbi Serviçal e Carniçal são do tipo Morto-vivo. Toda Cura aplicada a uma criatura desse tipo causa o mesmo valor de dano mágico: ignora Armadura, não provoca contra-ataque e pode ser anulada por Guarda Arcana. Não restaura vida nem remove Veneno. Quando causa dano, ativa a Devoção de quem usou a Cura; se o dano for anulado, não ativa. Amplificar não aumenta o valor convertido de Cura. Bônus de atributos, como +1 de vida de Chamado ou Cultivo, continuam sendo bônus e não são convertidos em dano.

Habilidades Cura e Luz Restauradora podem atingir Mortos-vivos aliados ou inimigos, inclusive com vida cheia. Alvos vivos continuam sendo apenas aliados feridos/envenenados ou o próprio castelo ferido. Custos e esgotamento continuam normais. Reconstrução continua limitada ao próprio castelo e Muralhas aliadas; se uma Muralha tiver tipo Morto-vivo, sua restauração também se converte em dano.

**Necromante do Véu**: classe/facção Horda, tipo Humano, custo 4, ataque 2, vida 4.

- **Pacto Sombrio**: pode entrar em decks da Horda mesmo sendo Humana. A habilidade não muda seu tipo nem permite outros Humanos sem essa exceção.
- **Chamado**: se ao menos um Humano inimigo morreu nesta partida, invoque um Carniçal 2/2. Deve haver espaço após a Necromante entrar; sem espaço ou sem a condição, somente ela entra.

**Carniçal**: neutro, Morto-vivo, 2/2, entra esgotado. É uma criatura invocada, não colecionável: não ocupa espaço de deck, não aparece na coleção para montagem, mas seu recurso e sua arte podem ser editados na galeria. Não tem Chamado nem outras habilidades.

A condição usa as mortes do lado inimigo, incluindo combate, contra-ataque, magia, veneno ou perda de vida pela saída de outra fonte. Mortes de Humanos aliados e de criaturas inimigas de outros tipos não contam. A condição permanece satisfeita até o fim da partida, e cada morte é registrada uma única vez. A Necromante continua Humana para essa regra caso morra do lado inimigo.

A receita Horda das Brumas da IA inclui duas Necromantes no lugar dos Familiares Rúnicos. Decks salvos permanecem preservados.

Validação: `tests/test_necromancy.gd` verifica Cura ofensiva, Armadura, Guarda Arcana, Veneno, Devoção, custos, prontidão, IA, exceção de composição, mortes, invocação e campo cheio. Artes geradas com imagegen, prompts em `art-prompts/necromancer-and-ghoul.md`.
