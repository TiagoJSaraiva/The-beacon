# Arquitetura

Visão do projeto como ele está **agora**. Atualize no mesmo passo de qualquer mudança nos itens abaixo.

## Visão geral
Survival horror de gerenciamento em primeira pessoa, 3D, dentro de um farol de dois andares (GDD em `../notes/gdd.md`, fora do repositório). O jogador cumpre um plantão de 3, 5 ou 7 noites (Easy, Medium, Hard), de 20h às 6h, mantendo gerador, combustível, feixe, alçapão e lanterna enquanto lida com nevoeiro, barcos, Afogados e o Homem de Nevoeiro. Sem HUD de estado: toda informação está em objetos do cenário.

**Entrega 1 (MVP)**: core loop completo e meta-jogo (menus, desbloqueio, agenda, save, tutorial) com placeholders (greybox CSG, áudio de tons) e todos os valores em configuração.

Princípios da implementação:
- Regras em classes `RefCounted` puras (`*_state.gd`, `*_rules.gd`), testáveis e serializáveis (`to_dict`/`from_dict`). Nós só fazem tick, leem input e aplicam o resultado.
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
autoload/           singletons (cada um com decisão registrada)
config/             classes de configuração e .tres de dificuldades e eventos
tools/              scripts headless de manutenção (scripts/ tem .gdignore e o Godot não os enxerga)
test/unit/          testes de regras puras
test/scenes/        testes de cena (gdUnit4 scene runner)
```

## Cenas principais
- `game/game.tscn` (Main Scene provisória) → `Game` (`Node3D`, `game.gd`):
  - `World` (`Node3D`): toda a simulação, congelada entre noites por `process_mode`. Filhos: `WorldEnvironment`, `Moon`, `Exterior`, `Lighthouse`, `Player`, `NightDirector`, `EventDirector`, `FogSystem`, `BoatDirector`, `DrownedDirector`, `FogManDirector`, `Navigation` (`NavigationRegion3D`, decisão 0009).
  - Fora do `World`: `Hud`, `NightEndScreen`.
  - Aplica a dificuldade (`default_difficulty` = Easy ao rodar direto), registra eventos, liga os sinais e conduz as noites (`RunState`). Emite `run_won`, `run_lost`, `exit_to_menu_requested` (hoje recarregam a cena; passo 19 leva às telas).
- `lighthouse/lighthouse.tscn` → `Lighthouse` (`Node3D`) → greybox CSG, `SpiralStaircase`, `Landing`, `Ramp`, `Trapdoor`, `EntranceDoor` (ver `sistemas/farol.md`); `Generator`, `ReserveTank`, `JerrycanDock` (`sistemas/energia-e-combustivel.md`); `LighthouseLamp`, `BeamControl` (`sistemas/feixe.md`); `WallClock`, `UpperLights`; `Desk` com monitores e `Radio`; `DrownedTargets`. O script `lighthouse.gd` faz a fiação interna e expõe métodos e sinais ao `Game`.
- `exterior/exterior.tscn` → `Exterior`: ilha, mar, rota dos barcos, câmeras, pontos de surgimento (`sistemas/exterior-e-cameras.md`).
- `player/player.tscn` → `Player` (`CharacterBody3D`) → `Head/Camera3D` (`InteractionRay`, `Flashlight`, `CarriedJerrycan`), `FallDamage` (ver `sistemas/jogador.md`).
- Entidades instanciadas pelos diretores: `boats/boat.tscn` (na `BoatPath`), `drowned/drowned.tscn` e `fog_man/fog_man.tscn` (filhos dos diretores).
- `ui/hud/hud.tscn` → `Hud` (`CanvasLayer`): hotkey, barra de progresso, borda vermelha, cegueira.
- `ui/night_end/night_end_screen.tscn` → `NightEndScreen` (`CanvasLayer`): entre noites.

Os diretores que mexem em outros sistemas (`DrownedDirector`, `FogManDirector`) recebem as referências do `Game` em `setup()`.

## Autoloads
_Nenhum._

## Sinais entre sistemas
- `Player.interaction.focus_changed` → `Hud.show_prompt` — hotkey ao mirar.
- `Player.interaction.hold_progress_changed` → `Hud.show_hold_progress` — barra de interações de duração.
- `NightDirector.time_changed` → `Lighthouse.show_time` — relógio de parede.
- `NightDirector.night_started` → `Game` → `EventDirector.reset_night`.
- `Lighthouse.jerrycan_carried_changed` → `Player.set_carrying` — galão na mão.
- Dentro do farol: `Generator.power_changed` → `PowerConsumer` (relógio, luzes, lâmpada); `BeamControl.switched` → lâmpada; `LighthouseLamp.beam_active_changed` → consumo do gerador, painel e `Lighthouse.beam_active_changed`; encher/despejar do galão.
- Eventos: cada sistema se registra no `EventDirector` (`Lighthouse`, `FogSystem`, `BoatDirector`).
- `NightDirector.night_ended` → `Game` (congela, limpa entidades, tela ou vitória); `NightEndScreen.continue_requested` → próxima noite.
- `Player.died` → `Game` → `run_lost`. `Player.slowed_changed` → `Hud.set_slowed`.
- `FogSystem.intensity_changed` → `Exterior.set_fog_intensity`, `BoatDirector.set_fog_intensity`; `FogSystem.covers_lighthouse_camera_changed` → `FogManDirector.set_fog_covers_camera`.
- `Lighthouse.beam_active_changed` → `BoatDirector.set_beam_active`.
- `BoatDirector.boat_arrived` → `Game` → `Radio.ring`; `boat_gone` → `Radio.stop_ringing`; `boat_sank` → `DrownedDirector.add_drowned_point`. `Radio.answered` → `BoatDirector.mark_answered`.
- `FogManDirector.player_blinded` → `Hud.show_blindness`.
- `Drowned.effect_triggered` → `DrownedDirector` → farol ou `Player.kill`.

## Input map
Teclas físicas (independem do layout do teclado). O olhar usa o movimento do mouse. Não há pulo (GDD 1.2.20).

| Ação | Tecla |
|---|---|
| `move_forward` / `move_back` / `move_left` / `move_right` | W / S / A / D |
| `sprint` | Shift |
| `crouch` | Ctrl |
| `toggle_flashlight` | Z |
| `check_battery` | X |
| `interact` | E (segurar em interações de duração) |

## Camadas de colisão
1 — `world` — paredes, chão, escada / todos colidem; raios de oclusão
2 — `barriers` — porta de entrada e alçapão / jogador e Afogados colidem; o Homem de Nevoeiro ignora
3 — `player` — jogador / detectado por Afogados e Homem de Nevoeiro
4 — `drowned` — Afogados
5 — `fog_man` — Homem de Nevoeiro
6 — `interactable` — objetos interativos / detectados pelo raio de interação do jogador
7 — `player_bounds` — paredes invisíveis que só o jogador detecta (ex.: vão da porta quebrada; ele nunca sai do farol)

## Áudio
Buses em `default_bus_layout.tres`: `Master` → `Music`, `SFX`. Sons placeholder (tons sintéticos) em `assets/audio/placeholder/`, gerados por `tools/generate_placeholder_audio.gd` (rodar com `godot --headless --path . --script res://tools/generate_placeholder_audio.gd`). Sons em loop usam `components/looping_sound.gd`.

## Navegação
Navmesh assada em runtime no `Game`, sem porta e alçapão (decisão 0009). `project.godot`: `navigation/3d/default_cell_size` e `default_cell_height` = 0.1.
