# Fluxo: planejar

1. Se o pedido for ambíguo, faça até 3 perguntas objetivas antes de planejar.
2. Leia `docs/arquitetura.md`, as notas de `docs/sistemas/` envolvidas e as decisões relevantes em `docs/decisoes/`.
3. Apresente o plano:
   - **Objetivo**: o que muda para quem joga.
   - **Arquivos**: criar / alterar, com uma linha de propósito cada.
   - **Cenas, nós e sinais**: o que entra na árvore e quem conecta a quem.
   - **Testes**: unitários previstos e, se houver, o teste de cena.
   - **Passos**: sequência de passos pequenos, cada um verificável com `check.ps1 -Fast`.
   - **Alternativas descartadas**: no máximo 2, com o motivo.
   - **Riscos**: o que pode quebrar ou ficar difícil de mudar depois.
4. Pare e aguarde aprovação. Não escreva código antes dela.
