# Energia e combustível

## Propósito
Gerador, tanque de reserva e galão (GDD 1.2.5, 1.2.24, 1.2.25).

## Componentes
- `power/generator.tscn` (`Generator`, regra `GeneratorState`): combustível, quebra, consumo extra do feixe; medidor (barra), luz vermelha quando quebrado, ponto de conserto (frente) e boca de combustível (topo).
- `components/power_consumer.gd` (`PowerConsumer`): filho de cada elemento alimentado, com `source` apontando o gerador; conectado na cena ao método `set_powered` do dono. Hoje: `WallClock`, `UpperLights` (`PoweredLights`), `LighthouseLamp`.
- `fuel/reserve_tank.tscn` (`ReserveTank`, regra `ReserveTankState`): medidor, mangueira com ponto de encher e ponto de conserto, poça e luz vermelha quando rompida.
- `fuel/jerrycan_dock.tscn` (`JerrycanDock`, regra `JerrycanState`): ponto de devolução; guarda quantidade e se o galão está na mão.
- Fiação em `Lighthouse`: encher (`ReserveTank.fill_requested` → `JerrycanState.fill_from`) e despejar (`Generator.refuel_requested` → `JerrycanState.pour_into`).

## Regras
- Gerador funciona com combustível > 0 e sem quebra. Consumo `generator_consumption_per_second` + `beam_extra_consumption_per_second` com o feixe aceso.
- Sem energia param lâmpada, relógio e luzes de cima. Monitores e rádio não dependem do gerador.
- Reserva é do plantão inteiro. Mangueira rompida: vaza `reserve_leak_per_second` e não enche o galão.
- Galão: pegar e devolver no ponto de devolução (E). Encher segurando E na mangueira (`jerrycan_fill_seconds`) completa até `jerrycan_capacity` com o que a reserva tiver. Despejar segurando E na boca do gerador (`jerrycan_pour_seconds`) põe o que o gerador aceitar; o resto fica no galão.
- Com o galão na mão: não conserta nada, não opera alçapão nem trinco (`HandsRule.FREE`); encher e despejar exigem o galão (`HandsRule.CARRYING`).

## Sinais
- `Generator.power_changed(powered)` → `PowerConsumer` → dono.
- `Generator.broken_changed`, `ReserveTank.hose_broken_changed`, `JerrycanDock.carried_changed` → `Lighthouse.jerrycan_carried_changed` → `Game` → `Player.set_carrying`.

## Testes
- `test/unit/generator_state_test.gd`, `reserve_tank_state_test.gd`, `jerrycan_state_test.gd` (inclui o ciclo reserva → galão → gerador).
