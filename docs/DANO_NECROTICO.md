# Dano necrótico e Maré Sepulcral

`CardData.DamageType` identifica os tipos de dano físico, mágico e necrótico. A resolução necrótica compartilhada está em `DuelMatch.apply_necrotic_damage`.

| Alvo | Resultado |
| --- | --- |
| Morto-vivo | Recupera vida até seu máximo atual |
| Artefato | Ignora o efeito, sem gastar cargas de Antimagia |
| Humano, Fera, Monstro, Elfo | Sofre dano que ignora Armadura |

Antimagia pode anular o dano aos vivos, mas não impede a restauração dos Mortos-vivos nem perde cargas por ela. Imunidade a magia impede ambos os efeitos. Amplificar aumenta o valor necrótico, incluindo a vida restaurada. Usar uma magia ou um disparo necrótico ativa Ressonância uma vez por ação.

A restauração necrótica é uma conversão do dano, não Cura comum: não causa dano em Mortos-vivos, não remove Veneno/Sangramento e não ativa Devoção. Cura comum mantém suas regras anteriores, inclusive causar dano mágico a Mortos-vivos. A conversão não revive criaturas mortas e não aumenta sua vida máxima.

## Maré Sepulcral

Magia da Necrópole, custo 4, aplica 2 de energia necrótica a todas as criaturas inimigas e a todos os Mortos-vivos dos dois lados. Não atinge castelos. Aliados vivos não são afetados; Artefatos são ignorados. Pode ser usada apenas quando houver ao menos uma criatura elegível; a IA avalia a cura concedida aos Mortos-vivos inimigos antes de decidir conjurá-la.

Arte: `assets/art/sepulchral_tide.webp`. [Prompt completo](art-prompts/sepulchral-tide.md). Ícone: `assets/ui/necrotic-icon.svg`.

## Necromante das Cinzas

Mantém custo 4, 2/4 e Colher Almas 1. Seu antigo Disparo Arcano foi substituído por **Disparo Necrótico 1**, que custa 1 mana e esgota. A propriedade `necrotic_damage` fica em ordem alfabética entre `magic_splash` e `neutral_deck_only` no Inspector.

O disparo pode mirar criaturas/castelo inimigos ou Mortos-vivos aliados; não mira Artefatos nem aliados vivos. Também pode curar Mortos-vivos inimigos. A prévia informa a vida restaurada e o cursor mostra o valor em verde com sinal positivo quando o alvo é Morto-vivo. O dano necrótico usa efeito violeta; a restauração usa o efeito verde de vida.

A IA pode curar seus Mortos-vivos e evita usar o disparo para beneficiar inimigos. Disparos contra castelos continuam sujeitos às armadilhas existentes. A carta da Maré e suas regras estão disponíveis na coleção e nas ofertas da aventura; não foram acrescentadas migrações de saves.

Validação: `tests/test_necrotic_damage.gd`, `tests/test_arcane_resonance.gd`, `tests/test_aim_cursor_damage.gd` e `tests/test_single_creature_type.gd`.
