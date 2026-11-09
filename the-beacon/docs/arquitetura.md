# Arquitetura

Visão do projeto como ele está **agora**. Atualize no mesmo passo de qualquer mudança nos itens abaixo.

## Visão geral
Survival horror de gerenciamento em primeira pessoa, 3D, dentro de um farol de dois andares (GDD em `../notes/gdd.md`, fora do repositório). O jogador cumpre um plantão de 3, 5 ou 7 noites (Easy, Medium, Hard), de 20h às 6h, mantendo geradores, galão, casa de máquinas, feixe, alçapão e lanterna enquanto lida com nevoeiro, barcos, o Afogado e as carrancas. Sem HUD de estado: toda informação está em objetos do cenário.

**Entrega 1 (MVP)**: core loop completo e meta-jogo (menus, desbloqueio, save, tutorial) com placeholders (greybox CSG, áudio de tons) e todos os valores em configuração. **Entrega 2** implementada: revisão das mecânicas (`planos/entrega-2.md`), à espera do playtest.

Princípios da implementação:
- Regras em classes `RefCounted` puras (`*_state.gd`, `*_rules.gd`), testáveis. Nós só fazem tick, leem input e aplicam o resultado. Só o estado que passa de uma noite para a outra é serializado (`RunState`, decisão 0015).
- Cada noite é uma carga nova de `game/game.tscn`; o `RunState` leva o que persiste.
- Todo valor de balanceamento vem de `DifficultyConfig` (`config/difficulties/*.tres`), com sub-configs por sistema.
- Eventos sorteáveis são `EventDefinition` (`config/events/*.tres`); o sistema que trata cada um se registra no `EventDirector`.

## Organização de pastas
Organização por feature: cada cena fica junto do seu script e dos recursos exclusivos dela.

```
<feature>/          ex.: player/, enemies/, ui/hud/
  <nome>.tscn
  <nome>.gd
components/         componentes reutilizados por mais de uma feature (ex.: health_component)
assets/             arte, áudio e fontes compartilhados
autoload/           singletons (cada um com decisão registrada) e as regras puras deles
config/             classes de configuração e .tres de dificuldades e eventos
tools/              scripts headless de manutenção do jogo
scripts/            pipeline de verificação (check.ps1, check-docs.ps1, check-doc-review.ps1, parse_check.gd); tem .gdignore, fora do res://
test/unit/          testes de regras puras
test/scenes/        testes de cena (gdUnit4 scene runner)
```

## Cenas principais
- `ui/main_menu/main_menu.tscn` (**Main Scene**) → `MainMenu`: menu, seleção de dificuldade e configurações (ver `sistemas/menus-e-telas.md`).
- `game/game.tscn` → `Game` (`Node3D`, `game.gd`):
  - `World` (`Node3D`): toda a simulação, congelada entre noites e na morte por `process_mode`. Filhos: `WorldEnvironment`, `Moon`, `Exterior`, `Lighthouse`, `Player`, `NightDirector`, `EventDirector`, `FogSystem`, `FogVisuals`, `BoatDirector`, `DrownedDirector`, `FigureheadDirector`, `TutorialDirector`, `Navigation` (`NavigationRegion3D`, decisão 0009).
  - Fora do `World`: `Hud`, `NightEndScreen`, `GameOverScreen`, `VictoryScreen`, `PauseMenu` (`sistemas/menus-e-telas.md`), `RunCarryover` (`sistemas/save-e-progresso.md`).
  - Uma noite do plantão: lê o pedido do `SceneRouter` (dificuldade e `RunState`; sem pedido, plantão novo na `default_difficulty` = Easy), apaga o save, aplica a dificuldade e o estado persistente, registra eventos e liga os sinais. Às 06:00 recolhe o estado persistente e segue para a próxima noite (recarregando a cena), o save ou a vitória. Emite `run_won(difficulty_id)` e `run_lost(cause)` como aviso.
- `lighthouse/lighthouse.tscn` → `Lighthouse` (`Node3D`) → greybox CSG (`Shell` com `EntranceDoor`, `UpperFloor` com `Trapdoor`; decisão 0019), `SpiralStaircase`, `Landing`, `Ramp` (ver `sistemas/farol.md`); `MainGenerator`, `EmergencyGenerator`, `FuelTank` (com `JerrycanSlot`), `Jerrycan` (`sistemas/energia-e-combustivel.md`); `MachineHouse`, `LighthouseLamp`, `BeamControl` (`sistemas/feixe.md`); `WallClock`, `UpperLights`; `Desk` com `Monitor` (um só, com canais), `Radio` e `Chair`; `DrownedTargets`. O script `lighthouse.gd` faz a fiação interna e expõe métodos e sinais ao `Game`.
- `exterior/exterior.tscn` → `Exterior`: ilha, mar, rota dos barcos e câmeras (`sistemas/exterior-e-cameras.md`).
- `player/player.tscn` → `Player` (`CharacterBody3D`) → `Head/Camera3D` (`InteractionRay`, `Flashlight`, `CarriedJerrycan`), `FallDamage` (ver `sistemas/jogador.md`).
- Entidades instanciadas pelos diretores: `boats/boat.tscn` (na `BoatPath`), `drowned/drowned.tscn` e `figurehead/figurehead.tscn` (filhos dos diretores).
- `ui/hud/hud.tscn` → `Hud` (`CanvasLayer`): hotkey de interagir, barra de progresso, texto do tutorial, borda vermelha, cegueira. Mostra a tecla atual (`Settings.bindings`) do último dispositivo usado.
- `ui/night_end/night_end_screen.tscn` → `NightEndScreen` (`CanvasLayer`): entre noites.

Os diretores que mexem em outros sistemas (`DrownedDirector`, `FigureheadDirector`, `TutorialDirector`) recebem as referências do `Game` em `setup()`. `RunCarryover` referencia os nós da cena por `@export` (decisão 0006).

## Autoloads
| Nome | Script | Papel | Decisão |
|---|---|---|---|
| `SceneRouter` | `autoload/scene_router.gd` | Troca menu ↔ jogo; `play_night(difficulty, run)` carrega cada noite e entrega o `RunRequest` ao `Game` | 0010, 0015 |
| `SaveService` | `autoload/save_service.gd` | Save único da partida (`RunState`, só entre noites) e progresso de desbloqueio (`user://`) | 0014 |
| `Settings` | `autoload/settings.gd` | Volumes, sensibilidade e controles remapeáveis (`user://settings.cfg`); aplica as ligações no `InputMap` | 0012, 0018 |

O parse do check carrega os scripts com os autoloads registrados (decisão 0013).

## Sinais entre sistemas
- `Player.interaction.focus_changed(focused)` → `Hud.show_prompt` — hotkey ao mirar.
- `Player.interaction.hold_progress_changed` → `Hud.show_hold_progress` — barra de interações de duração.
- `NightDirector.time_changed` → `Lighthouse.show_time` — relógio de parede.
- `NightDirector.night_started` → `Game` → `EventDirector.reset_night`.
- `Lighthouse.jerrycan_carried_changed` → `Player.set_carrying` — galão na mão.
- `Lighthouse.chair.sit_requested` → `Player.sit` — cadeira da mesa.
- Dentro do farol: geradores, alavanca, lâmpada e casa de máquinas → `Lighthouse`, que recalcula o `BeamState`, liga o consumo do gerador de emergência e emite `beam_lit_changed`; `FuelTank.hose_burst` → gerador principal; galão entre slot, mão e mundo.
- `Player.drop_requested` → `Lighthouse.drop_jerrycan` — soltar o galão.
- Eventos: cada sistema se registra no `EventDirector` (`Lighthouse`, `FogSystem`, `BoatDirector`).
- `NightDirector.night_ended` → `Game` (congela, `RunCarryover.capture`, tela ou vitória).
- `Player.died` → `Game` → `run_lost`. `Player.sprint_blocked_changed` → `Hud.set_hurt_border`.
- `Lighthouse.beam_operational_changed` → `FogSystem.set_beam_operational`. `FogSystem.stage_changed` → `Lighthouse.set_fog_stage` (bloqueio do feixe, mangueira), `FigureheadDirector.set_fog_stage`. `FogSystem.route_fog_changed` → `BoatDirector.set_route_fog`. `FogVisuals` lê o `FogSystem` direto (recebe-o em `setup()`).
- `Lighthouse.beam_lit_changed` → `BoatDirector.set_beam_lit`.
- `BoatDirector.calling_changed` → `Radio.set_ringing`; `boat_sank` → `DrownedDirector.add_drowned_point`. `Radio.answered` → `BoatDirector.warn_calling_boats`. `Lighthouse.monitor.channel_changed` → `BoatDirector.set_watched_channel` (o rádio só ouve barcos no canal aberto).
- `FigureheadDirector.player_blinded` → `Hud.show_blindness`; `player_knocked_down` → `Player.knock_down`.
- `Drowned.effect_triggered` → `DrownedDirector` → `Player.kill`. `FogSystem.stage_changed` → `DrownedDirector.set_fog_stage` (aproximação). O `DrownedDirector` chama direto `EntranceDoor.show_approach`/`burst_open` e `Trapdoor.set_banging`.
- `TutorialDirector.message_changed` → `Hud.show_tutorial`; o diretor escuta sozinho os sinais dos sistemas (`sistemas/tutorial.md`).
- `PauseMenu.paused_changed` → `Game` → `Player.set_controls_enabled`; `PauseMenu.exit_requested` → `Game` → `SceneRouter.go_to_main_menu`.
- `NightEndScreen.continue_requested` → `Game` → `SceneRouter.play_night`; `NightEndScreen.save_and_exit_requested` → `Game` → `SaveService.write_run`, `SceneRouter`. `GameOverScreen`, `VictoryScreen` → `Game` ou direto `SceneRouter`. `Settings.changed` → `Game` → `Player.sensitivity_scale`; `Hud` e `ControlsPanel` também escutam (teclas atuais).

## Input map
Teclado por tecla física (independe do layout) e controle no padrão Xbox (botões de face pela posição). O olhar usa o mouse ou o analógico direito. A tabela é o padrão do `project.godot`; o jogador remapeia a tecla de todas as ações abaixo exceto `look_*`, e o botão de `jump`, `interact`, `toggle_flashlight`, `check_battery`, `drop_item` e `pause` (decisão 0018).

| Ação | Teclado | Controle |
|---|---|---|
| `move_forward` / `move_back` / `move_left` / `move_right` | W / S / A / D | Analógico esquerdo |
| `look_up` / `look_down` / `look_left` / `look_right` | (mouse) | Analógico direito |
| `jump` | Espaço | A |
| `sprint` | Shift | L2 |
| `interact` | E (segurar em interações de duração) | Y |
| `toggle_flashlight` | Q | X |
| `check_battery` (segurar) | X | D-pad cima |
| `drop_item` | R | B |
| `pause` | Esc | Start |

Menus usam as ações `ui_*` padrão do Godot (só interface, nunca gameplay), que já incluem o controle (D-pad e analógico navegam, A confirma, B volta). Esc ou B (`ui_cancel`) volta uma página em todos os menus; no menu de pausa, `pause` também.

## Camadas de colisão
1 — `world` — paredes, chão, escada / todos colidem; raios de oclusão
2 — `barriers` — porta de entrada e alçapão / jogador e Afogado colidem
3 — `player` — jogador / detectado pelo Afogado
4 — `drowned` — Afogados
5 — (livre)
6 — `interactable` — objetos interativos / detectados pelo raio de interação do jogador
7 — (livre)
8 — `props` — objetos com física (galão) / colidem com `world`, `barriers` e entre si; o jogador os atravessa

## Camadas de render
1 — `default` — tudo
2 — `fog_near_ring` — anel de nevoeiro em volta do farol / fora do `cull_mask` das câmeras do mar

## Áudio
Buses em `default_bus_layout.tres`: `Master` → `Music`, `SFX`. Sons placeholder (tons sintéticos) em `assets/audio/placeholder/`, gerados por `tools/generate_placeholder_audio.gd` (rodar com `godot --headless --path . --script res://tools/generate_placeholder_audio.gd`). Sons em loop usam `components/looping_sound.gd`.

## Modelos 3D
Modelos de terceiros em `assets/models/<nome>/` (decisão 0023), extraídos dos pacotes em `../notes/modelos-store/` (fora do git) por `tools/import_store_model.gd`:
`godot --headless --path . --script res://tools/import_store_model.gd -- <zip> <nome> [--inner <zip interno>] [--max-size 2048] [--skip <marcador>]`.
A ferramenta reduz as texturas a 2048 px e descarta os mapas sem uso. Depois do primeiro `--import`, `tools/configure_model_textures.gd -- <nome>` ajusta o `.import` das texturas (compressão de VRAM, mipmaps, normal map), e o `--import` seguinte as reimporta. Sem isso, o Godot importa sem mipmaps e só corrige ao abrir o editor. Cada modelo tem a cena-embrulho `<nome>.tscn` (metros, base em y=0, centro em XZ, frente em +Z), que é o que as cenas do jogo instanciam. A colisão é sempre uma forma simples, separada da malha. Créditos em `assets/models/CREDITOS.md`. O rádio (`assets/RadiostationMCKINLEY_GameReady.fbx`) é anterior a esse formato.

## Navegação
Navmesh assada em runtime no `Game`, sem porta e alçapão (decisão 0009), só do interior: o grupo `navigation_source` fica só no `Lighthouse`. `project.godot`: `navigation/3d/default_cell_size` e `default_cell_height` = 0.1.
