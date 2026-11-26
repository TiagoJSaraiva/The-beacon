@AGENTS.md

## Específico do Gemini CLI

- Fluxos disponíveis como comandos: `/inicio`, `/planejar`, `/revisar`, `/fim`.
- O passo de auditoria do `/revisar` roda sem subagentes: siga `.agents/fluxos/auditar-fluxo.md` um fluxo por vez.
- Não há hook de início: rode a checagem de versão descrita em `.agents/fluxos/inicio.md`.
