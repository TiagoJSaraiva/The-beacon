# 0018 — Controles remapeáveis no Settings

- **Data**: 2026-11
- **Status**: aceita (amplia 0012)

## Contexto
A entrega 2 trouxe suporte a controle e pediu remapeamento. O input map do `project.godot` é o padrão; a escolha do jogador precisa valer desde a abertura do jogo e sobreviver entre sessões, como volumes e sensibilidade (0012). Os prompts da HUD e os textos do tutorial citavam teclas fixas.

## Decisão
- Regras em `InputBindings` (`autoload/input_bindings.gd`, puro e testado): a tecla física de cada ação de jogo e o botão de controle das ações de botão.
  - Teclado: `move_*`, `jump`, `sprint`, `interact`, `toggle_flashlight`, `check_battery`, `drop_item`, `pause`.
  - Controle: `jump`, `interact`, `toggle_flashlight`, `check_battery`, `drop_item`, `pause`. Analógicos (mover, olhar) e L2 (correr) ficam fixos.
  - Conflito vira troca: dar a uma ação a tecla de outra passa a tecla antiga para a outra.
  - Arquivo com valores inválidos ou repetidos volta ao padrão.
- O autoload `Settings` guarda as ligações na seção `controls` do `user://settings.cfg` e as aplica no `InputMap` ao abrir o jogo e a cada mudança. Só troca os eventos de tecla e de botão; os de eixo ficam.
- `ControlsPanel` (`ui/settings/`) é uma página do `SettingsPanel`, nos dois menus.
- A HUD mostra a tecla atual (`InputBindings.label_for`) do último dispositivo usado (teclado ou controle) no prompt de interação e nos textos do tutorial, que trazem marcadores `{ação}`.
- Menus seguem nas ações `ui_*` padrão do Godot, que já incluem o controle; não são remapeáveis.

## Alternativas descartadas
- **Remapear também eixos e gatilhos**: captura e conflito entre eixo e botão complicam a tela sem ganho claro no MVP.
- **Conflito bloqueado (recusar a tecla)**: obriga o jogador a liberar a tecla antes; a troca resolve em um passo.
- **Guardar o `InputMap` inteiro serializado**: grava também o que não é remapeável e quebra quando o input map padrão muda.

## Consequências
Ação de jogo nova: decidir se entra em `InputBindings` (e com qual padrão), além do `project.godot`. Texto que cita uma tecla usa `{ação}`.
