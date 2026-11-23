# 0029 — Mar pela Boujie Water Shader

- **Data**: 2026-11
- **Status**: aceita

## Contexto
O mar era um plano liso de cor chapada. O desenvolvedor pediu um componente pronto de mar texturizado com o reflexo da lua. O mar só é visto pelas três câmeras de segurança, paradas, numa GPU integrada que já renderiza a névoa volumétrica de cada uma.

## Decisão
- O addon **Boujie Water Shader** (Chrisknyfe, MIT, branch `main`) fica em `addons/boujie_water_shader/`, sem as capturas de tela do repositório.
- O nó `Sea` do `Exterior` é um `Ocean` do addon: anéis de malha com detalhe decrescente centrados na ilha (`levels_of_detail` 4, `outermost_resolution` 16, `far_edge` 300 = o `far` das câmeras). Sem o `CameraFollower3D`: as câmeras são três e paradas.
- O material é `exterior/sea_material.tres`, cópia do `deep_ocean_material` do addon com cores de mar à noite, água mais lisa (`roughness` 0,05) e ondas baixas. (Corrigido: a altura das ondas vem da `steepness`, não da amplitude; ver a decisão 0030, que também desceu o mar.)
- O reflexo da lua vem do céu da Sky3D (reflexo do céu no ambiente do mundo) e do brilho especular da luz da lua (decisão 0028).

## Alternativas descartadas
- **Oceano por FFT (OceanPro, Swell)**: mais realista, mas usa compute shaders e pesa mais numa GPU integrada com três câmeras.
- **Shader de água próprio**: o pedido era um componente pronto.

## Consequências
As ondas, a espuma e o reflexo do céu vêm do addon e se ajustam pelo material. O shader é transparente (lê a tela e a profundidade), o que soma custo por câmera. O addon foi testado pelo autor no Godot 4.1; no 4.7 ele importou e rodou sem erros. Atualizar é trocar a pasta do addon e conferir o material, que copia os parâmetros dele.
