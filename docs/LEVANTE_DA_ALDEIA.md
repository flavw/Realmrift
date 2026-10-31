# Levante da Aldeia

Neutra lendária, custo **5 mana**, ataque/vida impressos **\*/\***. Uma cópia por deck, mantendo o limite de 20 cartas. A galeria, coleção e editor incluem a nova carta; os decks salvos não são modificados automaticamente.

## Multidão

Ataque e vida base são o número de criaturas neutras aliadas vivas em campo, incluindo a própria turba. Herda as habilidades das **outros neutros aliados**, mas **não herda Chamados nem habilidades inimigas**. A contagem e a herança são contínuas; uma fonte que sai deixa de contribuir. Bônus permanentes e o dano já sofrido são preservados. Perder um neutro pode reduzir a vida a zero.

Valores numéricos compatíveis somam: Cultivo, Fúria, Armadura, Envenenar, Amplificar, potência de Disparo Arcano e Cura, Colheita, capacidade de Bloqueio e Guarda Arcana. Duas fontes de Cultivo 1 resultam em Cultivo 2. Os custos de ativação seguem o menor custo das fontes da respectiva habilidade; as cartas atuais usam 1 mana. Cura e Disparo continuam esgotando; Fúria não esgota.

Vigor, Voo, Arrancada e Muralha são propriedades únicas. Muralha inclui imunidade a Veneno, proibição de cura e de atacar. Arrancada herdada na entrada prepara a turba; recebê-la depois não a prepara novamente. Vigor concedido permanentemente por magia continua após a fonte de Vigor herdado sair.

Bloqueio e Guarda Arcana mantêm cargas próprias. A capacidade soma as fontes, mas só recupera uma carga por início de turno próprio. Recalcular a herança não repõe cargas gastas. Ganhar uma nova fonte concede a capacidade adicional; perder uma fonte reduz capacidade e cargas. Não copia dano, Veneno recebido, atributos das fontes, raridade ou outras Multidões. Isso evita ciclos entre cópias da turba.

Auras herdadas passam a ser geradas pela própria turba, para o seu lado do campo, com a mesma regra de alvos. Os bônus das fontes originais e da turba acumulam. Bônus de ataque de Aura não viram ataque permanente nem são copiados novamente.

Exemplo: com dois Fazendeiros e um Lobo, entra como **4/4, Cultivo 2 e Fúria 1**. No próximo turno ganha +2 de vida atual/máxima. Se um Fazendeiro sair, perde 1 de ataque e de vida base e passa a Cultivo 1; os ganhos de vida já recebidos permanecem.

## Interface e implementação

`CardData.legendary` define o limite de uma cópia; `DuelMatch.copy_limit` é usado na validação, no editor e na ampliação de decks antigos. A coleção mostra `0 / 1` e LENDÁRIA. Multidão é editável por `CardData.collective`.

`collective_rules.gd` calcula a herança por diferença, preservando dano, bônus permanentes e cargas. A atualização de Auras resolve também mortes decorrentes da redução da vida base e inclui essas mortes na ação para a animação normal. A carta completa mantém as regras resumidas; a ajuda lateral e os ícones de campo mostram as habilidades atuais. O inimigo passa a ser identificado à esquerda por jogador — classe, por exemplo **IA — Neutros**.

`tests/test_peasant_uprising.gd` verifica os limites no editor e salvamento, fontes neutras/de classe/inimigas, exclusão de Chamados, atributos variáveis, crescimento, cargas, Muralha, Aura, mortes, ausência de ciclos, interface e Ladina Relâmpago 3/2.
