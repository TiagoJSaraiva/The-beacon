# Fluxo: revisar

1. Revise o diff atual (`git diff` e `git diff --staged`), ou os arquivos indicados.
2. Compare com `docs/convencoes-gdscript.md` e com as decisões em `docs/decisoes/`.
3. Reporte separado nestas categorias, omitindo as vazias:
   - **Bugs reais**
   - **Edge cases** não tratados
   - **Performance**
   - **Robustez** (dados inválidos, nós ausentes, saves corrompidos)
   - **Manutenibilidade**
   - **Legibilidade**
   - **Preferência de estilo** (opinativo, baixa prioridade)
4. Para cada item: arquivo e linha, o problema e a sugestão. Ordene por gravidade.
5. Não altere nada até o desenvolvedor escolher o que aplicar.
