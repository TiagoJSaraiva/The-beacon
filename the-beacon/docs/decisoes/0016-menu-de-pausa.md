# 0016 — Menu de pausa no Esc no lugar da agenda

- **Data**: 2026-11
- **Status**: aceita

## Contexto
O GDD original não tinha pausa: o menu durante a partida era a agenda na mesa da torre, com o mundo correndo. Na revisão das mecânicas (`planos/entrega-2.md`), o MVP passa a ter um menu tradicional no Esc, e a agenda vira ideia para versões futuras. Como o save só existe entre noites (0014), um menu sem pausa obrigaria o jogador a escolher entre configurar o jogo e arriscar a partida.

## Decisão
- `PauseMenu` (`ui/pause_menu/`), instanciado no `Game`, abre com a ação `pause` (Esc) e pausa a árvore (`get_tree().paused`). Ele próprio roda com `process_mode = ALWAYS`.
- Páginas: índice (Continuar, Configurações, Sair para o menu), configurações (`SettingsPanel`) e confirmação de saída, que avisa que a partida será perdida.
- Só abre com a simulação rodando: nas telas de fim de noite, morte e vitória, fica desabilitado.
- A agenda (cena, overlay e controlador) sai do projeto.

## Alternativas descartadas
- **Menu no Esc sem pausa**: coerente com o GDD original, mas punitivo sem save no meio da noite.
- **Manter a agenda como menu**: o game designer adiou o menu "dentro do mundo" para depois do MVP.

## Consequências
O jogo passa a ter pausa, contrariando o GDD original (a atualizar pelo desenvolvedor). Sair pelo menu de pausa perde a partida (0014).
