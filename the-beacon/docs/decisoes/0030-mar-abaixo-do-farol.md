# 0030 — Mar abaixo do farol, sem mover o farol

- **Data**: 2026-11
- **Status**: aceita

## Contexto
As ondas do mar novo (decisão 0029) entravam no térreo. O desenvolvedor pediu para "subir" o farol sobre uma ilha. O farol tem dezenas de coordenadas absolutas (escada, alçapão, alvos do Afogado, posições dos testes e do painel de debug) em torno do térreo em y = 0.

## Decisão
- O farol fica onde está, com o térreo em y = 0. O mar (`Sea`, y = −2,9), a rota dos barcos (y = −2,6) e os pontos que as câmeras do mar miram (`SeaViewLeft`/`Right`, y = 0) desceram 2 m; a ilha sobe até a base do farol.
- No shader do mar, a altura de cada onda é a `steepness` dela e o deslocamento é a média das ondas (`WaveCount`); a `amplitude` só move a água na horizontal. A crista mais alta fica em nível do mar + média das `steepness` (hoje ~0,8 m, crista em ~−2,1).
- `test/scenes/sea_level_test.gd` garante a crista mais alta ao menos 1,5 m abaixo do térreo.

## Alternativas descartadas
- **Subir o farol**: o mesmo efeito, mas mexeria em todas as coordenadas absolutas do interior e dos testes.

## Consequências
O interior não muda. Quem posiciona coisas no mar ou na rota trabalha com o nível −2,9. Ondas mais altas exigem conferir o teste do nível do mar.
