# Muralha e apresentação das cartas

Muralha da Aldeia é uma criatura neutra de **4 mana, 0/4, Armadura 1 e Bloqueio 4**. O pedido Defensor 4 usa o sistema existente de Bloqueio: deve receber os quatro primeiros ataques físicos, e recupera só uma carga no início do seu turno, até quatro. Voo e magia mantêm suas regras de ignorar a obrigação.

**Muralha:** imune a Veneno, não recebe cura e não declara ataques. A imunidade vale para ataques/contra-ataques e Chamado de Veneno. Cargas indevidas também são removidas antes do dano periódico. Cura de criatura e magia de cura recusam a Muralha, sem consumir carta, mana ou prontidão. Armadura continua reduzindo cada dano físico; dano mágico ignora Armadura.

A proibição de declarar ataques permanece mesmo com Aura, bônus de ataque, preparo ou Vigor. A criatura ainda participa da defesa e contra-ataca conforme seu ataque efetivo, se receber bônus. Aumento de vida atual e máxima por bônus de atributos continua permitido, preservando os ferimentos; não é cura. A IA pula Muralhas ao escolher atacantes.

O custo 4 compensa a proteção inicial e a imunidade com ausência de ataques e de cura. A carta fica disponível na coleção e galeria; os decks salvos e as sugestões existentes não foram substituídos.

## Visual

- Cards da coleção maiores e proporcionais à largura disponível, mantendo quatro colunas.
- Carta localizada com borda dourada de quatro pixels, brilho e fundo destacado; sem texto adicional. Clicar em outra carta da coleção remove o destaque.
- Campo de afinidade removido dos recursos neutros, Inspector, coleção e ajuda.
- Vigor continua calculado no combate, mas não converte vida em ataque no texto da carta completa, campo, galeria ou prévia. Bônus reais de ataque, inclusive Aura, permanecem visíveis.

Recurso: `cards/village_wall.tres`, propriedade editável `wall=true`. Arte: `assets/art/village_wall.webp`, gerada com image_gen integrado. [Prompt](art-prompts/village-wall.md).

Validação: testes de Muralha, Vigor funcional/visual, Aura, filtros/rolagem, Chamados, cura e magias. Capturas estáticas verificadas no Godot. Coleção: 33 cartas, 26 criaturas e sete magias.
