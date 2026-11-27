# 0034 — Empurrão no topo do gerador principal e do tanque

- **Data**: 2026-11
- **Status**: aceita

## Contexto
O jogador e o galão não devem ficar parados em cima das máquinas. O gerador de emergência e a casa de máquinas têm um telhado invisível de duas águas a 60° (`SlipperyRoof`, camada `slippery_tops`). O gerador principal e o tanque ficam embaixo da escada em caracol, que passa de 0,25 a 1,6 m acima deles: um telhado com 46° ou mais furaria os degraus (até 0,48 m no gerador) e, no tanque, também a parede. As opções eram empurrar quem para em cima, mudar as máquinas de lugar ou deixar como estava; o desenvolvedor escolheu o empurrão.

## Decisão
- Um marcador `PushOffTop` (`Node3D`, `components/push_off_top.gd`) fica filho do corpo da máquina, no centro do topo, com o tamanho do topo e a velocidade do empurrão (2 m/s). A direção é a da borda mais próxima no plano do topo (`PushOffRules.edge_direction`).
- Quem se apoia procura o marcador no corpo em que pisa: o `Player`, com uma sondagem curta da cápsula para baixo depois do `move_and_slide` (parado, ele não reporta o piso), e o `Jerrycan`, pelos contatos do `_integrate_forces` com apoio de até 45°. O jogador recebe o empurrão no alvo do `_walk`, sem a parte da entrada que vai contra ele (`PushOffRules.steer`); o galão desliza pelo menos na velocidade do empurrão.
- Nenhuma forma de colisão nova: a escada, os raios de interação e a navmesh não mudam.

## Alternativas descartadas
- **Área invisível sobre o topo**: no tanque redondo, ela teria de ser grossa e pegaria quem passa na escada.
- **Mudar as máquinas de lugar**: mexe na arrumação do térreo.

## Consequências
Uma máquina nova sem espaço para o telhado ganha o empurrão só com o marcador na cena. A borda mais próxima ignora obstáculos: se ela ficar embaixo da escada, onde o jogador não cabe de pé, ele pode ficar preso empurrando contra o degrau (a validar jogando; se acontecer, o marcador pode ganhar os lados permitidos). Outros corpos (o Afogado) não são empurrados.
