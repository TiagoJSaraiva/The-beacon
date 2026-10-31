# Afogados

## Propósito
Principal ameaça física; a única que mata (GDD 1.2.10, 1.2.11).

## Componentes
- `drowned/threat_rules.gd` (`ThreatRules`): nível de ameaça e sorteios.
- `drowned/perception_rules.gd` (`PerceptionRules`): alcance com oclusão.
- `drowned/drowned_brain.gd` (`DrownedBrain`): máquina de estados das ações.
- `drowned/drowned.tscn` (`Drowned`, `CharacterBody3D` na camada `drowned`, colide com `world` e `barriers`): navega com `NavigationAgent3D`, conta obstáculos por raio, passos audíveis por proximidade.
- `drowned/drowned_director.gd` (`DrownedDirector`, nó no `World`, recebe `Lighthouse`, `Player` e `Exterior` em `setup()`): pontos, aparições, efeitos e batidas no alçapão.
- Alvos: marcadores `DrownedTargets/*` no farol (fora da porta, mangueira, gerador, rampa sob o alçapão); a saída é o ponto onde ele surgiu.
- `lighthouse/trapdoor_resistance.gd` (`TrapdoorResistance`), dentro do `Trapdoor`.

## Regras
- Ameaça = pontos × `threat_per_drowned_point` + `threat_from_broken_door` enquanto a porta está quebrada.
- A partir do 1º ponto, a cada `spawn_check_interval_seconds` sorteia aparição com chance `spawn_chance_base + spawn_chance_per_threat × ameaça`; extras com `extra_drowned_chance_per_threat × ameaça`, até `max_simultaneous_drowned`.
- Com a porta inteira, sempre a quebra primeiro (`door_break_seconds`). Depois: ameaça >= `chase_threat_threshold` → sobe e bate no alçapão (`bang_seconds`, depois vai embora); abaixo disso → sabota gerador (mais provável com a ameaça, `severe_action_weight_per_threat`) ou mangueira (`sabotage_seconds`), pulando o que já está quebrado, e vai embora.
- Jogador ao alcance (com a porta já aberta) é sempre o alvo; tocar (`kill_distance`) mata. Perdido o alcance, volta à ação anterior: esconder-se não sobe a ação para o nível 4.
- Alcance: distância + `occlusion_penalty` por obstáculo (`world`/`barriers`) entre os olhos dele e os do jogador, comparado a `perception_range`.
- Alçapão aberto ou quebrado na chegada → persegue até matar. Fechado → bate; a resistência (`TrapdoorConfig.resistance_seconds`) corre sem o trinco, congela com ele, não zera ao soltar e volta ao máximo quando ninguém bate. Zerada, o alçapão quebra.
- Mais lento que o jogador (`move_speed`). Às 06:00 todos somem; pontos e ameaça continuam.

## Sinais
- `Drowned.effect_triggered(effect)` → `DrownedDirector` → porta, mangueira, gerador ou `Player.kill(CAUSE_DROWNED)`.
- `DrownedDirector.threat_changed(threat)`, `drowned_appeared(count)`.

## Testes
- `test/unit/threat_rules_test.gd`, `perception_rules_test.gd`, `drowned_brain_test.gd`, `trapdoor_resistance_test.gd`.
- Validado por sondas headless (fora do repositório): baixa ameaça (porta → mangueira → embora → volta → gerador) e alta ameaça (porta → escada → alçapão quebra → persegue → mata).
