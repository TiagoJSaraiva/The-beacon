# Carranca

## Propósito
Armadilha do nevoeiro dentro do farol: cega o jogador e, com o tempo, o derruba (entrega 2; substitui o Homem de Nevoeiro).

## Componentes
- `figurehead/figurehead_tracker.gd` (`FigureheadTracker`, puro): limite, intervalos de volta, contagem até a derrubada, dissolução.
- `figurehead/figurehead_spawn_rules.gd` (`FigureheadSpawnRules`, puro): área pela altura, áreas tomadas pelo nevoeiro, ponto fora da vista e longe.
- `figurehead/figurehead.tscn` (`Figurehead`, `Node3D` sem corpo físico): imóvel e translúcida; pula no jogador ou se dissolve quando o diretor manda.
- `figurehead/figurehead_director.gd` (`FigureheadDirector`, nó no `World`, recebe o `Player` em `setup()`): surgimento, gatilho, luz, ataques.

## Regras
- Surge só nas áreas já tomadas pelo nevoeiro: térreo (`GROUND_FLOOR`), escada (`STAIRS`) e cabine (`CABIN`). A área de um ponto vem da altura (`stairs_from_height` 3.84, `cabin_from_height` 10.6).
- O ponto é aleatório na navmesh do interior (até `spawn_attempts` tentativas): fora do campo de visão do jogador (`view_half_angle_degrees` 60° a partir do olhar) e a pelo menos `min_spawn_distance`. Ela surge virada para o jogador.
- No máximo `max_simultaneous` (3) ao mesmo tempo, com `spawn_interval_seconds` entre uma aparição e a seguinte.
- Com o jogador a até `trigger_range` e linha de visão livre (`world`/`barriers`), ela pula nele: cega por `blind_seconds` (tela preta) e some.
- Depois de `blinds_before_knockdown` cegueiras, o ataque seguinte derruba: o jogador ajoelha e não se move nem pula por `knockdown_seconds` (`Player.knock_down`); o olhar continua livre. A contagem recomeça.
- Sob o cone aceso da lanterna, com linha de visão livre, por `dissolve_seconds` contínuos, ela se dissolve.
- A vaga de uma carranca volta depois de `respawn_after_destroyed_seconds` (dissolvida) ou `respawn_after_attack_seconds` (atacou). Se o nevoeiro deixa a área dela, ela some e a vaga volta na hora.
- A noite seguinte começa sem carrancas e com a contagem zerada.

## Sinais
- `FigureheadDirector.appeared`, `dissolved`; `player_blinded(seconds)` → `Hud.show_blindness`; `player_knocked_down(seconds)` → `Player.knock_down`.
- `FogSystem.stage_changed` → `FigureheadDirector.set_fog_stage`.

## Testes
- `test/unit/figurehead_tracker_test.gd`, `figurehead_spawn_rules_test.gd`.
- `test/scenes/figurehead_test.gd`: com o nevoeiro no farol, surge longe do jogador e, com ele perto e à vista, pula e cega.
- `test/scenes/player_test.gd`: a derrubada segura o jogador e depois o solta.
