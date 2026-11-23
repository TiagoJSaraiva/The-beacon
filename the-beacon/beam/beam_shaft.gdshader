// Facho de luz do farol: um cone aberto, somado à imagem, que imita a luz espalhada no ar.
// Mais forte perto da lente e apagando até a ponta, com as bordas do cone suaves (a luz some onde
// a superfície fica de lado para quem olha). Funde-se com a geometria que corta o cone e esmaece
// perto da câmera, para não virar uma parede chapada se o facho passar rente a ela.
// Malha: CylinderMesh com a ponta estreita em -Y local (a lente) e a larga em +Y; `length` é a
// altura dela.
shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled;

uniform vec3 color : source_color = vec3(1.0, 0.92, 0.7);
uniform float intensity : hint_range(0.0, 4.0) = 1.0;
// Comprimento da malha, em metros.
uniform float length = 90.0;
// Quanto o brilho cai ao longo do facho (maior = apaga mais cedo).
uniform float falloff : hint_range(0.1, 8.0) = 1.6;
// Quanto as bordas do cone somem (maior = facho mais fino e suave).
uniform float edge_softness : hint_range(0.1, 8.0) = 1.5;
// Distância em que o facho se funde com a geometria que o corta.
uniform float surface_fade : hint_range(0.01, 10.0) = 2.0;
// Distância da câmera abaixo da qual o facho some.
uniform float camera_fade : hint_range(0.1, 20.0) = 4.0;
uniform sampler2D depth_texture : hint_depth_texture, filter_nearest;

// 0 na lente, 1 na ponta.
varying float along;

void vertex() {
	along = clamp(VERTEX.y / length + 0.5, 0.0, 1.0);
}

void fragment() {
	float facing = abs(dot(normalize(NORMAL), normalize(VIEW)));
	float edges = pow(facing, edge_softness);
	float fade_along = pow(1.0 - along, falloff);

	float scene_depth = texture(depth_texture, SCREEN_UV).r;
	vec4 scene_view = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, scene_depth, 1.0);
	scene_view.xyz /= scene_view.w;
	float to_surface = VERTEX.z - scene_view.z;
	float surface = clamp(to_surface / surface_fade, 0.0, 1.0);
	float near_camera = clamp(-VERTEX.z / camera_fade, 0.0, 1.0);

	ALBEDO = color;
	ALPHA = clamp(intensity * edges * fade_along * surface * near_camera, 0.0, 1.0);
}
