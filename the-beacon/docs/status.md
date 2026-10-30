# Status

## Onde paramos
- Molde do projeto configurado: Godot 4.7, pipeline `scripts/check.ps1` (versão, gdformat, gdlint, parse, gdUnit4), godot-mcp, instruções para agentes.
- Check validado por sabotagem (formatação, lint, parse, teste): cada uma falha na etapa certa. O parse passou a usar `--check-only` por script (decisão 0007), pois o `--import` não compilava scripts não usados.
- Nenhuma mecânica implementada ainda.

## Próximo passo
- Definir o escopo do MVP e registrar em `docs/arquitetura.md` (visão geral).
- Criar a cena principal e defini-la como Main Scene.

## Bloqueios
- Nenhum.
