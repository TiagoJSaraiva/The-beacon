# Nevoeiro

## Propósito
Ameaça que surge no mar e avança até cobrir o feixe enquanto o farol está parado (entrega 2; GDD 1.2.10).

## Componentes
- `fog/fog_state.gd` (`FogState`, puro): avanço de 0 a 1, surgimento, recuo e trecho da rota dos barcos. Para o painel de debug: `force_advance` e `clear`.
- `fog/fog_stage.gd` (`FogStage`, puro): estágios pelo avanço, o avanço em que cada um começa (`threshold`) e o que cada um implica.
- `fog/fog_system.gd` (`FogSystem`, nó no `World`): roda o estado conforme o farol opera e avisa estágio e trecho da rota. `frozen` (painel de debug) para o avanço.
- `fog/fog_visuals.tscn` (`FogVisuals`, nó no `World`): um `FogVolume` por área, cada um com `FogMaterial` próprio (decisão 0025), somado a uma camada de shader (decisão 0027). A névoa volumétrica está ligada no `Environment` do mundo e no das câmeras, com densidade global zero: só os volumes têm nevoeiro. Ele é iluminado pela luz ambiente (`volumetric_fog_ambient_inject`) e pelas luzes da cena. A faixa e o anel usam `edge_fade` alto para a densidade cair até zero nas bordas.
  - Camada de shader (decisão 0027): cada volume tem um filho `ShaderLayer`, malha com o shader antigo (`fog/fog_volume.gdshader`, do Compatibility), que esmaece junto com ele. As duas camadas somam. `FogVisuals.volume_density_scale` e `shader_density_scale` (0 a 2) multiplicam a densidade de cada uma; 0 desliga. A volumétrica pega a cor das luzes, mas some onde está escuro (térreo); o shader é um véu cinza que não depende da luz. Nos volumes internos (térreo, escada, cabine), a cor dele é quase preta (0,06): sem luz ambiente dentro do farol, o cinza padrão brilharia no breu.
  - Sem `emission` no `FogMaterial`: o Godot soma a emissão num inteiro compactado, e nos voxels distantes o azul transborda para o verde.
  - Sem `height_falloff`: abaixo da origem do volume ele aumenta a densidade, e a faixa desce abaixo do mar.

## Regras
- Avanço de 0% (acabou de surgir) a 100% (cobre o feixe). Estágios (`FogConfig`): `NONE` (0), `SEA` (> 0), `NEAR` (`near_advance`, perto da entrada), `GROUND_FLOOR`, `STAIRS`, `TRAPDOOR`, `CABIN`, `BEAM` (`beam_cover_advance`, 1,0).
- Surge no mar em `start_advance` pelo evento `fog` ou depois de `idle_grace_seconds` com o farol sem operar. Surge uma vez por noite e não vai mais embora: nunca desce de `start_advance`.
- Farol parado: avança a `advance_per_second` até 1.
- Farol volta a operar depois de uma parada: devolve de uma vez `recoil_ratio` (50%) do que avançou nessa parada. Depois, enquanto opera, recua a `recede_per_second` (mais lento que o avanço; o `validate()` exige) até `start_advance`.
- No estágio `BEAM`, o recuo de uma vez espera `unblock_seconds` de farol operando; parar de novo reinicia a espera. Só nesse estágio o feixe fica bloqueado (`Lighthouse.set_fog_stage`).
- Efeitos por estágio:
  - `NEAR` ou acima: o anel em volta do farol aparece na câmera da porta. As câmeras do mar e a do jogador não o veem (camada de render `fog_near_ring`, fora do `cull_mask` delas): dentro do farol, ele somaria ao nevoeiro interno.
  - `GROUND_FLOOR` ou acima: na primeira vez, estoura a mangueira. Volume no térreo. Aproximação do Afogado. Carrancas no térreo.
  - `STAIRS`, `CABIN`: volumes e carrancas na escada e na cabine.
  - `TRAPDOOR` ou acima: desliga o trinco do alçapão e impede ligá-lo.
  - `BEAM`: bloqueia o feixe; volume denso em volta da cabeça do farol (`LampShroud`).
- Rota dos barcos: o nevoeiro cobre um trecho centrado em `route_center` (fixo). A largura cresce com o avanço até `max_route_coverage` (< 1, nunca fecha a rota), atingida em `NEAR`. A faixa no mar acompanha esse trecho, centrada no nível da rota, e fica mais densa e mais alta com o avanço (`fog/sea_band_shape.gd`, `SeaBandShape`, puro). A profundidade acompanha o comprimento até `sea_band_half_depth`. `FogVisuals.sea_band_offset` (metros: X ao longo da rota, Y para cima, Z para o lado; com a rota atual, +Z afasta do farol) desloca só o visual: os barcos continuam afundando no trecho da rota, então um deslocamento grande separa a faixa de onde eles afundam. Para mover o nevoeiro junto com a regra ao longo da rota, use `FogConfig.route_center`. A meia-altura começa igual ao meio-comprimento e chega a `sea_band_half_height` (60 m) em `NEAR`, passando do topo da imagem das câmeras do mar (`test/scenes/sea_cameras_test.gd`).
- Cada volume esmaece ao entrar e sair do seu estágio (`FogVisuals.fade_per_second`).
- Os volumes internos são cilindros retos dentro de um farol cônico: o raio de cada um cabe na parede no topo do trecho, para não vazar por fora, e sobra folga na parte baixa.
- A noite seguinte começa sem nevoeiro.

## Sinais
- `FogSystem.stage_changed(stage)` → `Lighthouse.set_fog_stage`, `DrownedDirector.set_fog_stage`, `FigureheadDirector.set_fog_stage`, tutorial.
- `FogSystem.route_fog_changed(start, end)` → `BoatDirector.set_route_fog`.
- `Lighthouse.beam_operational_changed(operational)` → `FogSystem.set_beam_operational`.

## Testes
- `test/unit/fog_state_test.gd`: surgimento por evento e por farol parado; não vai embora; avanço pelos estágios; recuo de uma vez só da última parada; recuo lento até o piso; espera com o feixe coberto; limiares; trecho da rota com centro fixo; `validate()` do recuo.
- `test/unit/sea_band_shape_test.gd`: altura igual ao comprimento no surgimento e no máximo em `NEAR`, crescendo entre os dois; profundidade limitada; tamanho mínimo.
- `test/scenes/sea_cameras_test.gd`: no crescimento máximo, o topo da face da frente da faixa passa da borda de cima das câmeras do mar.
- `test/scenes/lighthouse_power_test.gd`: só `BEAM` bloqueia o feixe, sem parar o farol; dentro do farol estoura a mangueira.
