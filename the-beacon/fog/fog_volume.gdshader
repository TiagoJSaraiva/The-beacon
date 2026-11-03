// Nevoeiro falso num volume (o renderizador Compatibility não tem névoa volumétrica).
// Desenha as faces de trás e calcula quanto do raio de visão atravessa o volume, até a
// primeira superfície da cena: paredes cortam o nevoeiro e dá para estar dentro dele.
// Malhas: BoxMesh de tamanho 2 ou CylinderMesh de raio 1 e altura 2; a escala do nó dá o
// tamanho real.
shader_type spatial;
render_mode unshaded, cull_front, depth_draw_never, depth_test_disabled, blend_mix;

uniform vec3 fog_color : source_color = vec3(0.45, 0.48, 0.52);
// Absorção por metro atravessado.
uniform float density = 0.1;
// Esmaece o volume inteiro (entrada e saída do estágio).
uniform float opacity : hint_range(0.0, 1.0) = 1.0;
uniform bool is_cylinder = false;
// Furo central do cilindro, em fração do raio (0 = cheio). O anel em volta do farol não
// pode encher o interior da torre.
uniform float inner_radius : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D depth_texture : hint_depth_texture, filter_nearest;

// Entrada e saída do raio no volume, em distância ao longo do raio.
vec2 box_hit(vec3 origin, vec3 direction) {
	vec3 inverse_direction = 1.0 / direction;
	vec3 a = (vec3(-1.0) - origin) * inverse_direction;
	vec3 b = (vec3(1.0) - origin) * inverse_direction;
	vec3 near_hits = min(a, b);
	vec3 far_hits = max(a, b);
	return vec2(
		max(max(near_hits.x, near_hits.y), near_hits.z),
		min(min(far_hits.x, far_hits.y), far_hits.z)
	);
}

// Trecho do raio dentro de um cilindro vertical infinito de raio `radius`.
vec2 side_hit(vec3 origin, vec3 direction, float radius) {
	float a = dot(direction.xz, direction.xz);
	float c = dot(origin.xz, origin.xz) - radius * radius;
	if (a <= 1e-6) {
		return c > 0.0 ? vec2(1.0, -1.0) : vec2(-1e9, 1e9);
	}
	float b = dot(origin.xz, direction.xz);
	float h = b * b - a * c;
	if (h < 0.0) {
		return vec2(1.0, -1.0);
	}
	float s = sqrt(h);
	return vec2((-b - s) / a, (-b + s) / a);
}

vec2 cylinder_hit(vec3 origin, vec3 direction) {
	vec2 side = side_hit(origin, direction, 1.0);
	float inverse_y = 1.0 / direction.y;
	float y0 = (-1.0 - origin.y) * inverse_y;
	float y1 = (1.0 - origin.y) * inverse_y;
	return vec2(max(side.x, min(y0, y1)), min(side.y, max(y0, y1)));
}

void fragment() {
	vec3 camera_world = INV_VIEW_MATRIX[3].xyz;
	vec3 direction_world = normalize((INV_VIEW_MATRIX * vec4(VERTEX, 0.0)).xyz);
	mat4 world_to_local = inverse(MODEL_MATRIX);
	// Mesma parametrização do raio no espaço local: as distâncias saem em metros.
	vec3 origin = (world_to_local * vec4(camera_world, 1.0)).xyz;
	vec3 direction = (world_to_local * vec4(direction_world, 0.0)).xyz;
	vec2 hit = is_cylinder ? cylinder_hit(origin, direction) : box_hit(origin, direction);

	float depth = texture(depth_texture, SCREEN_UV).r;
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
#else
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
#endif
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	float scene_distance = length(view.xyz / view.w);

	float entry_t = max(hit.x, 0.0);
	float exit_t = min(hit.y, scene_distance);
	float thickness = max(exit_t - entry_t, 0.0);
	if (is_cylinder && inner_radius > 0.0) {
		vec2 hole = side_hit(origin, direction, inner_radius);
		thickness -= max(min(exit_t, hole.y) - max(entry_t, hole.x), 0.0);
	}
	ALBEDO = fog_color;
	ALPHA = opacity * (1.0 - exp(-density * thickness));
}
