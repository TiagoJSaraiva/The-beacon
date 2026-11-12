# Modo debug

## Propósito
Painel dentro do jogo para testar funções e balanceamento sem mexer no código (decisão 0024).

## Componentes
- `debug/debug_mode.gd` (`DebugMode`): `ENABLED` liga o modo; `is_active()` exige também build de debug.
- `debug/debug_panel.tscn` (`DebugPanel`, `CanvasLayer`, `process_mode = ALWAYS`): filho do `Game`, fora do `World`. Abas em `%Tabs`.

## Regras
- Y (`debug_menu`) abre e fecha; Esc também fecha, sem abrir o menu de pausa. Não abre com o menu de pausa aberto nem fora da simulação (fim de noite, morte, vitória).
- Aberto, a simulação continua; o jogador fica travado e o mouse solto. "Pausar simulação" congela o `World` e é desfeita ao fechar.

## Sinais
- `DebugPanel.opened_changed(opened)` → `Game` → `Player.set_controls_enabled`.

## Testes
- `test/scenes/debug_panel_test.gd`: abrir, pausar o `World`, fechar com Esc sem abrir a pausa; não abrir com o painel desabilitado.
