# Instalação do pacote

Extraia este zip dentro de `the-beacon-mvp/`. A pasta `the-beacon/` do zip se mescla com a do projeto.

## Arquivos que substituem os existentes
- `.editorconfig`, `.gitignore`
- `scripts/check.ps1`, `scripts/check-godot-version.ps1`
- `test/unit/smoke_test.gd`: apague o antigo `test/unit/smoke-test.gd` (e o `.uid` dele, se existir)

O `.mcp.json` não está no pacote: mantenha o seu.

## Passos manuais (uma vez)
1. No editor do Godot: **Project Settings → Debug → GDScript → Untyped Declaration = Error**
   (ative "Advanced Settings" se não aparecer). Torna a tipagem obrigatória também para o Godot,
   e a etapa de parse do check passa a pegar declarações sem tipo.
2. Rode `.\scripts\check.ps1` e confirme `CHECK OK`.
3. Abra o `claude` na pasta `the-beacon`, aprove o hook e o MCP se pedir, e rode `/inicio`.
4. Commit de tudo.

## Por agente
| Agente | Lê | Comandos |
|---|---|---|
| Claude Code | `CLAUDE.md` → importa `AGENTS.md` | `.claude/commands/` |
| Codex | `AGENTS.md` (nativo) | peça "siga `.agents/fluxos/inicio.md`" |
| Gemini CLI | `GEMINI.md` → importa `AGENTS.md` | `.gemini/commands/` |

O MCP do Godot e o hook de versão estão configurados só para o Claude Code.
