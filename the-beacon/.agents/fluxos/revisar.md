# Fluxo: revisar

1. Revise o diff atual (`git diff` e `git diff --staged`) ou os arquivos indicados.
2. Compare com `docs/convencoes-gdscript.md` e com as decisões em `docs/decisoes/`.
3. Audite os fluxos tocados (decisão 0032): comentários, duplicação e código morto. Só neste comando; o `/fim` usa as categorias abaixo, mas não roda este passo.
   - Prepare: `node scripts/auditoria.mjs`. Ele escolhe os fluxos tocados pelo diff (cada nota de `docs/sistemas/` é um fluxo; scripts que nenhuma nota cita formam o grupo `sem-sistema`). Com o argumento `tudo`, use `--tudo`; com nomes de sistemas, `--fluxo <a,b>`. Nenhum fluxo: pule para o passo 4.
   - Revise cada fluxo listado por `.agents/fluxos/auditar-fluxo.md`. No Claude Code: um subagente `revisor-fluxo` por fluxo, todos em paralelo, com o nome do fluxo no pedido. Nos demais agentes: siga o procedimento você mesmo, um fluxo por vez.
   - Consolide: junte achados repetidos entre fluxos e procure no `.auditoria/indice.md` duplicação entre os fluxos revisados. **Confira cada achado no código antes de reportar** e descarte o que não se confirmar.
   - Scripts sem nota e arquivos citados que não existem, listados pelo script, entram em **Comentário divergente** como nota de sistema desatualizada.
4. Reporte separado nestas categorias, omitindo as vazias:
   - **Bugs reais**
   - **Comentário divergente** (`##` ou `#` que não corresponde mais ao código ou que repete o nome da função; nota de `docs/sistemas/` que não bate com o código. O check só garante que o `##` existe e que foi alterado ou confirmado quando a função mudou, não que está certo)
   - **Duplicação** (funções com o mesmo comportamento, dentro de um fluxo ou entre fluxos)
   - **Código morto** (função, variável, sinal ou ramo sem uso; função usada só em testes)
   - **Edge cases** não tratados
   - **Performance**
   - **Robustez** (dados inválidos, nós ausentes, saves corrompidos)
   - **Responsabilidade e acoplamento** (script com mais de uma responsabilidade, regra de jogo presa ao nó, referência direta entre irmãos fora da exceção da decisão 0006, variação de conteúdo em `if`/`match`; ver `docs/convencoes-gdscript.md`)
   - **Manutenibilidade**
   - **Legibilidade**
   - **Preferência de estilo** (opinativo, baixa prioridade)
5. Para cada item: arquivo e linha, o problema e a sugestão. Ordene por gravidade.
6. Não altere nada até o desenvolvedor escolher o que aplicar.
