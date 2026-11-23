# 0028 — Céu pela Sky3D e ambiente do jogador na câmera

- **Data**: 2026-11
- **Status**: aceita

## Contexto
O céu das câmeras de segurança era uma cor chapada, sem lua nem estrelas, e a lua era uma `DirectionalLight3D` parada. O desenvolvedor pediu um componente pronto de céu com lua e estrelas, com a lua andando conforme a hora. Ao mesmo tempo, o interior do farol passou a ser breu (luz ambiente zero), enquanto o exterior visto pelas câmeras precisa de luz ambiente. O jogador e as câmeras compartilham o mesmo `World3D`.

## Decisão
- O addon **Sky3D** (TokisanGames, MIT, v2.1.0) fica em `addons/sky_3d/`. O nó `Sky3D` é o `WorldEnvironment` do `World`, com sol, lua (com fases), estrelas e nuvens; o `Moon` antigo saiu.
- O relógio próprio da Sky3D fica desligado; `SkyClock` (`night/sky_clock.gd`) leva a hora do `NightClock` ao `Sky3D.current_time` a cada minuto do jogo.
- Data e lugar fixos no `TimeOfDay`: lua cheia de 11/06/2025, latitude 30° N, longitude 0, UTC +1. No hemisfério norte a lua passa pelo sul, na frente das câmeras do mar (que olham para +Z, o sul); a noite começa no fim do crepúsculo e termina no amanhecer.
- O ambiente do mundo (o da Sky3D, com a névoa volumétrica das câmeras) vale para as câmeras de segurança, que não têm mais `Environment` próprio. O jogador tem o seu na própria `Camera3D` (`player/interior_environment.tres`, luz ambiente zero), que tem prioridade sobre o do mundo.
- O plugin de editor da Sky3D não precisa estar ligado para o jogo rodar (os nós são scripts com `class_name`); ligá-lo no editor só adiciona os tipos ao menu de nós.

## Alternativas descartadas
- **Céu feito à mão** (shader com mapa de estrelas e textura da lua): mais leve e sob controle, mas exige escrever e calibrar o que a Sky3D já traz.
- **Um ambiente só para todos**: o interior não fica no breu sem apagar o exterior das câmeras.

## Consequências
A lua, as estrelas e o reflexo da lua no mar acompanham a noite sem código próprio. A Sky3D muda o ambiente do mundo sozinha (exposição, contribuição do céu), o que afeta só as câmeras de segurança. O mapa da Via Láctea é CC BY 4.0 e exige crédito (`assets/models/CREDITOS.md`). Atualizar a Sky3D é trocar a pasta do addon.
