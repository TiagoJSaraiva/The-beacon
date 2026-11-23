// Chão da ilha: areia embaixo, grama no alto e rocha onde é íngreme, pela altura e pela inclinação
// no espaço do mundo. Texturas em projeção triplanar (a malha da ilha não tem UV). A areia perto da
// água escurece, como areia molhada.
shader_type spatial;
render_mode diffuse_burley;

uniform sampler2D sand_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D sand_arm : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D grass_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D grass_arm : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D rock_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D rock_arm : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
// Repetições por metro de cada textura.
uniform float sand_scale = 0.125;
uniform float grass_scale = 0.125;
uniform float rock_scale = 0.1;
// Altura em que a grama começa a aparecer e em que cobre tudo.
uniform float grass_from_height = -1.6;
uniform float grass_full_height = -0.8;
// Inclinação (componente vertical da normal) em que a rocha começa e em que cobre tudo.
uniform float rock_from_slope = 0.9;
uniform float rock_full_slope = 0.72;
// Areia molhada: escurece abaixo de wet_height, até wet_darkening no nível do mar.
uniform float sea_level = -2.9;
uniform float wet_height = -2.2;
uniform float wet_darkening = 0.55;
// Quanto a textura da grama desmancha a borda entre areia e grama.
uniform float edge_breakup = 0.6;

varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

vec4 triplanar(sampler2D tex, vec3 position, vec3 normal, float scale) {
	vec3 weights = pow(abs(normal), vec3(4.0));
	weights /= weights.x + weights.y + weights.z;
	return texture(tex, position.zy * scale) * weights.x
		+ texture(tex, position.xz * scale) * weights.y
		+ texture(tex, position.xy * scale) * weights.z;
}

void fragment() {
	vec4 sand = triplanar(sand_albedo, world_position, world_normal, sand_scale);
	vec4 grass = triplanar(grass_albedo, world_position, world_normal, grass_scale);
	vec4 rock = triplanar(rock_albedo, world_position, world_normal, rock_scale);
	float sand_rough = triplanar(sand_arm, world_position, world_normal, sand_scale).g;
	float grass_rough = triplanar(grass_arm, world_position, world_normal, grass_scale).g;
	float rock_rough = triplanar(rock_arm, world_position, world_normal, rock_scale).g;

	float wet = smoothstep(wet_height, sea_level, world_position.y);
	sand.rgb *= mix(1.0, wet_darkening, wet);
	sand_rough *= mix(1.0, 0.4, wet);

	float breakup = (dot(grass.rgb, vec3(0.333)) - 0.5) * edge_breakup;
	float grass_amount = smoothstep(grass_from_height, grass_full_height, world_position.y + breakup);
	float rock_amount = 1.0 - smoothstep(rock_full_slope, rock_from_slope, world_normal.y);

	vec3 color = mix(sand.rgb, grass.rgb, grass_amount);
	float rough = mix(sand_rough, grass_rough, grass_amount);
	color = mix(color, rock.rgb, rock_amount);
	rough = mix(rough, rock_rough, rock_amount);
	ALBEDO = color;
	ROUGHNESS = rough;
}
