# Status

## Onde paramos
- **Entrega 1 (core loop + meta-jogo com placeholders) implementada**: os 25 passos do plano (fases A–E). Falta o playtest do desenvolvedor.
- Fases A–D (commit `557cab9`): configs, jogador, interação, lanterna, greybox, relógio, gerador, combustível, feixe, falhas, exterior e câmeras, nevoeiro, barcos e rádio, Afogados, Homem de Nevoeiro, transição entre noites.
- **Fase E (meta-jogo)**:
  - Autoloads `SceneRouter`, `SaveService`, `Settings` (decisões 0010–0012). A Main Scene agora é o menu principal.
  - Menu, seleção de dificuldade com desbloqueio em sequência, configurações (volumes e sensibilidade), game over e plantão concluído (`sistemas/menus-e-telas.md`).
  - Agenda na mesa da torre, com olhar focado e páginas: configurações, salvar e sair, sair sem salvar com confirmação (`sistemas/agenda.md`).
  - Save completo no meio da noite e Continuar (`sistemas/save-e-progresso.md`).
  - Tutorial do Easy por gatilhos, com textos em `.tres` (`sistemas/tutorial.md`).
  - O parse do `check.ps1` agora é um script único com autoloads (decisão 0013, substitui a 0007).
- Iluminação provisória mais clara em `game/game.tscn` só para testes.

## Próximo passo
Playtest da entrega 1. Roteiro:
1. **Menu**: só Easy liberado; Continuar desabilitado sem save; Configurações muda volume e sensibilidade na hora e mantém depois de reabrir o jogo.
2. **Tutorial (Easy)**: os três textos iniciais em fila; cada situação nova mostra o texto uma vez só. Ver se 8 s (`message_seconds`) é bom e se o texto atrapalha.
3. **Agenda**: abrir na mesa da torre; a câmera vira para ela e volta ao fechar; Esc fecha. O tempo continua correndo (relógio de parede e Afogados).
4. **Salvar e sair → Continuar**: voltar no mesmo horário, na mesma posição, com danos, galão na mão, nevoeiro e barco (rádio tocando se não atendido) e Afogados onde estavam.
5. **Sair sem salvar**: confirmação; depois Continuar fica desabilitado.
6. **Morte** (queda do patamar ou Afogado): "Você MAMOU"; Tentar novamente recomeça da noite 1; o save some.
7. **Vitória**: com `NightDirector.debug_time_scale` alto, vencer o Easy; a tela mostra dificuldade e noites; Medium fica liberado no menu.
8. **Mouse**: capturado no jogo, solto em menus, telas e agenda (no headless não dá para conferir).
- Para provocar ameaças cedo: subir `chance_per_check` de `config/events/fog.tres` e `boat.tres`; reduzir `sink_seconds_*` do `BoatConfig` em `easy.tres`.
- Depois: balanceamento dos valores das configs e arte/áudio finais.

## Bloqueios
- Nenhum. Observações:
  - `project.godot` aponta `config/icon="res://icon.svg"`, que não existe.
  - O check não acusa avisos do GDScript.
  - O bake da navmesh avisa no console que lê malhas visuais do CSG (custo só na abertura; decisão 0009).
  - Saves e progresso ficam em `user://` (`%APPDATA%/Godot/app_userdata/the-beacon/`). Para testar o desbloqueio do zero, apague `progress.json`.
  - `game.gd` está com ~195 linhas: a próxima responsabilidade nova deve nascer em componente próprio.
