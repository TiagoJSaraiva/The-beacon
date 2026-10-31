# Homem de Nevoeiro

## Propósito
Manifestação do nevoeiro que cega o jogador por alguns segundos (GDD 1.2.10).

## Componentes
- `fog_man/fog_man_tracker.gd` (`FogManTracker`, puro): aparição, dissipação, intervalo entre aparições.
- `fog_man/fog_man.tscn` (`FogMan`, `CharacterBody3D` na camada `fog_man`, colide só com `world`): atravessa porta e alçapão.
- `fog_man/fog_man_director.gd` (`FogManDirector`, nó no `World`, recebe `Player` e `Exterior` em `setup()`).

## Regras
- Surge em `FogManSpawn` quando o nevoeiro cobre a câmera do farol, se não houver outro e o intervalo (`spawn_cooldown_seconds`) tiver passado. Vai até o jogador (`move_speed`).
- Dissipa após `dissipate_seconds` contínuos dentro do cone aceso da lanterna, com linha de visão livre (paredes, piso e alçapão fechado bloqueiam a luz).
- Tocar o jogador (`touch_distance`) cega por `blind_seconds` (tela preta) e ele some. Não mata.
- Às 06:00 some.

## Sinais
- `FogManDirector.appeared`, `dissipated`, `player_blinded(seconds)` → `Hud.show_blindness`.

## Testes
- `test/unit/fog_man_tracker_test.gd`. Validado por sonda headless: atravessa porta e alçapão fechados e cega o jogador.
