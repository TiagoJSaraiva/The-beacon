class_name ThreatConfig
extends Resource
## Nível de ameaça e aparição dos Afogados (GDD 1.2.10).

@export var threat_per_drowned_point: float = 1.0
## Soma enquanto a porta de entrada está quebrada.
@export var threat_from_broken_door: float = 1.0
@export var spawn_check_interval_seconds: float = 45.0
@export_range(0.0, 1.0, 0.01) var spawn_chance_base: float = 0.15
@export_range(0.0, 1.0, 0.01) var spawn_chance_per_threat: float = 0.1
## Chance, por ponto de ameaça, de cada Afogado extra aparecer junto.
@export_range(0.0, 1.0, 0.01) var extra_drowned_chance_per_threat: float = 0.08
@export var max_simultaneous_drowned: int = 3
## A partir deste nível o Afogado sobe a escada atrás do jogador (ação nível 4).
@export var chase_threat_threshold: float = 3.0
## Peso extra da ação nível 3 (gerador) sobre a nível 2 (mangueira), por ponto de ameaça.
@export var severe_action_weight_per_threat: float = 0.25
