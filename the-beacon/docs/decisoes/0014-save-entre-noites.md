# 0014 — Save só entre noites, com o RunState

- **Data**: 2026-11
- **Status**: aceita (substitui 0011)

## Contexto
A revisão das mecânicas (`planos/entrega-2.md`) mudou o save: só se salva entre noites, Continuar começa a noite seguinte do início e sair no meio da noite (pelo menu, fechando o jogo ou Alt+F4) perde a partida inteira, para impedir que o jogador recomece uma noite ruim. Entre noites só sobrevivem pontos de Afogado, mangueira estourada, bateria da lanterna e o progresso do tutorial (decisão 0015).

## Decisão
- O autoload `SaveService` (`autoload/save_service.gd`) continua com dois arquivos separados em `user://`:
  - `run_save.json`: `{"version": N, "run": RunState.to_dict()}`. Versão diferente de `SAVE_VERSION` = sem save.
  - `progress.json`: `ProgressState`, como antes (a primeira dificuldade sempre liberada; vencer libera a seguinte).
- O save guarda só o `RunState` (`game/run_state.gd`), já apontando para a próxima noite. Não existe mais estado do meio da noite; o `RunSnapshot` sai.
- Só "Salvar e sair", na tela de fim de noite, grava.
- **Começar uma noite apaga o save.** Assim, qualquer saída antes do próximo "Salvar e sair" perde a partida, inclusive fechar o jogo à força, sem depender de detectar como o jogo foi fechado.
- Continuam apagando o save: morrer, vencer, sair pelo menu de pausa, escolher dificuldade em Novo Jogo.
- JSON legível; o catálogo de dificuldades é passado por parâmetro, sem preload escondido no autoload.

## Alternativas descartadas
- **Apagar o save só ao sair pelo menu de pausa**: Alt+F4 ou um travamento deixariam o save do começo da noite intacto, e o jogador poderia reiniciar uma noite ruim.
- **Manter o save do meio da noite (0011)**: exige serializar toda a simulação, e o design novo não quer mais retomar no meio da noite.

## Consequências
O save fica pequeno e estável: só muda quando o estado persistente muda. Fechar o jogo no meio da noite sem querer também perde a partida, e isso é intencional. Ao mudar o formato do `RunState`, subir `SAVE_VERSION`.
