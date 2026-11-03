# Menus, telas e configurações

## Propósito
Fluxo fora da simulação (GDD 15.1, 15.2): menu principal, seleção de dificuldade, configurações, menu de pausa, fim de noite, game over e plantão concluído.

## Componentes
- `ui/main_menu/main_menu.tscn` (`MainMenu`, Main Scene): Novo Jogo → seleção de dificuldade; Continuar (desabilitado sem save válido); Configurações; Sair. Os botões de dificuldade saem do `DifficultyCatalog`, com as bloqueadas desabilitadas e marcadas "(bloqueada)".
- `ui/settings/settings_panel.tscn` (`SettingsPanel`): volumes geral, música e efeitos, sensibilidade do olhar e o botão Controles, que abre a página `ControlsPanel` (`ui/settings/controls_panel.tscn`, decisão 0018). Usado no menu principal e no menu de pausa.
- `ui/pause_menu/pause_menu.tscn` (`PauseMenu`, `process_mode = ALWAYS`): índice (Continuar, Configurações, Sair para o menu), configurações e confirmação de saída (decisão 0016).
- `ui/night_end/night_end_screen.tscn` (`NightEndScreen`), `ui/game_over/game_over_screen.tscn` (`GameOverScreen`), `ui/victory/victory_screen.tscn` (`VictoryScreen`): instanciadas no `Game`, fora do `World`, como o `PauseMenu`.
- Autoloads: `SceneRouter` (troca de cena e pedido de noite, decisões 0010 e 0015), `Settings` (decisão 0012). Save e desbloqueio em `save-e-progresso.md`.

## Regras
- Escolher uma dificuldade apaga o save existente (Novo Jogo sobrescreve) e começa o plantão.
- Pausa: a ação `pause` (Esc, Start) pausa a árvore e abre o menu; só com a simulação rodando (não no fim de noite, morte ou vitória). Esc numa subpágina volta ao índice; no índice, fecha. Sair para o menu pede confirmação e perde a partida (o save foi consumido ao começar a noite).
- Fim de noite: "Próxima noite" recarrega a cena na noite seguinte; "Salvar e sair" grava o `RunState` e vai ao menu.
- Morte: simulação congela, save apagado, "Você MAMOU" com Tentar novamente (mesma dificuldade, da noite 1), Menu principal e Sair.
- Vitória (fim da última noite): save apagado, próxima dificuldade liberada, tela com dificuldade e noites sobrevividas.
- Configurações valem na hora (volumes nos buses `Master`, `Music`, `SFX`; teclas no `InputMap`) e são gravadas ao voltar (botão ou Esc/B), em `user://settings.cfg`. Limites em `SettingsState`; ligações em `InputBindings`. Vídeo está fora do MVP.
- Controles: uma linha por ação de jogo, com a tecla e o botão atuais. Ativar um deles espera a nova tecla ou o novo botão; Esc cancela. Dar a uma ação a tecla de outra troca as duas. "Restaurar padrão" volta ao `project.godot`. Analógicos e L2 aparecem, mas não mudam.
- Navegação por controle: os menus pegam foco ao abrir e usam as ações `ui_*`; Esc ou B volta uma página (menu principal, configurações, controles, pausa).
- Abrindo `game/game.tscn` direto (editor, testes), o jogo começa um plantão novo na `default_difficulty` (Easy).

## Sinais
- `SettingsPanel.back_requested`, `ControlsPanel.back_requested`; `Settings.changed` → `Game` (sensibilidade do jogador), `Hud`, `ControlsPanel`.
- `PauseMenu.paused_changed(paused)`, `exit_requested` → `Game`.
- `NightEndScreen.continue_requested`, `save_and_exit_requested` → `Game`.
- `GameOverScreen.retry_requested`, `menu_requested`, `quit_requested`; `VictoryScreen.menu_requested` → `Game` ou `SceneRouter`.

## Testes
- `test/unit/settings_state_test.gd`, `input_bindings_test.gd`, `progress_state_test.gd`. Menus e telas não têm teste de cena: validar jogando.
