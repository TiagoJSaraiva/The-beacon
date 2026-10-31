class_name DrownedConfig
extends Resource
## Comportamento de cada Afogado (GDD 1.2.10). Distâncias em metros.

## Precisa ser menor que a velocidade de caminhada do jogador.
@export var move_speed: float = 2.2
## Distância efetiva até a qual o jogador está "ao alcance".
@export var perception_range: float = 10.0
## Metros somados à distância por obstáculo entre o Afogado e o jogador.
@export var occlusion_penalty: float = 6.0
@export var door_break_seconds: float = 8.0
@export var sabotage_seconds: float = 6.0
## Tempo que ele bate no alçapão antes de desistir e ir embora.
@export var bang_seconds: float = 30.0
@export var kill_distance: float = 1.0
@export var footstep_audible_distance: float = 14.0
