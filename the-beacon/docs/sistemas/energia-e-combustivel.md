# Energia e combustível

## Propósito
Geradores, tanque, mangueira e galão (decisão 0017; GDD 1.2.5, 1.2.24).

## Componentes
- `power/generator.tscn` (`Generator`, regra `GeneratorState`): a mesma cena nos dois papéis, escolhidos por `feed`.
  - `MainGenerator` (térreo, `feed = HOSE`): funciona enquanto a mangueira está inteira; sem medidor nem boca de combustível.
  - `EmergencyGenerator` (cabine, ao lado da casa de máquinas, `feed = FUEL`): combustível, medidor (barra) e boca para o galão (topo).
- `fuel/fuel_tank.tscn` (`FuelTank`, térreo): reserva infinita; mangueira até o gerador principal; estourada, some e fica o toco com a poça. Contém o `JerrycanSlot`. `debug_burst_on_start` começa a noite com ela estourada (só depuração).
- `fuel/jerrycan_slot.tscn` (`JerrycanSlot`): prateleira no tanque; com o galão devolvido, enche-o e mostra o nível dele (barra).
- `fuel/jerrycan.tscn` (`Jerrycan`, `RigidBody3D` na camada `props`, regra `JerrycanState`): no slot (parado), na mão (escondido, sem colisão) ou solto no mundo (com física).
- Fiação em `Lighthouse` (energia, galão) e no `Player` (soltar).

## Regras
- Energia alimenta só a casa de máquinas e a lâmpada. Relógio, luzes, monitores e rádio funcionam sem ela (provisório).
- Com energia = gerador principal funcionando **ou** gerador de emergência com combustível.
- Mangueira: estoura uma vez (`Lighthouse.burst_hose()`), sem conserto, e continua estourada nas noites seguintes (`RunState.hose_burst`). Estourada, o gerador principal para de vez. Estoura na primeira vez que o nevoeiro entra no farol (`GROUND_FLOOR`).
- Gerador de emergência: começa cada noite cheio (`generator_start_fuel`). Só gasta (`generator_consumption_per_second`) quando é a fonte ativa (mangueira estourada) e a alavanca está ligada.
- Galão: começa cada noite cheio no slot. Pegar: E de mãos livres (no slot ou no chão). Soltar: R (`drop_item`), ou usar qualquer interação de mãos livres (ela fica em foco e o primeiro E só solta o galão). Sai da mão com um arremesso leve (`Player.drop_throw_speed`), sem atravessar a parede à frente. Devolver: E no slot vazio com o galão na mão.
- No slot, o galão enche de vazio a cheio em `jerrycan_slot_fill_seconds` (120 s).
- Despejar: segurar E na boca do gerador de emergência (`jerrycan_pour_seconds`) põe o que ele aceitar; o resto fica no galão.
- Com o galão na mão, `HandsRule.FREE` fica bloqueado (usar solta o galão) e `CARRYING` libera (boca do gerador, slot).

## Sinais
- `Generator.power_changed(powered)`, `Generator.refuel_requested` → `Lighthouse`.
- `FuelTank.hose_burst` → `Lighthouse` (gerador principal para), tutorial.
- `Jerrycan.pick_up_requested`, `JerrycanSlot.return_requested` → `Lighthouse` → `Lighthouse.jerrycan_carried_changed` → `Game` → `Player.set_carrying`.
- `Player.drop_requested(at, throw_velocity)` → `Game` → `Lighthouse.drop_jerrycan`. `InteractionRay.drop_requested` → `Player`.

## Testes
- `test/unit/generator_state_test.gd` (modo mangueira e modo combustível), `jerrycan_state_test.gd` (encher no slot, despejar).
- `test/scenes/lighthouse_power_test.gd`: o gerador de emergência assume quando a mangueira estoura e o feixe apaga sem combustível; galão do slot para a mão, para o chão (cai e para), de volta ao slot (enche) e despejado no gerador.
