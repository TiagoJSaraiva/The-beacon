# 0022 — Revisão do `##` de toda função alterada

- **Data**: 2026-11
- **Status**: aceita (amplia 0021)

## Contexto
A 0021 exige `##` em toda função e o check garante que ele existe, mas não que acompanha o código. Uma instrução escrita, sozinha, não foi seguida antes (a própria 0021 registra isso). Como os comentários descrevem o que o código faz hoje, inclusive bugs, uma correção muitas vezes também exige mudar o `##`.

## Decisão
- Ao alterar uma função (assinatura ou corpo), o `##` dela é revisado no mesmo passo.
- `scripts/check-doc-review.ps1`, chamado pelo `check.ps1` (inclusive no `-Fast`), compara o código com o HEAD (`git diff`, mudanças preparadas ou não). Reprova a função de arquivo versionado com alguma linha da assinatura ou do corpo alterada e nenhuma linha do bloco `##` alterada.
- Quando o `##` continua correto, `-Reviewed "<arquivo>::<função>"` o confirma: o hash do corpo atual vai para `.doc-review`, ignorado pelo git. Mexer de novo na função invalida a confirmação; entradas que não valem mais são descartadas a cada execução. O agente cita as funções confirmadas no resumo.
- Arquivos novos ficam de fora: tudo neles é novo, e o `##` deles já é exigido pela 0021.

## Alternativas descartadas
- **Mudar algo no `##` só para marcar a revisão (ex.: espaço no fim)**: o `gdformat -Fix` remove o espaço, e seria uma mudança invisível no diff.
- **Confirmação na mensagem do commit**: o check roda antes do commit, quando a mensagem não existe; exigiria um hook `commit-msg`, e o repositório não tem hooks versionados.

## Consequências
Cada função alterada exige um ato explícito: editar o `##` ou confirmá-lo, vendo o texto atual na mensagem do check. Código movido sem mudança, reformatação e a remoção de uma linha logo após o fim de uma função aparecem como alteração e pedem confirmação. A confirmação pode ser feita sem ler o comentário: a lista no resumo é o que o desenvolvedor confere.
