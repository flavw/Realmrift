# Expansão: arquétipos e magias

Foram adicionadas 12 cartas: uma criatura de cada uma das quatro classes jogáveis, quatro neutros de apoio e uma magia por classe. A expansão inicial levou a coleção a 22 cartas. A atualização de Vigor/Veneno acrescentou duas magias: total atual de 24 cartas (18 criaturas e 6 magias); veja [as regras novas](REGRAS_VIGOR_VENENO.md). Neutro é um conjunto compartilhado, sem classe de herói própria.

| Arquétipo | Carta | Classe/tipo | Mana | Ataque/vida | Habilidades/efeito |
| --- | --- | --- | --- | --- | --- |
| Proteção | Guardião da Muralha | Guerreiro/criatura | 4 | 2/4 | Armadura 1; Bloqueio 2 |
| Proteção | Vigia do Portão | Neutro/criatura | 2 | 2/2 | Bloqueio 1 |
| Proteção | Postura de Ferro | Guerreiro/magia | 2 | — | Aliado ganha +1 ataque e +2 Armadura permanentes |
| Arcano | Canalista do Eclipse | Mago/criatura | 3 | 1/3 | Disparo Arcano 2, custa 1 mana + esgotar |
| Arcano | Familiar Rúnico | Neutro/criatura | 2 | 0/3 | Amplificar 1 |
| Arcano | Chama Astral | Mago/magia | 3 | — | 3 de dano mágico a criatura inimiga |
| Ímpeto | Batedora do Crepúsculo | Ladino/criatura | 2 | 2/2 | Arrancada |
| Ímpeto | Falcão Mensageiro | Neutro/criatura | 1 | 1/1 | Voo |
| Ímpeto | Passo das Sombras | Ladino/magia | 1 | — | +1 ataque, Voo e Arrancada neste turno |
| Sustento | Guardião da Aurora | Clérigo/criatura | 4 | 2/5 | Vigor; Bloqueio 3 |
| Sustento | Peregrina da Vida | Neutro/criatura | 3 | 1/4 | Cultivo 1 |
| Sustento | Luz Restauradora | Clérigo/magia | 2 | — | Cura até 4 de vida de aliado ou castelo próprio |

## Nova habilidade: Amplificar N

Enquanto a criatura estiver viva em campo, magias e habilidades de dano mágico aliadas causam +N de dano. Duas fontes somam seus bônus. O bônus termina imediatamente quando a fonte sai do campo. Não aumenta dano físico, Fúria, cura ou efeitos de proteção. Não altera custos nem esgotamento. O valor atual aparece nas prévias e ações de Disparo Arcano e Chama Astral.

## Magias

Magias são cartas de uso único. Escolha Conjurar, depois clique em um alvo permitido. A seleção pode ser cancelada sem custo. Somente um alvo válido consome mana e a carta. Magias não têm ataque/vida, não entram no campo, não esgotam criaturas por si mesmas e podem ser usadas com cinco criaturas em campo. Bloqueio não restringe seu alvo e não é consumido por dano mágico.

- Postura de Ferro e Passo das Sombras só atingem criaturas aliadas vivas. Postura não muda prontidão; Passo pode preparar uma criatura recém-invocada que ainda não usou ação que esgota. Nenhuma das duas aumenta a vida.
- Chama Astral atinge somente criaturas inimigas, ignora Armadura e não tem contra-ataque. Não atinge castelos.
- Luz Restauradora só atinge aliados feridos ou seu castelo ferido. Respeita a vida máxima atual (inclusive Cultivo) e o limite 20 do castelo. Alvos cheios ou inimigos são inválidos.
- A IA usa as quatro magias pelas mesmas regras de custo e alvo, incluindo Passo depois de um ataque e cura quando há dano suficiente.

## Decks e futuro

A regra atual continua: 12 cartas, até duas cópias, três espaços salvos. Decks existentes continuam válidos e não são substituídos. Os neutros de apoio podem entrar em qualquer deck; Afinidade é uma indicação de sinergia, não uma restrição.

A restrição de uma única classe jogável + neutros permanece planejada para o futuro e ainda não é imposta ao editor. As três sugestões iniciais já usam Guerreiro+neutros, Ladino+neutros e Mago+neutros. Para montar um exemplo de Clérigo, use duas cópias de cada: Clériga da Aurora, Guardião da Aurora, Peregrina da Vida, Fazendeiro, Escudeiro da Lua e Luz Restauradora.

## Edição no Godot

Em CardData, Card Type escolhe Creature ou Spell. Spell Effect, Spell Value e Spell Secondary configuram os quatro efeitos implementados. Magic Power configura Amplificar; Affinity é um texto explicativo para neutros. Atributos, nomes, descrições e arte continuam editáveis no Inspector. Efeitos inéditos exigem implementação no motor e na IA.

Os SVGs de mana e ampulheta estão em assets/ui/. As 12 artes novas estão em assets/art/; foram geradas com imagegen, sem texto ou moldura. Prompts em docs/art-prompts/archetype-expansion.md. O número de mana é um Label preto em negrito sobre um círculo claro. O nome usa correção vertical de 6 px para alinhar visualmente a fonte At Dawn ao custo.

## Verificações

- tests/test_spells.gd: tipos, alvos inválidos sem consumo, custos, mortes, aura, buffs, preparo, cura, campo cheio, Bloqueio 2 e IA.
- tests/test_spell_ui.gd: seleção de alvo, conjuração, visibilidade do tipo Magia, uma animação e carregamento SVG.
- Regressões: testes de combate (20 partidas), habilidades, expansão anterior, suporte, decks, menu e ajuda lateral.

Balanceamento inicial: proteção investe em defesa física; arcano oferece remoção e bônus que dependem de uma criatura 0/3 sobreviver; ímpeto troca resistência por velocidade; sustento investe mana e ações para manter criaturas vivas. As cartas precisam continuar sendo avaliadas em partidas reais.
