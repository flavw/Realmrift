# Cripta Profanada, Esqueleto Inquieto e Zumbi

| Card | Facção | Tipo | Custo | Ataque/vida | Habilidades |
| --- | --- | --- | --- | --- | --- |
| Cripta Profanada | Necrópole | Artefato | 4 | 0/5 | Muralha; Reanimar: Zumbi 2/2 |
| Esqueleto Inquieto | Necrópole | Morto-vivo | 1 | 1/1 | Disparada, Impulsivo |
| Zumbi | Necrópole | Morto-vivo | 2 | 2/2 | Sem habilidades; apenas invocado |

A Cripta é uma criatura com a habilidade Muralha: não pode atacar nem receber Veneno. Não tem Armadura ou Bloqueio adicionais. **Reanimar** invoca um Zumbi no início de cada turno de seu dono, antes da compra normal, sem gastar mana ou cartas da mão. Não invoca ao entrar em campo nem no turno adversário. Respeita o limite de seis criaturas; campo cheio faz aquela ativação ser perdida. Cada Cripta pode invocar uma vez por início de turno.

O Zumbi entra esgotado e fica pronto no próximo turno de seu dono. Os aliados já presentes são preparados antes das novas invocações. Invocações automáticas recebem som e efeito de entrada, funcionam com a IA e mantêm as regras normais de criação de criaturas e bônus da aventura. O token não herda atributos/equipamentos da Cripta.

O Esqueleto tem **Disparada** e pode atacar no turno em que entra em campo. Também tem [Impulsivo](IMPULSIVO.md): se encerrar o turno ainda apto e sem ter atacado, realiza um ataque físico automático como Atacar com todos. Disparada é o termo usado na interface e nas descrições para a habilidade `swift`.

Cripta e Esqueleto são colecionáveis e entram na coleção e nas ofertas/recompensas da aventura. O Zumbi é um token não colecionável, separado do Zumbi Serviçal, com arte própria.

`CardData.turn_summon_key` indica o recurso a invocar no início do turno e permanece em ordem alfabética depois de `turn_draw`. A habilidade tem ícone próprio e explicação ao inspecionar o card. Não foram adicionadas migrações de saves antigos.

Artes: `assets/art/defiled_crypt.webp`, `assets/art/restless_skeleton.webp`, `assets/art/crypt_zombie.webp`. Prompts em [Cripta e Esqueleto](art-prompts/crypt-skeleton.md) e [Zumbi](art-prompts/crypt-zombie.md).

Validação: `tests/test_necropolis_crypt_skeleton.gd` e `tests/test_single_creature_type.gd`.
