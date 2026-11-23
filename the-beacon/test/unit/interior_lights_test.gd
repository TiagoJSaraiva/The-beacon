extends GdUnitTestSuite
## Força das luzes do farol: escala a energia de cada luz a partir da energia da cena, sem acumular.


func test_scales_from_the_scene_energy() -> void:
	var lights: InteriorLights = auto_free(InteriorLights.new())
	var group := Node3D.new()
	lights.add_child(group)
	var lamp := OmniLight3D.new()
	lamp.light_energy = 2.0
	group.add_child(lamp)
	lights.light_scale = 0.5
	add_child(lights)
	assert_float(lamp.light_energy).is_equal_approx(1.0, 0.001)

	lights.light_scale = 0.25
	assert_float(lamp.light_energy).is_equal_approx(0.5, 0.001)
	lights.light_scale = 1.0
	assert_float(lamp.light_energy).is_equal_approx(2.0, 0.001)
