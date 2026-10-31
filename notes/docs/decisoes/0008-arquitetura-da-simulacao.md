# 0008 — Arquitetura da simulação: regras puras, config em Resource e eventos registrados

- **Data**: 2026-10
- **Status**: aceita

## Contexto
O jogo é uma simulação de vários sistemas interligados (gerador, combustível, feixe, barcos, nevoeiro, Afogados...) cujos valores vão ser ajustados por meses e que precisa ser salva no meio da noite. Cada dificuldade muda só valores, não regras.

## Decisão
- **Regras e estado em `RefCounted` puros** (`*_state.gd`, `*_rules.gd`), sem depender da árvore de cena. Toda classe de estado tem `to_dict()` / `from_dict()` desde a criação, com teste de ida e volta. Os nós fazem o tick, leem input e aplicam o resultado.
- **Toda probabilidade recebe um `RandomNumberGenerator`** injetado, para testes determinísticos.
- **Configuração em `Resource`**: `DifficultyConfig` agrega sub-configs por sistema (`PowerConfig`, `FogConfig`...). Cada dificuldade é um `.tres` com os sub-configs embutidos; `DifficultyCatalog` guarda a ordem de desbloqueio. O jogo recebe a dificuldade e repassa o sub-config a cada sistema.
- **Eventos sorteáveis** são `EventDefinition` (janela de horário, intervalo, chance, máximo por noite). O `EventDirector` sorteia; cada sistema registra os eventos que trata com `register(definition, can_trigger, trigger)`. Evento novo = `.tres` novo + um registro, sem `match` central.
- **Uma única cena de jogo para o plantão inteiro**: as noites não recarregam a cena, então "tudo é mantido" entre noites (GDD 1.2.1) sem serializar nada.
- **Fiação entre sistemas no pai** (`Lighthouse`, `Game`); dependência de mão única entre componentes por `@export` tipado (0006).

## Alternativas descartadas
- **Autoload `GameState` com toda a simulação**: acesso simples, mas acopla tudo globalmente e contraria a regra de autoloads.
- **Uma cena por noite**: exigiria salvar e restaurar o farol inteiro a cada noite só para manter estado e posições.
- **Sub-configs em `.tres` separados por dificuldade**: mais de 30 arquivos para editar; embutidos, cada dificuldade é um único arquivo no inspetor.

## Consequências
Regras testáveis sem cena e save viável no meio da noite. Custo: cada sistema novo precisa de serialização e de um registro explícito; a cena de jogo cresce e precisa ter a fiação documentada em `arquitetura.md`.
