# Modo debug

## Propósito
Painel dentro do jogo para testar funções e balanceamento sem mexer no código (decisão 0024).

## Componentes
- `debug/debug_mode.gd` (`DebugMode`): `ENABLED` liga o modo; `is_active()` exige também build de debug.
- `debug/debug_panel.tscn` (`DebugPanel`, `CanvasLayer`, `process_mode = ALWAYS`): filho do `Game`, fora do `World`. Abas em `%Tabs`. Os sistemas chegam por `@export`; o catálogo, a dificuldade, os valores vivos da noite (`Game.night_config`) e o `RunState`, pelo `setup()` que o `Game` chama. No topo, a leitura de estado junta o `readout()` de cada aba.
- `debug/debug_tab.gd` (`DebugTab`): base das abas, que montam a interface em código (títulos, botões, valor com botão, caixas, linha de status).
- `debug/night_tab.gd` (`NightTab`): aba Noite.
- `debug/lighthouse_tab.gd` (`LighthouseTab`): aba Farol.
- `debug/fog_tab.gd` (`FogTab`): aba Nevoeiro.
- `debug/threats_tab.gd` (`ThreatsTab`): aba Ameaças.
- `debug/player_tab.gd` (`PlayerTab`): aba Jogador.
- `debug/fullbright_view.gd` (`FullbrightView`): "Sem escuridão" da aba Jogador.
- `debug/balance_tab.gd` (`BalanceTab`): aba Tabela (barra de botões e grade).
- `debug/night_table_grid.gd` (`NightTableGrid`): grade de uma tabela por noite (SpinBox para número, CheckBox para bool).
- Fora de `debug/`: `config/balance_table.gd` (`BalanceTable`), `config/config_fields.gd` (`ConfigFields`), `config/balance_labels.gd` (`BalanceLabels`) e o autoload `BalanceService` (decisão 0031).

## Regras
- Y (`debug_menu`) abre e fecha; Esc também fecha, sem abrir o menu de pausa. Não abre com o menu de pausa aberto nem fora da simulação (fim de noite, morte, vitória).
- Aberto, a simulação continua; o jogador fica travado e o mouse solto. "Pausar simulação" congela o `World` e é desfeita ao fechar.
- Noite: ir para uma hora (`NightClock.set_clock_hour`), velocidade do relógio (`NightDirector.debug_time_scale`), terminar a noite (leva o relógio às 06:00), recomeçar a noite, disparar cada evento registrado (`EventDirector.trigger_now`: respeita o `can_trigger` do sistema e não conta no máximo da noite) e ligar ou desligar o sorteio (`EventDirector.random_events_enabled`).
- Farol: queimar a lâmpada e quebrar a casa de máquinas mesmo no intervalo depois do conserto (`FailureState.skip_cooldown`), trocar e consertar, estourar a mangueira, definir o combustível do gerador de emergência (`GeneratorState.set_fuel_ratio`), encher e esvaziar o galão, inverter a alavanca (`BeamControl.toggle`) e o trinco (`Trapdoor.toggle_latch`, que segue as regras: nevoeiro, alçapão aberto, intervalo).
- Nevoeiro: surgir agora (só se ainda não surgiu), limpar (volta a antes de surgir, `FogState.clear`; o que ele já causou, como a mangueira estourada, continua), congelar o avanço (`FogSystem.frozen`), fixar o avanço (`FogState.force_advance`, sem recuo pendente) e ir para o começo de um estágio (`FogStage.threshold`). Também desloca a faixa no mar ao vivo (`FogVisuals.sea_band_offset`, um campo por eixo) e escreve no console o valor para copiar no `FogVisuals` da cena; a aba Tabela move o trecho da regra (`fog.route_center`).
- Ameaças: spawnar barco sem limite e afundar todos (cada um soma ponto de Afogado); +1 ponto, forçar a entrada, remover o Afogado e definir o nível de aproximação; invocar carranca a 4 m à frente do jogador (fora do alcance do pulo, 3 m), dissolver todas e zerar as cegueiras.
- Jogador: invulnerável (cobre Afogado e queda fatal), bateria infinita, encher a bateria (apaga a lanterna), tirar o bloqueio da corrida e teleportar para o ponto da navmesh mais perto da porta (dentro), de baixo do alçapão, da casa de máquinas, de cima do alçapão e da cadeira da cabine. "Força das luzes do farol" aplica `InteriorLights.light_scale` ao vivo. "Sem escuridão" troca o `Environment` da câmera do jogador (`Player.view_camera()`) por uma cópia com luz ambiente branca forte (as câmeras de segurança usam o do mundo) e devolve o original ao desmarcar.
- Tabela (decisão 0031): a tabela de balanceamento por noite de uma dificuldade, escolhida no topo (abre na dificuldade em jogo). Uma linha por valor, agrupada por tema, e uma coluna por noite; `nights` e `tutorial_enabled` ficam de fora (o `RunState` já os copiou). Com a aba aberta, o painel ocupa a tela inteira.
- Cada linha aparece com um nome em português (`BalanceLabels.LABELS`, com a unidade entre parênteses); a chave técnica (`fog.advance_per_second`) fica na dica ao passar o mouse. Um `@export` novo precisa de nome nesse dicionário: o teste `balance_labels_test.gd` reprova linha sem nome.
- A célula da noite e da dificuldade em jogo vale na hora (a coluna é aplicada em `Game.night_config`); as outras valem quando aquela noite for jogada. A coluna da noite em jogo tem "▶" no cabeçalho, e a célula diferente da noite anterior fica laranja.
- As edições ficam no `BalanceService` até fechar o jogo: sobrevivem a "Recomeçar a noite" e à noite seguinte. "Salvar" grava a tabela mostrada em `config/balance/<id>.json` quando o jogo roda pelo editor. No executável de debug exportado, onde o `res://` é só leitura, grava uma cópia local em `user://balance/<id>.json` (`%APPDATA%/Godot/app_userdata/the-beacon/balance/`), que vale por cima da do projeto até "Apagar cópia local"; a aba mostra o caminho quando está usando a cópia. Para levar os valores ao projeto, copie o arquivo por cima de `config/balance/<id>.json`. "Descartar alterações" volta ao arquivo. O topo do painel avisa quais tabelas têm alterações não salvas.
- "Copiar para as noites seguintes" repete a última célula editada ou focada nas noites à direita.
- Campos com `*` são copiados pelos sistemas ao montar a noite e só valem em "Recomeçar a noite": capacidade, enchimento e despejo do galão; todo o `repair`; tempo do trinco; toda a `flashlight` (`BalanceTab.RESTART_ONLY`). `boat.crossing_seconds` vale a partir do próximo barco. A bateria da lanterna passa de uma noite para a outra: `flashlight.battery_seconds` só conta na primeira noite de um plantão novo.
- "Recomeçar a noite" (aba Noite) recarrega a noite atual com o mesmo `RunState` (`SceneRouter.play_night`).
- "Ir para a noite" (aba Noite) carrega a noite escolhida do plantão (de 1 até o total), com os valores da tabela daquela noite e o estado que passa entre noites (pontos de Afogado, mangueira, bateria) como estava no começo da noite atual.

## Sinais
- `DebugPanel.opened_changed(opened)` → `Game` → `Player.set_controls_enabled`.
- `DebugPanel.restart_night_requested` (repassado do `NightTab`) → `Game` → `SceneRouter.play_night`.
- `DebugPanel.night_jump_requested(night)` (repassado do `NightTab`) → `Game` → `RunState.go_to_night` e `SceneRouter.play_night`.

## Testes
- `test/unit/config_fields_test.gd`: campos, faixas, grupos e seções.
- `test/unit/balance_table_test.gd` e `test/unit/balance_service_test.gd` (tabela por noite, leitura, gravação e descarte).
- `test/unit/balance_labels_test.gd`: toda linha das três dificuldades tem nome; sem nome sobrando nem repetido.
- `test/unit/night_clock_test.gd` (hora definida) e `test/unit/event_director_test.gd` (disparo manual).
- `test/unit/fog_state_test.gd` (limiares, `force_advance`, `clear`).
- `test/unit/flashlight_battery_test.gd` (bateria infinita).
- `test/unit/interior_lights_test.gd` (escala a energia a partir da cena, sem acumular).
- `test/unit/fullbright_view_test.gd` (troca e devolve o ambiente da câmera sem alterar o original; sem câmera ou sem ambiente, não faz nada).
- `test/unit/failure_state_test.gd` (`skip_cooldown`) e `test/unit/generator_state_test.gd` (`set_fuel_ratio`).
- `test/scenes/debug_panel_test.gd`: abrir, pausar o `World`, fechar com Esc sem abrir a pausa; não abrir com o painel desabilitado; célula da noite em jogo muda os valores vivos e a de outra noite não; a aba Noite pede outra noite; comandos de barcos, Afogado, carranca e jogador.
