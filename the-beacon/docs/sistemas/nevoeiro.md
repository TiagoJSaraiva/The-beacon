# Nevoeiro

## Propósito
Ameaça que avança do mar até a cabine enquanto o farol está parado (entrega 2; GDD 1.2.10).

## Componentes
- `fog/fog_state.gd` (`FogState`, puro): avanço de 0 a 1, fases e trecho da rota dos barcos.
- `fog/fog_stage.gd` (`FogStage`, puro): estágios pelo avanço e o que cada um implica.
- `fog/fog_system.gd` (`FogSystem`, nó no `World`): roda o estado conforme o farol opera e avisa estágio e trecho da rota.
- `fog/fog_visuals.tscn` (`FogVisuals`, nó no `World`) e `fog/fog_volume.gdshader`: volumes de nevoeiro falso (o renderizador Compatibility não tem névoa volumétrica). O shader mede quanto do raio de visão atravessa a caixa ou o cilindro até a primeira superfície da cena: paredes cortam o nevoeiro e dá para estar dentro dele.

## Regras
- Estágios (`FogConfig`): `NONE` (0), `SEA` (> 0), `NEAR` (`near_advance`), `GROUND_FLOOR`, `STAIRS`, `TRAPDOOR`, `CABIN`.
- Surge no mar (`start_advance`) pelo evento `fog` ou depois de `idle_grace_seconds` com o farol sem operar.
- Farol operando, nevoeiro no mar: adensa a `sea_densify_per_second` até `sea_max_advance` (abaixo de `NEAR`). Dura um tempo sorteado entre `min_duration_seconds` e `max_duration_seconds`, contado só nessa fase; ao fim, dissipa a `recede_per_second`.
- Farol parado: avança a `advance_per_second` até 1.
- Farol volta a operar com o nevoeiro em `NEAR` ou acima: segue bloqueando o feixe por `unblock_seconds` e recua até `recede_to_advance`; daí volta a se comportar como no mar. Abaixo de `NEAR`, só para de avançar.
- Efeitos por estágio:
  - `NEAR` ou acima: bloqueia o feixe (`Lighthouse.set_fog_stage`); o anel em volta do farol aparece na câmera da porta; surge o Homem de Nevoeiro.
  - `GROUND_FLOOR` ou acima: na primeira vez, estoura a mangueira. Volume no térreo.
  - `STAIRS`, `CABIN`: volumes na escada e na cabine.
  - `TRAPDOOR`: destrancar o trinco entra na fase E da entrega 2.
- Rota dos barcos: o nevoeiro cobre um trecho em volta de um centro sorteado ao surgir. A largura cresce com o avanço até `max_route_coverage` (< 1, nunca fecha a rota), atingida em `NEAR`. A faixa no mar acompanha esse trecho e fica mais densa com o avanço.
- Cada volume esmaece ao entrar e sair do seu estágio (`FogVisuals.fade_per_second`).
- A noite seguinte começa sem nevoeiro.

## Sinais
- `FogSystem.stage_changed(stage)` → `Lighthouse.set_fog_stage`, `FogManDirector.set_fog_stage`, tutorial.
- `FogSystem.route_fog_changed(start, end)` → `BoatDirector.set_route_fog`.
- `Lighthouse.beam_operational_changed(operational)` → `FogSystem.set_beam_operational`.

## Testes
- `test/unit/fog_state_test.gd`: surgimento por evento e por farol parado; teto no mar; fim da duração; avanço pelos estágios; espera e recuo; parada abaixo de `NEAR`; limiares; cobertura da rota.
- `test/scenes/lighthouse_power_test.gd`: `NEAR` bloqueia o feixe sem parar o farol; dentro do farol estoura a mangueira.
