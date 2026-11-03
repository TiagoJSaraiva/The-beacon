class_name DrownedDirector
extends Node
## Pontos de Afogado e o Afogado (entrega 2). Cada barco afundado soma um ponto. Com o
## nevoeiro dentro do farol e ao menos um ponto, ele se aproxima (barulho na porta); com o
## medidor cheio, arromba a porta e entra. No máximo um por noite, e ele não sai mais.
## Recebe o farol e o jogador do Game em setup().

signal drowned_entered

@export var drowned_scene: PackedScene

var drowned_points: int = 0
var approach: DrownedApproach = DrownedApproach.new(DrownedConfig.new())

var _config: DrownedConfig = DrownedConfig.new()
var _lighthouse: Lighthouse
var _player: Player
var _fog_inside: bool = false
var _drowned: Drowned


func _physics_process(delta: float) -> void:
	if _lighthouse == null:
		return
	if approach.tick(delta, _fog_inside, drowned_points):
		_enter()
	_lighthouse.entrance_door.show_approach(0.0 if approach.has_entered else approach.level)
	if _drowned == null:
		return
	var senses := DrownedSenses.new()
	senses.trapdoor_state = _lighthouse.trapdoor.state
	senses.trapdoor_latched = _lighthouse.trapdoor.is_latched()
	_drowned.think(delta, senses)
	_lighthouse.trapdoor.set_banging(_drowned.brain.is_banging())


func configure(config: DrownedConfig) -> void:
	_config = config
	approach = DrownedApproach.new(config)


func setup(lighthouse: Lighthouse, player: Player) -> void:
	_lighthouse = lighthouse
	_player = player


func set_fog_stage(stage: FogStage.Stage) -> void:
	_fog_inside = FogStage.is_inside(stage)


func add_drowned_point() -> void:
	drowned_points += 1


func _enter() -> void:
	_lighthouse.entrance_door.burst_open()
	_drowned = drowned_scene.instantiate()
	_drowned.setup(_config, _lighthouse.drowned_targets(), _player)
	add_child(_drowned)
	_drowned.global_position = _lighthouse.drowned_entry_point()
	_drowned.effect_triggered.connect(_on_drowned_effect_triggered)
	drowned_entered.emit()


func _on_drowned_effect_triggered(effect: DrownedBrain.Effect) -> void:
	if effect == DrownedBrain.Effect.KILL:
		_player.kill(Player.CAUSE_DROWNED)
