class_name SeaBandShape
extends RefCounted
## Tamanho da faixa de nevoeiro no mar (regra pura). A largura vem do trecho coberto da rota, e a
## profundidade a acompanha até um limite. A altura sobe com o crescimento do nevoeiro: começa
## igual à largura e chega a `max_half_height` no crescimento máximo, para passar do topo da
## imagem das câmeras do mar.

## Meia-altura no crescimento máximo.
var max_half_height: float = 60.0
## Limite da meia-profundidade.
var max_half_depth: float = 45.0
## Menor meia-medida: tamanho zero deixaria o volume degenerado.
var min_half_extent: float = 0.5


## Devolve as meias-medidas da faixa (x ao longo da rota, y para cima, z para o lado) a partir do
## meio-comprimento do trecho coberto e do crescimento do nevoeiro (0 a 1).
func half_extents(route_half_length: float, growth: float) -> Vector3:
	var half_length: float = maxf(route_half_length, min_half_extent)
	var start_height: float = minf(half_length, max_half_height)
	return Vector3(
		half_length,
		lerpf(start_height, max_half_height, clampf(growth, 0.0, 1.0)),
		minf(half_length, max_half_depth),
	)
