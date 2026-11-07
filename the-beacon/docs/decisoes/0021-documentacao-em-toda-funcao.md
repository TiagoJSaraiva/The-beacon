# 0021 — Comentário de documentação em toda função do jogo

- **Data**: 2026-11
- **Status**: aceita

## Contexto
O desenvolvedor lê e revisa todo o código, e o hover do editor mostra o `##` de uma função em qualquer chamada dela. A convenção pedia `##` só em classes e métodos públicos, e `AGENTS.md` dizia que comentários explicam o porquê, não o quê. Mesmo assim, só 85 de 238 funções públicas tinham `##`, e 98 de 465 no total: a regra escrita, sozinha, não foi seguida.

## Decisão
- Toda função fora de `test/` e `addons/` tem `##` logo acima dela, inclusive privadas, virtuais e callbacks.
- O `##` é o contrato para quem chama: o que a função faz ou devolve, com efeitos, unidades e pré-condições. O `#` comum continua explicando o porquê, e nenhum dos dois repete o código.
- `scripts/check-docs.ps1`, chamado pelo `check.ps1` (inclusive no `-Fast`), reprova função sem `##`.
- O alerta de ~200 linhas por script passa a contar só linhas de código.

## Alternativas descartadas
- **Só a instrução, sem check**: era a situação anterior, com 36% de adesão nas públicas.
- **Só funções públicas**: as privadas também são chamadas e lidas, e continuariam sem descrição no hover.
- **Exceção para virtuais**: o hover ajuda pouco nelas, mas o comentário ajuda na leitura, e uma regra sem exceções é mais fácil de verificar.

## Consequências
Toda chamada mostra uma descrição no hover. Em troca, cada mudança de comportamento tem mais um texto para manter, e um `##` errado engana mais que a falta dele. O check só garante que ele existe: a coerência fica para a revisão (`.agents/fluxos/revisar.md`). Os testes ficam de fora, porque `test_<comportamento>` já descreve o caso.
