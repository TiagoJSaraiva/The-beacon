extends GdUnitTestSuite
## "Sem escuridão": liga uma cópia clara do ambiente da câmera sem mexer no original e o devolve ao
## desligar.


func test_switches_to_a_bright_copy_and_back() -> void:
	var camera: Camera3D = auto_free(Camera3D.new())
	var original := Environment.new()
	original.ambient_light_energy = 0.7
	camera.environment = original
	var view := FullbrightView.new(camera)

	view.set_active(true)
	assert_object(camera.environment).is_not_same(original)
	assert_float(camera.environment.ambient_light_energy).is_equal_approx(
		FullbrightView.AMBIENT_ENERGY, 0.001
	)
	assert_float(original.ambient_light_energy).is_equal_approx(0.7, 0.001)

	view.set_active(false)
	assert_object(camera.environment).is_same(original)


func test_does_nothing_without_camera_or_environment() -> void:
	var view := FullbrightView.new(null)
	view.set_active(true)
	assert_bool(view.active).is_false()
	var bare := FullbrightView.new(auto_free(Camera3D.new()))
	bare.set_active(true)
	assert_bool(bare.active).is_false()
