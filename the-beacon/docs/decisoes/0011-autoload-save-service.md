# 0011 — Autoload SaveService e formato do save

- **Data**: 2026-11
- **Status**: substituída por 0014

## Contexto
GDD 1.2.22 e 1.2.14: um único save de partida, gravado só por "Salvar e sair" na agenda, com o estado exato no meio da noite. Ele é apagado ao morrer, ao vencer, em "Sair sem salvar" e em "Novo Jogo". O desbloqueio de dificuldades é permanente e nada disso o afeta. Menu, jogo e agenda leem e escrevem esses dados.

## Decisão
- Autoload `SaveService` (`autoload/save_service.gd`) com dois arquivos separados em `user://`:
  - `run_save.json`: `{"version": N, "run": {...}}`. Versão diferente de `SAVE_VERSION` = sem save (o menu desabilita "Continuar").
  - `progress.json`: `ProgressState` (`autoload/progress_state.gd`, regra pura e testada): a primeira dificuldade do catálogo sempre liberada; vencer libera a seguinte.
- JSON legível; vetores viram listas `[x, y, z]`. Cada sistema continua dono do próprio `to_dict`/`from_dict` (0008).
- O conteúdo de `run` é montado e restaurado pelo componente `RunSnapshot` (`game/run_snapshot.gd`), não pelo `Game` nem pelo `SaveService`, que só grava e lê o arquivo.
- O catálogo de dificuldades é passado por parâmetro (`is_unlocked(id, catalog)`), sem preload escondido no autoload.

## Alternativas descartadas
- **`ResourceSaver` com `.tres`**: guarda tipos nativos, mas carregar um `.tres` do usuário pode instanciar scripts arbitrários.
- **`ConfigFile`**: bom para chave-valor plano; o save tem listas de entidades aninhadas.
- **Um só arquivo para save e progresso**: apagar o save exigiria reescrever o arquivo preservando o progresso, e um erro ali apagaria o desbloqueio.

## Consequências
Formato inspecionável e fácil de depurar. Ao mudar o formato, subir `SAVE_VERSION` invalida saves antigos em vez de restaurá-los errado. JSON devolve números como `float`; os `from_dict` convertem.
