# Modo debug

## Propósito
Painel dentro do jogo para testar funções e balanceamento sem mexer no código (decisão 0024).

## Componentes
- `debug/debug_mode.gd` (`DebugMode`): `ENABLED` liga o modo; `is_active()` exige também build de debug.
- `debug/debug_panel.tscn` (`DebugPanel`, `CanvasLayer`, `process_mode = ALWAYS`): filho do `Game`, fora do `World`. Abas em `%Tabs`. Os sistemas chegam por `@export` e a dificuldade pelo `setup()` que o `Game` chama. No topo, a leitura de estado junta o `readout()` de cada aba.
- `debug/debug_tab.gd` (`DebugTab`): base das abas, que montam a interface em código (títulos, botões, valor com botão, caixas, linha de status).
- `debug/night_tab.gd` (`NightTab`): aba Noite.
- `debug/lighthouse_tab.gd` (`LighthouseTab`): aba Farol.
- `debug/fog_tab.gd` (`FogTab`): aba Nevoeiro.
- `debug/threats_tab.gd` (`ThreatsTab`): aba Ameaças.
- `debug/player_tab.gd` (`PlayerTab`): aba Jogador.
- `debug/fullbright_view.gd` (`FullbrightView`): "Sem escuridão" da aba Jogador.
- `debug/balance_tab.gd` (`BalanceTab`): aba Balanceamento.
- `debug/config_editor.gd` (`ConfigEditor`): linhas de um recurso (SpinBox para número, CheckBox para bool).
- `debug/config_fields.gd` (`ConfigFields`): regras puras: campos editáveis de um recurso, seções da dificuldade, diferenças e cópia.

## Regras
- Y (`debug_menu`) abre e fecha; Esc também fecha, sem abrir o menu de pausa. Não abre com o menu de pausa aberto nem fora da simulação (fim de noite, morte, vitória).
- Aberto, a simulação continua; o jogador fica travado e o mouse solto. "Pausar simulação" congela o `World` e é desfeita ao fechar.
- Noite: ir para uma hora (`NightClock.set_clock_hour`), velocidade do relógio (`NightDirector.debug_time_scale`), terminar a noite (leva o relógio às 06:00), recomeçar a noite, disparar cada evento registrado (`EventDirector.trigger_now`: respeita o `can_trigger` do sistema e não conta no máximo da noite) e ligar ou desligar o sorteio (`EventDirector.random_events_enabled`).
- Farol: queimar a lâmpada e quebrar a casa de máquinas mesmo no intervalo depois do conserto (`FailureState.skip_cooldown`), trocar e consertar, estourar a mangueira, definir o combustível do gerador de emergência (`GeneratorState.set_fuel_ratio`), encher e esvaziar o galão, inverter a alavanca (`BeamControl.toggle`) e o trinco (`Trapdoor.toggle_latch`, que segue as regras: nevoeiro, alçapão aberto, intervalo).
- Nevoeiro: surgir agora (só se ainda não surgiu), limpar (volta a antes de surgir, `FogState.clear`; o que ele já causou, como a mangueira estourada, continua), congelar o avanço (`FogSystem.frozen`), fixar o avanço (`FogState.force_advance`, sem recuo pendente) e ir para o começo de um estágio (`FogStage.threshold`). Também desloca a faixa no mar ao vivo (`FogVisuals.sea_band_offset`, um campo por eixo) e escreve no console o valor para copiar no `FogVisuals` da cena; a aba Balanceamento move o trecho da regra (`fog.route_center`).
- Ameaças: spawnar barco sem limite e afundar todos (cada um soma ponto de Afogado); +1 ponto, forçar a entrada, remover o Afogado e definir o nível de aproximação; invocar carranca a 4 m à frente do jogador (fora do alcance do pulo, 3 m), dissolver todas e zerar as cegueiras.
- Jogador: invulnerável (cobre Afogado e queda fatal), bateria infinita, encher a bateria (apaga a lanterna), tirar o bloqueio da corrida e teleportar para o ponto da navmesh mais perto da porta (dentro), de baixo do alçapão, da casa de máquinas, de cima do alçapão e da cadeira da cabine. "Força das luzes do farol" aplica `InteriorLights.light_scale` ao vivo. "Sem escuridão" troca o `Environment` da câmera do jogador (`Player.view_camera()`) por uma cópia com luz ambiente branca forte (as câmeras de segurança usam o do mundo) e devolve o original ao desmarcar.
- Balanceamento: uma seção por parte da dificuldade (`difficulty`, cada sub-config pelo nome da propriedade e `events/<id>`), gerada dos `@export` float, int e bool. `nights` e `tutorial_enabled` ficam de fora (o `RunState` já os copiou).
- A edição muda o recurso carregado em memória: vale na hora, nas noites seguintes e em plantões novos até fechar o jogo, e nunca é gravada em disco. Eventos são `.tres` compartilhados entre dificuldades, então a edição vale para todas.
- Campos com `*` são copiados pelos sistemas ao montar a noite e só valem em "Recomeçar a noite": capacidade, enchimento e despejo do galão; todo o `repair`; tempo do trinco; toda a `flashlight` (`BalanceTab.RESTART_ONLY`). `boat.crossing_seconds` vale a partir do próximo barco.
- "Exportar alterações" imprime no console `<seção>.<campo>: <original> -> <atual>`, comparando com o `.tres` lido de novo do disco. "Restaurar originais" volta a esses valores.
- "Recomeçar a noite" (aba Noite) recarrega a noite atual com o mesmo `RunState` (`SceneRouter.play_night`).

## Sinais
- `DebugPanel.opened_changed(opened)` → `Game` → `Player.set_controls_enabled`.
- `DebugPanel.restart_night_requested` (repassado do `NightTab`) → `Game` → `SceneRouter.play_night`.

## Testes
- `test/unit/config_fields_test.gd`: campos, faixas, grupos, seções, diferenças e cópia.
- `test/unit/night_clock_test.gd` (hora definida) e `test/unit/event_director_test.gd` (disparo manual).
- `test/unit/fog_state_test.gd` (limiares, `force_advance`, `clear`).
- `test/unit/flashlight_battery_test.gd` (bateria infinita).
- `test/unit/interior_lights_test.gd` (escala a energia a partir da cena, sem acumular).
- `test/unit/fullbright_view_test.gd` (troca e devolve o ambiente da câmera sem alterar o original; sem câmera ou sem ambiente, não faz nada).
- `test/unit/failure_state_test.gd` (`skip_cooldown`) e `test/unit/generator_state_test.gd` (`set_fuel_ratio`).
- `test/scenes/debug_panel_test.gd`: abrir, pausar o `World`, fechar com Esc sem abrir a pausa; não abrir com o painel desabilitado; comandos de barcos, Afogado, carranca e jogador.
