# Instruções do projeto

- Trabalhe na pasta Realmrift.
- Atualize o GitHub somente quando o usuário pedir explicitamente. Mudanças locais não autorizam push ou publicação automática.
- Mensagens que começam com "dúvida" pedem somente explicação, sem alterações.
- Não faça muitos testes de animação. Prefira verificações direcionadas.
- Textos de habilidades: omita atributos que não mudam. Por exemplo, um bônus de +0 ataque/+1 vida deve ser descrito apenas como +1 de vida, inclusive nas explicações completas.
- Terminologia: use facções na interface e `Faction`/`faction` no código. A habilidade Antimagia usa `antimagic`. O nome exibido da habilidade `swift` é Disparada.
- Dano necrótico: cura Mortos-vivos até a vida máxima, ignora Artefatos e causa dano aos demais tipos. Use a resolução compartilhada `apply_necrotic_damage`; essa restauração não é Cura comum, não remove Veneno/Sangramento nem ativa Devoção. Amplificar aumenta a energia necrótica; Antimagia bloqueia o dano aos vivos, e imunidade a magia impede o efeito.
- Não acrescente migrações nem compatibilidade com saves antigos nas próximas mudanças, salvo pedido explícito do usuário.
- CardData: mantenha `cost`, `attack` e `health` no início dos atributos exportados, nessa ordem; os demais ficam em ordem alfabética. Criaturas possuem um único tipo; Pacto Sombrio foi removido.
- Balanceamento: Aldeia e Ermos são facções complementares. Em geral, seus cards devem ser um pouco menos eficientes que os das facções principais de custo semelhante, oferecendo apoio e cobertura sem substituir as especialidades dessas facções. Considere atributos, custo, habilidades e sinergias em conjunto; não aplique uma redução automática global.
- Artes de criaturas em assets/art/, interface em assets/ui/, sons em assets/audio/ e prompts em docs/art-prompts/.
- As artes podem ser diurnas ou noturnas. Não force cenários noturnos por causa do nome do jogo.

- Preferência visual para futuras artes de mulheres adultas: adotar um toque mais sensual, especialmente no desenho das armaduras, mantendo o estilo de fantasia e sem nudez explícita. Não aplicar essa orientação a menores de idade ou personagens com aparência infantil.

- Para novas artes de cards, reserve aproximadamente 7% da altura no topo para o nome e o custo de mana, usando a arte da Camponesa Generosa como referência; evite cobrir o rosto ou detalhes importantes.
