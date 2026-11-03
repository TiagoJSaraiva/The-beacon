# Status

## Onde paramos
- **Entrega 1** implementada (commits `557cab9` e `ce2214a`): core loop e meta-jogo com placeholders. O playtest dela foi descartado, porque a entrega 2 muda os sistemas.
- **Entrega 2** (`planos/entrega-2.md`), revisão das mecânicas após reunião com o game designer:
  - **Fase A concluída** (passos 1–5): decisões 0014–0017; `RunState` com o estado persistente (pontos de Afogado, mangueira, bateria, tutorial); cada noite recarrega a cena (`SceneRouter.play_night`, `RunCarryover`); save só entre noites ("Salvar e sair" no fim de noite; começar a noite apaga o save); menu de pausa no Esc no lugar da agenda; serialização do meio da noite removida.
  - **Fase B concluída** (passos 6–10): input map com teclado e controle (analógico direito olha); pulo no lugar de agachar; queda média bloqueia a corrida por 30 s com a borda vermelha; bateria em barra no corpo da lanterna; cadeira na mesa da cabine (olhar limitado, mover ou pular levanta). `ViewFocus` removido.
- Iluminação provisória mais clara em `game/game.tscn` só para testes.

## Próximo passo
Entrega 2, **fase C** (cabine e energia): greybox da cabine sem janelas, casa de máquinas, energia por mangueira e galão, galão com física, mangueira que estoura. Um commit ao fim de cada fase.
- Validar jogando a fase A: Esc pausa e solta o mouse; Continuar e Configurações na pausa; Sair para o menu deixa Continuar desabilitado; fim de noite → Salvar e sair → Continuar começa a noite seguinte; Próxima noite recarrega com o farol consertado e o nevoeiro limpo.
- Validar jogando a fase B: altura do pulo; velocidade do olhar no analógico direito (`stick_look_degrees_per_second`); L2 corre; borda vermelha e corrida bloqueada depois de cair do meio da escada; barra da bateria legível ao segurar X; sentar na cadeira, alcance dos monitores e do rádio sentado, limite do olhar (75°) e levantar. Conferir se o pulo deixa sair do farol por alguma janela ou vão.
- Depois da entrega 2: novo roteiro de playtest, balanceamento e arte/áudio finais.

## Bloqueios
- Nenhum. Observações:
  - `project.godot` aponta `config/icon="res://icon.svg"`, que não existe.
  - O check não acusa avisos do GDScript.
  - O bake da navmesh avisa no console que lê malhas visuais do CSG (custo só na abertura; decisão 0009).
  - Saves e progresso ficam em `user://` (`%APPDATA%/Godot/app_userdata/the-beacon/`). Para testar o desbloqueio do zero, apague `progress.json`. Rodar `game.tscn` direto ou os testes de cena apaga o save de partida (começar a noite consome o save).
  - Os prompts da HUD mostram só a tecla do teclado (E), mesmo jogando no controle; resolver junto com o remapeamento (passo 28).
  - `game.gd` está com ~195 linhas: a próxima responsabilidade nova deve nascer em componente próprio.
