# 0025 — Forward+ e nevoeiro por névoa volumétrica

- **Data**: 2026-11
- **Status**: aceita

## Contexto
A decisão 0020 manteve o projeto no Compatibility porque se acreditava que o PC de desenvolvimento (Ryzen 7 5700U, GPU integrada) não rodava o Forward+. A premissa estava errada: com o driver D3D12, o jogo roda normalmente no Forward+. O nevoeiro era falso, feito com malhas e um shader próprio (`fog_volume.gdshader`), e não reagia à luz.

## Decisão
- O renderizador passa a ser o Forward+ (`renderer/rendering_method` padrão), com o driver D3D12 no Windows. O Mobile continua apontando para o Compatibility.
- O nevoeiro visível passa a ser névoa volumétrica: cada volume do `FogVisuals` é um `FogVolume` com `FogMaterial` próprio, e o shader falso sai.
- A densidade global da névoa volumétrica fica em zero no `Environment` do mundo e no das câmeras: só os volumes têm nevoeiro, como antes.
- O feixe e a lanterna espalham luz no nevoeiro (`light_volumetric_fog_energy`).
- Substitui a 0020.

## Alternativas descartadas
- **Manter o shader falso no Forward+**: funciona e custa menos, mas não reage à luz, que é o ganho visual buscado.
- **Névoa global por altura no `Environment`**: não se limita a um trecho da rota nem a uma área do farol por estágio.

## Consequências
O nevoeiro fica com bordas suaves sem cálculo próprio e mostra os fachos de luz. A névoa volumétrica é calculada por viewport, e as três câmeras de segurança mais a do jogador pagam esse custo. A grade dela é grosseira: o nevoeiro pode vazar um pouco por paredes finas. O Compatibility deixa de ser opção, porque nele o nevoeiro some.
