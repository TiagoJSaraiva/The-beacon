# Menus, telas e configurações

## Propósito
Fluxo fora da simulação (GDD 15.1, 15.2): menu principal, seleção de dificuldade, configurações, fim de noite, game over e plantão concluído.

## Componentes
- `ui/main_menu/main_menu.tscn` (`MainMenu`, Main Scene): Novo Jogo → seleção de dificuldade; Continuar (desabilitado sem save válido); Configurações; Sair. Os botões de dificuldade saem do `DifficultyCatalog`, com as bloqueadas desabilitadas e marcadas "(bloqueada)".
- `ui/settings/settings_panel.tscn` (`SettingsPanel`): volumes geral, música e efeitos, e sensibilidade do mouse. Usado no menu e na agenda.
- `ui/night_end/night_end_screen.tscn` (`NightEndScreen`), `ui/game_over/game_over_screen.tscn` (`GameOverScreen`), `ui/victory/victory_screen.tscn` (`VictoryScreen`): instanciadas no `Game`, fora do `World`.
- Autoloads: `SceneRouter` (troca de cena e pedido de partida, decisão 0010), `Settings` (decisão 0012). Save e desbloqueio em `save-e-progresso.md`.

## Regras
- Escolher uma dificuldade apaga o save existente (Novo Jogo sobrescreve) e começa o plantão.
- Morte: simulação congela, save apagado, "Você MAMOU" com Tentar novamente (mesma dificuldade, da noite 1), Menu principal e Sair.
- Vitória (fim da última noite): save apagado, próxima dificuldade liberada, tela com dificuldade e noites sobrevividas.
- Fim de noite → Menu principal não mexe no save.
- Configurações valem na hora (volumes nos buses `Master`, `Music`, `SFX`) e são gravadas ao clicar Voltar, em `user://settings.cfg`. Limites em `SettingsState`. Vídeo e controles estão fora do MVP.
- Abrindo `game/game.tscn` direto (editor, testes), o jogo usa a `default_difficulty` (Easy).

## Sinais
- `SettingsPanel.back_requested`; `Settings.changed` → `Game` (sensibilidade do jogador).
- `GameOverScreen.retry_requested`, `menu_requested`, `quit_requested`; `VictoryScreen.menu_requested`; `NightEndScreen.menu_requested` → `SceneRouter`.

## Testes
- `test/unit/settings_state_test.gd`, `progress_state_test.gd`. Menus e telas não têm teste de cena: validar jogando.
