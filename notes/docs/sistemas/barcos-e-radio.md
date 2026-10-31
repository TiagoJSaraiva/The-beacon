# Barcos e rádio

## Propósito
Barcos que pedem passagem, o rádio que revela se são permitidos ou piratas e o afundamento (GDD 1.2.26, provisório).

## Componentes
- `boats/boat_passage.gd` (`BoatPassage`, puro): regra da passagem.
- `boats/boat.tscn` (`Boat`, `PathFollow3D`): visual na `BoatPath`; afunda com animação.
- `boats/boat_director.gd` (`BoatDirector`, nó no `World`): um barco por vez, evento `boat`.
- `boats/radio.tscn` (`Radio`, na mesa do andar de cima): toca (som em loop e luz piscando) e é atendido com E; não depende do gerador.

## Regras
- Ao surgir, o barco aparece no monitor do mar e o rádio toca. Atender toca a mensagem: dois tons subindo = permitido; três tons graves = pirata (`pirate_chance`). Sem legenda no MVP.
- A passagem dura `passage_seconds`. Permitido: a contagem até afundar só anda com nevoeiro e feixe apagado, a `1 / sink_seconds(intensidade)` por segundo (intensidade 0 → `sink_seconds_at_min_intensity`, 1 → `sink_seconds_at_max_intensity`). Feixe aceso pausa, apagar retoma. Chegando a 1, afunda e soma 1 ponto de afogado.
- Pirata: nunca afunda; se o feixe acender durante a passagem, `pirate_guided` (sem consequência no MVP).
- Às 06:00 o barco some sem consequência.

## Sinais
- `BoatDirector.boat_arrived(is_pirate, answered)` → `Game` → `Radio.ring`.
- `BoatDirector.boat_gone` → `Radio.stop_ringing`; `boat_sank` → `DrownedDirector.add_drowned_point`; `boat_passed`, `pirate_guided`.
- `Radio.answered(is_pirate)` → `BoatDirector.mark_answered`.

## Testes
- `test/unit/boat_passage_test.gd`.
