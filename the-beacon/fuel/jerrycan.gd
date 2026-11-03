class_name Jerrycan
extends RigidBody3D
## Galão de combustível com física (decisão 0017). Fica no slot do tanque, na mão do
## jogador ou solto no mundo. Na mão, o corpo some: o jogador só exibe uma cópia visual.

## Jogador interagiu com o galão (de mãos livres); o farol decide o que fazer.
signal pick_up_requested

enum Place { SLOT, HAND, WORLD }

var state: JerrycanState = JerrycanState.new(PowerConfig.new().jerrycan_capacity)
var place: Place = Place.SLOT

@onready var _shape: CollisionShape3D = %Shape
@onready var _pick_point: Interactable = %PickPoint


func configure(power: PowerConfig) -> void:
	state = JerrycanState.new(power.jerrycan_capacity)


func take_in_hand() -> void:
	place = Place.HAND
	freeze = true
	visible = false
	_set_solid(false)


## Solta em `at`, com a velocidade do arremesso.
func drop(at: Vector3, throw_velocity: Vector3) -> void:
	place = Place.WORLD
	global_position = at
	visible = true
	_set_solid(true)
	freeze = false
	linear_velocity = throw_velocity
	angular_velocity = Vector3.ZERO


## Assenta parado no slot.
func dock(at: Transform3D) -> void:
	place = Place.SLOT
	freeze = true
	global_transform = at
	visible = true
	_set_solid(true)


func _set_solid(solid: bool) -> void:
	# Pode ser chamado durante a física (raio de interação): adia a troca da colisão.
	_shape.set_deferred("disabled", not solid)
	_pick_point.enabled = solid


func _on_pick_point_interacted() -> void:
	pick_up_requested.emit()
