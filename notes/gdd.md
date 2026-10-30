# Modelo Game Design Document - GDD

![](img/gdd-01.png)

Versão do Documento: 0.2
Autor: Dragão Baiano
Data: 30/10/2026

# 1. Projeto e Visão geral do Jogo

---

## ⇒ 1.1  High Concept (Conceito geral)

Adicione seu textohajvhkavhsfahsvkhas aqui

### 1.1 High Concept — Conceito Geral

O jogo é um survival horror de gerenciamento ambientado inteiramente dentro de um farol isolado em uma ilha. O jogador assume o papel de um faroleiro contratado para cumprir um período de plantão, que pode variar de acordo com a dificuldade escolhida.

Durante cada noite, o jogador precisa manter o farol funcionando e sobreviver até o amanhecer. O turno começa em um horário determinado, como 20h, e termina às 6h da manhã. Para concluir a partida, o jogador deve sobreviver ao número de noites correspondente à dificuldade selecionada, independentemente das condições em que o farol se encontra ao final do período.

O jogador não pode deixar o farol. Sua sobrevivência depende da administração dos sistemas presentes em seus dois andares, incluindo a iluminação do farol, gerador de energia, combustível, rádio, câmeras de segurança, alçapão e seus mecanismos de proteção, além de sua lanterna pessoal.

Os recursos consumíveis são limitados, principalmente o combustível utilizado pelo gerador e a bateria da lanterna. Problemas nos sistemas do farol exigem que o jogador se desloque fisicamente pelo ambiente para realizar manutenção, reabastecimento ou reparos, criando situações em que é necessário escolher entre diferentes tarefas enquanto o tempo continua avançando.

A luz do farol é o principal mecanismo de proteção. Quando há nevoeiro e um barco permitido se aproxima, o feixe do farol precisa estar ligado para o barco passar em segurança. Cada barco que afunda aumenta a ameaça dos Afogados, que passam a ir e voltar até o fim do plantão. Quando a iluminação é interrompida, o jogador precisa restaurar o funcionamento do sistema antes que isso aconteça.

Ao longo das noites, fenômenos e entidades sobrenaturais podem surgir de acordo com diferentes condições e eventos probabilísticos. Esses acontecimentos podem ser influenciados pelas ações do jogador e pelo estado dos sistemas do farol. Entre as principais ameaças estão o Nevoeiro, o Homem de Nevoeiro e os Afogados. Também existem navios piratas fantasmas, que se passam por barcos comuns no rádio (no MVP, sem ataque; ver 1.2.23).

O jogador deverá interpretar as informações disponíveis, administrar os recursos e decidir quando manter ou interromper determinados sistemas do farol. Manter o feixe ligado protege os barcos, mas gasta combustível do gerador; desligá-lo economiza combustível, mas deixa os barcos expostos. Essas decisões criam situações de risco nas quais diferentes ameaças podem ocorrer simultaneamente ou como consequência das ações do jogador.

Um relógio digital fixo na parede do farol funciona como referência temporal para o jogador, permitindo acompanhar o avanço da noite e estimar quanto tempo falta para o término do turno. O tempo do jogo é acelerado em relação ao tempo real: **1 hora do jogo = 1 minuto e 30 segundos reais**, ou seja, uma noite completa (20h às 6h) dura **15 minutos reais**.

### Objetivo

O objetivo principal do jogador é sobreviver durante todas as noites do período contratado até a chegada da troca de plantão.

### Condição de Vitória

O jogador vence ao sobreviver durante todo o número de noites determinado pela dificuldade escolhida.

### Condição de Derrota

O jogador perde em apenas dois casos (ver 1.2.15):

- Ser morto por um **Afogado**.
- **Cair de grande altura** (por exemplo, da escada em caracol).

### Estrutura Básica

- **Easy:** período de sobrevivência mais curto e menor frequência/intensidade de eventos e ameaças.
- **Medium:** período de sobrevivência intermediário e maior ocorrência de eventos.
- **Hard:** período de sobrevivência mais longo e maior frequência e combinação de eventos.

As ameaças são as mesmas em todas as dificuldades; o que muda são os valores parametrizados (ver 1.2.14).
A experiência central do jogo consiste em **gerenciar o farol enquanto se administra o risco de permanecer vivo dentro dele**.

## ⇒ 1.2  Game Overview (Visão Geral do jogo)

Adicione seu texto aqui

# 1.2 Game Overview — Visão Geral do Jogo

## 1.2.1 Estrutura da Partida

O jogador assume o papel de um funcionário contratado para trabalhar como faroleiro em uma ilha isolada. Seu objetivo é cumprir integralmente o período de plantão, permanecendo vivo até a chegada da troca de turno.

A duração da partida é determinada pela dificuldade escolhida antes do início do jogo:

- **Easy:** 3 noites.
- **Medium:** 5 noites.
- **Hard:** 7 noites.
A duração do plantão não é uma escolha independente do jogador. Cada nível de dificuldade possui uma quantidade de noites predefinida.

Cada noite possui um período de funcionamento definido pelo jogo. Inicialmente, o período estabelecido é das **20h às 6h**. Ao chegar às 6h, a noite é encerrada e, caso ainda existam noites restantes no contrato, uma nova noite começa posteriormente.

O jogador permanece dentro do farol durante todo o período da partida e não possui acesso à área externa da ilha.

A partida é concluída quando o jogador sobrevive ao número total de noites correspondente à dificuldade escolhida. O estado do farol no momento do encerramento não interfere na vitória.

### Início do plantão

Na primeira noite, o farol começa com **tudo funcionando** e o **feixe desligado**.

### Passagem entre noites

- Às **06:00 a noite simplesmente termina**, mesmo que haja algo em andamento (Afogado batendo no alçapão, barco passando etc.).
- **Tudo é mantido** para a noite seguinte: combustível do gerador e da reserva, bateria da lanterna, danos não consertados, pontos de afogado e nível de ameaça, estado do alçapão e posição dos objetos.

---

## 1.2.2 Estrutura de uma Noite

Cada noite possui um ritmo livre, sem uma sequência fixa de acontecimentos.

O jogador inicia a noite com os sistemas do farol em determinado estado e precisa administrar suas condições enquanto o tempo avança. Eventos, falhas e ameaças podem ocorrer durante diferentes períodos da noite, seguindo condições e possibilidades previamente estabelecidas pelo sistema de eventos.

Não existe uma sequência obrigatória de eventos como:

> Evento A → Evento B → Evento C → Final da noite.

Em vez disso, diferentes acontecimentos podem ocorrer de maneira independente ou interligada.

Uma noite pode, portanto, apresentar uma combinação diferente de situações dependendo das ações realizadas pelo jogador, do estado dos sistemas do farol e dos eventos que forem ativados.

O objetivo desse modelo é fazer com que cada noite seja uma situação de gerenciamento e tomada de decisão em tempo real, em vez de uma sequência previsível de acontecimentos.

---

## 1.2.3 Core Gameplay Loop

O ciclo principal de gameplay consiste em:

**Monitorar → Identificar → Priorizar → Agir → Lidar com consequências → Monitorar novamente**

Durante a noite, o jogador deverá:

1. **Monitorar**
  - Observar o estado dos sistemas do farol.
  - Acompanhar as câmeras de segurança pelos monitores fixos.
  - Escutar e utilizar o rádio.
  - Consultar o relógio digital de parede para acompanhar o avanço da noite.
1. **Identificar**
  - Detectar falhas nos sistemas.
  - Identificar alterações no ambiente.
  - Reconhecer possíveis ameaças.
  - Interpretar informações recebidas pelo rádio e pelas câmeras.
1. **Priorizar**
  - Determinar qual problema deve ser resolvido primeiro.
  - Avaliar quais situações podem esperar e quais representam risco imediato.
  - Considerar as possíveis consequências de ignorar determinado problema.
1. **Agir**
  - Realizar reparos.
  - Reabastecer o gerador.
  - Administrar os sistemas do farol.
  - Utilizar a lanterna.
  - Manipular a iluminação.
  - Operar o rádio.
  - Consertar a porta e segurar o trinco do alçapão.
1. **Lidar com consequências**
  - As ações do jogador podem resolver determinados problemas enquanto criam ou permitem outros.
  - Falhas não resolvidas podem aumentar o risco de ocorrência de eventos.
  - Determinadas condições podem desencadear novas ameaças.
1. **Retornar ao monitoramento**
  - Após realizar uma ação, o jogador precisa voltar a acompanhar o estado do farol e do ambiente.
Esse ciclo continua até que o jogador sobreviva ao restante da noite ou seja morto.

---

## 1.2.4 Gerenciamento do Farol

O farol é o principal ambiente de gameplay e está dividido em dois níveis.

### Térreo

O térreo concentra os principais sistemas relacionados à geração e abastecimento de energia:

- Porta de entrada do farol.
- Casa de máquinas: o cômodo onde fica o gerador de energia.
- Tanque de reserva de combustível, com medidor de nível e mangueira para encher o galão.
- Galão, guardado no seu ponto de devolução, ao lado do tanque de reserva.
O jogador precisa acessar essa área para realizar determinadas tarefas de manutenção e abastecimento.

O térreo **não tem iluminação**: é muito escuro, e o jogador precisa da lanterna para andar nele.

Fluxo do combustível: **tanque de reserva → galão → gerador**. Quando o gerador fica com pouco combustível, o jogador desce até o térreo, pega o galão, enche o galão na reserva e despeja no gerador (ver 1.2.5).

### Escada em caracol

O térreo e a torre superior são ligados por uma escada em caracol (detalhes em 1.2.20). O alçapão fica no topo dessa escada, na entrada da torre superior, e só é operado pelo lado de cima.

### Torre superior

A parte superior do farol concentra os principais sistemas de operação e monitoramento. É o único andar com iluminação, que depende do gerador:

- Lâmpada do farol.
- Sistema de controle da iluminação.
- Rádio.
- Monitores fixos das câmeras de segurança.
- Alçapão (no topo da escada em caracol).
- Trinco do alçapão.
- Relógio digital de parede.
- Mesa com a agenda (menu do jogo; ver 1.2.22).
"Área de gerenciamento e operação" é apenas o nome do conjunto dos itens acima, não um local ou sistema à parte.

A divisão física dos sistemas faz com que o jogador precise se deslocar pelo ambiente para realizar suas tarefas.

O gerenciamento não acontece exclusivamente através de menus ou interfaces abstratas. O jogador precisa estar fisicamente próximo de determinados sistemas para operá-los.

---

## 1.2.5 Recursos

Os recursos consumíveis do jogo são limitados e possuem funções distintas.

### Combustível

O combustível é utilizado pelo gerador responsável por fornecer energia aos sistemas do farol.

- O gerador tem seu próprio nível de combustível, mostrado num **medidor no gerador**, que diminui enquanto ele funciona. Manter o feixe do farol ligado aumenta o consumo.
- O **tanque de reserva** no térreo é **limitado** para todo o plantão e tem um **medidor de nível** visível.
- Se a reserva acabar, não há mais como reabastecer o gerador.
- Se a mangueira da reserva romper, a reserva vaza aos poucos e não é possível encher o galão até ela ser consertada (ver 1.2.25).

**Reabastecimento**

1. Pegar o galão no ponto de devolução (mão direita).
2. **Encher o galão** na mangueira da reserva: interação de duração (segurar E). O galão comporta uma quantidade fixa de combustível por vez, retirada da reserva.
3. **Despejar no gerador**: interação de duração (segurar E). O medidor do gerador sobe na quantidade que o galão carrega.
4. Devolver o galão ao ponto de devolução.

A capacidade do galão e quanto ele enche o gerador são valores parametrizados (ver 12.1).

Esse processo exige deslocamento pelo farol e consome tempo durante a noite, criando uma oportunidade para que outros eventos ocorram enquanto o jogador está ocupado.

**O que o gerador alimenta.** Sem combustível, ou com o gerador quebrado, param de funcionar:

- A lâmpada do farol (o feixe apaga e o farol para de girar).
- O relógio digital de parede.
- A iluminação do andar superior.

Quando o gerador volta a funcionar, esses elementos voltam junto. **Os monitores das câmeras e o rádio não dependem do gerador**: continuam funcionando sempre.

### Bateria da Lanterna

A lanterna pessoal acompanha o jogador durante toda a partida e possui uma bateria limitada. A bateria só é gasta enquanto a lanterna está ligada e não pode ser recarregada nem substituída.

Sua utilização deve ser administrada pelo jogador, principalmente durante situações em que a iluminação do farol ou outras fontes de luz não estejam disponíveis. Regras completas em 1.2.19.

### Lâmpada do farol (não é recurso)

A lâmpada do farol pode queimar, mas não é um recurso consumível: a troca não depende de estoque. Ver 1.2.18.

---

## 1.2.6 Sistemas do Farol

Os elementos do farol não são tratados exclusivamente como recursos consumíveis. Cada sistema possui sua própria lógica e pode apresentar diferentes condições de funcionamento.

Entre os principais sistemas estão:

- Gerador (1.2.5, 1.2.25).
- Tanque de reserva de combustível e galão (1.2.5, 1.2.24).
- Lâmpada do farol (1.2.18).
- Sistema de controle da iluminação (1.2.7).
- Rádio (1.2.26).
- Câmeras de segurança (1.2.17).
- Porta de entrada (1.2.11).
- Alçapão e trinco (1.2.11).
- Lanterna pessoal (1.2.19).

---

## 1.2.7 Luz do Farol

A luz do farol possui uma função essencial tanto para o funcionamento do farol quanto para a sobrevivência do jogador.

- O jogador **liga e desliga o feixe** no sistema de controle da iluminação.
- Com o feixe ligado, a lâmpada acende e o farol gira, consumindo mais combustível do gerador.
- O feixe só funciona se o gerador estiver funcionando e a lâmpada não estiver queimada.

### Quando ligar e quando desligar (MVP)

- **Desligar:** para não gastar combustível à toa quando não há barco precisando.
- **Ligar:** quando um **barco permitido** se aproxima **e existe nevoeiro**. Para saber se o barco é permitido ou pirata, o jogador precisa **atender o rádio** antes. Detalhes em 1.2.26.

Esse é o conflito central da iluminação no MVP:

- **Economizar combustível ou proteger os barcos.** Um barco desprotegido pode afundar e aumentar a ameaça dos Afogados até o fim do plantão.
- **Ligar rápido ou confirmar antes.** Ligar o feixe sem atender o rádio pode guiar um navio pirata até o farol.

---

## 1.2.8 Sistema de Eventos

Os eventos do jogo são baseados em uma combinação de tempo, condições e ações do jogador.

Os acontecimentos podem possuir **janelas de ocorrência**, em vez de horários exatos.

Por exemplo:

> Uma entidade pode possuir uma janela entre determinado horário de uma noite e outro horário posterior durante o qual existe uma possibilidade de ocorrência.

Isso significa que o jogador não necessariamente saberá quando um evento irá acontecer, mesmo que saiba que ele pode acontecer naquele período.

Os eventos podem ser classificados em três grupos principais:

### Eventos temporais

Eventos que podem ocorrer dentro de determinadas janelas de tempo.

### Eventos condicionais

Eventos cuja ocorrência depende do estado de algum sistema ou de uma condição específica.

### Eventos correlacionados

Eventos cuja ocorrência é influenciada por acontecimentos anteriores ou pelas ações do jogador.

Um evento pode, inclusive, alterar as condições necessárias para outro evento.

---

## 1.2.9 Eventos Entrelaçados

Um dos principais elementos do gameplay é a possibilidade de acontecimentos se influenciarem.

Um evento não precisa simplesmente começar e terminar de maneira isolada. Ele pode criar condições para que outro acontecimento seja ativado.

Exemplo conceitual:

**Lâmpada queima → jogador demora para trocar → barco passa no nevoeiro sem luz → barco afunda → nível de ameaça sobe → Afogado quebra a porta e danifica o gerador → o farol apaga de novo.**

Outro exemplo:

**Problema no combustível → jogador precisa descer até o térreo → jogador deixa o andar superior sem supervisão → outro evento pode ocorrer durante sua ausência.**

Dessa forma, as ações do jogador não servem apenas para resolver problemas. Elas também podem alterar o conjunto de situações possíveis naquele momento.

O objetivo desse sistema é criar **decisões em tempo real**, nas quais o jogador precisa avaliar não apenas o problema atual, mas também as possíveis consequências de dedicar tempo a determinada tarefa.

A estrutura exata das dependências e probabilidades será definida posteriormente.

---

## 1.2.10 Sistema de Ameaças

As ameaças sobrenaturais são parte integrante do gerenciamento do farol.

As principais entidades inicialmente planejadas são:

### Nevoeiro

O Nevoeiro é uma ameaça ambiental.

- **Surge aleatoriamente**, de vez em quando, durante a noite.
- Tem **intensidade variável**: pode ficar mais forte ou mais fraco enquanto está presente.
- É visível nos **monitores das câmeras**.
- **Quanto mais forte**, mais espaço cobre e **mais rápido um barco afunda** se o feixe do farol estiver desligado.
- **Quanto mais fraco**, **mais tempo** o jogador tem para ligar o feixe antes que o barco afunde.
- Quando fica **muito forte**, a ponto de cobrir até a imagem da **câmera do farol** (a que mostra a entrada), surge o **Homem de Nevoeiro**.

### Homem de Nevoeiro

O Homem de Nevoeiro é uma manifestação física do Nevoeiro, assumindo a forma de uma silhueta humana.

- Surge quando o nevoeiro está tão forte que cobre a câmera do farol.
- **Entra no farol pela porta**, que não o bloqueia, e vai até o jogador.
- O jogador o **dissipa apontando a lanterna** para ele.
- Se ele tocar o jogador, o jogador fica **cego por alguns segundos** (a tela fica preta). O contato não mata.
- Ele **some** em dois casos: ao ser dissipado pela lanterna ou depois de cegar o jogador.

### Afogados

Os Afogados são a principal ameaça física e a única entidade que pode matar o jogador.

**Origem e pontos de afogado**

- Quando o jogador demora demais para ligar o feixe para um barco no nevoeiro, o barco **afunda** (ver 1.2.26).
- Cada barco afundado soma **1 ponto de afogado**. O primeiro barco afundado faz os Afogados começarem a aparecer.
- A partir daí, os Afogados **vão e voltam**: aparecem, agem, vão embora e voltam a aparecer até o fim do plantão.

**Nível de ameaça**

O **nível de ameaça** é um valor geral que controla o quanto os Afogados são perigosos:

- **Sobe** com cada ponto de afogado (cada barco afundado).
- **Sobe** enquanto a **porta do farol estiver quebrada**, e volta a cair quando a porta é consertada.

Quanto maior o nível de ameaça:

- Maior a chance de os Afogados aparecerem.
- Maior a chance de fazerem ações mais graves (ver tabela abaixo).
- Maior a chance de aparecerem **vários Afogados ao mesmo tempo**.

**Ações dos Afogados, da mais leve à mais grave**

| Nível da ação | Ação |
|---|---|
| 1 | **Quebrar a porta** (se ainda não estiver quebrada). |
| 2 | **Danificar a mangueira da reserva** (ver 1.2.25). |
| 3 | **Danificar o gerador**. |
| 4 | **Bater no alçapão**, tentando entrar no andar superior. |

**Regras de comportamento**

- Com a porta **inteira**, o Afogado **sempre precisa quebrá-la (nível 1) antes de entrar**. Por isso, quando a porta está quebrada, o jogador costuma consertá-la antes de fazer o resto da manutenção no térreo.
- Quando um Afogado aparece, ele sabota o farol e tenta matar o faroleiro.
- **Se o jogador estiver ao alcance, o alvo é sempre o jogador.** Se o Afogado alcançar o jogador, o jogador morre.
- **Alcance** é uma **distância**, como na vida real: objetos entre o Afogado e o jogador (chão, paredes, portas etc.) bloqueiam parcialmente a percepção. Não é simplesmente "estar no mesmo andar".
- Os níveis 2 e 3 só acontecem quando o jogador **não está ao alcance** e o nível de ameaça **não é alto o bastante** para o Afogado ir atrás dele pelo alçapão.
- Com o nível de ameaça alto o bastante, o Afogado sobe a escada atrás do jogador (nível 4).
- **Se o jogador se esconder atrás do alçapão durante uma ação de nível 1, 2 ou 3, a ação não sobe para o nível 4**: o Afogado continua fazendo o que estava fazendo.
- Os Afogados são **mais lentos que o jogador**.
- Os **passos** dos Afogados podem ser ouvidos **por proximidade** (não em qualquer lugar do farol).
- No MVP, os Afogados **não percebem** o barulho do jogador nem a luz da lanterna; só a distância conta.

A IA dos Afogados será refinada depois do MVP.

### Navios Piratas Fantasmas

> **No MVP, os navios piratas existem, mas o ataque deles não é implementado** (ver 1.2.23).

- Um navio pirata chega como qualquer barco: aparece no monitor do mar e chama pelo rádio (ver 1.2.26).
- A mensagem do rádio indica se o barco é **permitido** ou **pirata**. O jogador só tem essa informação se **atender o rádio**.
- Se o jogador **ligar o feixe para um navio pirata**, o pirata **encontra o farol e ataca**.
- Se o feixe ficar **desligado**, o navio pirata simplesmente **vai embora**, mesmo com nevoeiro: ele não afunda e não soma ponto de afogado.
- No MVP, o ataque fica de fora: o pirata pode existir e ser identificado pelo rádio, mas encontrar o farol não tem consequência ainda.

Para versões posteriores: os navios piratas podem desencadear situações de invasão ao farol. A frequência e disponibilidade dessa ameaça serão definidas pelo balanceamento de dificuldade.

---

## 1.2.11 Proteções do Farol

O jogador possui mecanismos físicos de proteção dentro do farol.

O principal deles é o alçapão localizado na área superior, no topo da escada em caracol que sobe do térreo.

### Alçapão e trinco

- O jogador **abre e fecha o alçapão** por interação, **só pelo lado de cima**. Para descer ao térreo, ele precisa deixá-lo aberto, e não é possível fechá-lo por baixo.
- Se o alçapão estiver **aberto** quando um Afogado sobe a escada, o Afogado alcança o jogador e o mata.
- Quando o alçapão está **fechado**, o Afogado bate nele tentando entrar (ação de nível 4; ver 1.2.10).
- O alçapão tem uma **resistência**: um tempo total de batidas que ele aguenta antes de quebrar.
  - Enquanto o Afogado bate e o jogador **não** segura o trinco, esse tempo **corre**.
  - Enquanto o jogador **segura o trinco** (mantém a hotkey pressionada), o tempo fica **congelado**.
  - **Soltar o trinco não zera o tempo**: ele volta a correr de onde parou.
  - Se o tempo acabar, o **alçapão quebra**.
  - Quando o Afogado **vai embora**, a resistência **volta ao máximo**.
- **Alçapão quebrado é praticamente fim de jogo**: o Afogado entra no andar superior e vai até o jogador.
- O alçapão **não bloqueia o Homem de Nevoeiro**, que só é contido pela lanterna (ver 1.2.10).

### Porta de entrada

- A porta do térreo é a **primeira barreira** contra os Afogados: com ela inteira, o Afogado precisa quebrá-la antes de entrar (ação de nível 1).
- Enquanto está **quebrada**, a porta **aumenta o nível de ameaça**; ao ser consertada, esse aumento é removido (ver 1.2.10).
- A porta é consertada como as outras falhas, segurando a hotkey (ver 1.2.25).
- A porta não bloqueia o Homem de Nevoeiro.

Isso impede que o jogador simplesmente permaneça em uma posição segura durante toda a partida: descer para reabastecer ou consertar exige deixar o alçapão aberto.

---

## 1.2.12 Tomada de Decisão e Gerenciamento de Risco

O jogo é construído em torno de decisões que envolvem risco e custo de oportunidade.

O jogador frequentemente precisará escolher entre tarefas que não podem ser executadas simultaneamente.

Por exemplo:

- Abastecer o gerador ou monitorar as câmeras.
- Reparar a iluminação ou investigar uma comunicação no rádio.
- Verificar o alçapão ou permanecer acompanhando uma ameaça.
- Manter o feixe ligado por segurança ou desligá-lo para economizar combustível.
- Descer para reabastecer (deixando o alçapão aberto) ou esperar com ele fechado.
As consequências dessas escolhas podem gerar novos eventos ou aumentar a possibilidade de acontecimentos futuros.

Dessa forma, o jogador não possui controle absoluto sobre a sequência dos acontecimentos. Ele controla principalmente **como reage às situações que surgem**.

---

## 1.2.13 Progressão de Ameaça

A ameaça aumenta progressivamente ao longo das noites e varia de acordo com a dificuldade escolhida.

No MVP, essa progressão é feita **só por valores parametrizados**; todas as ameaças existem desde o início. A lógica geral é:

- Maior quantidade de situações simultâneas.
- Maior frequência de eventos.
- Maior possibilidade de eventos correlacionados.
- Redução da margem de erro.
- Maior necessidade de priorização.
Os valores exatos, probabilidades, intervalos e condições de ativação serão definidos durante o balanceamento e refinados depois do MVP.

---

## 1.2.14 Dificuldade

A dificuldade determina tanto a duração do contrato quanto a intensidade geral da experiência.

As dificuldades são **desbloqueadas em sequência**: no início só Easy está disponível; Medium é liberada ao **vencer** Easy, e Hard ao **vencer** Medium. O desbloqueio é um progresso permanente, guardado separado do save da partida: morrer ou apagar o save não o desfaz.

### Easy — 3 noites

Inclui o tutorial em toda partida (ver 9.1). Focado em apresentar os sistemas fundamentais do jogo e permitir que o jogador aprenda a rotina do farol com menor pressão.

Possui menor frequência e complexidade de eventos.

### Medium — 5 noites

Aumenta a duração do contrato e a exposição do jogador aos eventos sobrenaturais.

Apresenta maior necessidade de gerenciamento simultâneo e maior frequência de situações interligadas.

### Hard — 7 noites

Representa a maior duração de sobrevivência e a maior complexidade geral.

Tem maior duração e maior frequência e combinação de eventos.

As ameaças são as mesmas nas três dificuldades. A diferença entre elas está só nos valores parametrizados, definidos durante o balanceamento e refinados depois do MVP.

---

## 1.2.15 Condições de Vitória e Derrota

### Vitória

O jogador vence ao sobreviver durante todas as noites determinadas pela dificuldade escolhida.

- Easy: sobreviver a 3 noites.
- Medium: sobreviver a 5 noites.
- Hard: sobreviver a 7 noites.
O estado dos sistemas do farol no momento da conclusão não interfere na vitória.

### Derrota

O jogador morre em apenas dois casos:

- **Afogado:** alcança o jogador, em qualquer andar. Por exemplo: no térreo, subindo com o alçapão aberto ou depois de quebrar o alçapão (ver 1.2.10 e 1.2.11).
- **Queda de grande altura:** por exemplo, cair da escada em caracol de muito alto.

Outras consequências que **não matam**:

- **Queda de altura menor:** o jogador fica mais lento por alguns segundos e a borda da tela fica vermelha.
- **Toque do Homem de Nevoeiro:** cegueira temporária (tela preta por alguns segundos).

Ao morrer, o **plantão inteiro é perdido**: a partida recomeça da primeira noite e o save é apagado (ver 1.2.22).

Ao **vencer**, o save da partida também é apagado; o que fica é o desbloqueio da próxima dificuldade (ver 1.2.14).

---

## 1.2.16 Princípio Central da Experiência

A experiência central do jogo pode ser resumida como:

> **Manter o farol funcionando enquanto o jogador tenta descobrir o que pode esperar e o que precisa ser resolvido imediatamente.**

O jogador não está simplesmente realizando tarefas em uma ordem predeterminada.

Ele precisa constantemente avaliar o estado do farol, interpretar informações incompletas, priorizar problemas, administrar recursos e decidir quais riscos está disposto a assumir.

As ameaças e os sistemas do farol estão interligados de forma que uma decisão pode solucionar um problema enquanto cria uma nova situação de risco.

O objetivo é fazer com que cada noite seja uma sequência dinâmica de decisões, na qual o jogador precisa sobreviver às consequências de suas próprias escolhas até que o turno termine.

---

## 1.2.17 Câmeras de Segurança e Monitores

As câmeras de segurança **não são acessadas por HUD, menu ou atalho de teclado**.

- As imagens das câmeras aparecem em **monitores fixos no cenário**, na torre superior.
- Para ver o ponto de vista de uma câmera, o jogador precisa **ir até os monitores e de fato olhar para eles** em primeira pessoa.
- Enquanto olha os monitores, o jogador continua no mundo: o tempo segue correndo e o que acontece ao redor continua acontecendo.
- Deve haver um monitor separado para cada imagem capturada por câmera.

### Câmeras do MVP

São duas câmeras, cada uma com seu monitor:

- **Câmera do mar:** filma o mar. Mostra os barcos se aproximando e o nevoeiro.
- **Câmera do farol:** filma o farol de fora, num ponto de vista que inclui a **porta de entrada**. Mostra o nevoeiro e os Afogados chegando.

---

## 1.2.18 Lâmpada do Farol

A lâmpada do farol pode queimar durante a noite (ver 6.1 e 1.2.25). Queimada, o feixe não funciona, e os barcos que passarem no nevoeiro ficam desprotegidos.

- As lâmpadas de reposição são **infinitas**: não existe estoque, contagem ou limite.
- Quando a lâmpada queima, o jogador precisa ir fisicamente até a lâmpada e realizar a troca.
- A lâmpada **nunca é segurada** pelo jogador. A troca é feita indo até o farol e interagindo com ele: uma interação de duração em que o jogador mantém a hotkey pressionada (ver 1.2.21).
- O custo da falha está no **tempo e no deslocamento** gastos para trocar, e no período em que o farol fica sem luz, não na escassez de lâmpadas.

---

## 1.2.19 Lanterna Pessoal

- A lanterna tem uma **bateria limitada** para toda a partida.
- A bateria **só é gasta enquanto a lanterna está ligada**; desligada, não consome.
- A bateria **não pode ser recarregada nem substituída**. Não existem pilhas, carregadores ou pontos de recarga.
- O nível de bateria é **exibido na própria lanterna**, num display de carga no corpo do objeto, nunca na HUD. Ver seção 15.
- Para ver a bateria, o jogador aperta **X**: o personagem olha para a parte da lanterna que tem o display. Ele continua podendo andar enquanto olha.
- Liga e desliga com **Z**.
- A duração total da bateria é um parâmetro de balanceamento (ver 12.1).

### Para que serve

- **Enxergar no escuro:** o térreo não tem luz nenhuma, e o andar de cima fica escuro quando o gerador para. Fora da área iluminada, a lanterna é a única fonte de luz.
- **Dissipar o Homem de Nevoeiro:** apontar a lanterna para ele o dissipa (ver 1.2.10).

---

## 1.2.20 Escada em Caracol

- A escada que liga o primeiro andar (torre superior) ao térreo é **em caracol**, com um **vão no meio**. É por esse vão que o jogador pode cair (não existe tecla de pulo).
- O **alçapão** fica no topo da escada, separando a escada da torre superior (ver 1.2.11).
- Todo deslocamento entre os andares passa por ela, o que torna o tempo de subida e descida parte do custo de cada tarefa.
- Cair da escada de grande altura mata o jogador. Uma queda de altura menor não mata, mas deixa o jogador mais lento por alguns segundos e com a borda da tela vermelha (ver 1.2.15).

---

## 1.2.21 Informação sem HUD

O jogo **não exibe informações de estado do jogo na HUD**. Toda informação de gameplay é apresentada por objetos do próprio jogo:

- Horário → relógio digital fixo na parede.
- Câmeras → monitores fixos no cenário (1.2.17).
- Bateria da lanterna → indicador na própria lanterna (1.2.19).
- Combustível → medidor no gerador e medidor no tanque de reserva.
- Estado dos sistemas → luzes, sons e aparência dos próprios equipamentos (ver 7.1).

### Únicas exceções na tela

A HUD só mostra elementos de **interação**, nunca estado do jogo:

- **Hotkey de interação:** ao mirar em um objeto interativo, aparece apenas a tecla de interação. É a única indicação de que o objeto é interativo.
- **Barra de progresso:** interações que levam tempo (por exemplo, consertar algo) mostram uma barrinha de progresso enquanto são executadas.
- **Instruções do tutorial:** apenas durante o tutorial (ver 9.1).

Efeitos de tela causados por eventos (tela preta da cegueira, borda vermelha da queda) não são HUD: são consequências que o jogador sente.

### Interações de duração

- Interações que levam tempo, como consertos, exigem que o jogador **mantenha a hotkey de interação pressionada** até a barra de progresso completar.
- Soltar a tecla interrompe a interação e **zera o progresso**: é preciso recomeçar do zero. Isso é intencional, para aumentar a tensão.

Detalhes em 15.1 e 15.3.

---

## 1.2.22 Agenda (menu sem pausa)

O jogo **não pausa**. O menu durante a partida é uma **agenda física** que fica sobre uma mesa na **torre superior**.

- O jogador abre a agenda interagindo com ela no cenário.
- Ao interagir, a câmera "olha" para a agenda aberta sobre a mesa, que fica centralizada na tela.
- A agenda tem **várias páginas**, e as opções escritas nelas são **clicáveis**.
- **O tempo continua correndo** enquanto a agenda está aberta; o jogador continua vulnerável a tudo o que acontece no farol.
- Opções da agenda:
  - Configurações (som, entre outras).
  - Salvar e sair.
  - Sair sem salvar.
- Não existe tela ou menu de pausa tradicional.

### Salvamento

- **Salvar** guarda o **estado exato da partida no meio da noite**: horário, estado de todos os sistemas, recursos, ameaças em andamento e posição do jogador.
- **Continuar**, no Menu Principal, restaura a partida exatamente nesse ponto.
- **Não existe salvamento automático**, nem entre as noites. O jogo só salva quando o jogador escolhe "Salvar e sair" na agenda.
- Existe **um único save** de partida.
- Ao **morrer**, o save é **apagado** e o plantão inteiro é perdido (ver 1.2.15).
- Ao **vencer** o plantão, o save também é apagado.
- **Sair sem salvar** também **perde tudo**: o save da partida é apagado, inclusive um save feito antes. Isso impede salvar, arriscar e sair sem salvar se der errado.
- **Novo Jogo sobrescreve** o save existente.
- O **desbloqueio de dificuldades** fica guardado à parte e não é afetado por nada disso (ver 1.2.14).

---

## 1.2.23 Escopo do MVP

### Dentro do MVP

- **Ameaças:** Nevoeiro, Homem de Nevoeiro e Afogados (com nível de ameaça).
- **Navios piratas:** existem e são identificados pelo rádio, mas **sem ataque**.
- **Dificuldades:** as três (Easy, Medium, Hard), desbloqueadas em sequência (ver 1.2.14).
- **Tutorial** em toda partida no Easy (ver 9.1).
- **Falhas:** lâmpada queimada, mangueira rompida e gerador quebrado, além dos danos dos Afogados (ver 1.2.25).
- **Barcos e rádio** em versão simplificada (ver 1.2.26).
- **Agenda** com configurações de som, salvar e sair, e sair sem salvar.

### Fora do MVP

- **Ataque dos navios piratas** ao farol. Os navios piratas em si existem no MVP.
- **IA refinada dos Afogados:** o MVP usa as regras básicas da 1.2.10.

### Em aberto

Tudo o que foi deixado para depois está listado em [decisoes-futuras.md](decisoes-futuras.md).

---

## 1.2.24 Objetos Seguráveis

Só dois objetos podem ser segurados e usados pelo jogador:

- **Lanterna:** sempre na **mão esquerda**. Acompanha o jogador durante toda a partida (ver 1.2.19).
- **Galão de combustível:** na **mão direita**, quando o jogador o pega. Fica guardado ao lado do tanque de combustível, no térreo (ver 1.2.4).

Como cada objeto tem sua própria mão, o jogador pode carregar o galão e usar a lanterna ao mesmo tempo.

- O galão **não pode ser largado** em qualquer lugar. Ele tem um **ponto de devolução** ao lado do tanque de reserva, onde fica guardado; para soltá-lo, o jogador interage com esse ponto (**E**).
- **Com o galão na mão, o jogador não pode:**
  - consertar nada;
  - abrir ou fechar o alçapão;
  - segurar o trinco.
- Para fazer qualquer uma dessas ações, ele precisa antes devolver o galão.

Todo o resto, incluindo a lâmpada do farol, é operado por interação no local e nunca é segurado (ver 1.2.18).

---

## 1.2.25 Falhas do MVP

Todas as falhas são consertadas **segurando a hotkey de interação** no próprio objeto até a barra de progresso completar (ver 1.2.21).

| Falha | Consequência | Conserto |
|---|---|---|
| **Lâmpada queima** | O feixe do farol não funciona; barcos no nevoeiro ficam desprotegidos. | Trocar a lâmpada (torre superior). |
| **Mangueira da reserva rompe** | A reserva **perde combustível aos poucos** e não é possível encher o galão. | Consertar a mangueira (térreo). |
| **Gerador quebra** | Tudo o que o gerador alimenta para de funcionar (ver 1.2.5). | Consertar o gerador (térreo). |

### Danos causados pelos Afogados (ver 1.2.10)

| Dano | Consequência | Conserto |
|---|---|---|
| **Porta quebrada** (nível 1) | Aumenta o nível de ameaça enquanto estiver quebrada. | Consertar a porta (térreo). |
| **Mangueira/tanque de reserva danificado** (nível 2) | Igual à mangueira rompida: a reserva **perde combustível aos poucos**, mesmo sem uso, e não é possível encher o galão. | Consertar a mangueira (térreo). |
| **Gerador danificado** (nível 3) | Igual ao gerador quebrado. | Consertar o gerador (térreo). |
| **Alçapão quebrado** (após o nível 4) | O Afogado entra no andar superior; praticamente fim de jogo (ver 1.2.11). | — |

**Feedback das falhas:** sons e efeitos visuais provisórios (placeholders), a refinar depois. Ver também 7.1.

---

## 1.2.26 Barcos e Rádio (MVP, provisório)

> Regras provisórias para o MVP. Serão refinadas depois.

1. Em momentos aleatórios da noite, um **barco se aproxima**: ele aparece no **monitor do mar** e o **rádio toca**.
2. O jogador pode **atender o rádio** (interação simples na torre superior). A mensagem indica se o barco é **permitido** ou **pirata**. Sem atender, o jogador não tem essa informação. No MVP, a mensagem é **só som** (sem legenda).
3. O barco leva um tempo para passar pela ilha (parâmetro de balanceamento).
4. **Barco permitido** durante a passagem:
   - **Sem nevoeiro:** passa em segurança, com ou sem o feixe.
   - **Com nevoeiro:** precisa do feixe **ligado até terminar de passar**.
   - **Contagem até afundar:** começa **quando o rádio toca** e corre enquanto o feixe estiver desligado (por escolha, lâmpada queimada ou gerador parado). Com o feixe ligado, a contagem para; se o feixe for desligado antes de o barco passar, ela volta a correr.
   - Se a contagem chegar ao fim, o barco **afunda**.
   - A duração da contagem depende da **intensidade do nevoeiro**: quanto mais forte, mais curta (ver 1.2.10).
5. **Navio pirata:** se o jogador **ligar o feixe** para ele, o pirata encontra o farol e ataca. No MVP, o ataque não é implementado (ver 1.2.10). Com o feixe desligado, o pirata simplesmente vai embora, sem afundar.
6. Cada barco afundado soma **1 ponto de afogado** e aumenta o nível de ameaça (ver 1.2.10).

## ⇒ 1.3  Título do jogo

The Beacon

## ⇒ 1.4  O que faz dele único?

Adicione seu texto aqui

O jogo resgata a tensão e a nostalgia de jogos como **Five Nights at Freddy's**, colocando essa fórmula em um novo ambiente e com sistemas de gerenciamento mais dinâmicos.

Preso dentro de um farol, o jogador precisa monitorar, administrar e reagir aos acontecimentos enquanto tenta sobreviver até o fim do seu plantão. Os eventos não seguem uma sequência simples e previsível: diferentes situações podem acontecer, se combinar e até ser desencadeadas pelas próprias decisões do jogador.

O diferencial está em **nunca ter certeza absoluta do que acontecerá em seguida**, obrigando o jogador a tomar decisões em tempo real, assumir riscos e torcer para conseguir chegar vivo ao final da noite.

## ⇒ 1.5  Principais Gameplay Features (Recursos de Jogabilidade)

Adicione seu texto aqui

- **Sobrevivência em um ambiente confinado:** todo o jogo acontece dentro de um farol, dividido entre a área de operação superior e a casa de máquinas no térreo.
- **Gerenciamento do farol:** mantenha gerador, iluminação, combustível e demais sistemas essenciais funcionando durante toda a noite.
- **Recursos limitados:** administre o combustível do gerador e a bateria não recarregável da lanterna, decidindo quando e como utilizá-los.
- **Monitoramento por câmeras:** pelos monitores fixos da torre, observe o ambiente externo e acompanhe a atividade no mar para identificar possíveis ameaças.
- **Comunicação por rádio:** atenda os chamados das embarcações para descobrir se são barcos permitidos ou navios piratas.
- **Eventos dinâmicos e imprevisíveis:** acontecimentos possuem janelas de possibilidade e podem ocorrer ou não dependendo do estado do jogo e das ações do jogador.
- **Eventos entrelaçados:** determinadas ações ou falhas podem desencadear novos acontecimentos, criando sequências de problemas e situações inesperadas.
- **Tomada de decisões em tempo real:** priorize problemas e escolha quais riscos assumir enquanto diferentes situações podem acontecer simultaneamente.
- **Entidades sobrenaturais:** enfrente ameaças como o Nevoeiro, o Homem de Nevoeiro e os Afogados, cada uma com comportamentos e formas diferentes de ameaçar o jogador.
- **Defesas físicas:** utilize e mantenha mecanismos como o alçapão e seu trinco para impedir que determinadas ameaças alcancem o jogador.
- **Controle da iluminação:** ligue o feixe do farol para guiar os barcos permitidos no nevoeiro e desligue-o para economizar combustível.
- **Manutenção física:** realize tarefas manualmente pelo ambiente, como transportar combustível entre o tanque e o gerador, em vez de resolver todas as necessidades através de menus.
- **Progressão de dificuldade:** sobreviva a 3, 5 ou 7 noites dependendo da dificuldade, com aumento gradual da frequência e combinação dos eventos.
- **Sobrevivência até o fim do plantão:** não é necessário restaurar ou manter o farol em perfeitas condições para vencer; o objetivo final é permanecer vivo até o término do contrato.

# 2. Público-alvo e Plataformas

---

## ⇒ 2.1  Público alvo

Adicione seu texto aqui

- **Idade:** 16–35 anos.
- **Gênero:** Todos os gêneros.
- **Perfil:** Jogadores que gostam de survival horror, suspense, gerenciamento e experiências de tensão.
- **Interesses:** Jogos como *Five Nights at Freddy's*, terror sobrenatural, mistério, exploração de sistemas e situações imprevisíveis.
- **Comportamento:** Gostam de aprender padrões, tomar decisões sob pressão e experimentar diferentes estratégias para sobreviver.
- **Plataforma:** Principalmente PC, com possibilidade de expansão para consoles.
- **Perfil de jogador:** Casual/intermediário, mas com potencial de atrair jogadores mais dedicados interessados em dominar os sistemas e aumentar a dificuldade.

## ⇒ 2.2  Plataforma

Steam

## ⇒ 2.3  Gênero do jogo

Adicione seu texto aqui

Gerenciamento de recursos com suspense/terror

## ⇒ 2.4  Modelo de negócios

Adicione seu texto aqui

venda de chaves na steam

# 3. Produção

---

## ⇒ 3.1  Protótipo

Adicione seu texto aqui

## ⇒ 3.2  Pré-alpha

Adicione seu texto aqui

## ⇒ 3.3  Versão Alpha

Adicione seu texto aqui

## ⇒ 3.4  Versão Beta

Adicione seu texto aqui

## ⇒ 3.5  Versão Closed Beta

Adicione seu texto aqui

## ⇒ 3.6  Versão Release Candidate

Adicione seu texto aqui

## ⇒ 3.7  Versão Gold

Adicione seu texto aqui

# 4. Jogabilidade I: OCR e 3Cs

## ⇒ 4.1  Objective, Challenge e Reward - OCR

## ⇒ 4.1.1  Objective

Adicione seu texto aqui

## ⇒ 4.1.2  Challenge

Adicione seu texto aqui

## ⇒ 4.1.2  Reward

Adicione seu texto aqui

## ⇒ 4.2  Camera, Character e Control - 3 Cs

## ⇒ 4.2.1  Câmera

Adicione seu texto aqui

1º pessoa

Sem HUD de estado do jogo sobreposta à visão; apenas hotkey de interação, barra de progresso e, no tutorial, instruções (ver 1.2.21 e seção 15).

## ⇒ 4.2.2 Personagem

Adicione seu texto aqui

A definir, mas é um homem

## ⇒ 4.2.3 Controle

Adicione seu texto aqui

| Tecla | Ação |
|---|---|
| **W A S D** | Andar |
| **Mouse** | Olhar |
| **Shift** | Correr (no MVP, só movimento) |
| **Ctrl** | Agachar (no MVP, só movimento) |
| **Z** | Ligar/desligar a lanterna |
| **X** | Olhar a bateria (o personagem olha para o display de carga da lanterna) |
| **E** | Interagir (segurar em interações de duração) |

# 5. Jogabilidade II: Regras e Estrutura do Jogo

## ⇒ 5.1  Quais as principais habilidades exigidas no jogo?

Adicione seu texto aqui

Nenhuma, só tem a lanterna para ligar, desligar e um botão de interação com os objetos

## ⇒ 5.2  Que tipo de experiência você quer passar com o seu jogo?

Adicione seu texto aqui

Passar uma sensação constante de **tensão, isolamento e vulnerabilidade**, fazendo o jogador se sentir preso dentro do farol e nunca ter certeza do que acontecerá em seguida.

A experiência deve fazer o jogador **tomar decisões sob pressão, assumir riscos e torcer para conseguir sobreviver até o fim do plantão**.

## ⇒ 5.3  Quais motivações você vai apresentar para os seus jogadores?

Adicione seu texto aqui

Ainda não sabemos, mas basicamente ele é um CLT que precisa de dinheiro e se meteu em uma situação bem ruim…

# 6. Jogabilidade III: Fluxo

## ⇒ 6.1  Para garantir a variedade e ritmo do jogo, quais são as suas mecânicas auxiliares e modificadores no jogo?

Adicione seu texto aqui

- Mangueira do tanque de cobustivel rompendo no meio das noites (ver 1.2.25);
- Lampada queimando (troca sem estoque; ver 1.2.18);
- Nevoeiro atrapalhando;
- Gerador quebrando (ver 1.2.25);
- Barcos aparecendo e pedindo ajuda em momentos aleatórios (ver 1.2.26);

## ⇒ 6.2  Quais são as recompensas no jogo?

Adicione seu texto aqui

Sobreviver

## ⇒ 6.3  Quais são os seus inimigos e desafios no jogo?

Adicione seu texto aqui

- **Nevoeiro:** ameaça ambiental que surge aleatoriamente e varia de intensidade; põe os barcos em risco e, muito forte, gera o Homem de Nevoeiro.
- **Homem de Nevoeiro:** entidade que pode deixar o jogador temporariamente cego; dissipada com a lanterna.
- **Afogados:** surgem quando barcos afundam, vão e voltam até o fim do plantão, sabotam o farol e podem matar o jogador.
- **Navios Piratas Fantasmas:** se passam por barcos comuns; o rádio revela quem são. Se o feixe os guiar, encontram o farol e atacam (ataque fora do MVP).
- **Falhas do farol:** problemas no gerador, iluminação, combustível e sistemas de proteção.
- **Recursos limitados:** gerenciamento de combustível e bateria da lanterna (não recarregável).
- **Tempo:** o jogador precisa sobreviver durante toda a noite enquanto administra os problemas do farol.
- **Eventos imprevisíveis:** acontecimentos que podem surgir, se combinar e ser desencadeados pelas próprias ações do jogador.

## ⇒ 6.4  Qual o tipo de fluxo do seu jogo?

Adicione seu texto aqui

**Fluxo baseado em ciclos de sobrevivência.**

O jogador passa por ciclos de **noite → gerenciamento e sobrevivência → amanhecer → próxima noite**, com eventos dinâmicos e imprevisíveis ocorrendo durante cada ciclo.

A estrutura geral é:

**Início da noite → Monitoramento e gerenciamento → Eventos e ameaças → Tomada de decisões → Sobrevivência → Amanhecer → Próxima noite → Final do plantão**.

# 7. Jogabilidade IV: Sistema e Protótipo

## ⇒ 7.1  Faça uma lista com o mínimo de 3 Signs (sinais) e 3 Feedbacks (retornos) do seu jogo

Adicione seu texto aqui

Assim, eu entendo que boa parte deles deve ter relação diretamente com a história, já que o jogador não tem HUD. Então deveria ser sinais visuais no ambiente ou barulhos.

- Mangueira estourando faz um som e muda o modelo da mangueira ou bota uma animação dela rasgada;
- Radio faz barulho e mostra alguma luz no aparelho;
- Maquina com problema precisa piscar ou ficar acesso uma luz vermelha;

Não tem nada muito definitivo nesse momento, então pode escolher algo simples ou nem colocar por enquanto, só para termos uma base da coisa.

## ⇒ 7.2  Se você fosse criar o protótipo do seu jogo, quais as 3 mecânicas que você gostaria de validar?

Adicione seu texto aqui

1. **Gerenciamento e priorização:** validar se gerenciar o farol e decidir qual problema resolver primeiro gera tensão e decisões interessantes.
1. **Eventos imprevisíveis e entrelaçados:** validar se eventos que surgem e se influenciam de acordo com as ações do jogador criam situações inesperadas e divertidas.
1. **Tensão de sobrevivência:** validar se o ciclo de monitorar o farol, reagir às ameaças e sobreviver até o amanhecer mantém o jogador em estado constante de tensão.

# 8. Mecânicas

## ⇒ 8.1  Descreva a mecânica principal do seu jogo

Adicione seu texto aqui

A mecânica principal do jogo é o **gerenciamento do farol sob pressão**.

O jogador precisa monitorar seus sistemas, administrar recursos e responder a eventos sobrenaturais enquanto decide, em tempo real, **qual problema deve ser resolvido primeiro e quais riscos pode assumir**.

As ações do jogador podem influenciar os acontecimentos seguintes, fazendo com que uma decisão ou falha desencadeie novos problemas. O objetivo é manter-se vivo e administrar o farol até o amanhecer, repetindo esse ciclo durante todas as noites do plantão.

## ⇒ 8.2  Liste 3 regras do seu jogo

Adicione seu texto aqui

1. **O jogador nunca pode sair do farol:** toda a sobrevivência e gerenciamento acontecem dentro dos dois andares do farol.
1. **O farol deve guiar os barcos permitidos no nevoeiro:** sem o feixe, barcos afundam e aumentam a ameaça dos Afogados, que podem matar o jogador.
1. **O jogador precisa sobreviver até o final do plantão:** a vitória ocorre ao sobreviver às 3, 5 ou 7 noites determinadas pela dificuldade escolhida.

## ⇒ 8.3  Liste 3 parâmetros que você vai utilizar na sua mecânica principal

Adicione seu texto aqui

1. **Nível de combustível:** determina por quanto tempo o gerador consegue manter os sistemas do farol funcionando.
1. **Tempo restante da noite:** determina quanto falta para o amanhecer e influencia a urgência das decisões do jogador.
1. **Nível de ameaça:** controla a chance de os Afogados aparecerem, a gravidade das ações deles e a chance de aparecerem vários ao mesmo tempo. Sobe com cada barco afundado (ponto de afogado) e enquanto a porta estiver quebrada (ver 1.2.10).

# 9. Level Design I: Tutorial e Progressão

## ⇒ 9.1  Tipo de tutorial você vai utilizar

Adicione seu texto aqui

**Tutorial integrado à gameplay (Learning by Doing).**

O "tutorial" não é uma fase separada: é um **estado** do jogo em que, **na primeira vez que cada tipo de ação ou situação diferente acontece**, aparece um texto instruindo o jogador.

- Está ativo em **toda partida no Easy**, desde o início da primeira noite.
- **Não pode ser pulado.**
- O jogo **roda normalmente**, com os sorteios de eventos funcionando como em qualquer noite.
- O tutorial **termina quando o jogador tiver passado por todas as tarefas diferentes**.
- As instruções aparecem **na HUD**. É o **único momento** do jogo em que a HUD mostra texto (ver 1.2.21).

Assim, o aprendizado é gradual, sem interromper a experiência de terror com longas explicações.

## ⇒ 9.2  Power-ups (se houver)

Adicione seu texto aqui

Não teremos para o jogador

# 10. Level Design II: Níveis de Dificuldade

## ⇒ 10.1  Níveis de dificuldade que o player irá enfrentar

Adicione seu texto aqui

- **Easy:** 3 noites, menor frequência de eventos e maior margem para erros.
- **Medium:** 5 noites, maior frequência e combinação de eventos.
- **Hard:** 7 noites, maior frequência e complexidade dos eventos.

As ameaças são as mesmas nas três; muda só o valor dos parâmetros.

Desbloqueio em sequência: Medium só libera após vencer Easy, e Hard só após vencer Medium (ver 1.2.14).

## ⇒ 10.2  Níveis de habilidade que ajudara o player

Adicione seu texto aqui

Não tem

# 11. Level Design III: Comportamento dos Inimigos

## ⇒ 11.1  Liste o comportamento de todos os inimigos

Adicione seu texto aqui

- **Nevoeiro:** surge aleatoriamente e fica mais forte ou mais fraco; é visível nas câmeras. Quanto mais forte, mais espaço cobre e mais rápido um barco afunda com o feixe desligado. Quando cobre até a câmera do farol, gera o Homem de Nevoeiro.
- **Homem de Nevoeiro:** surge com o nevoeiro muito denso, entra no farol pela porta (que não o bloqueia) e vai até o jogador. É dissipado ao ser iluminado pela lanterna. Se tocar o jogador, causa **cegueira temporária** (tela preta por alguns segundos), sem matar.
- **Afogados:** começam a aparecer quando um barco afunda e vão e voltam até o fim do plantão. Agem por níveis: 1) quebrar a porta, 2) danificar a mangueira da reserva, 3) danificar o gerador, 4) bater no alçapão. Se o jogador estiver ao alcance, ele é sempre o alvo. São mais lentos que o jogador, e seus passos são ouvidos por proximidade. A chance e a gravidade das ações dependem do nível de ameaça. Detalhes em 1.2.10.
- **Navios Piratas Fantasmas:** chegam como barcos comuns e chamam pelo rádio; a mensagem revela que são piratas. Se o jogador ligar o feixe para eles, encontram o farol e atacam. No MVP, o pirata existe, mas o ataque não é implementado.

# 12. Level Design IV: Balanceamento

## ⇒ 12.1  Liste os sistemas de mecânicas que poderão receber balanceados durante o jogo

Adicione seu texto aqui

- **Duração das noites:** valor inicial de 1 min 30 s reais por hora do jogo (15 min por noite).
- **Consumo de combustível:** velocidade com que o gerador consome combustível.
- **Duração da bateria:** tempo de uso da lanterna.
- **Frequência de falhas:** frequência com que os sistemas do farol apresentam problemas.
- **Tempo de reparo:** tempo necessário para corrigir cada falha.
- **Frequência de eventos:** quantidade de eventos que podem ocorrer durante uma noite.
- **Probabilidade dos eventos:** chance de determinados eventos serem ativados.
- **Encadeamento de eventos:** condições necessárias para um evento desencadear outro.
- **Tempo de resposta:** período disponível para o jogador reagir a determinadas ameaças.
- **Nevoeiro:** frequência de aparição, variação de intensidade e relação entre intensidade e tempo até o barco afundar.
- **Frequência e comportamento das entidades:** frequência de aparição e agressividade de cada inimigo.
- **Duração da cegueira:** tempo durante o qual o Homem de Nevoeiro afeta a visão do jogador.
- **Afogados e nível de ameaça:** quanto cada ponto de afogado e a porta quebrada somam ao nível de ameaça; como o nível afeta a chance de aparição, a gravidade das ações e a chance de vários ao mesmo tempo; o limite a partir do qual eles sobem atrás do jogador; velocidade; alcance dos passos.
- **Alçapão:** resistência (tempo de batidas até quebrar).
- **Reserva danificada:** velocidade com que o combustível vaza.
- **Barcos:** frequência, tempo de passagem e proporção de navios piratas.
- **Quedas:** altura que mata, altura que só deixa lento, e duração da lentidão.
- **Consumo extra do feixe:** quanto o feixe ligado aumenta o gasto de combustível.
- **Capacidade do tanque de reserva:** combustível total disponível para o plantão.
- **Galão:** quanto combustível carrega por vez, quanto sobe o medidor do gerador e a duração de encher e de despejar.
- **Dificuldade por nível:** quantidade e complexidade dos eventos em Easy, Medium e Hard.

# 13. História e Narrativa

## ⇒ 13.1  Defina o estilo da narrativa do jogo

Adicione seu texto aqui

**Narrativa ambiental e indireta**, com foco em mistério e terror psicológico.

A história será descoberta principalmente através do **ambiente, documentos, mensagens de rádio, acontecimentos sobrenaturais e pequenas pistas**, evitando longas cenas expositivas.

O jogo deve manter o jogador em constante dúvida sobre o que é real, incentivando-o a interpretar os acontecimentos e montar a história por conta própria.

NADA DA HISTÓRIA ESTÁ DEFINIDO

## ⇒ 13.2  Em até 2 parágrafos, resuma como será a história do jogo

Adicione seu texto aqui

O jogador aceita um contrato para trabalhar como faroleiro em uma ilha isolada, responsável por manter o farol funcionando durante seu período de plantão. Ao chegar, tudo parece ser apenas mais um trabalho solitário, mas, conforme as noites passam, acontecimentos estranhos começam a surgir. O nevoeiro se torna cada vez mais presente, figuras aparecem nas proximidades e o rádio começa a transmitir mensagens que não deveriam existir.

Preso dentro do farol e sem possibilidade de deixar a ilha, o jogador precisa descobrir como lidar com as manifestações sobrenaturais enquanto mantém os sistemas funcionando. Conforme as noites avançam, fica cada vez menos claro se as falhas do farol estão atraindo as entidades ou se algo naquele lugar sempre esteve esperando por uma oportunidade para alcançá-lo. O objetivo é sobreviver até a chegada da troca de plantão e descobrir, através dos acontecimentos e pistas encontradas durante o trabalho, o que realmente está acontecendo naquela ilha.

## ⇒ 13.3 Divida a história do seu jogo em arcos, use a técnica de outline

Adicione seu texto aqui

Como a história ainda está em fase inicial, eu sugiro um outline simples, deixando espaço para desenvolver a lore posteriormente.

### Arco 1 — O Plantão

- O jogador chega à ilha para assumir seu primeiro plantão no farol.
- Aprende a rotina e os sistemas necessários para manter o farol funcionando.
- Os primeiros acontecimentos estranhos começam a surgir.
- Pequenas anomalias no rádio, nas câmeras e no ambiente indicam que existe algo errado.
- O jogador ainda acredita que os acontecimentos podem ter explicações naturais.

### Arco 2 — O Nevoeiro

- O Nevoeiro começa a aparecer com maior frequência.
- Falhas no farol passam a ter consequências mais graves.
- O jogador percebe que a luz parece manter algo afastado.
- Primeiros encontros com o Homem de Nevoeiro e os Afogados.
- Informações encontradas no farol começam a indicar que outros trabalhadores podem ter passado por situações semelhantes.

### Arco 3 — O Que Está Lá Fora

- As manifestações sobrenaturais se tornam mais frequentes e agressivas.
- O rádio começa a transmitir mensagens cada vez mais estranhas.
- O jogador percebe que algumas comunicações podem estar tentando manipulá-lo.
- As câmeras revelam acontecimentos que não podem ser explicados facilmente.
- O jogador começa a entender que manter o farol funcionando não é apenas uma obrigação de trabalho, mas uma forma de impedir que algo alcance o farol.

### Arco 4 — A Verdade

- Os acontecimentos anteriores começam a se conectar.
- O jogador descobre pistas sobre a origem das entidades e sobre o histórico do farol.
- As noites se tornam progressivamente mais perigosas.
- As ameaças passam a agir de maneira coordenada.
- O jogador precisa utilizar tudo o que aprendeu para sobreviver aos últimos plantões.

### Arco 5 — A Troca de Plantão

- O jogador chega à última noite do contrato.
- As ameaças atingem seu ponto máximo.
- Os sistemas do farol e as proteções são levados ao limite.
- O jogador precisa sobreviver até o horário da troca de plantão.
- Ao amanhecer, o período de trabalho termina, encerrando a experiência principal.
**Observação:** os detalhes sobre a origem do Nevoeiro, dos Afogados e das demais entidades ainda podem ser definidos posteriormente. O outline estabelece a **progressão narrativa e o aumento do mistério**, mas não precisa fechar a explicação da lore neste momento.

# 14. Arte e Estética

## ⇒ 14.1 Defina o estilo de arte e estética do jogo

ambiente de penumbra industrial úmido

![](img/gdd-02.png)

Limite gráfico

![](img/gdd-03.png)

![](img/gdd-04.png)

![](img/gdd-05.png)

## ⇒ 14.2 Descreva brevemente a arte do jogo usando referencias visuais

Adicione seu texto aqui

Tijolos por toda parte, já que é um farol… Poças d’agua, goteiras fazendo barulho para confundir, Som de motores funcionando, Madeira e metal por toda parte para ranger e atrapalhar. No seu escritório uma mistura de elementos modernos com itens velhos. Claramente alguém foi comprando itens novos mas não tinha direito para atualizar todo o ambiente de trabalho. Então tem coisas analógicas e digitais misturadas.

## ⇒ 14.3 Desenvolva a direção de arte do jogo

Adicione seu texto aqui

Homem fumaça

![](img/gdd-06.png)

Metal, mandeira, boteiras, ferrugem e rangidos fazem parte do cotidiano. Coisas nalticas espalhadas para ambientar, poucos itens modernos no meio de itens que devem estar lá desde a inalguração do farol.

# 15. UI/UX Interface do usuário

## ⇒ 15.1 Liste todas as telas de interface do usuário incluindo HUD

Adicione seu texto aqui

### Telas principais

- **Tela de título / Menu Principal**
  - Novo Jogo
  - Continuar
  - Configurações
  - Sair
- **Seleção de dificuldade**
  - Easy — 3 noites
  - Medium — 5 noites (bloqueada até vencer Easy)
  - Hard — 7 noites (bloqueada até vencer Medium)
- **Tela de Game Over**
  - Você MAMOU (morte)
  - Tentar novamente
  - Voltar ao menu principal
- **Tela de fim de noite** (entre uma noite e outra)
  - Noite concluída
  - Continuar para a próxima noite / Voltar ao menu
- **Tela de plantão concluído** (vitória)
  - Plantão concluído
  - Dificuldade
  - Número de noites sobrevividas
  - Voltar ao menu

- **Agenda (menu durante a partida, sem pausa)** (ver 1.2.22)
  - Configurações (som, entre outras)
  - Salvar e sair
  - Sair sem salvar

Não existe tela de pausa tradicional (ver 1.2.22).

### HUD durante a gameplay

A HUD **não mostra estado do jogo**. Ela tem apenas:

- **Hotkey de interação**, quando o jogador mira em um objeto interativo.
- **Barra de progresso**, durante interações que levam tempo (ex.: consertar).
- **Instruções do tutorial**, apenas durante o tutorial (ver 9.1).

### Interfaces diegéticas

**Todas** as informações são apresentadas **dentro do próprio ambiente do farol**, por objetos do jogo:

- **Relógio digital fixo na parede:** horário atual e quanto falta para o amanhecer.
- **Monitores fixos das câmeras de segurança:** o jogador olha para eles para ver o ponto de vista das câmeras (ver 1.2.17).
- **Indicador de bateria na própria lanterna** (ver 1.2.19).
- **Medidores de combustível** no gerador e no tanque de reserva.
- **Controles e indicadores do sistema de iluminação.**
- **Equipamentos e controles do rádio.**
- **Indicadores presentes nos próprios equipamentos:** luzes, sons e mudanças visuais que sinalizam falhas (ver 7.1).
- **Ameaças/eventos:** comunicadas por som, música de fundo e mudanças visuais no ambiente.
O objetivo é manter a interface integrada ao ambiente para preservar a **imersão e a tensão do survival horror**.

## ⇒ 15.2 Fluxo de funcionamento dos botões de todas as telas

Adicione seu texto aqui

### Menu Principal

- **Novo Jogo** → Abre a seleção de dificuldade. Sobrescreve o save existente.
- **Continuar** → Carrega a partida salva, caso exista, no estado exato em que foi salva.
- **Configurações** → Abre as opções do jogo.
- **Sair** → Fecha o jogo.

### Seleção de Dificuldade

- **Easy** → Seleciona 3 noites e inicia o jogo (com o tutorial ativo).
- **Medium** → Seleciona 5 noites e inicia o jogo. Disponível só após vencer Easy.
- **Hard** → Seleciona 7 noites e inicia o jogo. Disponível só após vencer Medium.
- **Voltar** → Retorna ao Menu Principal.

### Durante a Gameplay

- **Interagir** → Executa a ação correspondente ao objeto ou sistema selecionado. Em interações de duração (ex.: consertos), é preciso manter a tecla pressionada até a barra de progresso completar.
- **Lanterna (Z)** → Liga/desliga a lanterna.
- **Bateria (X)** → O personagem olha para o display de carga da lanterna.
- **Rádio** → Interagir com o rádio atende o chamado de um barco e revela se ele é permitido ou pirata (ver 1.2.26).
- **Alçapão** → Interagir abre ou fecha; segurar a interação segura o trinco e congela o tempo de resistência enquanto um Afogado bate (ver 1.2.11).
- **Câmeras** → Não há botão ou atalho. O jogador vai até os monitores fixos e olha para eles; cada câmera tem seu próprio monitor (ver 1.2.17).
- **Agenda** → Interagir com a agenda sobre a mesa abre o menu sem pausar o jogo (ver 1.2.22).
- **Controles do farol** → Liga/desliga o feixe do farol (ver 1.2.7).
A maior parte dessas interações será realizada diretamente no ambiente, sem menus tradicionais.

### Agenda (substitui o menu de pausa)

O tempo continua correndo enquanto a agenda está aberta (ver 1.2.22). As opções são clicáveis nas páginas da agenda:

- **Configurações** → Abre as opções do jogo (som, entre outras).
- **Salvar e sair** → Salva o estado exato da partida (no meio da noite) e volta ao Menu Principal.
- **Sair sem salvar** → Abandona a partida, apaga o save (o plantão é perdido) e volta ao Menu Principal.
- **Fechar a agenda** → A câmera volta à visão normal do jogador.

### Tela de Game Over

- **Tentar Novamente** → Reinicia o plantão inteiro, da primeira noite, na dificuldade selecionada. O save da partida já foi apagado na morte (ver 1.2.22).
- **Menu Principal** → Retorna ao Menu Principal.
- **Sair** → Fecha o jogo.

### Tela de Fim de Noite

- **Continuar** → Prossegue para a próxima noite. Não salva automaticamente (ver 1.2.22).
- **Menu Principal** → Retorna ao Menu Principal.

### Tela de Plantão Concluído

- **Menu Principal** → Retorna ao Menu Principal. O save da partida já foi apagado na vitória e a próxima dificuldade foi desbloqueada (ver 1.2.14 e 1.2.22).

### Configurações

- **Áudio** → Ajusta volume geral, música e efeitos sonoros.
- **Vídeo** → Ajusta resolução, qualidade gráfica e opções de exibição. *(Em aberto para o MVP.)*
- **Controles** → Permite visualizar e alterar os comandos. *(Em aberto para o MVP.)*
- **Sensibilidade** → Ajusta a sensibilidade de câmera/mouse.
- **Voltar** → Retorna à tela anterior.

## ⇒ 15.3 Fluxo de funcionamento dos informações da HUD que estarão diretamente ligadas a gameplay

Adicione seu texto aqui

A HUD não mostra estado do jogo, só elementos de interação e, no tutorial, instruções (ver 1.2.21). As informações abaixo são essenciais para a tomada de decisões, mas são todas exibidas por objetos do próprio jogo, para preservar a tensão e a imersão.

- **Relógio digital de parede**
  - Exibe o horário atual da noite.
  - Avança de acordo com o tempo acelerado do jogo.
  - Permite ao jogador acompanhar quanto falta para o amanhecer.
  - **20:00 → início da noite**
  - **06:00 → noite concluída.**
- **Combustível (medidor no gerador e medidor no tanque de reserva)**
  - O medidor do gerador exibe o combustível atual do gerador, que diminui enquanto ele funciona (mais rápido com o feixe ligado).
  - O medidor da reserva exibe quanto resta para o plantão inteiro.
  - Níveis baixos no gerador indicam a necessidade de abastecimento.
  - O jogador precisa se deslocar até o térreo para realizar o abastecimento.
- **Bateria da Lanterna (indicador na própria lanterna)**
  - Exibe o nível de bateria disponível.
  - Diminui apenas enquanto a lanterna está ligada.
  - Não pode ser recarregada nem substituída; ao atingir níveis críticos, o jogador só pode economizar o que resta.
- **Câmeras (monitores fixos)**
  - Mostram o ponto de vista das câmeras de segurança quando o jogador olha para os monitores.
- **Estado do Farol (a própria luz e o painel de iluminação)**
  - Indica se a iluminação principal está funcionando.
  - **Operacional:** luz funcionando normalmente.
  - **Falha:** sistema apresenta problema e exige atenção.
  - **Desligado:** iluminação foi desligada pelo jogador ou por alguma falha.
  - Sem o feixe, barcos que passam no nevoeiro correm risco de afundar (ver 1.2.26).
- **Alertas de Sistema (luzes e sons nos equipamentos)**
  - Informam quando um sistema relevante apresenta uma condição que exige atenção.
  - Exemplo: falha no gerador, problema na iluminação ou necessidade de abastecimento.
  - Os alertas não devem resolver o problema para o jogador; apenas comunicar que existe uma situação que precisa ser investigada.
- **Indicadores de Interação (únicos elementos na HUD)**
  - Hotkey de interação: aparece apenas quando o jogador mira em um objeto interativo e some quando ele deixa de mirar.
  - Barra de progresso: aparece enquanto o jogador mantém a hotkey pressionada em interações que levam tempo (ex.: consertar) e some ao concluir ou ao soltar a tecla. Soltar a tecla zera o progresso.
- **Indicadores de Eventos/Ameaças (som, música e ambiente)**
  - Utilizados apenas quando necessário para comunicar informações que o jogador não poderia obter visualmente.
  - Devem ser sutis e evitar revelar diretamente a localização ou o comportamento das entidades.
  - O objetivo é fornecer informação suficiente para o jogador tomar uma decisão, sem eliminar a sensação de incerteza.

### Princípio da informação

Os objetos do jogo devem **informar, mas não jogar pelo jogador**.

O jogador deve receber informações suficientes para compreender o estado dos sistemas e tomar decisões, mas ainda precisar **observar o ambiente, utilizar as câmeras, ouvir o rádio e interpretar os acontecimentos** para descobrir o que realmente está acontecendo.

# 16. Programação

## ⇒ 16.1 Defina a Engine e a Linguagem de Programação do seu jogo

Adicione seu texto aqui

**Godot 4.7**, com **GDScript 2.0**.

## ⇒ 16.2 Liste todos os plugins e recursos de scripts prontos do seu jogo

Adicione seu texto aqui

Sei lá

## ⇒ 16.3 Liste as principais mecânicas que serão programadas do zero ( mais importantes )

Adicione seu texto aqui

### Nota técnica: estado de funcionamento dos elementos alimentados

Cada elemento que depende do gerador (lâmpada/feixe e rotação do farol, relógio digital, iluminação do andar superior) deve ter, no código, um **estado de funcionamento** e uma função, acionada por **signal**, que troca entre os estados. Assim fica fácil decidir o que funciona ou não em cada situação (gerador sem combustível, gerador quebrado, lâmpada queimada) e incluir novos elementos sem mexer nos existentes.

## ⇒ 16.4 Liste todas as mecânicas adicionais que serão programadas do zero  ( menos importantes, que não influenciam o funcionamento do jogo )

Adicione seu texto aqui

## ⇒ 16.5 Resuma brevemente um fluxo que una a programação a mecânica do jogo

Adicione seu texto aqui

# 17. Música e Efeitos Sonoros

## ⇒ 17.1 Defina o estilo musical do jogo ( use referencias )

Adicione seu texto aqui

## ⇒ 17.2 Liste a quantidade de musicas ( trilhas sonoras ) do jogo

Adicione seu texto aqui

## ⇒ 17.3 Liste a quantidade de efeitos sonoros ( sound fx ) do jogo

Adicione seu texto aqui

## ⇒ 17.4 Crie um fluxo de implementação dos sound fx ( do mais importante para o menos importante )

Adicione seu texto aqui

# 18. QA -  Testes ( Quality Assurance )

## ⇒ 18.1 Crie uma lista de mecânicas principais a serem testadas

Adicione seu texto aqui

## ⇒ 18.2 Crie uma lista de mecânicas secundarias a serem testadas

Adicione seu texto aqui

## ⇒ 18.3 Crie uma lista de pontos que o QA deverá ter mais atenção durante os testes

Adicione seu texto aqui

## ⇒ 18.4 Crie um grupo de pessoas com conhecimento da area de games para testes mais profundos

Adicione seu texto aqui

## ⇒ 18.5 Crie um grupo de pessoas leigas a area de games para testes mais gerais

Adicione seu texto aqui

## ⇒ 18.9 Crie uma lista de BUGS e divida em 3 categorias

## ⇒ 18.9.1 Bugs leves ( que não impedem o jogo ser executado)

Adicione seu texto aqui

## ⇒ 18.9.2 Bugs médios ( geralmente gráficos ou sonoros, não impedem o jogo de ser executados mas são muito evidentes)

Adicione seu texto aqui

## ⇒ 18.9.3 Bugs críticos ( impedem o jogo de ser executado, travam o progresso do player ou fecha a execução do jogo)

Adicione seu texto aqui

# 19. Adicione suas necessidades de GDD

## ⇒ 19.1 Adicione quaisquer tópicos que tenha necessidade de ser documentado

Adicione seu texto aqui

---

# **Referências de imagens**

# **Referências de videos **

# **Referências de audios**

# **Anexo de arquivos**

Adicione quantas referências achar necessário

---

> Editado e melhorado por [Fork Games ST](https://www.forkgamesst.com/) a partir do Template do [Game Dev Tales](https://www.notion.so/e1fd596e628d4ef28b5e693da3a3534b).

---

Se esse template foi útil para você não deixe de nos seguir nos links a baixo:

---

> **[INSTAGRAM](https://www.instagram.com/forkgamesst/)**

> **[SITE](https://www.forkgamesst.com/)**

> **forkgamesst@gmail.com**

---

Sinta-se a vontade para compartilhar e usar esse template como achar melhor. 😉
