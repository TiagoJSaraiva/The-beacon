# 0009 — Navmesh assada em runtime, sem as barreiras

- **Data**: 2026-10
- **Status**: aceita

## Contexto
Afogados e Homem de Nevoeiro precisam andar do exterior até o térreo e subir a escada em caracol até o alçapão. Porta e alçapão abrem, fecham e quebram durante a partida; o Homem de Nevoeiro atravessa os dois, os Afogados não. O greybox (CSG e escada gerada por `@tool`) muda com frequência.

## Decisão
- Uma `NavigationRegion3D` (`World/Navigation`) assada em `Game._ready`, um frame depois de montar a cena (o CSG gera a geometria no primeiro frame).
- Fonte: grupo `navigation_source` (`Lighthouse`, `Exterior`), colliders estáticos da camada `world` apenas. Porta e alçapão ficam em `barriers` e **não entram** na navmesh: os caminhos sempre passam por eles. Quem respeita a barreira é a regra (`DrownedBrain` para na porta e no alçapão) e a física (o corpo do Afogado colide com `barriers`; o do Homem de Nevoeiro, não).
- Células de 0.1 m (navmesh e `navigation/3d/default_cell_size`/`default_cell_height` em `project.godot`), agente com raio 0.4, altura 1.8, `agent_max_climb` 0.3, inclinação máxima 40°, área limitada por `filter_baking_aabb`.

## Alternativas descartadas
- **Navmesh pré-assada no editor**: sem custo na abertura, mas fica desatualizada a cada mudança do greybox.
- **Barreiras na navmesh com re-bake ao abrir/fechar**: re-bake caro e lento a cada mudança; e o Homem de Nevoeiro precisaria de outra navmesh.

## Consequências
Caminho sempre coerente com a geometria atual. Custo: um travamento curto na abertura (o parser do CSG lê as malhas visuais e o Godot avisa no console). A geometria precisa evitar degraus laterais baixos e sobreposição horizontal de pisos andáveis de níveis diferentes no mesmo ponto (ver `sistemas/farol.md`). Quando a arte final chegar, avaliar pré-assar.
