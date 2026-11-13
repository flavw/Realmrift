# Gema menor, editor de decks e Arauto da Lua

- Gema de mana: 40 px no custo superior e 28 px nas habilidades, mantendo centralização óptica e número editável.
- Lista do editor: gema com número de mana em cada linha, facção atual visível e inclusão de cartas de outras facções bloqueada.
- Cada deck: 12 cartas, até duas cópias, uma facção + aldeões. Só aldeões também é permitido; afinidade não restringe o uso de aldeões.
- Decks antigos mistos: preservados como rascunhos para correção; não podem iniciar uma partida nem ser salvos sem corrigir.
- **Arauto da Lua**: aldeão, 2 mana, 1/2, **Chamado**. Ao entrar pela mão, concede +1/+1 permanente a outro Humano aliado escolhido. Sem Humano aliado válido, não aplica bônus. Alvos esgotados são válidos; o bônus não prepara nem esgota. Sem alvo próprio, inimigo ou castelo. Cancelar/alvo inválido não consome carta ou mana. Bônus de invocações diferentes acumulam; não repete no início de turnos.

Arte gerada com image_gen integrado e salva em `C:\Users\flavi\Documents\Codex\Realmrift\assets\art\moon_herald.webp`; prompt em `docs/art-prompts/moon-herald.md`. Coleção atual: 29 cartas, sendo 23 criaturas e 6 magias.

Verificado com testes do motor e da interface: Chamado com e sem aliado, alvo obrigatório, consumo atômico, permanência/empilhamento, campo cheio, IA escolhendo aliado, facção única, preservação de decks antigos, reparo antes do mulligan e gemas na lista do editor.

A última rodada solicitada de 15 partidas foi concluída antes desta adição, com Vigor ofensivo e Disparo Arcano 2 por 1 mana: Guerreiro 4–1 Ladina, 4–1 Clérigo e 3–2 Mago. As listas já eram de facção única + aldeões e não continham o Arauto. Os resultados e logs dessa rodada permanecem separados em `relatorio-guerreiro-rodada-2.md` e arquivos JSON/CSV.

GitHub não foi atualizado.

Atualização: Chamado é o gatilho, e o efeito é separado por `entry_effect`. O Arauto concede +1 ataque e +1 vida atual/máxima; o resumo exibido é Chamado — +1/+1.
