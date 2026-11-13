# Colheita e reparo da aldeia

## Veneno

Castelos são imunes. Ataques de criaturas com Envenenar continuam causando o dano físico normal ao castelo, sem aplicar Veneno. Qualquer status antigo do castelo é descartado sem dano. Veneno em criaturas mantém acúmulo, ignora Armadura, causa dano no fim do turno do alvo e termina.

## Reconstrução da Aldeia

Mantém custo 2 e restaura 2 de vida do castelo ou de uma Muralha aliada, limitada à vida máxima do alvo. É a exceção que permite reparar Muralhas; habilidades de Cura e Luz Restauradora continuam sem poder curá-las. Não afeta criaturas comuns nem alvos inimigos. Uma criatura que herdou Muralha também é alvo válido.

Se houver qualquer Muralha aliada em campo, clicar na carta abre seleção entre o castelo e as Muralhas aliadas. Cancelar ou escolher um alvo inválido não gasta recursos. Sem Muralha aliada, resolve automaticamente no castelo; Muralhas inimigas não mudam isso. A IA avalia a vida faltante do alvo.

Depois do reparo, compra uma carta se o campo aliado contiver apenas aldeões, ou estiver vazio. Esse requisito não impede o reparo em campos mistos. Pode conjurar em alvo com vida cheia. O efeito de cura e seu som também acompanham o reparo.

## Camponesa e Líder

Camponesa Generosa passa a 1/3, custo 2. Seu Chamado dá +1 de vida atual/máxima permanentemente aos outros aliados, sem restrição de facção. Líder da Aldeia passa a 3/4, custo 4. Sua Aura dá +1 ataque aos outros aliados, sem restrição de facção. Nenhum deles aplica seu próprio efeito em si. Uma segunda fonte pode beneficiar a primeira normalmente.

## Boi da Colheita

Aldeia, custo 3, 2/3, Colheita 1. Cada ativação de Cultivo de um aliado dá +1/+1 permanente ao Boi. Cultivo 2 continua sendo uma ativação; dois aliados com Cultivo 1 são duas. Cultivo recebido pelo próprio Boi também conta. Não reage a Cultivo inimigo, cura, Chamado ou recálculo da interface.

As ativações de Cultivo ocorrem no início do turno do dono. A rotina registra cada ativação e aplica os bônus de Colheita sem criar novos eventos de Cultivo. Assim não existe recursão. Multidão herda e acumula Colheita, como as demais habilidades numéricas, preservando os atributos já ganhos.

Exemplo: dois Fazendeiros e um Boi em campo; no início do turno, o Boi passa de 2/3 a 4/5. Com um Levante da Aldeia adicional, ele herda Cultivo 2 e Colheita 1, produz uma terceira ativação de Cultivo e participa dos bônus de Colheita.

Verificações: `test_harvest_and_repair.gd`, regressões de Aura/Camponesa, Multidão, Veneno, Reconstrução, seleção e marcadores no campo.
