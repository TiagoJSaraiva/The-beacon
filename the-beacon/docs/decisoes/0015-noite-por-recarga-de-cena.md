# 0015 — Cada noite recarrega a cena de jogo a partir do RunState

- **Data**: 2026-11
- **Status**: aceita (substitui, da 0008, os itens "uma única cena de jogo para o plantão inteiro" e "toda classe de estado tem `to_dict`/`from_dict`")

## Contexto
A 0008 manteve uma única cena para o plantão inteiro porque, no GDD original, tudo continuava de uma noite para a outra. Na revisão das mecânicas (`planos/entrega-2.md`), entre noites só sobrevivem pontos de Afogado, mangueira estourada, bateria da lanterna e o progresso do tutorial; todo o resto volta ao estado inicial. O save também passou a ser só entre noites (0014).

## Decisão
- O `RunState` (`game/run_state.gd`) guarda tudo o que passa de uma noite para a outra: dificuldade, noites, noite atual e o estado persistente.
- Cada noite é uma carga nova de `game/game.tscn`: `SceneRouter.play_night(difficulty, run)`. Plantão novo, próxima noite e Continuar usam esse mesmo caminho.
- O `Game` aplica o estado persistente ao montar a noite e o recolhe às 06:00 (`RunCarryover`, `game/run_carryover.gd`).
- Só o estado persistente precisa de `to_dict`/`from_dict` (o `RunState` e o que o `SaveService` grava). Classes de estado da noite não serializam.
- Os outros itens da 0008 continuam valendo: regras em `RefCounted` puros, RNG injetado, configuração em `Resource`, eventos registrados, fiação no pai.

## Alternativas descartadas
- **Manter a cena e resetar cada sistema entre noites**: cada sistema precisaria de um `reset()` correto, e "próxima noite" e "Continuar" seriam dois caminhos diferentes, um deles sem teste natural.

## Consequências
O reset entre noites é garantido, e o caminho de Continuar é o mesmo de toda noite. Estado que precisa sobreviver tem que ir explicitamente para o `RunState`. A navmesh é assada de novo a cada noite (um travamento curto na abertura da cena).
