# 0023 — Modelos de terceiros: cena-embrulho, texturas em 2K, colisão separada

- **Data**: 2026-11
- **Status**: aceita

## Contexto
O greybox começa a ser substituído por modelos baixados (Sketchfab/Fab, Megascans). Cada pacote vem com uma escala, uma orientação e um formato (glTF ou FBX) próprios, e as texturas vêm em 4K, com PNGs de até 20 MB. O repositório não usa Git LFS, e o GitHub recusa arquivos acima de 100 MB. A navmesh lê só os colliders estáticos (decisão 0009). O primeiro modelo importado, o rádio, foi instanciado direto na cena dele, com escala não uniforme.

## Decisão
- Os pacotes originais ficam fora do git, em `notes/modelos-store/` (ignorado). `tools/import_store_model.gd` extrai cada um para `assets/models/<nome>/`. Ele reduz as texturas para no máximo 2048 px e descarta os mapas que o `StandardMaterial3D` não usa (cavity, displacement, gloss, specular, height).
- Cada modelo tem uma cena-embrulho `assets/models/<nome>/<nome>.tscn` que o normaliza: metros, base em y=0, centrado em XZ e frente voltada para +Z. As cenas do jogo instanciam o embrulho, nunca o arquivo importado. O ajuste ao objeto (tamanho do placeholder) é a escala dessa instância.
- glTF: o importador liga as texturas. FBX: um `StandardMaterial3D` por material em `assets/models/<nome>/materials/`, ligado como material externo nas opções de import (`_subresources` do `.import`).
- A colisão continua em formas simples, separada da malha, com o mesmo tamanho do placeholder. A malha do modelo não colide.
- Origem e licença de cada modelo em `assets/models/CREDITOS.md`.

## Alternativas descartadas
- **Instanciar o arquivo importado direto na feature, como no rádio**: a escala e a orientação ficam repetidas em cada uso, e a troca do modelo exige mexer em todas as cenas.
- **Versionar as texturas em 4K**: cerca de 260 MB só nos seis primeiros modelos; em primeira pessoa, 2K basta.
- **Git LFS**: exige configurar o LFS em cada clone e tem cota no GitHub; com 2K, o peso ainda é aceitável sem ele.

## Consequências
Trocar um modelo mexe só no embrulho, e a navmesh e a física não mudam com a arte. Se um modelo precisar de mais definição, roda-se a ferramenta de novo com `--max-size`. O rádio ainda segue o formato antigo (`assets/RadiostationMCKINLEY_GameReady.fbx`) até ser migrado.
