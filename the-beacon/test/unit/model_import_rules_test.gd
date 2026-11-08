extends GdUnitTestSuite


func test_large_texture_shrinks_keeping_aspect() -> void:
	assert_vector(ModelImportRules.fitted_size(Vector2i(4096, 4096), 2048)).is_equal(
		Vector2i(2048, 2048)
	)
	assert_vector(ModelImportRules.fitted_size(Vector2i(8192, 4096), 2048)).is_equal(
		Vector2i(2048, 1024)
	)
	assert_vector(ModelImportRules.fitted_size(Vector2i(1024, 4096), 2048)).is_equal(
		Vector2i(512, 2048)
	)


func test_small_texture_keeps_size() -> void:
	assert_vector(ModelImportRules.fitted_size(Vector2i(2048, 1024), 2048)).is_equal(
		Vector2i(2048, 1024)
	)
	assert_vector(ModelImportRules.fitted_size(Vector2i(16, 16), 2048)).is_equal(Vector2i(16, 16))


func test_extreme_aspect_keeps_at_least_one_pixel() -> void:
	assert_vector(ModelImportRules.fitted_size(Vector2i(8192, 1), 2048)).is_equal(Vector2i(2048, 1))


func test_model_and_used_maps_are_wanted() -> void:
	assert_bool(ModelImportRules.is_wanted("scene.gltf")).is_true()
	assert_bool(ModelImportRules.is_wanted("scene.bin")).is_true()
	assert_bool(ModelImportRules.is_wanted("Generator/Generator.fbx")).is_true()
	assert_bool(ModelImportRules.is_wanted("textures/chair_baseColor.png")).is_true()
	assert_bool(ModelImportRules.is_wanted("Pack_4K_Normal.JPG")).is_true()


func test_unused_maps_and_other_files_are_skipped() -> void:
	assert_bool(ModelImportRules.is_wanted("Pack_4K_Cavity.jpg")).is_false()
	assert_bool(ModelImportRules.is_wanted("Pack_4K_Displacement.jpg")).is_false()
	assert_bool(ModelImportRules.is_wanted("Generator_low_Tank_Height.png")).is_false()
	assert_bool(ModelImportRules.is_wanted("tlzkdilva.json")).is_false()
	assert_bool(ModelImportRules.is_wanted("textures/")).is_false()


func test_extra_skips_drop_matching_textures_only() -> void:
	var skips: PackedStringArray = ["_rusted"]
	assert_bool(ModelImportRules.is_wanted("textures/device29_rusted_normal.png", skips)).is_false()
	assert_bool(ModelImportRules.is_wanted("textures/device29_normal.png", skips)).is_true()
	assert_bool(ModelImportRules.is_wanted("scene_rusted.gltf", skips)).is_true()


func test_textures_get_vram_compression_and_mipmaps() -> void:
	var params: Dictionary = ModelImportRules.texture_import_params("chair_baseColor.png")
	assert_int(params["compress/mode"]).is_equal(ModelImportRules.COMPRESS_VRAM)
	assert_bool(params["mipmaps/generate"]).is_true()
	assert_int(params["detect_3d/compress_to"]).is_equal(ModelImportRules.DETECT_3D_DISABLED)
	assert_bool(params.has("compress/normal_map")).is_false()


func test_normal_maps_get_normal_map_mode() -> void:
	var params: Dictionary = ModelImportRules.texture_import_params("Pack_4K_Normal.jpg")
	assert_int(params["compress/normal_map"]).is_equal(ModelImportRules.NORMAL_MAP_ENABLED)
	assert_bool(ModelImportRules.is_normal_map("Generator_low_Tank_Normal.png")).is_true()
	assert_bool(ModelImportRules.is_normal_map("Generator_low_Tank_Roughness.png")).is_false()


func test_common_root_is_found_only_when_shared() -> void:
	var nested: PackedStringArray = ["Generator/", "Generator/Generator.fbx", "Generator/a.png"]
	assert_str(ModelImportRules.common_root(nested)).is_equal("Generator/")
	var flat: PackedStringArray = ["scene.gltf", "textures/a.png"]
	assert_str(ModelImportRules.common_root(flat)).is_equal("")
	var mixed: PackedStringArray = ["textures/a.png", "source/b.zip"]
	assert_str(ModelImportRules.common_root(mixed)).is_equal("")
	assert_str(ModelImportRules.common_root(PackedStringArray())).is_equal("")
