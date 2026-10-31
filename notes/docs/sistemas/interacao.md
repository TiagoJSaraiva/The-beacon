# Interação

## Propósito
Uso dos objetos do cenário com a tecla E. A HUD só mostra a hotkey ao mirar e a barra de progresso (GDD 1.2.21).

## Componentes
- `components/interactable.gd` (`Interactable`, `Area3D` na camada `interactable`): declara modo, duração, prompt e restrições. Não conhece o efeito; o dono escuta os sinais.
- `player/interaction_ray.gd` (`InteractionRay`, `RayCast3D` na câmera): encontra o alvo e traduz a tecla.
- `components/hold_progress.gd` (`HoldProgress`): regra pura do progresso.
- `ui/hud/hud.tscn` (`Hud`): `show_prompt(text)`, `show_hold_progress(ratio, active)`; ligado pelo `Game`.

## Regras
- Modos: `PRESS` (toque), `HOLD` (segurar até completar `hold_seconds`; soltar ou trocar de alvo zera), `HOLD_CONTINUOUS` (efeito enquanto segura, ex.: trinco).
- Depois de completar, só aceita outra interação ao soltar a tecla. Segurar E enquanto vira para outro objeto não dispara o novo.
- O raio colide com `world` e `barriers`: paredes bloqueiam a mira.
- `hands_rule`: `ANY`, `FREE` (bloqueado com o galão na mão) ou `CARRYING` (só com o galão), conforme `InteractionRay.hands_busy`.
- `usable_check`: checagem opcional do dono, recebe o corpo de quem interage (ex.: alçapão só por cima).

## Sinais
- `Interactable.interacted`, `hold_completed`, `hold_state_changed(holding)`.
- `InteractionRay.focus_changed(prompt)`, `hold_progress_changed(ratio, active)` → `Hud`.

## Testes
- `test/unit/hold_progress_test.gd`.
- `test/scenes/interaction_test.gd`: soltar antes do fim zera; segurar até o fim completa.
