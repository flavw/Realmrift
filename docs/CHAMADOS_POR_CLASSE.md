# Chamado por classe e decks novos

A coleção agora tem **29 cartas: 23 criaturas e 6 magias**. Chamado continua sendo o gatilho genérico de entrada pela mão.

| Classe | Carta | Mana | Ataque/vida base | Chamado |
| --- | --- | ---: | --- | --- |
| Guerreiro | Ferreiro da Muralha | 3 | 2/3 | Outro aliado ganha +1 Armadura permanente |
| Mago | Conjuradora do Éter | 4 | 1/3 | Invoca Familiar Rúnico 0/3, Amplificar 1, se houver espaço |
| Ladino | Alquimista das Brumas | 3 | 2/2 | Aplica Veneno 2 a uma criatura inimiga |
| Clérigo | Oráculo da Aurora | 3 | 1/3, Vigor | Outro aliado ganha +2 de vida atual e máxima |

Bônus e veneno usam o lado correto do alvo. Sem alvo disponível, a criatura entra sem aplicar o efeito. Cancelar não gasta mana ou carta. A Conjuradora não pede alvo: o Familiar entra esgotado, sua aura já funciona e não ocupa carta da mão/deck. Se a Conjuradora completar o quinto espaço, não há Familiar. Vida concedida preserva o dano anterior e não limpa Veneno. Chamado não ocorre novamente a cada turno.

## Substituição dos decks

Os três decks salvos passam a ser **Muralha Lunar**, **Caçada das Brumas** e **Círculo Arcano**, com 12 cartas, até duas cópias e uma classe + neutros. A versão do arquivo de decks foi atualizada para 2: listas antigas são substituídas uma única vez, e edições salvas depois disso são preservadas.

Há quatro sugestões no seletor do editor. **Aurora Vital**, de Clérigo, pode substituir qualquer um dos três espaços usando Carregar sugestão e depois Salvar deck. Carregar muda somente o rascunho; não salva automaticamente. A IA também pode usar as quatro receitas.

### Muralha Lunar

2× squire, 2× sentinel, 2× wall_smith, 2× warrior, 1× wall_guard, 1× moon_herald, 2× iron_stance.

### Caçada das Brumas

2× dusk_scout, 2× raven, 2× rogue, 2× mist_alchemist, 1× moon_herald, 1× messenger_hawk, 2× shadow_step.

### Círculo Arcano

2× mage, 2× aether_summoner, 1× runic_familiar, 2× eclipse_channeler, 2× conductive_bolt, 1× astral_flame, 2× squire.

### Aurora Vital

2× cleric, 2× dawn_warden, 2× dawn_oracle, 2× farmer, 1× moon_herald, 1× squire, 1× restoring_light, 1× vigor_vow.

## Validação

Testes do motor e da interface cobrem os quatro Chamados, escolha de lado, Armadura permanente, Veneno acumulativo, bônus de vida/Vigor, token com aura e esgotamento, limites de quatro/cinco espaços, IA, seletor de quatro receitas, regras de cópias/classe e substituição única dos decks antigos.

As simulações e relatórios anteriores usam versões anteriores de cartas e receitas; seus números não avaliam estes quatro Chamados nem os decks novos. Esta atualização não inclui uma nova rodada de balanceamento.

## Artes

Artes geradas com image_gen integrado. Prompts em `docs/art-prompts/class-calls.md`. Arquivos finais:

- `C:\Users\flavi\Documents\Codex\Realmrift\assets\art\wall_smith.webp`
- `C:\Users\flavi\Documents\Codex\Realmrift\assets\art\aether_summoner.webp`
- `C:\Users\flavi\Documents\Codex\Realmrift\assets\art\mist_alchemist.webp`
- `C:\Users\flavi\Documents\Codex\Realmrift\assets\art\dawn_oracle.webp`

GitHub não foi atualizado.
