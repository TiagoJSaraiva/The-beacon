# Exterior e câmeras

## Propósito
Ilha, mar e rota dos barcos; câmeras de segurança vistas só pelos monitores fixos (GDD 1.2.17).

## Componentes
- `exterior/exterior.tscn` (`Exterior`): `Island` (CSG), `Sea`, `BoatPath` (`Path3D` de x −140 a 140 em z=70), marcadores `SeaViewLeft`/`SeaViewRight`/`DoorView`. Fora da navmesh: o Afogado só anda dentro do farol.
- `exterior/security_camera.tscn` (`SecurityCamera`): `SubViewport` com `Camera3D` e `Environment` próprio; mira o `target` em `_ready`.
  - `SeaCameraLeft` e `SeaCameraRight`: no alto da torre, miram x = 48 e x = −48 da rota; juntas formam um panorama da rota inteira.
  - `DoorCamera`: fora da porta de entrada, mirando-a.
- `lighthouse/security_monitor.tscn` (`SecurityMonitor`): tela que exibe a textura da câmera. Três na mesa da cabine: `SeaMonitorLeft`, `SeaMonitorRight` (panorama, lado a lado) e `DoorMonitor`.

## Regras
- A câmera da esquerda mira o lado +X da rota, que aparece à esquerda na tela; os barcos vão da direita para a esquerda no panorama.
- Monitores funcionam sem energia.
- O nevoeiro aparece pelos volumes do `FogVisuals` (`nevoeiro.md`), que as câmeras renderizam como qualquer objeto. Exceção: as câmeras do mar têm `cull_mask` sem a camada de render `fog_near_ring`, e o anel em volta do farol não as cobre.

## Sinais
- O `Game` passa as texturas com `Lighthouse.show_camera_feeds(sea_left, sea_right, door)`.

## Testes
Sem teste dedicado (só visual).
