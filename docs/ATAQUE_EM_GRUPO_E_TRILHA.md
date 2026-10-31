# Ataque em grupo, castelos e trilha

## Atacar com todos

O novo botão executa ataques físicos na ordem atual do campo, priorizando o castelo. Se houver Bloqueio, a criatura ataca o primeiro alvo legal; Voo continua podendo atingir o castelo. A fila guarda IDs de atacantes e procura a posição atual antes de cada combate, para que mortes e mudanças de índices não pulem criaturas. Alvos e condições são recalculados após cada ataque.

Só usa ataques legais: ignora criaturas esgotadas, Muralhas e criaturas sem força física, respeitando Vigor. Não ativa habilidades, não gasta mana, não encerra o turno e para se a partida acabar. Durante a sequência, outros comandos de duelo ficam bloqueados. Cada ataque usa a animação e os sons normais; o layout tem tempo para se atualizar entre combates.

## Castelos

Artes originais geradas para `assets/art/castle_player.webp` e `assets/art/castle_enemy.webp`, em azul e vinho. Substituem os símbolos no alvo clicável sem alterar regras, vida ou posicionamento.

## Música

O menu usa a composição instrumental ambiente **Aldeia ao Amanhecer**, sintetizada localmente. Os combates usam **Chariots Of War**, de **Aakash Gandhi**, em `assets/audio/chariots_of_war.ogg`. O crédito também aparece no menu Créditos do jogo.

O autoload `GameMusic` mantém um único reprodutor entre menu, duelo e novas partidas, alternando a faixa conforme a tela. A opção Som pausa/retoma a música junto ao controle dos efeitos, sem reiniciar a faixa. A preferência dura a sessão do jogo.

Para recompor, execute `tools/generate_music.py` usando Python com numpy e ffmpeg no PATH. A partitura, instrumentos e síntese estão no próprio script; não usa gravações externas. A saída é codificada por pipe diretamente para Ogg, sem manter WAV.

## Verificação

`test_attack_all_and_music.gd`: prioridade de alvos, Bloqueio/Voo, mortes e mudança de índices, parada na vitória, ausência de gastos extras, recursos dos castelos, duração/loop/mute e um único reprodutor. A sequência lógica usa animação substituída; `VERIFY_ATTACK_ANIMATION=1` habilita o cenário curto de duas animações reais. Testes sem interface carregam a faixa sem iniciar reprodução de áudio. `ffprobe` confirma estéreo, 44,1 kHz, Ogg Vorbis e duração de 91,43 s.
