# 0024 — Modo debug por constante e painel no jogo

- **Data**: 2026-11
- **Status**: aceita

## Contexto
Testar balanceamento e situações raras (nevoeiro no alçapão, Afogado entrando, carranca na escada) exige mexer no código ou nos `.tres` e esperar a noite chegar lá. O desenvolvedor quer um painel dentro do jogo para disparar funções e mudar valores ao vivo (`../notes/feature-godmode.txt`).

## Decisão
- `DebugMode.ENABLED` (`debug/debug_mode.gd`) liga o modo no código. Ele só vale em build de debug (`OS.is_debug_build()`): um export nunca traz o painel.
- `DebugPanel` (`debug/debug_panel.tscn`) é filho do `Game`, fora do `World`, com `process_mode = ALWAYS`. Abre com a ação `debug_menu`, tecla física Y, sem botão de controle e fora da tela de remapeamento (decisão 0018).
- Aberto, a simulação continua rodando e o jogador fica travado como na pausa. A caixa "Pausar simulação" congela o `World` só enquanto o painel está aberto.
- O painel chama os sistemas ("call down"); nenhum sistema conhece o painel.

## Alternativas descartadas
- **Inspetor remoto do editor**: exige o editor aberto e não dispara funções.
- **Tecla R da nota original**: já é `drop_item`. F1 exige Fn em alguns teclados.

## Consequências
O jogo ganha uma ação de input só de teste e um nó a mais no `Game`. Funções novas do painel podem pedir métodos públicos pequenos nos sistemas.
