class_name DrownedConfig
extends Resource
## Afogado (entrega 2). Distâncias em metros.

@export_group("Aproximação")
## Subida do medidor por segundo, com o nevoeiro dentro do farol e ao menos um ponto.
@export var approach_base_per_second: float = 0.01
## Somado à subida por ponto de Afogado.
@export var approach_per_point_per_second: float = 0.005
## Descida por segundo com o nevoeiro fora do farol.
@export var approach_recede_per_second: float = 0.02

@export_group("Dentro do farol")
## Precisa ser menor que a velocidade de caminhada do jogador.
@export var move_speed: float = 2.2
## Distância efetiva até a qual o jogador está "ao alcance".
@export var perception_range: float = 10.0
## Metros somados à distância por obstáculo entre o Afogado e o jogador.
@export var occlusion_penalty: float = 6.0
@export var kill_distance: float = 1.0
## Com o trinco ligado, bate por este tempo e cansa.
@export var tire_seconds: float = 20.0
## Cansado, descansa no térreo por este tempo antes de voltar a bater.
@export var rest_seconds: float = 25.0
@export var footstep_audible_distance: float = 14.0
