# Energia e combustível

## Propósito
Geradores, tanque, mangueira e galão (decisão 0017; GDD 1.2.5, 1.2.24).

## Componentes
- `Generator` (`power/generator.gd`, regra `GeneratorState`): o mesmo script nos dois papéis, escolhidos por `feed`, cada um com a sua cena e o seu modelo. `GeneratorState.set_fuel_ratio` define o combustível (painel de debug).
  - `power/main_generator.tscn` (`MainGenerator`, térreo, `feed = HOSE`, modelo `main_generator`): funciona enquanto a mangueira está inteira; sem medidor nem boca de combustível.
  - `power/emergency_generator.tscn` (`EmergencyGenerator`, térreo, ao lado da casa de máquinas, `feed = FUEL`, modelo `emergency_generator`): combustível e o componente `FuelInlet`.
- `power/fuel_gauge.tscn` (`FuelGauge`, `CabinFuelGauge` no painel da alavanca, na cabine): medidor de barra, só de leitura, que repete o nível do gerador de emergência para quem está em cima decidir quando descer. Funciona sem energia. `Generator.fuel_ratio_changed` → `Lighthouse` → `FuelGauge.show_fuel_ratio`.
- `power/fuel_inlet.tscn` (`FuelInlet`): medidor (barra), tampa e boca para o galão (topo). Mostra o nível que o gerador passa e emite `pour_completed`; o gerador o recebe por `@export var fuel_inlet` e reclama no console se o papel por combustível ficar sem ele.
- `fuel/fuel_tank.tscn` (`FuelTank`, térreo, modelo `gas_tank`): reserva infinita; colisão cilíndrica só no corpo do tanque, deixando livre o vão do slot embaixo dele; mangueira até o gerador principal; estourada, some e fica o toco com a poça. Contém o `JerrycanSlot`. `debug_burst_on_start` começa a noite com ela estourada (só depuração).
- `fuel/jerrycan_slot.tscn` (`JerrycanSlot`): prateleira no tanque; com o galão devolvido, enche-o e mostra o nível dele (barra).
- `fuel/jerrycan.tscn` (`Jerrycan`, `RigidBody3D` na camada `props` que reporta contatos, regra `JerrycanState`, modelo `fuel_container` com o bico para +X; a caixa de colisão cobre só o corpo): no slot (parado), na mão (escondido, sem colisão) ou solto no mundo (com física).
- Fiação em `Lighthouse` (energia, galão) e no `Player` (soltar).
- Topo do gerador de emergência: telhado invisível de duas águas a 60° (`components/slippery_roof.gd`, `SlipperyRoof`, geometria em `RidgeRoof`), na camada `slippery_tops`. O jogador e o galão escorregam dele; os raios (mira na boca do gerador) e a navmesh o ignoram. O gerador principal e o tanque não têm: a escada em caracol passa logo acima deles, e o telhado furaria os degraus.
- Topo do gerador principal e do tanque: empurrão para a borda mais próxima (decisão 0034). O marcador `PushOffTop` (`components/push_off_top.gd`, regra `PushOffRules`) fica no `Body` de cada um, no centro do topo, com o tamanho do topo (`top_size`) e a velocidade (`push_speed`, 2 m/s). O jogador (`Player`) e o galão (`Jerrycan._integrate_forces`, que reporta contatos) procuram o marcador no corpo em que estão apoiados. Sem forma de colisão nova: a escada, os raios e a navmesh não mudam.

## Regras
- Energia alimenta só a casa de máquinas e a lâmpada. Relógio, monitores, rádio e as luzes da cabine funcionam sem ela (provisório). As luzes do térreo e da escada (`LowerLights`, `lighthouse/powered_lights.gd`) só acendem com o gerador principal: a mangueira estourada as apaga de vez (decisão 0036).
- Com energia = gerador principal funcionando **ou** gerador de emergência com combustível.
- Mangueira: estoura uma vez (`Lighthouse.burst_hose()`), sem conserto, e continua estourada nas noites seguintes (`RunState.hose_burst`). Estourada, o gerador principal para de vez. Estoura na primeira vez que o nevoeiro entra no farol (`GROUND_FLOOR`).
- Gerador de emergência: começa cada noite cheio (`generator_start_fuel`). Só gasta (`generator_consumption_per_second`) quando é a fonte ativa (mangueira estourada) e a alavanca está ligada.
- Galão: começa cada noite cheio no slot. Pegar: E de mãos livres (no slot ou no chão). Soltar: R (`drop_item`), ou usar qualquer interação de mãos livres (ela fica em foco e o primeiro E só solta o galão). Sai da mão com um arremesso leve (`Player.drop_throw_speed`), sem atravessar a parede à frente. Devolver: E no slot vazio com o galão na mão.
- No slot, o galão enche de vazio a cheio em `jerrycan_slot_fill_seconds` (120 s).
- Despejar: segurar E na boca do gerador de emergência (`jerrycan_pour_seconds`) põe o que ele aceitar; o resto fica no galão.
- Com o galão na mão, `HandsRule.FREE` fica bloqueado (usar solta o galão) e `CARRYING` libera (boca do gerador, slot).

## Sinais
- `Generator.power_changed` (principal) → `Lighthouse` → `PoweredLights.set_powered` (`LowerLights`).
- `FuelInlet.pour_completed` → `Generator` (emergência) → `Generator.refuel_requested` → `Lighthouse`. `Generator.power_changed(powered)` → `Lighthouse`.
- `FuelTank.hose_burst` → `Lighthouse` (gerador principal para), tutorial.
- `Jerrycan.pick_up_requested`, `JerrycanSlot.return_requested` → `Lighthouse` → `Lighthouse.jerrycan_carried_changed` → `Game` → `Player.set_carrying`.
- `Player.drop_requested(at, throw_velocity)` → `Game` → `Lighthouse.drop_jerrycan`. `InteractionRay.drop_requested` → `Player`.

## Testes
- `test/unit/generator_state_test.gd` (modo mangueira e modo combustível), `jerrycan_state_test.gd` (encher no slot, despejar), `ridge_roof_test.gd` (inclinação e cobertura do telhado).
- `test/scenes/lighthouse_power_test.gd` também cobre o medidor da cabine (acompanha o nível do gerador ao definir, despejar e esvaziar) e as luzes do térreo e da escada apagando com a mangueira estourada, com as da cabine acesas.
- `test/scenes/slippery_roof_test.gd`: o jogador e o galão soltos sobre o gerador de emergência escorregam até o chão.
- `test/unit/push_off_rules_test.gd` (borda mais próxima, entrada contra o empurrão) e `test/scenes/push_off_top_test.gd`: o jogador e o galão parados em cima do gerador principal e do tanque caem no chão, o jogador pela borda mais próxima.
- `test/scenes/lighthouse_power_test.gd`: o gerador de emergência assume quando a mangueira estoura e o feixe apaga sem combustível; galão do slot para a mão e da prateleira vazia para a mão pelo raio de interação real, para o chão (cai e para), de volta ao slot (enche) e despejado no gerador; só o gerador de emergência tem boca de combustível, e o despejo nela chega ao farol.
