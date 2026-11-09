# Exterior e câmeras

## Propósito
Ilha, mar e rota dos barcos; câmeras de segurança vistas só pelo monitor da mesa (GDD 1.2.17).

## Componentes
- `exterior/exterior.tscn` (`Exterior`): `Island` (CSG), `Sea`, `BoatPath` (`Path3D` de x −140 a 140 em z=70), marcadores `SeaViewLeft`/`SeaViewRight`/`DoorView`. Fora da navmesh: o Afogado só anda dentro do farol.
- `exterior/security_camera.tscn` (`SecurityCamera`): `SubViewport` com `Camera3D` e `Environment` próprio; mira o `target` em `_ready`.
  - `SeaCameraLeft` e `SeaCameraRight`: no alto da torre, com `fov` de 75°, miram x = 23 e x = −23 da rota. Juntas cobrem a rota inteira e enxergam em comum o meio dela (x de −30 a 30, cerca de 21% da rota), onde fica o nevoeiro (`FogConfig.route_center`, `max_route_coverage` = 0,2): ele aparece no lado direito de uma imagem e no esquerdo da outra.
  - `DoorCamera`: fora da porta de entrada, mirando-a.
- `lighthouse/security_monitor.tscn` (`SecurityMonitor`, nó `Monitor` na mesa da cabine): um monitor só, que mostra uma câmera por vez. Interagir (`SwitchPoint`) passa ao próximo canal; a regra fica em `lighthouse/monitor_channels.gd` (`MonitorChannels`, puro).

## Regras
- A câmera da esquerda mira o lado +X da rota, que aparece à esquerda na tela; os barcos vão da direita para a esquerda. Mudou a mira, o `fov` ou a rota: confira o trecho do nevoeiro dentro da sobreposição (`test/scenes/sea_cameras_test.gd`).
- Canais, na ordem de `Exterior.channel_cameras()`: 0 porta, 1 mar à esquerda, 2 mar à direita; depois do último, volta ao primeiro. A noite começa no canal 0. A tela não mostra o número do canal.
- O monitor funciona sem energia.
- O nevoeiro aparece pelos volumes do `FogVisuals` (`nevoeiro.md`), que as câmeras renderizam como qualquer objeto. Exceção: as câmeras do mar têm `cull_mask` sem a camada de render `fog_near_ring`, e o anel em volta do farol não as cobre.

## Sinais
- O `Game` passa as texturas com `Lighthouse.show_camera_feeds(Exterior.channel_feeds())`.
- `SecurityMonitor.channel_changed(index)` ao trocar de canal.

## Testes
- `test/unit/monitor_channels_test.gd`: começa no primeiro canal, passa por todos e volta ao início.
- `test/scenes/sea_cameras_test.gd`: as duas câmeras do mar enxergam as pontas do trecho máximo do nevoeiro, e cada uma cobre a ponta da rota do seu lado.
