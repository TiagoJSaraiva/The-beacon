# Exterior e câmeras

## Propósito
Ilha, mar e rota dos barcos; câmeras de segurança vistas só pelo monitor da mesa (GDD 1.2.17).

## Componentes
- `exterior/exterior.tscn` (`Exterior`): `Island` (`exterior/island.gd`, `@tool`: malha em anéis gerada pelo relevo de `IslandShape` (puro): platô de grama até ~13 m em volta do farol, 3 cm abaixo do térreo, encosta, praia no nível do mar por volta de 27 m e fundo raso; contorno irregular por ruído; material `exterior/island_ground.tres` (`island_ground.gdshader`: areia embaixo, grama no alto, rocha onde é íngreme, areia molhada perto da água); só visual, sem colisão), `EntranceProps` (`exterior/entrance_props.tscn`: tambores, boias, tronco, pedras e capim, só no quadro da câmera da porta e sem colisão; o resto da ilha não tem props), `Sea` (`Ocean` da Boujie Water Shader com `exterior/sea_material.tres`: ondas baixas, cores de noite, reflexo do céu e da lua; decisão 0029), com o nível em y = −2,9, 2 m abaixo do farol (decisão 0030; a altura das ondas é a média das `WaveSteepnesses`), `BoatPath` (`Path3D` de x −140 a 140 em z=70, y = −2,6), marcadores `SeaViewLeft`/`SeaViewRight`/`DoorView`. Fora da navmesh: o Afogado só anda dentro do farol.
- `exterior/security_camera.tscn` (`SecurityCamera`): `SubViewport` com `Camera3D`, sem `Environment` próprio (usa o do mundo, o da Sky3D); mira o `target` em `_ready`.
  - `SeaCameraLeft` e `SeaCameraRight`: no alto da torre, com `fov` de 75°, miram x = 23 e x = −23 da rota. Juntas cobrem a rota inteira e enxergam em comum o meio dela (x de −30 a 30, cerca de 21% da rota), onde fica o nevoeiro (`FogConfig.route_center`, `max_route_coverage` = 0,2): ele aparece no lado direito de uma imagem e no esquerdo da outra.
  - `DoorCamera`: fora da porta de entrada, mirando-a.
- `lighthouse/security_monitor.tscn` (`SecurityMonitor`, nó `Monitor` na mesa da cabine): um monitor só, que mostra uma câmera por vez. Interagir (`SwitchPoint`) passa ao próximo canal; a regra fica em `lighthouse/monitor_channels.gd` (`MonitorChannels`, puro).
- Renderização sob demanda: só a câmera do canal aberto renderiza, e só com o jogador na cabine (`CabinZone`, `Area3D` do `Lighthouse` ligada ao `viewer_zone` do monitor) e a tela no enquadramento (`ScreenNotifier`, `VisibleOnScreenNotifier3D`). O enquadramento não vê pisos: a zona da cabine impede que o monitor conte como visto do térreo. As outras câmeras ficam paradas na última imagem (`SecurityCamera.set_live`). O enquadramento das câmeras, usado pelo rádio, não depende disso.

## Regras
- A câmera da esquerda mira o lado +X da rota, que aparece à esquerda na tela; os barcos vão da direita para a esquerda. Mudou a mira, o `fov` ou a rota: confira o trecho do nevoeiro dentro da sobreposição (`test/scenes/sea_cameras_test.gd`).
- Canais, na ordem de `Exterior.channel_cameras()`: 0 porta, 1 mar à esquerda, 2 mar à direita; depois do último, volta ao primeiro. A noite começa no canal 0. A tela não mostra o número do canal.
- O monitor funciona sem energia.
- O nevoeiro aparece pelos volumes do `FogVisuals` (`nevoeiro.md`). O céu é o da Sky3D (decisão 0028): a lua cheia nasce baixa à esquerda das câmeras do mar no começo da noite, passa alta pelo meio (o reflexo dela aparece no mar) e se põe à direita no amanhecer. O `Environment` do mundo (`Environment_exterior` em `game.tscn`) tem a névoa volumétrica ligada, com densidade global zero e alcance de 120 m, para cobrir a faixa no mar inteira (a rota fica a cerca de 70 m). Exceção: as câmeras do mar têm `cull_mask` sem a camada de render `fog_near_ring`, e o anel em volta do farol não as cobre.
- O `Sky` do ambiente do mundo é declarado em `game.tscn` (a Sky3D só cria um quando falta), com `process_mode` incremental e radiância de 64 px. O shader da Sky3D usa `TIME`: no modo automático, o Godot recalcularia a radiância inteira a cada quadro (~13 ms numa GPU integrada); o incremental a reparte em vários quadros, sem diferença visível nas câmeras.

## Sinais
- O `Game` passa as texturas com `Lighthouse.show_camera_feeds(Exterior.channel_feeds())`.
- `SecurityMonitor.channel_changed(index)` ao trocar de canal.
- `SecurityMonitor.live_channel_changed(index)` → `Exterior.show_live_channel`: a câmera que precisa renderizar (`MonitorChannels.NO_CHANNEL` = nenhuma).

## Testes
- `test/unit/island_shape_test.gd`: platô plano sob o farol em todo ângulo, praia no nível do mar, fundo abaixo dele, perfil sempre descendo e malha virada para cima.
- `test/scenes/sea_level_test.gd`: a crista mais alta das ondas fica ao menos 1,5 m abaixo do térreo do farol.
- `test/unit/monitor_channels_test.gd`: começa no primeiro canal, passa por todos e volta ao início; câmera viva só com o jogador no cômodo e a tela à vista.
- `test/scenes/sea_cameras_test.gd`: as duas câmeras do mar enxergam as pontas do trecho máximo do nevoeiro, e cada uma cobre a ponta da rota do seu lado.
