# 0027 — Nevoeiro por shader somado à névoa volumétrica

- **Data**: 2026-11
- **Status**: aceita

## Contexto
A decisão 0025 trocou o nevoeiro falso (malha com `fog_volume.gdshader`) por `FogVolume`. A névoa volumétrica pega a cor e os fachos das luzes, mas onde está escuro (térreo) ela quase some. O desenvolvedor testou as duas camadas juntas na branch `teste/nevoeiro-shader-e-volume` e aprovou.

## Decisão
- Cada volume do `FogVisuals` tem um filho `ShaderLayer`: malha com o shader antigo, que esmaece junto com o volume. As duas camadas somam.
- `FogVisuals.volume_density_scale` e `shader_density_scale` (0 a 2) multiplicam a densidade de cada camada; 0 desliga.
- Cada `ShaderLayer` usa uma cópia do material, para o recurso da cena não levar o estado de uma noite para a outra.
- Substitui a parte do nevoeiro visível da 0025; o Forward+ com D3D12 continua valendo.

## Alternativas descartadas
- **Só névoa volumétrica (0025)**: some no escuro, e o nevoeiro é a ameaça que o jogador precisa ler.
- **Só o shader**: não reage à luz nem mostra o facho da lanterna.

## Consequências
O nevoeiro fica visível mesmo sem luz e ainda pega o tom das lâmpadas. O custo soma os dois: a névoa volumétrica por viewport e o shader por pixel coberto pelos volumes. O shader é sem sombreamento: num ambiente sem luz, a cor dele precisa ser ajustada para não brilhar.
