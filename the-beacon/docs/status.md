# Status

## Onde paramos
- Entrega 1 (core loop + meta-jogo com placeholders) em andamento, seguindo o plano aprovado de 25 passos (fases A–E). Decisões 0008 (arquitetura da simulação) e 0009 (navegação).
- **Fases A, B e C** concluídas: configs, jogador, interação, lanterna, greybox, relógio, gerador, combustível, feixe, falhas sorteadas.
- **Fase D (ameaças)** concluída:
  - Exterior com câmeras do mar e do farol nos monitores da mesa.
  - Nevoeiro (só nas câmeras), barcos e rádio com mensagem por tons, pirata guiado sem consequência.
  - Afogados com nível de ameaça, navmesh em runtime, porta, sabotagens, alçapão com resistência e trinco, morte.
  - Homem de Nevoeiro (atravessa porta e alçapão, dissipa com a lanterna, cega).
  - Plantão: fim de noite congela a simulação, limpa entidades e mostra a tela entre noites; última noite = vitória.
- Geometria do farol mudou para a navmesh funcionar (escada em 0.9 volta a partir de 36°, guarda-corpo baixo no começo, patamar à frente do fim da escada, alçapão maior e com dobradiça na borda longa, lâmpada fora do centro). Ver `sistemas/farol.md`.
- Sons placeholder gerados por `tools/generate_placeholder_audio.gd`.
- Iluminação provisória mais clara em `game/game.tscn` só para testes.
- Provisório até o passo 19: vitória, morte e "menu principal" recarregam a cena.

## Próximo passo
- Playtest da fase D. Para provocar ameaças cedo: subir `chance_per_check` de `config/events/fog.tres` e `boat.tres`; reduzir `sink_seconds_*` do `BoatConfig` em `easy.tres`; `NightDirector.debug_time_scale` para fim de noite rápido.
- Depois: fase E, passo 19 — `SceneRouter`, menu principal, seleção de dificuldade, game over e vitória.

## Bloqueios
- Nenhum. Observações: `project.godot` aponta `config/icon="res://icon.svg"`, que não existe. O `check.ps1` não acusa avisos do GDScript. O bake da navmesh avisa no console que lê malhas visuais do CSG (custo só na abertura; decisão 0009). `game.gd` está perto de 150 linhas e vai crescer com save, agenda e tutorial: na fase E, separar a fiação ou o save num componente.
