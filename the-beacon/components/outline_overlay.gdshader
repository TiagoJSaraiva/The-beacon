// Contorno do objeto em foco: casco invertido. A malha é redesenhada um pouco maior, só com as
// faces de trás (cull_front), numa cor chapada; o que sobra além da silhueta vira o contorno.
// Usado como `material_overlay` (ver OutlineHighlight), então serve a qualquer malha sem mexer
// nos materiais dela.
shader_type spatial;
render_mode unshaded, cull_front, shadows_disabled, fog_disabled, skip_vertex_transform;

uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
// Espessura em metros no mundo: a mesma em objetos de qualquer escala (o gerador principal é
// esticado na cena).
uniform float thickness : hint_range(0.0, 0.1) = 0.012;

void vertex() {
	vec3 world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
	vec3 world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz + world_normal * thickness;
	VERTEX = (VIEW_MATRIX * vec4(world_position, 1.0)).xyz;
	NORMAL = normalize((VIEW_MATRIX * vec4(world_normal, 0.0)).xyz);
}

void fragment() {
	ALBEDO = color.rgb;
}
