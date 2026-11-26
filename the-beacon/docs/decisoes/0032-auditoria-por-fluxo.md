# 0032 — Auditoria de comentários, duplicação e código morto por fluxo

- **Data**: 2026-11
- **Status**: aceita

## Contexto
A 0011 garante pelo check que toda função tem `##` e que ele é revisto quando a função muda, mas não que está certo; a coerência ficou para a revisão. O `/revisar` só olhava o diff, então um `##` que ficou errado num commit antigo não era mais visto.

O comentário errado é o defeito mais caro para quem trabalha com agentes: o agente lê o `##`, confia nele, não reconhece a função que já faz o que precisa e escreve outra igual. A duplicação nasce do comentário, e o código morto aparece quando uma das duas deixa de ser chamada.

## Decisão
- O `/revisar` ganha um passo de auditoria (`.agents/fluxos/revisar.md`), só nele: o `/fim` e o `/integrar` não o rodam.
- Um fluxo é uma nota de `docs/sistemas/` com os arquivos que ela cita entre crases e os scripts das cenas citadas. Scripts que nenhuma nota cita formam o grupo `sem-sistema`, e isso já é um achado: a nota está desatualizada.
- `scripts/auditoria.mjs` prepara a auditoria sem julgar nada: o mapa fluxo → scripts, o índice de todas as funções do jogo (assinatura e `##`) e os candidatos a código morto (função sem referência por nome em `.gd`, `.tscn` e `.tres`, fora de comentários, ou referenciada só em testes). Saída em `.auditoria/`, ignorada pelo git. É o único script do projeto em Node, e não em PowerShell: o Node já é exigido pelo MCP `godot` (`npx`), e o mesmo script serve aos outros projetos feitos a partir do modelo.
- Por padrão, só os fluxos tocados pelo diff (mudanças locais, arquivos novos e commits não enviados). `/revisar tudo` audita o jogo inteiro.
- Cada fluxo é revisado por `.agents/fluxos/auditar-fluxo.md`. No Claude Code, um subagente `revisor-fluxo` (Haiku, esforço alto, só leitura) por fluxo, em paralelo. Nos outros agentes, o próprio agente segue o procedimento, um fluxo por vez (decisão 0003).
- O agente principal consolida: junta achados repetidos, procura duplicação entre fluxos no índice e confere cada achado no código antes de reportar. Nada é alterado até o desenvolvedor escolher.

## Alternativas descartadas
- **Auditar o jogo inteiro a cada `/revisar`**: custo proporcional ao tamanho do jogo em toda revisão, quase sempre para reler código que não mudou.
- **Só o subagente, sem o script**: um revisor que vê um fluxo não sabe se uma função é chamada de outro sistema, de um sinal ligado na cena ou por `call("nome")`, nem conhece as funções de fora para achar duplicação.
- **Só o script**: contagem de referências acha código morto, mas não compara o significado do comentário com o corpo.
- **Revisores com modelo maior**: cada fluxo é uma leitura local de poucos scripts; o custo maior não compensa, e o agente principal já confere cada achado.
- **Fluxos de jogo descritos à parte (ex.: "início da noite → fim")**: mais um documento para manter; as notas de sistema já listam os componentes e precisam estar atuais de qualquer forma.

## Consequências
Os `##` e as notas de sistema passam a ser conferidos contra o código sempre que o sistema muda, e o índice mostra ao revisor as funções de todo o jogo. Não é o fluxo `multiagente` removido pela 0008: os revisores só leem, sem branch, worktree nem commit. A seção **Componentes** das notas precisa citar os caminhos dos scripts e cenas, senão eles caem em `sem-sistema`. A contagem por nome não distingue funções homônimas em classes diferentes: um nome usado em qualquer lugar conta para todas, então o script pode deixar passar código morto, mas só marca como morto o que é usado quando o nome é montado em tempo de execução (ex.: `call("_on_" + acao)`).
