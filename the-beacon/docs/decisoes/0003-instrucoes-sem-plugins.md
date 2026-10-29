# 0003 — Instruções em AGENTS.md, sem plugins de agente

- **Data**: 2026-10
- **Status**: aceita

## Contexto
O projeto deve funcionar com Claude Code, Codex e Gemini CLI. Plugins como Superpowers, claude-mem e ECC adicionam contexto, custo e instruções concorrentes, e são específicos de um agente.

## Decisão
`AGENTS.md` é a fonte única de instruções. `CLAUDE.md` e `GEMINI.md` apenas o importam. Fluxos de trabalho ficam em `.agents/fluxos/` como markdown comum, com comandos finos por agente apontando para eles.

## Alternativas descartadas
- **Superpowers**: bom processo, mas TDD rígido não combina com mecânicas de jogo, e é específico do Claude.
- **claude-mem**: memória automática e opaca, fora do repositório.
- **LSP de GDScript**: ganho pequeno para o tamanho atual; reavaliar se o projeto crescer muito.

## Consequências
A disciplina de memória depende dos fluxos `fim` e da revisão do desenvolvedor.
