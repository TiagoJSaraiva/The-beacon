# Barcos e rádio

## Propósito
Barcos que cruzam o mar e precisam de aviso quando há nevoeiro (entrega 2).

## Componentes
- `boats/boat_passage.gd` (`BoatPassage`, puro): travessia, aviso e desfecho de um barco.
- `boats/boat.tscn` (`Boat`, `PathFollow3D`): visual na `BoatPath`; afunda ou desvia com animação.
- `boats/boat_director.gd` (`BoatDirector`, nó no `World`): até `max_simultaneous_boats` barcos, evento `boat`.
- `boats/radio.tscn` (`Radio`, na mesa da cabine): toca (som em loop e luz piscando) e é atendido com E; sem tocar, toca uma música ambiente em loop (`Ambient`, bus `Music`, placeholder `radio_ambient.wav`); funciona sem energia.

## Regras
- O barco cruza a rota inteira em `crossing_seconds` (12 s): aparece numa câmera do mar, passa pelo trecho que as duas enxergam (onde fica o nevoeiro) e segue na outra.
- Sem nevoeiro, o rádio não toca e o barco passa.
- Com nevoeiro adiante do barco, ele chama. O rádio toca só enquanto algum barco que chama aparece na câmera do canal aberto no monitor (`Camera3D.is_position_in_frustum` na posição do barco, sem considerar oclusão). Só contam as câmeras com `shows_boat_route` (as do mar): pelo enquadramento, a da porta também alcança o mar distante, mas no canal dela o rádio nunca toca. Trocar de canal para um sem barco chamando faz o toque parar; um barco que chama fora do canal aberto não toca o rádio.
- Atender vale para os barcos que chamam no canal aberto: com o feixe aceso, eles param e desviam; com o feixe apagado, param de chamar e seguem em frente.
- Dentro do trecho de nevoeiro sem ter desviado, o barco afunda na hora e soma 1 ponto de Afogado. Isso inclui o nevoeiro que cresce por cima de um barco (premissa a validar).
- Não há mais piratas.
- A noite seguinte começa sem barcos.

## Sinais
- `BoatDirector.calling_changed(calling)` → `Radio.set_ringing`; `boat_sank` → `DrownedDirector.add_drowned_point`.
- `Radio.answered` → `BoatDirector.warn_calling_boats`.
- `SecurityMonitor.channel_changed(index)` → `BoatDirector.set_watched_channel`. O `Game` passa as câmeras dos canais e o canal inicial com `BoatDirector.watch_cameras`.
- `FogSystem.route_fog_changed` → `BoatDirector.set_route_fog`; `Lighthouse.beam_lit_changed` → `BoatDirector.set_beam_lit`.

## Testes
- `test/scenes/radio_channel_test.gd`: o rádio só toca com o barco que chama no canal aberto e para ao trocar de canal.
- `test/unit/boat_passage_test.gd`: sem nevoeiro passa; afunda ao entrar no trecho; aviso com feixe aceso desvia; com feixe apagado segue; para de chamar depois de passar o trecho.
