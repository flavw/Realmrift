# Facções e Antimagia no código

A interface usa **facções**. A enumeração de CardData é `Faction`; a propriedade exportada e a chave de combate são `faction`. Os identificadores numéricos de 0 a 8 foram preservados. O construtor, filtros, composição, cores, símbolos, recursos de cards, cenas e testes usam essa terminologia.

A habilidade continua chamada **Antimagia** na interface. No código, propriedade, capacidades, eventos, badges e nomes de recursos usam `antimagic`. O Guardião Arcano usa `cards/antimagic_guardian.tres`, a chave `antimagic_guardian`, a arte `assets/art/antimagic_guardian.webp` e o ícone `assets/ui/antimagic-icon.svg`. Os símbolos de facção usam o prefixo `faction-`.

## Compatibilidade

O formato de decks passa à versão 14, com `base_faction`. `scripts/save_schema.gd` converte nomes legados somente na leitura: propriedades de facção, Antimagia, capacidades, bônus, eventos e a chave antiga do Guardião Arcano. Essa conversão é recursiva e também atende expedições salvas no meio de um combate, cartas com itens e metadados. Um valor já escrito com o nome atual tem prioridade sobre uma duplicata antiga.

Ao salvar novamente, os arquivos usam os nomes atuais. Decks, capas, nomes personalizados, facções, cargas restantes, vida e progressão são preservados. Nomes antigos permanecem apenas na compatibilidade e nas fixtures legadas de teste.

Validação: `tests/test_save_schema_renames.gd`, `tests/test_faction_names.gd`, `tests/test_wastes_faction.gd`, `tests/test_arcane_guard_sequence.gd` e `tests/test_arcane_guard_indicator.gd`.
