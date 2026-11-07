# Status

## Onde paramos
- **Entrega 1** implementada (commits `557cab9` e `ce2214a`): core loop e meta-jogo com placeholders. O playtest dela foi descartado, porque a entrega 2 muda os sistemas.
- **Entrega 2 implementada** (`planos/entrega-2.md`, fases A a G, um commit por fase), revisão das mecânicas após reunião com o game designer:
  - **A** — noites por recarga de cena a partir do `RunState`; save só entre noites; menu de pausa no lugar da agenda (decisões 0014–0017).
  - **B** — controle e teclado; pulo no lugar de agachar; queda média bloqueia a corrida; bateria em barra; cadeira.
  - **C** — cabine sem janelas; casa de máquinas e câmara da lâmpada; farol operando/aceso; gerador principal pela mangueira e de emergência pelo galão; galão com física; mangueira que estoura sem conserto.
  - **D** — nevoeiro com avanço e estágios, visual por volumes de shader; bloqueio do feixe; panorama do mar; barcos reescritos (sem pirata).
  - **E** — alçapão com trinco que liga e desliga; porta só arrombada; Afogado que se aproxima com o nevoeiro dentro, entra uma vez e caça até o fim da noite.
  - **F** — carranca no lugar do Homem de Nevoeiro: armadilha imóvel que cega e derruba; a lanterna a dissolve.
  - **G** — tutorial com passos novos (nevoeiro perto, alçapão, Afogado se aproximando) e teclas como marcadores `{ação}`; controles remapeáveis com página própria nas configurações (decisão 0018); prompts e tutorial mostram a tecla do dispositivo em uso; voltar com Esc/B em todos os menus; limpeza (som do pirata) e `validate()` das dificuldades ampliado.
- Iluminação provisória mais clara em `game/game.tscn` só para testes.
- **Farol cônico** (experimento, a avaliar jogando): raio interno de 6,5 m no chão (1,3x o original) a 5,5 m na cabine (1,1x), com a cabine em y=10,8 (1,2x a altura anterior), escada de 0,9 volta e 8,4 m seguindo a parede, porta e alçapão alinhados e cada passagem como uma cena só, com o buraco na raiz (decisão 0019). Objetos internos continuam onde estavam: o espaço novo está livre para organizar.
- **Correções do playtest**: o galão agora pode ser pego no slot (o ponto de devolução desativado bloqueava o raio de interação). O nevoeiro externo ficou mais alto e esvaece nas bordas; o interno não mudou (decisão 0020).
- **Documentação do código**: toda função fora de `test/` e `addons/` tem `##`, e o check reprova função sem ele (decisão 0021). O check não avalia se o texto está certo: isso fica para a revisão.

## Próximo passo
Playtest da entrega 2: montar o roteiro a partir da lista abaixo, jogar e balancear. Depois, arte e áudio finais.

Validar jogando (por fase):
- **Farol cônico**: sem frestas em volta da porta e do alçapão (conferência visual, sem teste automático); leitura da porta vertical na parede inclinada; andar rente à parede na escada; enquadramento da câmera da porta e das câmeras do mar; nevoeiro no anel e nos volumes internos; arrombamento (folha não atravessa a parede); iluminação da cabine; trecho alto da escada, onde a queda já é fatal (acima de 6 m); ritmo com a subida mais longa do jogador e do Afogado.
- **A**: Esc pausa e solta o mouse; Continuar e Configurações na pausa; Sair para o menu deixa Continuar desabilitado; fim de noite → Salvar e sair → Continuar começa a noite seguinte; Próxima noite recarrega com o farol consertado e o nevoeiro limpo.
- **B**: altura do pulo; velocidade do olhar no analógico direito (`stick_look_degrees_per_second`); L2 corre; borda vermelha e corrida bloqueada depois de cair do meio da escada; barra da bateria legível; sentar na cadeira, alcance dos monitores e do rádio sentado, limite do olhar (75°) e levantar.
- **C**: leitura da cabine (casa de máquinas, câmara da lâmpada, gerador de emergência, alavanca); volante e zumbido com o farol operando; conserto da casa de máquinas e troca da lâmpada; subir a escada com o galão, despejar no gerador de emergência, física do galão solto (chão e escada), devolver ao slot e ver o medidor encher. `FuelTank.debug_burst_on_start` estoura a mangueira desde o início.
- **D**: legibilidade do nevoeiro nas três câmeras e dentro do farol; altura e bordas da faixa no mar; base da faixa no mar e divisão entre os dois monitores; barcos fora do nevoeiro legíveis na neblina de `NEAR`; tempo até surgir com o farol parado (45 s) e ritmo de avanço; travessia de 12 s no panorama; rádio só com nevoeiro; atender com o feixe aceso desvia; barco que entra no nevoeiro afunda. Premissa: o nevoeiro que cresce por cima de um barco também o afunda.
- **E**: barulho de aproximação na porta; arrombamento; perseguição e morte; trinco ligado → bate, cansa, descansa e volta; trinco desligado → abre o alçapão e sobe; nevoeiro no alçapão destranca; barra de 0,8 s do trinco. Atalho: `DrownedDirector.add_drowned_point` e farol parado.
- **F**: susto da carranca (pulo a 3 m), cegueira de 4 s, derrubada de 3 s na terceira vez, dissolução pela lanterna (0,3 s), pontos de surgimento parecem aleatórios e escondidos, ritmo (12 s entre aparições, volta em 40 s).
- **G**: textos do tutorial com as teclas certas no teclado e no controle (o prompt troca ao usar o outro dispositivo); remapear tecla e botão, conflito vira troca, Esc cancela a espera, "Restaurar padrão", gravar e reabrir o jogo; navegar todos os menus só com o controle, B voltando uma página.

## Bloqueios
- Nenhum. Observações:
  - `project.godot` aponta `config/icon="res://icon.svg"`, que não existe.
  - O check não acusa avisos do GDScript.
  - O bake da navmesh avisa no console que lê malhas visuais do CSG (custo só na abertura; decisão 0009).
  - Saves e progresso ficam em `user://` (`%APPDATA%/Godot/app_userdata/the-beacon/`). Para testar o desbloqueio do zero, apague `progress.json`. Rodar `game.tscn` direto ou os testes de cena apaga o save de partida (começar a noite consome o save).
  - Afogado: se o alçapão fechar com ele em cima e o jogador fora do alcance, ele pode ficar preso tentando descer pelo painel fechado.
  - Mover a porta não leva `DoorInside`, a câmera da porta nem as fendas acima dela (decisão 0019).
  - `game.gd` está com ~150 linhas de código, abaixo do alerta de ~200 (decisão 0021), mas continua concentrando a fiação da noite: responsabilidade nova deve nascer em componente próprio.
