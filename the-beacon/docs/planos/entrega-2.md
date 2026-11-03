# Plano — Entrega 2: revisão das mecânicas

- **Origem**: reunião com o game designer (`../notes/anotacao.txt`) e esclarecimentos com o desenvolvedor (2026-11).
- **Status**: aprovado (2026-11). Um commit ao fim de cada fase.
- **Fora deste plano**: piratas (só documentação), tela única de câmeras com frequências do rádio (`../notes/anotacao-ver-ainda.txt`), aumento de consumo por noite, menu "natural" dentro do jogo.

## Objetivo

O que muda para quem joga:

- A cabine (andar de cima) não tem janelas: o mar só é visto pelos monitores, agora com duas câmeras de mar lado a lado.
- O farol gira pela **casa de máquinas** (na cabine). O feixe sai de cima do telhado. Lâmpada e casa de máquinas quebram ao acaso, têm conserto e um intervalo mínimo entre quebras. A alavanca continua.
- O combustível só vira problema depois que a **mangueira estoura** (sem conserto). A partir daí, o jogador leva o galão do tanque (térreo) ao gerador de emergência (cabine) e o devolve ao slot, que o enche aos poucos.
- O **nevoeiro** avança em estágios enquanto o farol está parado: mar → câmera da porta → térreo → escada → alçapão → cabine. Perto do farol, ele bloqueia o feixe. Dentro do farol, ele libera o Afogado e as carrancas.
- **Barcos** só pedem aviso quando há nevoeiro. Avisado pelo rádio com o farol aceso, o barco para e desvia. Se não for avisado e entrar no nevoeiro, afunda na hora.
- O **Afogado** é a condição de morte: com o nevoeiro dentro do farol, um barulho cresce e, no máximo, ele arromba a porta. Fica até o fim da noite.
- A **carranca** substitui o Homem de Nevoeiro: uma armadilha imóvel que cega o jogador e, depois de algumas vezes, o derruba.
- O jogador **pula** e não agacha mais. Uma queda média bloqueia a corrida. Há suporte a controle e remapeamento.
- O menu de pausa no **Esc** substitui a agenda. Só dá para **salvar entre noites**, e sair no meio da noite perde a partida.

## Modelo dos sistemas (vocabulário padronizado)

Usar estes nomes em código, docs e conversa.

### Estrutura

| Nome | Código | Onde | Papel |
|---|---|---|---|
| Térreo | — | y=0 | Tanque, slot do galão, gerador principal, porta de entrada |
| Cabine | — | y=9, sem janelas | Mesa (3 monitores, rádio), cadeira, casa de máquinas, gerador de emergência, alçapão, alavanca |
| Tanque de combustível | `FuelTank` | Térreo | Reserva infinita. Alimenta o gerador principal pela mangueira. Tem o slot do galão |
| Mangueira | parte do `FuelTank` | Térreo | Inteira: o gerador principal funciona sozinho. Estourada (uma vez, sem conserto): o gerador principal para de vez |
| Slot do galão | `JerrycanSlot` | No tanque | Pegar e devolver o galão. Devolvido, ele enche em `jerrycan_slot_fill_seconds` (~120 s), com medidor de nível do galão |
| Galão | `Jerrycan` | Solto no mundo | Corpo com física. R solta. Usar uma interação de mãos livres também o solta |
| Gerador principal | `Generator` (instância `MainGenerator`) | Térreo | Fonte de energia enquanto a mangueira está inteira. Não quebra, não tem medidor nem boca de combustível |
| Gerador de emergência | `Generator` (instância `EmergencyGenerator`) | Cabine, ao lado da casa de máquinas | Fonte de energia depois que a mangueira estoura. Tem combustível, medidor e boca para o galão |
| Casa de máquinas | `MachineHouse` | Cabine | Gira o farol. Quebra ao acaso e tem conserto. Uma tubulação vertical vai dela até o telhado |
| Câmara da lâmpada | parte da `MachineHouse` | Na tubulação, com portinha | Onde se troca a lâmpada |
| Feixe | `LighthouseLamp` (cabeça no telhado) | Acima do telhado | Luz giratória |
| Alavanca | `BeamControl` | Cabine | Liga e desliga o farol |

**Energia** alimenta só a casa de máquinas e a lâmpada. Relógio, luzes, monitores e rádio funcionam sem energia (provisório, até o game designer definir).

**Farol operando** = alavanca ligada + energia + lâmpada inteira + casa de máquinas inteira.
**Feixe aceso** = farol operando + nevoeiro sem bloquear.

### Nevoeiro: um único avanço com estágios

Um valor `advance` de 0 a 1, com limiares em `FogConfig`:

| Estágio | O que acontece |
|---|---|
| `NONE` | Sem nevoeiro |
| `SEA` | Cobre um trecho da rota dos barcos (nunca a rota inteira: `max_route_coverage` < 1). Fica mais denso e cobre mais o mar com o tempo, o que aumenta a urgência |
| `NEAR` | Aparece também na câmera da porta. **Bloqueia o feixe** |
| `GROUND_FLOOR` | Invadiu o farol. Na primeira vez, estoura a mangueira. Começa a aproximação do Afogado. Carrancas no térreo |
| `STAIRS` | Sobe a escada. Carrancas na escada |
| `TRAPDOOR` | Destranca o trinco e impede trancar de novo |
| `CABIN` | Toma a cabine. Carrancas na cabine |

Dinâmica:

- **Surge** pelo evento `fog` (no estágio `SEA`) ou quando o farol fica sem operar por mais de `idle_grace_seconds`.
- Com o farol operando, fica no mar e se adensa até `sea_max_advance`. Ao fim da duração sorteada, recua até sumir.
- Com o farol parado, avança a `advance_per_second` até 1.
- Quando o farol volta a operar com o nevoeiro em `NEAR` ou acima, ele segue bloqueando o feixe por `unblock_seconds` e então recua até `recede_to_advance`. Abaixo de `NEAR`, para de avançar.

### Barcos e rádio

- O barco atravessa a rota em `crossing_seconds` (12 s), visível nas duas câmeras do mar. No máximo `max_simultaneous_boats` (1) ao mesmo tempo.
- Sem nevoeiro, o rádio não toca e o barco passa.
- Com nevoeiro, o rádio toca. Atender com o **feixe aceso** faz o barco parar e desviar; com o feixe apagado, ele segue em frente. Um atendimento vale para todos os barcos que estão chamando.
- Se o barco entra no trecho de nevoeiro sem ter desviado, afunda na hora e soma 1 **ponto de Afogado**.
- A lógica de pirata é removida.

### Afogado

- **Aproximação** (`DrownedApproach`): um medidor de 0 a 1 que sobe enquanto o nevoeiro está em `GROUND_FLOOR` ou acima e há pontos de Afogado. A taxa é `approach_base_per_second + approach_per_point × pontos`. Com o nevoeiro fora do farol, o medidor desce. O barulho (posicional, vindo da porta) acompanha o medidor.
- Com o medidor cheio, ele **arromba a porta** (no MVP: só som e a porta abrindo e voltando, sem a animação de mola) e aparece do lado de dentro. É no máximo um por noite e ele não sai mais, mesmo que o nevoeiro recue. Com 0 pontos, não aparece.
- **Dentro**: persegue o jogador ao alcance (regras de percepção atuais) e mata ao tocar. Fora do alcance, vai ao alçapão e bate:
  - trinco ligado: bate por `tire_seconds`, cansa, fica no térreo por `rest_seconds` e volta a bater;
  - trinco desligado: abre o alçapão depois de `resistance_seconds`, sobe e persegue.
- Não sabota nada.

### Alçapão e trinco

- Estados `CLOSED` e `OPEN`. O estado `BROKEN` sai.
- O trinco liga e desliga com tempo de carga `latch_toggle_seconds` (0 = toque, sem barra).
- O nevoeiro em `TRAPDOOR` destranca o trinco. Só é possível trancar de novo depois de o nevoeiro recuar e passar `latch_relock_cooldown_seconds`.
- Aberto pelo Afogado, o alçapão só pode ser fechado depois de `reclose_cooldown_seconds`.

### Carranca (`Figurehead`, substitui `FogMan`)

- Surge só nas áreas já tomadas pelo nevoeiro (térreo, escada, cabine), em pontos aleatórios: fora da vista do jogador e a mais de `min_spawn_distance`, para não serem decoráveis. No máximo `max_simultaneous` (3).
- É imóvel e translúcida. Com o jogador dentro de `trigger_range` e com linha de visão, ela pula: cega por `blind_seconds` e some.
- Depois de `blinds_before_knockdown` cegueiras na noite, o ataque seguinte **derruba**: o jogador ajoelha e não se move por `knockdown_seconds` (3 s).
- Iluminada pela lanterna por `dissolve_seconds` (alguns ms), se dissolve.
- Volta a surgir depois de `respawn_after_destroyed_seconds` (se foi destruída) ou `respawn_after_attack_seconds` (se atacou). Os dois parâmetros começam com o mesmo valor.
- Some quando o nevoeiro recua da área onde está.

### Jogador e controles

| Ação | Teclado | Controle |
|---|---|---|
| Mover / olhar | WASD / mouse | Analógico esquerdo / direito |
| `jump` | Espaço | A |
| `sprint` | Shift | L2 |
| `interact` | E | Y |
| `toggle_flashlight` | Q | X |
| `check_battery` (segurar) | X | D-pad cima |
| `drop_item` | R | B |
| `pause` | Esc | Start |

- `crouch` sai.
- Queda média bloqueia a corrida por `sprint_block_seconds` (30 s), com a borda vermelha na tela. A queda fatal continua.
- A bateria aparece como barra, e conferir continua sendo "segurar para ver".
- **Cadeira**: interagir senta. O olhar fica livre dentro de um limite. Qualquer tecla de movimento ou o pulo levanta.

### Partida, noites e save

- **Persistem entre noites** (`RunState`): dificuldade, noite atual, pontos de Afogado, mangueira estourada, bateria da lanterna e passos do tutorial já mostrados.
- **Todo o resto reseta**: cada noite recarrega a cena de jogo a partir do `RunState` (decisão 0015).
- **Fim de noite**: tela com "Próxima noite" e "Salvar e sair". Na última noite, vitória.
- **Save**: só "Salvar e sair" grava (só o `RunState`). Continuar começa a noite seguinte e **apaga o save ao começar a noite**. Por isso sair pelo menu, fechar o jogo ou dar Alt+F4 no meio da noite perde a partida, e Continuar fica desabilitado.
- **Pausa**: Esc pausa e abre Continuar, Configurações e "Sair para o menu", que avisa que a partida será perdida.

## Decisões a registrar

| Nº | Título | Substitui |
|---|---|---|
| 0014 | Save só entre noites, com o `RunState` | 0011 (o `SaveService` e os dois arquivos continuam; sai o `RunSnapshot`) |
| 0015 | Cada noite recarrega a cena de jogo a partir do `RunState`; só o estado persistente exige `to_dict`/`from_dict` | 0008, nos itens "uma única cena" e "toda classe de estado serializável" |
| 0016 | Menu de pausa no Esc com pausa real; a agenda sai do MVP | — (contradiz o GDD "sem pausa"; registrar) |
| 0017 | Modelo de energia: gerador principal pela mangueira e gerador de emergência pelo galão | — (registra a alternativa de um gerador só como descartada, para retomar se fizer sentido) |
| 0018 | Controles remapeáveis no `Settings` (`settings.cfg`) | Amplia 0012 |

## Arquivos

### Criar

| Arquivo | Propósito |
|---|---|
| `docs/decisoes/0014` … `0018` | Decisões acima |
| `machine_house/machine_house.tscn`, `.gd`, `machine_house_state.gd` | Casa de máquinas, tubulação, câmara da lâmpada; quebra, conserto, cooldown |
| `fuel/fuel_tank.tscn`, `.gd` | Tanque infinito, mangueira (estoura, sem conserto), slot. Substitui `reserve_tank` |
| `fuel/jerrycan.tscn`, `.gd` | Galão `RigidBody3D`: pegar, soltar, arremessar leve |
| `fuel/jerrycan_slot.tscn`, `.gd`, `jerrycan_slot_state.gd` | Encher aos poucos e medidor. Substitui `jerrycan_dock` |
| `fog/fog_stage.gd` | Enum e limiares de estágio (puro) |
| `fog/fog_visuals.gd` | Faixas de nevoeiro falso (malhas translúcidas com shader) no mar, na porta e por área interna |
| `drowned/drowned_approach.gd` | Medidor de aproximação (puro) |
| `figurehead/*` | Renomeado de `fog_man/*` (`git mv`, junto com os `.uid`) |
| `figurehead/figurehead_spawn_rules.gd` | Escolha de ponto aleatório fora da vista e longe do jogador (puro) |
| `player/chair.tscn`, `.gd` | Cadeira e ponto de vista sentado |
| `player/sprint_block.gd` | Regra do bloqueio da corrida (pura), ou dentro de `FallRules` |
| `ui/pause_menu/pause_menu.tscn`, `.gd` | Menu de pausa |
| `ui/settings/controls_panel.tscn`, `.gd`, `autoload/input_bindings.gd` | Remapeamento (regras de conflito puras) |
| `config/machine_house_config.gd`, `config/figurehead_config.gd` | Configs novas |
| `config/events/machine_breakdown.tres` | Evento de quebra da casa de máquinas |
| Testes | Ver seção Testes |

### Alterar (principais)

| Arquivo | Mudança |
|---|---|
| `game/run_state.gd` | Campos persistentes e `to_dict`/`from_dict` |
| `game/game.gd` | Monta a noite a partir do `RunState`; fim de noite recolhe o estado persistente; sem agenda nem snapshot. A fiação nova vai para componentes, porque o arquivo já tem ~195 linhas |
| `autoload/scene_router.gd`, `run_request.gd`, `save_service.gd` | `start_night(run)`; save = `RunState`; `SAVE_VERSION` sobe |
| `ui/night_end/*`, `ui/main_menu/*` | "Próxima noite" / "Salvar e sair"; Continuar |
| `lighthouse/lighthouse.tscn`, `.gd` | Cabine sem janelas; casa de máquinas, gerador de emergência, cadeira, 3º monitor; feixe no telhado; fiação nova de energia |
| `lighthouse/trapdoor.gd`, `trapdoor_resistance.gd` | Sem `BROKEN`; trinco liga/desliga; cooldowns |
| `lighthouse/entrance_door.gd` | Sem quebra nem conserto; arrombamento (som e porta abrindo e voltando); sem a parede `player_bounds` do vão |
| `power/generator.gd`, `generator_state.gd` | Sem quebra; modo "alimentado pela mangueira" ou "por combustível" |
| `beam/beam_state.gd`, `lighthouse_lamp.gd` | Operando e aceso; lâmpada com cooldown; cabeça no telhado |
| `fog/fog_state.gd`, `fog_system.gd` | Reescrita: avanço e estágios |
| `boats/boat_passage.gd`, `boat_director.gd`, `radio.gd` | Reescrita: travessia, trecho de nevoeiro, desvio, N barcos, sem pirata |
| `exterior/exterior.tscn`, `.gd` | Segunda câmera de mar; sem `DrownedSpawns`; sai do grupo `navigation_source` |
| `drowned/drowned_brain.gd`, `drowned_director.gd`, `drowned.gd` | Entrada pela porta, perseguir, bater, cansar, descansar |
| `player/player.gd`, `fall_rules.gd`, `fall_damage.gd`, `flashlight.gd`, `interaction_ray.gd` | Pulo; sem agachar; bloqueio de corrida; barra; derrubada; sentar; soltar o galão ao usar `HandsRule.FREE` |
| `autoload/settings.gd`, `settings_state.gd`, `ui/settings/settings_panel.*` | Página de controles |
| `project.godot` | Input map (acima, com controle); camada 8 `props` (galão) |
| `config/*.gd`, `config/difficulties/*.tres` | Configs novas e removidas; `validate()` |
| `tutorial/*` | Passos novos: casa de máquinas, mangueira e galão, nevoeiro perto, Afogado se aproximando, carranca, trinco |
| `docs/arquitetura.md`, `docs/sistemas/*.md` | Junto com cada passo |

### Remover

`agenda/` (inteira), `game/agenda_controller.gd`, `game/run_snapshot.gd`, `player/view_focus.gd` (se a cadeira não o reaproveitar), `fuel/reserve_tank*`, `fuel/jerrycan_dock*`, `drowned/threat_rules.gd`, `config/threat_config.gd`, `config/events/generator_breakdown.tres`, `hose_rupture.tres`, `assets/audio/placeholder/radio_pirate.wav`, `docs/sistemas/agenda.md`, e o `to_dict`/`from_dict` das classes que deixam de persistir.

## Cenas, nós e sinais (novos ou alterados)

- `Game`:
  - recebe `RunState` → configura sistemas;
  - `NightDirector.night_ended` → recolhe `pontos`, `hose_broken` e `battery` → vitória ou `NightEndScreen`.
- Energia (no `Lighthouse`):
  - `FuelTank.hose_burst` → `MainGenerator` para e o `EmergencyGenerator` assume;
  - energia → `MachineHouse.set_powered`, `LighthouseLamp.set_powered`.
- Farol: `MachineHouse.broken_changed`, `LighthouseLamp.burned_changed`, `BeamControl.switched` → `Lighthouse.beam_operational_changed` → `FogSystem.set_beam_operational`.
- Nevoeiro:
  - `FogSystem.stage_changed(stage)` → `Lighthouse` (bloqueio do feixe, estouro da mangueira, trinco), `Exterior` e visuais, `DrownedDirector`, `FigureheadDirector`;
  - `FogSystem.route_fog_changed(start, end)` → `BoatDirector`.
- Barcos:
  - `Lighthouse.beam_lit_changed` → `BoatDirector`;
  - `BoatDirector.calling_changed(calling)` → `Radio.ring`/`stop_ringing`;
  - `Radio.answered` → `BoatDirector.warn_calling_boats()`;
  - `BoatDirector.boat_sank` → `DrownedDirector.add_drowned_point`.
- Afogado: `DrownedDirector.approach_changed(ratio)` (som), `drowned_entered` → `EntranceDoor.burst_open()`.
- Carranca: `FigureheadDirector.player_blinded(seconds)` → `Hud.show_blindness`; `player_knocked_down(seconds)` → `Player.knock_down`.
- Jogador: `Player.sprint_blocked_changed(active)` → `Hud.set_hurt_border` (substitui `slowed_changed`).
- Pausa: ação `pause` → `PauseMenu` (`process_mode = WHEN_PAUSED`) → `get_tree().paused`.

## Testes

Unitários (`test/unit/`):

| Arquivo | Cobertura |
|---|---|
| `run_state_test` | Campos persistentes; ida e volta do save |
| `fog_state_test` (reescrito) | Surgimento por evento e por farol parado; adensamento no mar com teto; avanço; bloqueio desde `NEAR`; espera de desbloqueio e recuo; estágios e limiares; cobertura da rota < 1 |
| `boat_passage_test` (reescrito) | Sem nevoeiro passa; afunda ao entrar no trecho; aviso com feixe aceso desvia; com feixe apagado segue; N barcos |
| `machine_house_state_test`, `beam_state_test` | Quebra, conserto, cooldown; operando e aceso |
| `generator_state_test` | Modo mangueira (sem consumo) e modo combustível (consumo só com a alavanca ligada) |
| `jerrycan_slot_state_test` | Enche em ~120 s, nível, pegar e devolver |
| `trapdoor_rules_test` | Trinco com carga 0 e > 0; destrancado pelo nevoeiro e cooldown; aberto pelo Afogado e cooldown para fechar; resistência só destrancado |
| `drowned_approach_test` | Sobe só com nevoeiro dentro e pontos > 0; taxa por ponto; desce; entra uma vez |
| `drowned_brain_test` (reescrito) | Persegue, bate, cansa, descansa, volta; nunca sai |
| `figurehead_tracker_test`, `figurehead_spawn_rules_test` | Limite 3; cooldowns separados; contagem → derrubada; dissolução; só em área com nevoeiro; fora da vista e longe |
| `fall_rules_test` | Queda média → bloqueio; fatal |
| `input_bindings_test` | Conflitos, padrão, ida e volta |

Cena (`test/scenes/`), no máximo um por mecânica:

| Arquivo | Cobertura |
|---|---|
| `night_transition_test` (reescrito) | Fim da noite 1 → próxima noite: pontos e mangueira mantidos; casa de máquinas, nevoeiro, galão e posição resetados |
| `save_restore_test` (reescrito) | Salvar e sair → Continuar começa a noite 2 com o estado persistente e o save some |
| `player_test` | Pulo (altura em faixa); queda média bloqueia a corrida |

Game feel a validar jogando: altura do pulo, física do galão na escada, susto da carranca, legibilidade do nevoeiro nas câmeras, tempo de 12 s da travessia, barulho do Afogado.

## Passos

Cada passo termina com `check.ps1 -Fix -Fast` e com a nota do sistema atualizada. O check completo roda no fim de cada fase.

### Fase A — Fundação: noites, save e pausa

1. Escrever as decisões 0014–0017 e marcar 0008 e 0011 como substituídas nas partes afetadas.
2. `RunState` com os campos persistentes e testes.
3. Noite por recarga: `SceneRouter.start_night(run)`, `Game` montado pelo `RunState`, fim de noite recolhendo o estado, `NightEndScreen` com "Próxima noite" e "Salvar e sair", Continuar, save apagado ao começar a noite. Reescrever `night_transition_test` e `save_restore_test`.
4. Remover `RunSnapshot`, a serialização do meio da noite e o `clear()` entre noites que deixou de ser usado.
5. Menu de pausa no Esc. Remover a agenda e o Esc de depuração do mouse.

### Fase B — Jogador

6. Input map novo, com teclado e controle; analógico direito para olhar.
7. Pulo; remover agachar.
8. Queda média bloqueia a corrida, com borda vermelha.
9. Bateria em barra.
10. Cadeira: sentar, olhar com limite, levantar.

### Fase C — Cabine e energia

11. Greybox da cabine: sem janelas, casa de máquinas com tubulação até o telhado, câmara da lâmpada, gerador de emergência, cadeira, terceiro monitor; feixe no telhado.
12. Casa de máquinas (estado, evento `machine_breakdown`, conserto, cooldown) e feixe operando/aceso. Cooldown da lâmpada. Remover a quebra do gerador.
13. Energia: gerador principal pela mangueira, gerador de emergência por combustível; energia só para casa de máquinas e lâmpada.
14. Galão com física, slot que enche em ~120 s com medidor, R solta, interação de mãos livres solta. Tanque infinito.
15. Mangueira que estoura sem conserto (`Lighthouse.burst_hose()`), persistida no `RunState`. Remover o evento `hose_rupture`, o vazamento e o conserto.

### Fase D — Nevoeiro e barcos

16. `FogState` reescrito com avanço e estágios, e testes.
17. Visual do nevoeiro: faixa no mar (trecho da rota), na câmera da porta e por área interna.
18. Fiação: bloqueio do feixe, estouro da mangueira na primeira invasão, trinco (preparado para a fase E).
19. Segunda câmera e segundo monitor do mar, em panorama.
20. Barcos reescritos: travessia de 12 s, trecho de nevoeiro, rádio só com nevoeiro, desvio, N barcos, sem pirata.

### Fase E — Alçapão, porta e Afogado

21. Alçapão sem `BROKEN`, trinco liga/desliga com carga, destrancamento pelo nevoeiro, cooldowns.
22. Aproximação do Afogado (medidor e som), arrombamento da porta e entrada por dentro. Remover ameaça, sabotagem e surgimento no exterior; navmesh só do interior.
23. Cérebro do Afogado reescrito: perseguir, bater, cansar, descansar.

### Fase F — Carranca

24. Renomear `FogMan` → `Figurehead`, só a renomeação.
25. Regras: limite, cooldowns, contagem até a derrubada, dissolução, pontos aleatórios em área com nevoeiro.
26. Cena: imóvel e translúcida, gatilho por proximidade com linha de visão, salto, dissolução pela lanterna. `Player.knock_down`.

### Fase G — Tutorial, controles e fechamento

27. Tutorial: passos e textos novos; remover os obsoletos.
28. Remapeamento (decisão 0018): página de controles no `SettingsPanel`, persistência e menus navegáveis por controle.
29. Limpeza de configs, eventos e áudios órfãos; `validate()` das dificuldades; `arquitetura.md` e `status.md`.

## Premissas a validar no playtest

Decididas no planejamento sem confirmação explícita. Fáceis de mudar.

- O desvio do barco é decidido no momento do atendimento. Atendido com o feixe apagado, o rádio para de tocar e o barco segue.
- Com a alavanca desligada, o gerador de emergência não gasta combustível, mas o nevoeiro avança.
- O tutorial não repete os passos já mostrados nas noites seguintes.
- A tela de fim de noite não tem "Menu sem salvar": as opções são próxima noite ou salvar e sair.
- O trinco só volta a trancar depois de o nevoeiro sair do estágio `TRAPDOOR` e passar o cooldown.

## Alternativas descartadas

- **Manter uma única cena e resetar cada sistema entre noites**: exigiria um `reset()` correto em cada sistema e manteria dois caminhos diferentes (próxima noite e Continuar). Recarregar a cena torna os dois o mesmo caminho e garante o reset.
- **Um gerador só, que muda de alimentado pela mangueira para abastecido pelo galão**: é mais simples, mas o game designer quer o gerador de emergência na cabine, porque ele obriga a levar o galão escada acima. Fica registrado na decisão 0017.

## Riscos

- **Nevoeiro visual**: o projeto usa o renderizador Compatibility, sem `FogVolume` nem nevoeiro volumétrico. O nevoeiro em trechos e por área vai ser falso: malhas translúcidas com shader de ruído, mais a fog de profundidade das câmeras. Se ficar ruim, mudar o renderizador é uma decisão à parte (memória: no Windows, o driver tem que ser D3D12).
- **Recarga por noite**: a navmesh é assada de novo a cada noite (um travamento curto atrás da tela de transição). Qualquer estado esquecido fora do `RunState` some, o que é intencional, mas precisa de teste.
- **Galão com física na escada em caracol**: pode rolar, prender ou atravessar o chão. Mitigação: amortecimento alto e, fora dos limites, o galão volta ao slot.
- **Pulo**: alcança lugares novos e muda as quedas. Rever `min_user_height` do alçapão e as alturas de `FallConfig`.
- **Escopo**: quase todos os sistemas são reescritos. O playtest da entrega 1 fica obsoleto, e um novo roteiro sai no fim da fase G.
- O GDD (`../notes/gdd.md`) fica desatualizado em pulo, pausa, agenda, save e ameaças. Atualizá-lo é com o desenvolvedor.
