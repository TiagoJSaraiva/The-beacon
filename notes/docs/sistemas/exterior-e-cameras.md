# Exterior e câmeras

## Propósito
Ilha, mar e rota dos barcos; câmeras de segurança vistas só pelos monitores fixos (GDD 1.2.17).

## Componentes
- `exterior/exterior.tscn` (`Exterior`): `Island` (CSG, grupo `navigation_source`), `Sea`, `BoatPath` (`Path3D` em z=70), marcadores `SeaView`/`DoorView`, `DrownedSpawns` (3 pontos na margem), `FogManSpawn`.
- `exterior/security_camera.tscn` (`SecurityCamera`): `SubViewport` com `Camera3D` e `Environment` próprio (`resource_local_to_scene`); mira o `target` em `_ready`.
- `lighthouse/security_monitor.tscn` (`SecurityMonitor`): tela que exibe a textura da câmera. Dois monitores na mesa do andar de cima (`SeaMonitor`, `LighthouseMonitor`).

## Regras
- Câmera do mar mostra a rota dos barcos; câmera do farol mostra a porta de entrada.
- Monitores não dependem do gerador.
- O nevoeiro aparece só na fog do `Environment` de cada câmera: densidade = `max_fog_density × intensidade`. O ambiente principal não tem fog (cobriria o interior).

## Sinais
- `FogSystem.intensity_changed` → `Exterior.set_fog_intensity`.
- O `Game` passa as texturas com `Lighthouse.show_camera_feeds()`.

## Testes
Sem teste dedicado (só visual).
