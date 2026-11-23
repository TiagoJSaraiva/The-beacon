# Créditos dos modelos

Modelos de terceiros usados no jogo (decisão 0023). Os pacotes originais ficam em `../notes/modelos-store/`, fora do git; a lista completa de candidatos está no documento citado em `../notes/modelos-link.txt`.

Os da Poly Haven são CC0. A página do Fab de nenhum dos outros mostra os termos de licença (campo "License terms" vazio). **Confirme a licença na conta do Fab antes de publicar o jogo.** Os da Quixel Megascans têm termos próprios.

| Pasta | Modelo | Autor | Fonte | Uso no jogo |
|---|---|---|---|---|
| `old_wooden_chair/` | Old Wooden Chair Low-poly PBR | Max3d | https://www.fab.com/listings/1ddd1ea0-ff0d-430c-9dcc-8e31a44220b5 | Cadeira da mesa (`player/chair.tscn`) |
| `old_wooden_table/` | Old Wooden Table Low-poly PBR | Max3d | https://www.fab.com/listings/a403fbfc-187d-4613-9386-ed583b9806c7 | Mesa dos monitores (`Desk/Top`), esticada |
| `flashlight/` | Flash Light | Slav3106 | https://www.fab.com/listings/cbd0dab4-8969-4936-aafa-14669407bbf6 | Lanterna (`player/flashlight.tscn`) |
| `machinery_device/` | Machinery device | maxpsr | https://www.fab.com/listings/eb1cdc1d-d44c-429e-a2e9-a2e05bed3f65 | Carcaça da casa de máquinas (versão enferrujada) |
| `main_generator/` | Generator (a confirmar) | a confirmar | https://www.fab.com/listings/1d962814-8a9e-420c-9aa6-506fcb07633a (a confirmar) | Gerador principal (`power/main_generator.tscn`). Sem mapa de rugosidade (valor fixo no material) |
| `emergency_generator/` | Power Generator | RamananTitus | https://www.fab.com/listings/c8b5eb88-9944-433a-b69a-a0442040be69 | Gerador de emergência (`power/emergency_generator.tscn`) |
| `fuel_container/` | Props_FuelContainer (a confirmar) | a confirmar | a confirmar (export glTF do Sketchfab) | Galão com bico (`fuel/jerrycan.tscn`, `player/player.tscn`). O embrulho centra o corpo, sem o bico, que aponta para +X |
| `gas_tank/` | Propane Tank (a confirmar) | a confirmar | a confirmar (um dos links de tanques em `../notes/modelos-link.txt`) | Tanque de combustível (`fuel/fuel_tank.tscn`) |
| `radio_station/` | Radiostation McKinley (a confirmar) | a confirmar | a confirmar | Rádio da mesa (`boats/radio.tscn`) |
| `hanging_industrial_lamp/` | Hanging Industrial Lamp | Kuutti Siitonen | https://polyhaven.com/a/hanging_industrial_lamp (CC0) | Pendentes da cabine (`lighthouse/ceiling_lamp.tscn`). O vidro usa material próprio (vidro fosco emissivo): o Godot não lê a transmissão do glTF |
| `industrial_caged_sconce/` | Industrial Caged Sconce | Ulan Cabanilla | https://polyhaven.com/a/industrial_caged_sconce (CC0) | Arandelas do térreo e da escada (`lighthouse/wall_lamp.tscn`). O pacote é um kit; o embrulho mostra só a variante `a` |

## Texturas de superfície

Da Poly Haven, licença CC0 (domínio público, sem atribuição obrigatória). Em `assets/textures/<pasta>/`, em 2K.

| Pasta | Textura | Autor | Fonte | Uso no jogo |
|---|---|---|---|---|
| `castle_brick_02_white/` | Castle Brick 02 White | Rob Tuytel | https://polyhaven.com/a/castle_brick_02_white | Parede externa do farol |
| `worn_mossy_plasterwall/` | Worn Mossy Plasterwall | Amal Kumar | https://polyhaven.com/a/worn_mossy_plasterwall | Parede interna do farol (reboco caiado com mofo) |
| `concrete_floor_worn_001/` | Concrete Floor Worn 001 | Dimitrios Savva, Rico Cilliers | https://polyhaven.com/a/concrete_floor_worn_001 | Piso do térreo |
| `dark_wooden_planks/` | Dark Wooden Planks | Amal Kumar | https://polyhaven.com/a/dark_wooden_planks | Piso da cabine e patamar da escada de mão |
| `concrete_wall_003/` | Concrete Wall 003 | Dimitrios Savva, Rico Cilliers | https://polyhaven.com/a/concrete_wall_003 | Teto da cabine |
| `metal_plate/` | Metal Plate | Rob Tuytel | https://polyhaven.com/a/metal_plate | Degraus da escada em caracol |

## Addons

| Pasta | O quê | Autor | Licença | Crédito exigido |
|---|---|---|---|---|
| `addons/sky_3d/` | Sky3D v2.1.0 (céu, sol, lua, estrelas) | Cory Petkovsek, J. Cuéllar e contribuidores (TokisanGames) | MIT | Não |
| `addons/sky_3d/assets/thirdparty/textures/milkyway/` | "The Milky Way panorama" (e uma versão só com as estrelas mais brilhantes) | ESO/S. Brunier | CC BY 4.0 | **Sim**: "The Milky Way panorama by ESO/S. Brunier, licensed under CC BY 4.0 and used in original and modified forms." (https://www.eso.org/public/images/eso0932a/) |
| `addons/sky_3d/assets/thirdparty/textures/moon/` | Mapa da lua | GPoSM | MIT | Não |
