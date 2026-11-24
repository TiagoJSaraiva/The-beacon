# 0031 — Balanceamento em tabela por noite

- **Data**: 2026-11
- **Status**: aceita

## Contexto
Cada valor de balanceamento existia uma vez por dificuldade, nos sub-configs do `.tres`. Só a chance dos eventos mudava de noite para noite, por uma fórmula (`chance_increase_per_night`). Os eventos (`config/events/*.tres`) eram compartilhados entre as dificuldades, então um valor de evento valia para as três. O desenvolvedor quer balancear o aumento da dificuldade noite a noite numa tabela por dificuldade, com uma linha por valor e uma coluna por noite, editada no modo debug (`../notes/godmode.txt`, decisão 0024).

## Decisão
- Cada dificuldade tem uma tabela em `config/balance/<id>.json`: uma linha por campo `@export` numérico ou bool da dificuldade, dos sub-configs e dos eventos (chave `<seção>.<campo>`, ex.: `fog.advance_per_second`, `events/boat.chance_per_check`) e um valor por noite. Ficam de fora `nights` e `tutorial_enabled`, copiados pelo `RunState`. O arquivo tem uma linha da tabela por linha de texto, para ler e comparar no git.
- `BalanceTable` (`config/balance_table.gd`, puro) gera as linhas a partir dos configs: um `@export` novo vira uma linha nova, com o valor do `.tres` em todas as noites, sem mudar código. Linha desconhecida no arquivo é ignorada com aviso; noites a menos repetem o último valor.
- O autoload `BalanceService` lê e guarda as tabelas enquanto o jogo está aberto, para que as edições do painel sobrevivam à recarga da cena a cada noite (decisão 0015). O `Game` monta a noite com `config_for_night`: uma cópia profunda da dificuldade (eventos inclusive) com os valores da noite. A dificuldade do `.tres` não muda e continua sendo a que passa entre noites.
- `chance_increase_per_night` saiu: o aumento da chance está na linha `difficulty.event_chance_multiplier`, gerada com os valores que a fórmula dava.
- Os números do `.tres` passam a ser só o valor inicial de uma linha nova.

## Alternativas descartadas
- **Tabela dentro do `.tres` (Dictionary exportado)**: salvar de dentro do jogo regravaria o `.tres` inteiro, a cópia local do executável exportado teria outro formato e editar um dicionário de arrays no Inspector é ruim.
- **Gravar só as noites que diferem de uma base**: arquivo menor, mas a tabela completa, com uma célula por noite, é o que o desenvolvedor pediu e é mais simples de ler, salvar e revisar.
- **Estado em `static var` no lugar do autoload**: estado global implícito e difícil de isolar nos testes (mesmo motivo da decisão 0013).

## Consequências
Balancear vira editar a tabela; o `.tres` só define a estrutura. Mudar um número no Inspector não tem efeito se a linha já está na tabela. Valores que hoje são constantes no código só entram na tabela depois de virarem `@export` num config. A cópia profunda por noite custa pouco (uma vez por carga de cena).
