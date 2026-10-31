# 0004 — Memória do projeto em docs/

- **Data**: 2026-10
- **Status**: aceita

## Contexto
Agentes não lembram nada entre sessões. Reexplicar o projeto custa tempo e tokens.

## Decisão
Memória curada em markdown dentro de `docs/`, versionada com o código: status, arquitetura, sistemas e decisões. Atualizada ao fim de cada sessão pelo fluxo `fim`. Anotações pessoais, wireframes e rascunhos ficam fora do repositório do jogo, em `../notes`.

## Alternativas descartadas
- **Vault do Obsidian**: o valor estava nos arquivos markdown, não no aplicativo.
- **Memória automática (claude-mem)**: registra tentativas, não o que é verdade.

## Consequências
Código e documentação voltam juntos em qualquer commit. A memória exige revisão do diff de `docs/`.
