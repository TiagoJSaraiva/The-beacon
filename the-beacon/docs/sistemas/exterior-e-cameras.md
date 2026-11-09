# Exterior e câmeras

## Propósito
Ilha, mar e rota dos barcos; câmeras de segurança vistas só pelos monitores fixos (GDD 1.2.17).

## Componentes
- `exterior/exterior.tscn` (`Exterior`): `Island` (CSG), `Sea`, `BoatPath` (`Path3D` de x −140 a 140 em z=70), marcadores `SeaViewLeft`/`SeaViewRight`/`DoorView`. Fora da navmesh: o Afogado só anda dentro do farol.
- `exterior/security_camera.tscn` (`SecurityCamera`): `SubViewport` com `Camera3D` e `Environment` próprio; mira o `target` em `_ready`.
  - `SeaCameraLeft` e `SeaCameraRight`: no alto da torre, com `fov` de 75°, miram x = 23 e x = −23 da rota. Juntas cobrem a rota inteira e enxergam em comum o meio dela (x de −30 a 30, cerca de 21% da rota), onde fica o nevoeiro (`FogConfig.route_center`, `max_route_coverage` = 0,2): ele aparece no lado direito de uma imagem e no esquerdo da outra.
  - `DoorCamera`: fora da porta de entrada, mirando-a.
- `lighthouse/security_monitor.tscn` (`SecurityMonitor`): tela que exibe a textura da câmera. Três na mesa da cabine: `SeaMonitorLeft`, `SeaMonitorRight` (panorama, lado a lado) e `DoorMonitor`.

## Regras
- A câmera da esquerda mira o lado +X da rota, que aparece à esquerda na tela; os barcos vão da direita para a esquerda. Mudou a mira, o `fov` ou a rota: confira o trecho do nevoeiro dentro da sobreposição (`test/scenes/sea_cameras_test.gd`).
- Monitores funcionam sem energia.
- O nevoeiro aparece pelos volumes do `FogVisuals` (`nevoeiro.md`), que as câmeras renderizam como qualquer objeto. Exceção: as câmeras do mar têm `cull_mask` sem a camada de render `fog_near_ring`, e o anel em volta do farol não as cobre.

## Sinais
- O `Game` passa as texturas com `Lighthouse.show_camera_feeds(sea_left, sea_right, door)`.

## Testes
- `test/scenes/sea_cameras_test.gd`: as duas câmeras do mar enxergam as pontas do trecho máximo do nevoeiro, e cada uma cobre a ponta da rota do seu lado.
