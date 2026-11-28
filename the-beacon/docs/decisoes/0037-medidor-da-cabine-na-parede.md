# 0037 — Medidor do gerador de emergência na parede da cabine

- **Data**: 2026-11
- **Status**: aceita (substitui a 0035 só na posição do medidor da cabine)

## Contexto
A decisão 0035 pôs um `FuelGauge` no painel da alavanca, na cabine, para repetir o nível do gerador de emergência, e deixou a posição exata (parede, poste ou mesa) para o patrão decidir. O desenvolvedor escolheu a parede, ciente de que o patrão pode mudá-la de novo.

## Decisão
- O `CabinFuelGauge` fica na face interna da parede da cabine, na direção da alavanca a partir do centro (x −3,375; y 12,1; z −4,296), de frente para o centro, com escala 2 para ler de longe (a mesa e a alavanca ficam a 3 a 5 m).
- O resto da 0035 vale: repete o nível do gerador de emergência, só leitura, funciona sem energia, e o medidor do próprio gerador continua.
- A posição é provisória: mudar de lugar é só trocar a transformação da instância na cena do `Lighthouse`, sem código.

## Alternativas descartadas
- **Poste do meio e mesa**: o patrão pode preferir outro lugar de qualquer forma, e a parede não ocupa a mesa nem o poste.

## Consequências
O medidor deixa de aparecer junto à alavanca: o jogador precisa erguer o olhar para a parede para vê-lo. A face da parede é plana (32 lados): se a cabine mudar de raio ou de lados, a posição e o giro precisam ser medidos de novo.
