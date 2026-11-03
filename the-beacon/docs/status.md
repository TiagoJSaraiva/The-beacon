# Status

## Onde paramos
- **Entrega 1** implementada (commits `557cab9` e `ce2214a`): core loop e meta-jogo com placeholders. O playtest dela foi descartado, porque a entrega 2 muda os sistemas.
- **Entrega 2** (`planos/entrega-2.md`), revisão das mecânicas após reunião com o game designer:
  - **Fase A concluída** (passos 1–5): decisões 0014–0017; `RunState` com o estado persistente (pontos de Afogado, mangueira, bateria, tutorial); cada noite recarrega a cena (`SceneRouter.play_night`, `RunCarryover`); save só entre noites ("Salvar e sair" no fim de noite; começar a noite apaga o save); menu de pausa no Esc no lugar da agenda; serialização do meio da noite removida.
  - **Fase B concluída** (passos 6–10): input map com teclado e controle (analógico direito olha); pulo no lugar de agachar; queda média bloqueia a corrida por 30 s com a borda vermelha; bateria em barra no corpo da lanterna; cadeira na mesa da cabine (olhar limitado, mover ou pular levanta). `ViewFocus` removido.
  - **Fase C concluída** (passos 11–15): cabine sem janelas; casa de máquinas com tubulação até a cabeça do farol no telhado e câmara da lâmpada; farol "operando" e "aceso" (`BeamState`); lâmpada e casa de máquinas com intervalo mínimo entre quebras (`FailureState`, evento `machine_breakdown`); gerador principal pela mangueira e gerador de emergência por combustível, energia só para casa de máquinas e lâmpada; galão com física, slot que enche em 120 s, R solta; mangueira que estoura sem conserto (`RunState.hose_burst`, `SAVE_VERSION` 3). Saíram tanque de reserva, vazamento, consertos de mangueira e gerador, e `PowerConsumer`.
  - **Fase D concluída** (passos 16–20): nevoeiro com avanço e estágios (`FogState`, `FogStage`), que surge sozinho com o farol parado; volumes de nevoeiro falso por shader (`FogVisuals`) no mar, em volta do farol e por área interna; bloqueio do feixe a partir de `NEAR` e estouro da mangueira na primeira invasão; duas câmeras do mar em panorama e câmera da porta reapontada; barcos reescritos (12 s, rádio só com nevoeiro, desvio, vários barcos, sem pirata).
  - **Fase E concluída** (passos 21–23): alçapão aberto/fechado com trinco que liga e desliga, destrancado pelo nevoeiro, e intervalos para religar e para fechar (`TrapdoorRules`); porta sem quebra nem conserto, só arrombamento; Afogado que se aproxima com o nevoeiro dentro (`DrownedApproach`, barulho na porta), entra uma vez por noite e não sai, cérebro novo (perseguir, bater, cansar, descansar). Saíram ameaça, sabotagem, surgimento no exterior, `player_bounds` e a navmesh do exterior.
- Iluminação provisória mais clara em `game/game.tscn` só para testes.

## Próximo passo
Entrega 2, **fase F** (carranca): renomear `FogMan` → `Figurehead`, regras (limite, intervalos, derrubada, dissolução, pontos aleatórios no nevoeiro) e cena. Um commit ao fim de cada fase.
- Validar jogando a fase A: Esc pausa e solta o mouse; Continuar e Configurações na pausa; Sair para o menu deixa Continuar desabilitado; fim de noite → Salvar e sair → Continuar começa a noite seguinte; Próxima noite recarrega com o farol consertado e o nevoeiro limpo.
- Validar jogando a fase B: altura do pulo; velocidade do olhar no analógico direito (`stick_look_degrees_per_second`); L2 corre; borda vermelha e corrida bloqueada depois de cair do meio da escada; barra da bateria legível ao segurar X; sentar na cadeira, alcance dos monitores e do rádio sentado, limite do olhar (75°) e levantar.
- Validar jogando a fase C: leitura da cabine (casa de máquinas, câmara da lâmpada, gerador de emergência, alavanca); volante girando e zumbido com o farol operando; conserto da casa de máquinas e troca da lâmpada na portinha. Com `FuelTank.debug_burst_on_start` ligado no `lighthouse.tscn`: subir a escada com o galão, despejar no gerador de emergência, física do galão solto (chão e escada), devolver ao slot e ver o medidor encher.
- Validar jogando a fase D: legibilidade do nevoeiro nas três câmeras e dentro do farol (cor, densidade, esmaecimento); tempo até o nevoeiro surgir com o farol parado (45 s) e o ritmo de avanço; travessia de 12 s no panorama; rádio tocando só com nevoeiro; atender com o feixe aceso desvia o barco; barco que entra no nevoeiro afunda. Premissa: o nevoeiro que cresce por cima de um barco também o afunda.
- Validar jogando a fase E: barulho de aproximação na porta (volume e legibilidade); arrombamento; perseguição e morte; com o trinco ligado, ele bate, cansa, descansa no térreo e volta; com o trinco desligado, abre o alçapão e sobe; nevoeiro no alçapão destranca; barra de 0,8 s do trinco. Para chegar rápido: afundar um barco (ou `DrownedDirector.add_drowned_point`) e deixar o farol parado.
- Depois da entrega 2: novo roteiro de playtest, balanceamento e arte/áudio finais.

## Bloqueios
- Nenhum. Observações:
  - `project.godot` aponta `config/icon="res://icon.svg"`, que não existe.
  - O check não acusa avisos do GDScript.
  - O bake da navmesh avisa no console que lê malhas visuais do CSG (custo só na abertura; decisão 0009).
  - Saves e progresso ficam em `user://` (`%APPDATA%/Godot/app_userdata/the-beacon/`). Para testar o desbloqueio do zero, apague `progress.json`. Rodar `game.tscn` direto ou os testes de cena apaga o save de partida (começar a noite consome o save).
  - Os prompts da HUD mostram só a tecla do teclado (E), mesmo jogando no controle; resolver junto com o remapeamento (passo 28).
  - Interino até a fase F: o Homem de Nevoeiro nasce fora do farol e, sem navmesh no exterior, fica parado lá.
  - `game.gd` está com ~195 linhas: a próxima responsabilidade nova deve nascer em componente próprio.
