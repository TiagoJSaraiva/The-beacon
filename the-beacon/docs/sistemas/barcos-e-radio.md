# Barcos e rádio

## Propósito
Barcos que cruzam o mar e precisam de aviso quando há nevoeiro (entrega 2).

## Componentes
- `boats/boat_passage.gd` (`BoatPassage`, puro): travessia, aviso e desfecho de um barco.
- `boats/boat.tscn` (`Boat`, `PathFollow3D`): visual na `BoatPath`; afunda ou desvia com animação.
- `boats/boat_director.gd` (`BoatDirector`, nó no `World`): até `max_simultaneous_boats` barcos, evento `boat`.
- `boats/radio.tscn` (`Radio`, na mesa da cabine): toca (som em loop e luz piscando) e é atendido com E; funciona sem energia.

## Regras
- O barco cruza a rota inteira em `crossing_seconds` (12 s), visível nas duas câmeras do mar.
- Sem nevoeiro, o rádio não toca e o barco passa.
- Com nevoeiro adiante do barco, ele chama: o rádio toca enquanto houver algum barco chamando.
- Atender vale para todos os barcos que estão chamando: com o feixe aceso, eles param e desviam; com o feixe apagado, param de chamar e seguem em frente.
- Dentro do trecho de nevoeiro sem ter desviado, o barco afunda na hora e soma 1 ponto de Afogado. Isso inclui o nevoeiro que cresce por cima de um barco (premissa a validar).
- Não há mais piratas.
- A noite seguinte começa sem barcos.

## Sinais
- `BoatDirector.calling_changed(calling)` → `Radio.set_ringing`; `boat_sank` → `DrownedDirector.add_drowned_point`.
- `Radio.answered` → `BoatDirector.warn_calling_boats`.
- `FogSystem.route_fog_changed` → `BoatDirector.set_route_fog`; `Lighthouse.beam_lit_changed` → `BoatDirector.set_beam_lit`.

## Testes
- `test/unit/boat_passage_test.gd`: sem nevoeiro passa; afunda ao entrar no trecho; aviso com feixe aceso desvia; com feixe apagado segue; para de chamar depois de passar o trecho.
