# Procedimento: auditar um fluxo

Usado pelo passo de auditoria de `revisar.md`, um fluxo por vez (no Claude Code, pelo subagente `revisor-fluxo`). Não é um comando. **Só leitura: não altere nenhum arquivo.**

Um fluxo é uma nota de `docs/sistemas/` com os scripts que ela cita, ou o grupo `sem-sistema` (scripts que nenhuma nota cita). O comentário que não bate com a função é o defeito mais grave desta auditoria: quem lê o `##`, confia nele e não encontra a função que já faz o que precisa acaba escrevendo outra igual.

1. Leia, inteiros:
   - `.auditoria/fluxos/<fluxo>.md`, gerado por `node scripts/auditoria.mjs`: a nota, os scripts e os candidatos a código morto;
   - a nota do sistema, se houver;
   - cada script listado;
   - `.auditoria/indice.md`: todas as funções do jogo, com a assinatura e o `##` em uma linha.
2. Procure, nesta ordem:
   - **Comentário divergente**. Para cada função, compare o `##` com o corpo, linha a linha. É divergência:
     - algo que o `##` afirma e o código não faz, ou faz diferente (condição, valor, unidade, ordem);
     - efeito visível para quem chama que o `##` omite: o que devolve, sinais emitidos, estado alterado, nós criados ou liberados, casos em que devolve nulo, vazio ou falso;
     - `##` que só repete o nome da função;
     - `#` comum que descreve algo que o código ao lado não faz, ou um motivo que não vale mais;
     - `##` de classe, de variável, de sinal ou de `@export` que não bate com o uso.
   - **Nota divergente**: regra, valor, componente ou sinal da nota do sistema que não bate com o código.
   - **Duplicação**: duas funções com o mesmo comportamento (o mesmo cálculo ou a mesma sequência de efeitos), dentro do fluxo ou entre uma função do fluxo e outra do índice. Suspeita com função de fora do fluxo: abra a outra e compare os corpos antes de reportar. Não conta como duplicação: implementações da mesma função virtual em classes diferentes, um wrapper de uma linha que só dá nome a uma chamada, e uma repetição que um `#` justifica.
   - **Código morto**:
     - cada candidato listado: busque o nome em `.gd`, `.tscn` e `.tres` (chamadas, `connect`, `call("nome")`, `[connection ... method=]`, trilhas de animação) e confirme;
     - variável, constante, sinal, `@export` ou enum declarado e nunca usado;
     - ramo que nunca executa e código depois de `return`.
     Função usada só em testes é código morto do jogo: diga quais testes a usam.
3. Fora do escopo: estilo, formatação, desempenho e bugs em geral, que são do restante do `/revisar`. Bug real visto de passagem: uma linha em **Outros**.
4. Responda só com os achados, sem introdução:

   ```
   - [Comentário divergente | Nota divergente | Duplicação | Código morto | Outros] arquivo:linha `função`: o problema, em uma frase.
     Evidência: o que o comentário diz × o que o código faz; ou onde está a outra função e o que as duas fazem; ou a busca feita.
     Confiança: alta | média
   ```

   Não reporte o que for de confiança baixa. Nada encontrado: `Nenhum achado em <fluxo>.`
