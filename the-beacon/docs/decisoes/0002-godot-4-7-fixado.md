# 0002 — Godot 4.7 fixado

- **Data**: 2026-10
- **Status**: aceita

## Contexto
Mudanças de versão alteram formato de cena, avisos e comportamento, quebrando testes sem mudança de código.

## Decisão
Godot 4.7.x via Steam, no branch `stable-4.7` (recebe só patches). `scripts/check-godot-version.ps1` compara a versão instalada com `config/features` do `project.godot` e bloqueia o check em caso de divergência.

## Alternativas descartadas
- **Atualização automática da Steam**: risco de salto de versão no meio do projeto.
- **Executável standalone**: desnecessário, pois o executável da Steam devolve saída ao terminal com redirecionamento.

## Consequências
Migrar para 4.8+ é uma decisão explícita, registrada em nova nota.
