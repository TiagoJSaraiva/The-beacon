# 0036 — Luzes do térreo e da escada seguem o gerador principal

- **Data**: 2026-11
- **Status**: aceita (substitui a 0017 só no trecho "luzes funcionam sem energia")

## Contexto
A decisão 0017 deixou relógio, luzes, monitores e rádio funcionando sem energia (provisório). O patrão pediu que, quando a mangueira estoura e o gerador de emergência assume, as luzes de baixo apaguem. O GDD 1.2.4 já descreve o térreo sem iluminação, muito escuro, só com a lanterna.

## Decisão
- As luzes do térreo e da escada (`LowerLights`: quatro arandelas no térreo e duas acima da escada) só funcionam com o gerador principal, ou seja, com a mangueira inteira. Estourada, apagam e ficam apagadas pelo resto do plantão, porque a mangueira não tem conserto.
- As luzes da cabine (`UpperLights`) não mudam: seguem acesas. O que acontece com elas com o gerador de emergência sem combustível está em aberto (pendência com o patrão no `status.md`).
- Relógio, monitores e rádio continuam funcionando sem energia (0017, provisório).
- A regra é o estado de funcionamento por sinal da nota técnica do GDD 16.3: `Generator.power_changed` do principal → `Lighthouse` → `PoweredLights.set_powered`.

## Alternativas descartadas
- **Apagar também as luzes de cima**: o GDD diz que a iluminação do andar superior depende do gerador, mas sem definir o caso do gerador de emergência; fica para a pendência.
- **Apagar com o nevoeiro dentro do farol**: a mangueira estoura nesse momento (0017), então o efeito é o mesmo sem uma segunda regra.

## Consequências
O térreo fica no escuro, só com a lanterna, depois da primeira entrada do nevoeiro, o que muda o ritmo do tutorial e da fuga do Afogado: validar jogando. O Afogado não depende de luz.
