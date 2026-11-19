# Multiplayer por IP

Versão base baixada antes da implementação: `6d11a53` (main de flavw/Realmrift).

## Jogar

1. Use a mesma versão do jogo nos dois computadores.
2. Abra Multiplayer no menu inicial e escolha um deck normal válido de 22 cartas.
3. O anfitrião clica em Criar partida. O lobby exibe seus IPs locais e a porta UDP em uso.
4. O convidado informa o IP do anfitrião e a mesma porta e clica em Entrar pelo IP.
5. Os dois confirmam a própria mão inicial. A escolha de quem começa é aleatória.

Porta padrão: **24567/UDP**. Na mesma máquina, use duas instâncias e o IP `127.0.0.1`. Na mesma rede, use o IP local mostrado pelo anfitrião. Na internet, encaminhe UDP no roteador e permita o jogo no firewall, ou use uma VPN de rede local. O jogo não faz alterações automáticas no roteador/firewall. Não há servidor central nem cadastro.

## Escopo e resolução

- ENet para dois aplicativos nativos; um jogador hospeda a simulação.
- O lobby valida os decks e compara protocolo e catálogo de regras antes de iniciar.
- O host sorteia compras, efeitos e o primeiro turno. O convidado envia apenas intenções de jogada.
- O host valida o remetente, a revisão da partida, custos, turno, alvos e demais regras antes de alterar o duelo. Confirmações simultâneas de mulligan são independentes.
- Ambos recebem o estado do próprio ponto de vista: seu campo embaixo, inimigo em cima. Efeitos visuais usam os mesmos IDs de unidades e registros de ações remapeados.
- O estado enviado oculta a mão do outro jogador, toda ordem futura de compra e a escolha da armadilha inimiga. O host ainda executa a simulação completa em sua própria máquina; isto é um modo de partidas entre conhecidos, sem sistema competitivo de antitrapaça.
- Ataques em grupo e ataques automáticos são resolvidos e enviados na ordem. Magias com dois alvos, cura, dano necrótico, Fúria e Chamados usam o motor existente.
- Desistência encerra o duelo. Desconexão abre um aviso e permite retornar ao lobby. Não há retomada de partida ou revanche automática nesta versão.
- Nenhuma recompensa, XP ou item de aventura participa do duelo. Entrar no multiplayer não abandona nem modifica a expedição salva.
- O atalho de vitória de playtest fica desativado no multiplayer. Reinício local e edição de deck durante a partida também ficam desativados.

## Arquivos

`scripts/duel_network.gd`: autoload que mantém a conexão, handshake e autoridade do host.

`scripts/network_duel.gd`: validação de comandos, projeção e ocultação de informações privadas.

`multiplayer_lobby.tscn` e `scripts/multiplayer_lobby.gd`: criar/entrar, escolha do deck e status de conexão.

`scripts/main.gd`: envia as ações de interface e anima os estados recebidos, sem executar IA no multiplayer.

## Verificações

- `tests/test_network_duel.gd`: projeção dos dois lados, privacidade, comandos inválidos, cura aliada, dano inimigo, magias de dois alvos, armadilhas e decks.
- `tests/network_peer_runner.gd`: duas instâncias reais, duelo inteiro via ENet e comparação do hash público final.
- `tests/network_ui_peer.gd`: mesmo teste através dos métodos da interface, com animações, mulligan e resultado.
- `tests/network_connection_runner.gd`: versões incompatíveis e desconexão durante a partida.

Exemplo de teste local em dois terminais (diretório do projeto, substitua GODOT pelo executável):

```text
GODOT --headless --path . --script tests/network_peer_runner.gd -- host 24568 meu-teste
GODOT --headless --path . --script tests/network_peer_runner.gd -- client 24568 meu-teste
```

Use uma identificação nova (`meu-teste`) em cada execução; relatórios e logs ficam em `work/`, fora do Git. O teste usa conexão local. Acesso pela internet depende da configuração real da rede e não foi validado por esse teste.

## Navegador

O ENet desta implementação não funciona em clientes web. Para manter o anfitrião no aplicativo e permitir um convidado pelo navegador, será necessário exportar o jogo para web e acrescentar WebSocket ou WebRTC. Uma página HTTPS normalmente precisará de WSS/TLS se usar WebSocket. Isso não faz parte desta implementação.

Referências oficiais: [Multiplayer de alto nível](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html), [ENetMultiplayerPeer](https://docs.godotengine.org/en/stable/classes/class_enetmultiplayerpeer.html), [Exportação web](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html).
