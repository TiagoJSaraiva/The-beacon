# 0017 — Modelo de energia: gerador principal pela mangueira e gerador de emergência pelo galão

- **Data**: 2026-11
- **Status**: aceita

## Contexto
Na revisão das mecânicas (`planos/entrega-2.md`), o combustível só vira problema depois que a mangueira estoura (uma vez, sem conserto). A reunião usou vários nomes para as mesmas peças (gerador, casa de máquinas, gerador reserva), e o fluxo precisou ser padronizado.

## Decisão
- **Tanque de combustível** (térreo): reserva infinita. Alimenta o **gerador principal** pela mangueira e tem o slot que enche o galão aos poucos.
- **Gerador principal** (térreo): fonte de energia enquanto a mangueira está inteira. Não quebra e não tem boca de combustível.
- **Gerador de emergência** (cabine, ao lado da casa de máquinas): fonte de energia depois que a mangueira estoura. Tem combustível, medidor e boca para o galão. O jogador sobe a escada com o galão para abastecê-lo.
- **Casa de máquinas** (cabine): gira o farol. Quebra ao acaso e tem conserto.
- A energia alimenta só a casa de máquinas e a lâmpada. Relógio, luzes, monitores e rádio funcionam sem ela (provisório).
- Os dois geradores usam a mesma cena (`Generator`), configurada para cada papel.

## Alternativas descartadas
- **Um gerador só**, que passa de "alimentado pela mangueira" para "abastecido pelo galão": é mais simples (uma peça a menos e nenhuma troca de fonte), mas o game designer quer o gerador de emergência na cabine, para obrigar a levar o galão escada acima. Retomar se o ciclo do galão não precisar mais do deslocamento.

## Consequências
Os nomes desta decisão são o vocabulário do código e das notas. A fiação de energia no `Lighthouse` precisa escolher a fonte ativa, conforme o estado da mangueira.
