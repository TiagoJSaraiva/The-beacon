# 0035 — Gerador de emergência e casa de máquinas no térreo, com o medidor repetido na cabine

- **Data**: 2026-11
- **Status**: aceita (substitui a 0017 só na posição das peças e no deslocamento do galão)

## Contexto
A decisão 0017 pôs o gerador de emergência e a casa de máquinas na cabine, para obrigar o jogador a subir a escada com o galão. Depois dela, o game designer mudou os dois para o térreo (a cena já os tem lá: casa de máquinas no centro, gerador de emergência ao lado), e a decisão não foi atualizada. O medidor do gerador de emergência ficou onde o jogador não o vê enquanto opera o farol.

## Decisão
- **Casa de máquinas**: carcaça e ponto de conserto no térreo, no centro; a tubulação sobe até a cabeça do farol, passando pela câmara da lâmpada na cabine (ponto de troca da lâmpada). O resto da 0017 sobre ela vale.
- **Gerador de emergência**: no térreo, ao lado da casa de máquinas. O galão é despejado nele no térreo, sem subir a escada. O resto da 0017 (combustível, medidor, boca) vale.
- **Medidor na cabine**: um `FuelGauge` no painel da alavanca repete o nível do gerador de emergência, para o jogador saber da cabine quando descer. O medidor do próprio gerador continua. Funciona sem energia, como o relógio.

## Alternativas descartadas
- **Devolver as peças à cabine**: contraria o pedido do game designer.
- **Medidor só no gerador**: o jogador teria de descer para ver o nível, e o GDD (1.2.21) quer a informação no cenário onde ele decide.

## Consequências
A decisão 0017 e `planos/entrega-2.md` (histórico) ainda dizem "cabine" para as duas peças: vale esta. A pendência do patrão sobre a posição exata do medidor na cabine (parede, poste ou mesa) está no `status.md`.
