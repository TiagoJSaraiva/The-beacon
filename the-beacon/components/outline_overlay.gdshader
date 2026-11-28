// Contorno do objeto em foco: casco invertido. A malha é redesenhada um pouco maior, só com as
// faces de trás (cull_front), numa cor chapada; o que sobra além da silhueta vira o contorno.
// Usado como `material_overlay` (ver OutlineHighlight), então serve a qualquer malha sem mexer
// nos materiais dela.
shader_type spatial;
render_mode unshaded, cull_front, shadows_disabled, fog_disabled, skip_vertex_transform;

uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
// Espessura em metros no mundo, medida a 1 m da câmera. Cresce com a distância (entre os limites
// abaixo) para o traço manter quase a mesma largura na tela; é a mesma em objetos de qualquer
// escala (o gerador principal é esticado na cena).
uniform float thickness : hint_range(0.0, 0.1) = 0.012;
uniform float distance_min = 0.5;
uniform float distance_max = 4.0;

void vertex() {
	vec3 world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
	vec3 world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 view_position = (VIEW_MATRIX * vec4(world_position, 1.0)).xyz;
	float scale = clamp(length(view_position), distance_min, distance_max);
	world_position += world_normal * thickness * scale;
	VERTEX = (VIEW_MATRIX * vec4(world_position, 1.0)).xyz;
	NORMAL = normalize((VIEW_MATRIX * vec4(world_normal, 0.0)).xyz);
}

void fragment() {
	ALBEDO = color.rgb;
}
