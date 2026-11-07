// Nevoeiro falso num volume (o renderizador Compatibility não tem névoa volumétrica).
// Desenha as faces de trás e calcula quanto do raio de visão atravessa o volume, até a
// primeira superfície da cena: paredes cortam o nevoeiro e dá para estar dentro dele.
// Malhas: BoxMesh de tamanho 2 ou CylinderMesh de raio 1 e altura 2; a escala do nó dá o
// tamanho real.
// Sem esmaecimento, a densidade é uniforme e o cálculo é direto (interior do farol). Com
// esmaecimento, ela varia dentro do volume e o raio é amostrado em passos (exterior).
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
// Fração das laterais em que a densidade cai até zero na borda (0 = corte seco).
uniform float edge_fade : hint_range(0.0, 1.0) = 0.0;
// Fração da metade de cima do volume em que a densidade cai até zero no topo.
uniform float top_fade : hint_range(0.0, 1.0) = 0.0;
// Amostras por raio quando há esmaecimento.
uniform int march_steps : hint_range(1, 64) = 16;
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

// Densidade relativa (0 a 1) num ponto do espaço local do volume.
float density_shape(vec3 point) {
	float shape = 1.0 - smoothstep(1.0 - top_fade, 1.0, point.y);
	if (is_cylinder) {
		float radius = length(point.xz);
		if (radius < inner_radius) {
			return 0.0;
		}
		return shape * (1.0 - smoothstep(1.0 - edge_fade, 1.0, radius));
	}
	shape *= 1.0 - smoothstep(1.0 - edge_fade, 1.0, abs(point.x));
	return shape * (1.0 - smoothstep(1.0 - edge_fade, 1.0, abs(point.z)));
}

// Metros de nevoeiro atravessados, ponderados pela densidade relativa.
float marched_thickness(vec3 origin, vec3 direction, float entry_t, float exit_t, vec2 pixel) {
	float step_length = (exit_t - entry_t) / float(march_steps);
	if (step_length <= 0.0) {
		return 0.0;
	}
	// Deslocar o início por pixel troca as faixas visíveis entre os passos por um grão fino.
	float jitter = fract(52.9829189 * fract(dot(pixel, vec2(0.06711056, 0.00583715))));
	float sum = 0.0;
	for (int i = 0; i < march_steps; i++) {
		float t = entry_t + (float(i) + jitter) * step_length;
		sum += density_shape(origin + direction * t);
	}
	return sum * step_length;
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
	float thickness = 0.0;
	if (edge_fade > 0.0 || top_fade > 0.0) {
		if (is_cylinder && inner_radius > 0.0) {
			// De dentro do furo, começa onde ele termina: o jogador dentro do farol não paga
			// amostras em todos os pixels por um nevoeiro que a parede esconde.
			vec2 hole = side_hit(origin, direction, inner_radius);
			if (hole.x <= entry_t && entry_t < hole.y) {
				entry_t = hole.y;
			}
		}
		thickness = marched_thickness(origin, direction, entry_t, exit_t, FRAGCOORD.xy);
	} else {
		thickness = max(exit_t - entry_t, 0.0);
		if (is_cylinder && inner_radius > 0.0) {
			vec2 hole = side_hit(origin, direction, inner_radius);
			thickness -= max(min(exit_t, hole.y) - max(entry_t, hole.x), 0.0);
		}
	}
	ALBEDO = fog_color;
	ALPHA = opacity * (1.0 - exp(-density * thickness));
}
