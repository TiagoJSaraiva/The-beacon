extends GdUnitTestSuite
## Relógio de parede: segue o jogo fora da vista e corre em tempo real enquanto é visto.

const CLOCK := preload("res://night/wall_clock.tscn")

var _clock: WallClock
var _camera: Camera3D


## Relógio na origem (visor para +Z) e câmera a 2 m, olhando para ele.
func _spawn(seconds_per_viewed_minute: float) -> void:
	_clock = CLOCK.instantiate()
	_clock.seconds_per_viewed_minute = seconds_per_viewed_minute
	add_child(auto_free(_clock))
	_camera = Camera3D.new()
	add_child(auto_free(_camera))
	_camera.position = Vector3(0.0, 0.0, 2.0)
	_camera.make_current()


func _display_text() -> String:
	return (_clock.find_child("Display") as Label3D).text


func test_viewed_clock_stays_frozen_while_the_game_advances() -> void:
	_spawn(1000.0)
	_clock.show_time("21:00")
	await await_millis(150)
	_clock.show_time("22:00")
	await await_millis(150)
	assert_str(_display_text()).is_equal("21:00")


func test_viewed_clock_runs_in_real_time_but_stays_behind_the_game() -> void:
	_spawn(0.1)
	_clock.show_time("21:00")
	await await_millis(150)
	_clock.show_time("23:00")
	await await_millis(600)
	assert_str(_display_text()).is_not_equal("21:00")
	assert_str(_display_text()).is_not_equal("23:00")


func test_clock_out_of_view_follows_the_game() -> void:
	_spawn(1000.0)
	_camera.rotation_degrees.y = 180.0
	await await_millis(150)
	_clock.show_time("22:00")
	await await_millis(100)
	assert_str(_display_text()).is_equal("22:00")


func test_wall_between_camera_and_clock_hides_it() -> void:
	_spawn(1000.0)
	var wall := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(4.0, 4.0, 0.1)
	shape.shape = box
	wall.add_child(shape)
	wall.position = Vector3(0.0, 0.0, 1.0)
	add_child(auto_free(wall))
	await await_millis(150)
	_clock.show_time("22:00")
	await await_millis(100)
	assert_str(_display_text()).is_equal("22:00")
