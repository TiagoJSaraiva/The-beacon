# 0033 — Corpo humano do jogador: duas cópias da malha e braços por camada

- **Data**: 2026-11
- **Status**: aceita

## Contexto
O jogador era só uma câmera: a lanterna e o galão flutuavam na frente dela e, ao passar perto de uma luz, só a sombra do objeto aparecia. O desenvolvedor pediu um corpo humano, com modelo e animações baixados (não precisam ser CC0, só gratuitos, porque é protótipo), pernas animadas separadas do tronco e da cabeça, e a lanterna e o galão nas mãos. O pacote *Universal Animation Library* (Quaternius, CC0, versão Standard) traz um manequim com esqueleto de 65 ossos e 43 animações sem root motion, entre elas `Idle_Torch` (lanterna na mão esquerda). Não tem andar de lado nem de costas, nem pose de carregar.

## Decisão
- O corpo é a cena `player/body/player_body.tscn` (`PlayerBody`), filha do `Player`, com o modelo em `assets/models/player_body/` (decisão 0023). O `Player` chama `update_body` a cada quadro com a pose, a velocidade, a base global, a inclinação do olhar e se está no chão.
- A animação vem de um `AnimationTree` montado em código: uma transição entre parado, andar, trote, pulo, sentado e ajoelhado, seguida de `AnimationNodeTimeScale`, e duas camadas `Blend2` com filtro de ossos, uma por braço (`Idle_Torch` na esquerda, `Pistol_Aim_Neutral` na direita, só quando carrega o galão). Pernas e tronco ficam separados pelo filtro de ossos.
- Andar de lado ou de costas: `LocomotionRules` (pura) converte a velocidade para o referencial do corpo, gira as pernas na direção do movimento (até 90°) e, de costas, toca a animação ao contrário. O `TorsoAim` (`SkeletonModifier3D`) desfaz esse giro no `spine_01` e inclina `spine_02`, `spine_03` e `neck_01` com o olhar.
- A câmera fica dentro da cabeça, então a malha existe em duas cópias: a inteira na camada de render 4 (`world_view_body`, projeta a sombra e aparece nas câmeras de segurança) e uma sem os triângulos movidos pelo osso `Head` (peso maior que 0,5) na camada 3 (`player_view_body`, sem sombra), só para a câmera do jogador. A câmera do jogador deixa de fora a camada 4, e as câmeras de segurança, a 3. A luz da lanterna também deixa de fora a camada 4, para o braço não fazer sombra no próprio feixe.
- A lanterna (`Flashlight.follow`) e o galão carregado seguem um `BoneAttachment3D` na mão, com a orientação da câmera (lanterna, para o feixe apontar para onde o jogador olha) ou do corpo (galão, de pé). O corpo fica 0,15 m atrás da câmera para o peito não encher a tela ao olhar para baixo.

## Alternativas descartadas
- **Só braços na câmera (viewmodel)**: resolveria a lanterna que flutua, mas não a sombra, que era o problema.
- **Esconder a cabeça com um plano de corte no shader**: ao olhar para baixo o pescoço inclina e o plano cortava o peito. O corte por peso de pele não depende da pose.
- **Zerar a escala do osso da cabeça**: tiraria a cabeça também da sombra, que é compartilhada com a cópia inteira.
- **Mixamo ou outros modelos**: exigem conta e download manual; o pacote do Quaternius já tinha manequim e a animação da lanterna.

## Consequências
Trocar o modelo exige que o novo tenha ossos com os mesmos nomes (`Head`, `spine_01` a `spine_03`, `neck_01`, `clavicle_*`, `hand_*`) e animações com os nomes de `PlayerBody.STATE_ANIMATIONS`, ou ajustar essas constantes. Uma câmera nova precisa deixar de fora a camada 3 (e, se for a do jogador, a 4), senão vê o corpo duas vezes. O corpo custa uma segunda cópia da malha (~14 mil triângulos) desenhada e uma terceira nas sombras; medido a 1600×900 na GPU integrada, a diferença foi de ~0,1 ms. A pose dos braços é aproximada (a mão atravessa o galão e a lanterna), e subir a escada de mão usa a animação parada.
