# Farol (estrutura)

## Propósito
Greybox dos dois andares, escada em caracol, porta de entrada e alçapão (GDD 1.2.4, 1.2.11, 1.2.20).

## Componentes
- `lighthouse/lighthouse.tscn` (`Lighthouse`, `lighthouse.gd`, grupo `navigation_source`): CSG com colisão. Farol cônico: `Outer` e `Inner` são `CSGPolygon3D` girados (32 lados planos). Raio interno de 6,5 m no chão a 5,5 m em y=10,8, reto na cabine; parede de 0,5 m na horizontal; térreo em y=0; cabine (andar de cima) em y=10,8, sem janelas; teto em 13,8 m.
- Materiais (`assets/textures/`, `arquitetura.md`): reboco caiado com mofo na parede interna (`worn_mossy_plasterwall`, lado de 2,5 m), tijolo na externa, concreto no térreo, tábuas no piso da cabine e no patamar, reboco no teto, chapa de metal nos degraus.
- Luzes: `InteriorLights` (`lighthouse/interior_lights.gd`) multiplica a energia de todas as luminárias por `light_scale` (0,4; 1 = a energia da cena de cada uma), e o painel de debug a muda ao vivo. Dentro dele, `UpperLights` com três `lighthouse/ceiling_lamp.tscn` (pendente industrial no teto da cabine, `OmniLight3D` de energia 1 e alcance 7) e `LowerLights` com seis `lighthouse/wall_lamp.tscn` (arandela com grade, energia 0,7 e alcance 4,5): quatro no térreo a 2 m e duas acima da escada (3,4 e 7,7 m), em faces da parede onde a escada passa longe. Todas com sombra: sem ela, a luz da cabine atravessava a laje e iluminava o térreo. As do térreo e da escada (`LowerLights`, script `PoweredLights`) apagam quando a mangueira estoura (decisão 0036).
- `lighthouse/spiral_staircase.gd` (`@tool`): gerada por parâmetros. A colisão é uma rampa invisível em segmentos; o visual são degraus soltos de chapa de metal (`metal_plate`), em cunha, presos na parede por uma mão-francesa cada, com vão entre eles e a face de cima na altura da rampa no meio do degrau (`step_rise` 0.16, `step_fill` 0.7; divisão em `SpiralStepLayout`, puro). A malha dos degraus é uma `ArrayMesh` só. Hoje: na base, raio interno 4.9 e externo 6.5; os dois encolhem 0.778 até o topo (`radius_shrink`), acompanhando a parede. O nó é girado 62° em Y; vai de 0 a 8.4 m em 1.045 volta, seguindo a parede, e termina em (4.85; 8.4; −0.84), na entrada do patamar sob o alçapão. Ao mudar a inclinação da parede, ajuste também `radius_shrink`.
- `LadderLanding` (patamar com topo em 8.4 m, x 4.05–5.75, z −0.9–1.1): embaixo do vão do alçapão, no fim da escada.
- `lighthouse/ladder.tscn` (`Ladder`, `@tool`, instância `Ladder` em (4.7; 8.4; 1.03), girada 180°): escada de mão de 2.4 m do patamar até o piso da cabine, encostada na borda z≈1.08 do vão; sobe-se de frente para +Z e sai-se para a frente, no piso. Colisão: placa fina na camada `world` que acaba no nível do piso. `ClimbZone` (camada `ladders`) cobre o lado de quem sobe e, acima do topo, a saída para o piso; é onde o jogador se agarra (`jogador.md`). Nenhuma peça passa do nível do piso: as laterais acabam no topo e o último degrau fica abaixo dele (a borda do piso faz esse papel).
- `LadderLink` (`NavigationLink3D`, bidirecional, sempre ligado): do patamar (4.7; 8.4; 0.45) ao piso da cabine (4.7; 10.8; 1.6), por onde o Afogado usa a escada de mão (`afogados.md`, decisão 0026).
- Passagens (decisão 0019): a raiz de cada cena é o buraco, um `CSGBox3D` de subtração. Para mover, arraste o nó dentro do pai CSG; ele precisa continuar filho direto desse pai.
- `lighthouse/trapdoor.tscn` (`Trapdoor`, filho de `UpperFloor`): buraco no piso de cima encostado na parede, em x 3.95–5.45, z −0.76–1.08 (nó girado −90° em Y). Dobradiça na borda do lado da parede (x≈5.5); o painel (1.93 × 1.6, um pouco maior que o vão) abre girando para cima, ficando em pé rente à parede. Interativo para abrir e fechar: um volume fixo de 1 m de altura sobre o vão (não gira com o painel), para o alçapão ser mirado de longe, aberto ou fechado; e trinco ao lado que liga e desliga (regras em `TrapdoorRules`; `toggle_latch()` é público para o painel de debug).
- `lighthouse/entrance_door.tscn` (`EntranceDoor`, filho de `Shell`): buraco e folha de 1,4 × 2,2 m, no centro de uma face plana da parede (−50,625°). A folha é vertical, em r≈6,53, rente à face interna no chão; por dentro, o vão fica mais fundo no alto. Painel na camada `barriers`; a folha visível anima à parte no arrombamento; barulho de aproximação do lado de fora.
- Térreo: tanque de combustível com o slot do galão (x −5.0, z −1.0) e gerador principal (x −3.3, z 4.0), ligados pela mangueira (`energia-e-combustivel.md`); casa de máquinas (no centro, x 0, z 0; carcaça com o ponto de conserto, `feixe.md`) e gerador de emergência (x −0.07, z −1.86) (decisão 0035).
- Fora da cena da porta, sem acompanhá-la: `DoorInside`, `DoorCamera`/`DoorView` (`exterior-e-cameras.md`) e as fendas `DoorHole2` e `DoorHole3`, acima dela.
- Cabine: mesa com um monitor de três canais (porta e os dois lados do mar; instância `Monitor` com escala 1,4, tela de 0,7 × 0,525 m), rádio e cadeira (`Chair`, ver `jogador.md`); a tubulação da casa de máquinas sobe pelo centro até a cabeça do farol no telhado, com a câmara da lâmpada e a portinha de troca na cabine (y 11.9); alavanca num poste (x −1.65, z −2.1) com o medidor do gerador de emergência no painel (`energia-e-combustivel.md`, `feixe.md`).

## Regras
- Queda do patamar (8.4 m) até o térreo é fatal com a config padrão; do meio da escada, só bloqueia a corrida.
- A geometria evita sobrepor, na mesma posição horizontal, piso andável de níveis diferentes no encontro escada/patamar: o Recast soldava vértices entre eles e quebrava a navmesh. A escada não passa de 8.4 m, para deixar 2.1 m de folga sob a laje do piso de cima (fundo em 10.5).
- Alçapão: `CLOSED` ou `OPEN`. Abre e fecha e liga o trinco só com os pés do jogador acima da dobradiça (`min_user_height`); exige mãos livres. O painel também exige os pés fora da área que ele varre ao girar, com folga `user_clearance` (0.35 m, o raio da cápsula): em cima dele, o jogador seria arremessado (`TrapdoorRules.is_clear_of_panel`).
  - Trinco: liga e desliga com o alçapão fechado, segurando E por `latch_toggle_seconds` (0 = um toque). Trancado, o alçapão não abre.
  - Nevoeiro em `TRAPDOOR` ou acima desliga o trinco e impede ligá-lo; depois de ele sair, só passado `latch_relock_cooldown_seconds`.
  - O Afogado batendo com o trinco desligado abre o alçapão em `resistance_seconds` (acumula enquanto ele bate; recomeça quando para). Aberto por ele, só fecha passado `reclose_cooldown_seconds`.
- Porta: não quebra nem tem conserto; a colisão nunca abre, então o jogador nunca sai do farol. O arrombamento do Afogado é só som e a folha abrindo e voltando.


## Sinais
- `Trapdoor.state_changed(state)`, `Trapdoor.latch_changed(latched)`.
- `Lighthouse.set_fog_stage` → `Trapdoor.set_fog_present`; `DrownedDirector` → `Trapdoor.set_banging`, `EntranceDoor.show_approach`, `EntranceDoor.burst_open`.

## Testes
- `test/unit/spiral_staircase_mesh_test.gd`: cada triângulo dos degraus é de frente para a sua normal (invertida, a luz não pega na escada).
- `test/unit/spiral_step_layout_test.gd`: quantidade de degraus pela altura, trecho centrado na fatia com vão, sem vão com `fill` 1.
- `test/unit/trapdoor_rules_test.gd`: trinco só fechado e trava o alçapão; nevoeiro destranca e o intervalo para religar; batidas só abrem destrancado; resistência recomeça; intervalo para fechar depois de aberto pelo Afogado; área do painel com a folga.
- `test/scenes/trapdoor_test.gd`: em cima do painel, o jogador não o usa; mirando o vão a mais de 1 m da borda, o abre; com o painel aberto, rente à parede, o fecha de dentro da cabine.
- A navegação na escada é coberta por `test/scenes/drowned_entry_test.gd`.
