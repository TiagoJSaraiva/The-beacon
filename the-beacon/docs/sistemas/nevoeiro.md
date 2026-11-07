# Nevoeiro

## Propósito
Ameaça que avança do mar até a cabine enquanto o farol está parado (entrega 2; GDD 1.2.10).

## Componentes
- `fog/fog_state.gd` (`FogState`, puro): avanço de 0 a 1, fases e trecho da rota dos barcos.
- `fog/fog_stage.gd` (`FogStage`, puro): estágios pelo avanço e o que cada um implica.
- `fog/fog_system.gd` (`FogSystem`, nó no `World`): roda o estado conforme o farol opera e avisa estágio e trecho da rota.
- `fog/fog_visuals.tscn` (`FogVisuals`, nó no `World`) e `fog/fog_volume.gdshader`: volumes de nevoeiro falso (o renderizador Compatibility não tem névoa volumétrica). O shader mede quanto do raio de visão atravessa a caixa ou o cilindro até a primeira superfície da cena: paredes cortam o nevoeiro e dá para estar dentro dele. Com `edge_fade` ou `top_fade`, usados só na faixa e no anel, amostra o raio em `march_steps` passos para a densidade cair até zero nas bordas (decisão 0020).

## Regras
- Estágios (`FogConfig`): `NONE` (0), `SEA` (> 0), `NEAR` (`near_advance`), `GROUND_FLOOR`, `STAIRS`, `TRAPDOOR`, `CABIN`.
- Surge no mar (`start_advance`) pelo evento `fog` ou depois de `idle_grace_seconds` com o farol sem operar.
- Farol operando, nevoeiro no mar: adensa a `sea_densify_per_second` até `sea_max_advance` (abaixo de `NEAR`). Dura um tempo sorteado entre `min_duration_seconds` e `max_duration_seconds`, contado só nessa fase; ao fim, dissipa a `recede_per_second`.
- Farol parado: avança a `advance_per_second` até 1.
- Farol volta a operar com o nevoeiro em `NEAR` ou acima: o avanço fica parado por `unblock_seconds` e depois recua a `recede_per_second` até `recede_to_advance`; daí volta a se comportar como no mar. O feixe segue bloqueado até o avanço ficar abaixo de `near_advance` (ver "Comportamento atual a revisar"). Abaixo de `NEAR`, só para de avançar.
- Efeitos por estágio:
  - `NEAR` ou acima: bloqueia o feixe (`Lighthouse.set_fog_stage`); o anel em volta do farol aparece na câmera da porta e como neblina geral nas câmeras do mar.
  - `GROUND_FLOOR` ou acima: na primeira vez, estoura a mangueira. Volume no térreo. Aproximação do Afogado. Carrancas no térreo.
  - `STAIRS`, `CABIN`: volumes e carrancas na escada e na cabine.
  - `TRAPDOOR` ou acima: desliga o trinco do alçapão e impede ligá-lo.
- Rota dos barcos: o nevoeiro cobre um trecho em volta de um centro sorteado ao surgir. A largura cresce com o avanço até `max_route_coverage` (< 1, nunca fecha a rota), atingida em `NEAR`. A faixa no mar acompanha esse trecho e fica mais densa com o avanço; altura e profundidade crescem com o comprimento até `sea_band_half_height` e `sea_band_half_depth`, e no máximo ela passa do topo da imagem das câmeras.
- Cada volume esmaece ao entrar e sair do seu estágio (`FogVisuals.fade_per_second`).
- Os volumes internos são cilindros retos dentro de um farol cônico: o raio de cada um cabe na parede no topo do trecho, para não vazar por fora, e sobra folga na parte baixa.
- A noite seguinte começa sem nevoeiro.

## Comportamento atual a revisar
A feature ainda vai mudar; isto descreve o código de hoje (`FogState`), sem correção prevista. Valores das três dificuldades, que usam os padrões de `FogConfig`.

- **O feixe fica bloqueado bem mais que `unblock_seconds`.** O bloqueio vem do estágio (`blocks_beam`: avanço `>= near_advance`), não da fase. Ao voltar a operar com o nevoeiro em `NEAR` ou acima, o avanço fica parado em `HOLDING` por `unblock_seconds` (8 s) e recua em `RECEDING` a `recede_per_second` (0,03/s). Tempo total sem feixe depois de o farol voltar: `unblock_seconds + (avanço − near_advance) / recede_per_second` = `8 + (avanço − 0,3) / 0,03` s. Em `NEAR` (0,3): 8 s; no térreo (0,45): 13 s; na cabine (0,9): 28 s; no máximo (1,0): ~31 s. Nesse recuo os estágios descem um a um (o nevoeiro sai da cabine, do alçapão, da escada e do térreo nessa ordem). Se o farol parar antes, volta a `ADVANCING`.
- **O trecho na rota pode saltar de lugar enquanto o nevoeiro se dissipa.** Ao fim da duração no mar, a fase vira `CLEAR`, mas o avanço só cai a 0,03/s. Como `CLEAR` só vem de `SEA`, que fica abaixo de `near_advance`, isso leva no máximo ~10 s. Nesse tempo, `route_segment()` ainda cobre um trecho em volta do centro antigo, e `can_start()` já é verdadeiro.
  - Se o evento `fog` disparar nessa janela (tentativa a cada 30 s, das 20h30 às 5h, até 3 por noite) ou o farol ficar 45 s sem operar, `start()` sorteia outro `route_center` (entre 0,25 e 0,75) e mantém o avanço (no mínimo `start_advance`).
  - O trecho muda de lugar no mesmo frame, com meia-largura `max_route_coverage × min(avanço / near_advance, 1) / 2`. A faixa no mar é reposicionada direto (`FogVisuals._place_sea_band`); só a opacidade esmaece.
  - Um barco que estava fora do trecho antigo e cai dentro do novo afunda no passo seguinte (`BoatPassage.tick`), sem chance de aviso. Um barco antes do trecho novo que ainda não foi atendido passa a chamar.

## Sinais
- `FogSystem.stage_changed(stage)` → `Lighthouse.set_fog_stage`, `DrownedDirector.set_fog_stage`, `FigureheadDirector.set_fog_stage`, tutorial.
- `FogSystem.route_fog_changed(start, end)` → `BoatDirector.set_route_fog`.
- `Lighthouse.beam_operational_changed(operational)` → `FogSystem.set_beam_operational`.

## Testes
- `test/unit/fog_state_test.gd`: surgimento por evento e por farol parado; teto no mar; fim da duração; avanço pelos estágios; espera e recuo; parada abaixo de `NEAR`; limiares; cobertura da rota.
- `test/scenes/lighthouse_power_test.gd`: `NEAR` bloqueia o feixe sem parar o farol; dentro do farol estoura a mangueira.
