# Aldeia e Necrópole

Atualização: [Ermos](ERMOS.md) agora complementa Horda e Necrópole. Lobo da Noite e Zumbi Serviçal pertencem aos Ermos; Necromante do Véu pertence à Necrópole. A versão de decks atual é 13; as notas de criação abaixo registram a versão 12.

Os antigos Neutros passam a se chamar **Aldeia**. Seu identificador numérico permanece 2 para preservar decks e expedições. Os campos de persistência legados `neutral_deck_only` e `neutral_deck` continuam compatíveis com os arquivos existentes.

## Composição

- Vanguarda, Arcano, Submundo, Luminares e Selvagem aceitam Aldeia como complemento.
- Horda não aceita nenhuma carta da Aldeia, incluindo criaturas não humanas e magias.
- Necrópole também não usa os Aldeia como complemento.
- Decks exclusivamente da Aldeia continuam permitidos. Cartas exclusivas desses decks mantêm a restrição.
- A aventura conserva sua regra própria: o protagonista pode recrutar de qualquer facção após o draft inicial.

A coleção, os filtros, os símbolos, a construção, o salvamento e a validação de partidas usam as novas regras. O draft inicial e os inimigos da Horda na aventura também não usam Aldeia.

## Necrópole

Facção 7, cores verde espectral e símbolo de crânio. As duas primeiras cartas são colecionáveis, aparecem no construtor e podem entrar nas ofertas/recompensas da aventura. Ainda não há cartas suficientes para montar um deck próprio legal de 22 cartas; a facção não foi adicionada às opções iniciais da aventura nem aos decks padrão da IA.

| Card | Tipo | Custo | Ataque/vida | Habilidades |
| --- | --- | --- | --- | --- |
| Necromante das Cinzas | Humano | 4 | 2/4 | Colher Almas 1; Disparo Necrótico 1 por 1 mana |
| Sentinela da Cripta | Morto-vivo | 2 | 1/3 | Bloqueio 1 |

**Colher Almas N:** quando outro aliado morre, a criatura recebe +N de ataque e +N de vida permanentemente durante aquele combate. Cada morte conta uma vez para cada fonte viva. Mortes inimigas e a própria morte não ativam. Se a fonte morrer simultaneamente, não recebe o bônus e não volta à vida. Há ícone no card completo, miniatura, descrição ao inspecionar, registro de combate e efeito visual de melhoria.

O Sentinela mantém as regras existentes de Mortos-vivos: Cura causa dano mágico; não recebe imunidade automática a Veneno.

## Adaptação da Horda

O Fungo da Ninhada passa a ser Horda, de acordo com sua identidade e seu texto de ambientação. O deck padrão continua com 22 cartas, substituindo Lobo da Noite por **Lobo dos Ermos** (mesmos atributos e Fúria 1) e Reconstrução da Vila por **Uivo de Guerra** (magia Horda de custo 1, concede +1 ataque aos Monstros aliados até o fim do turno). Os dois cards de apoio reaproveitam artes existentes.

Ao carregar decks anteriores à versão 12, essas duas substituições são feitas somente nas listas da Horda; nomes, espaços e seleção ativa são preservados. Outras composições antigas que se tornem incompatíveis continuam editáveis, mas precisam ser corrigidas antes de jogar. O Carniçal invocado pertence agora à Necrópole e continua sendo uma ficha não colecionável.

Artes e prompts: [Necrópole](art-prompts/necropolis.md). Verificação principal: `tests/test_villagers_necropolis.gd`.
