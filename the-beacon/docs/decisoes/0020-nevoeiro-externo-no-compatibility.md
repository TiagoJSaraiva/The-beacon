# 0020 — Nevoeiro externo com densidade variável no Compatibility

- **Data**: 2026-11
- **Status**: aceita

## Contexto
A faixa no mar e o anel em volta do farol apareciam nas câmeras como blocos baixos, de contorno seco. A causa era o modelo dos volumes (densidade uniforme, topo abaixo da câmera), não a falta de névoa volumétrica. O PC de desenvolvimento só roda o renderizador Compatibility, que não tem `FogVolume` nem névoa volumétrica. O nevoeiro do interior já está como o desejado: um filtro uniforme no ar.

## Decisão
- O projeto continua no Compatibility.
- `fog_volume.gdshader` ganha `edge_fade` e `top_fade`. Com algum deles ligado, o raio é amostrado em `march_steps` passos e a densidade cai até zero nas bordas. Sem eles, vale o cálculo direto de antes.
- Só `SeaBand` e `NearRing` usam o esmaecimento, sem ruído. Os volumes internos não mudam.
- A faixa passa da altura das câmeras. Altura e profundidade acompanham o comprimento do trecho coberto, até os limites em `FogVisuals`, para o nevoeiro subir à medida que se espalha.

## Alternativas descartadas
- **Trocar para Forward+**: o PC de desenvolvimento não roda esse renderizador.
- **Ruído 3D em movimento**: testado em protótipo, deu aspecto de nuvem em vez de filtro no ar.

## Consequências
O exterior custa mais por pixel, o que pouco pesa nas câmeras (320x240). O anel e a faixa também são desenhados para a câmera do jogador, mesmo escondidos pelas paredes.
