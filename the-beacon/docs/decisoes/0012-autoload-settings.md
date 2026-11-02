# 0012 — Autoload Settings para as preferências do jogador

- **Data**: 2026-11
- **Status**: aceita

## Contexto
As configurações (GDD 15.2: volumes geral, música e efeitos, e sensibilidade do mouse; vídeo e controles fora do MVP) são editadas no menu principal e na agenda. Os volumes precisam valer desde a abertura do jogo, antes de qualquer menu.

## Decisão
- Autoload `Settings` (`autoload/settings.gd`): carrega `user://settings.cfg` (`ConfigFile`) ao iniciar, aplica os volumes nos buses `Master`, `Music` e `SFX` e emite `changed` a cada edição.
- Regras e limites em `SettingsState` (`autoload/settings_state.gd`, puro e testado).
- Grava ao sair da tela de configurações (`SettingsPanel`, `ui/settings/`), não a cada movimento do slider.
- A sensibilidade é uma escala sobre `Player.mouse_sensitivity`, aplicada pelo `Game` (o `Player` não conhece o autoload).

## Alternativas descartadas
- **Guardar as configurações no `SaveService`**: mistura preferência do jogador com save de partida, que é apagado o tempo todo.
- **Cada tela aplicar e gravar por conta própria**: duas cópias da mesma lógica (menu e agenda) e volumes sem efeito até abrir uma delas.

## Consequências
Uma mudança vale na hora nas duas telas. Uma configuração nova exige um campo em `SettingsState`, um setter em `Settings` e um controle no `SettingsPanel`.
