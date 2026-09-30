extends Node2D

# Suelo estático: se dibuja una vez, sin generar texturas cada fotograma.
func _draw() -> void:
	draw_rect(Rect2(0, -32, 480, 302), Color("c4b79a"))
	draw_rect(Rect2(27, 51, 426, 201), Color("b8a380"))
	_patch(Rect2(40, 100, 197, 110), Color("819569"), true, 23)
	_patch(Rect2(40, 210, 77, 40), Color("819569"), true, 24)
	_patch(Rect2(253, 225, 190, 25), Color("819569"), true, 25)
	for bounds in [Rect2(52, 51, 143, 49), Rect2(195, 51, 13, 102), Rect2(195, 140, 248, 17), Rect2(239, 151, 15, 101), Rect2(117, 210, 122, 6), Rect2(254, 211, 189, 14)]:
		_patch(bounds, Color("d2c4a5"), false, int(bounds.position.x))
	var paved := Rect2(257, 160, 180, 50)
	draw_rect(paved.grow(2), Color("d9c9a9"))
	draw_rect(paved, Color("bc896d"))
	var random := RandomNumberGenerator.new()
	random.seed = 52
	# Juntas de bajo contraste; variaciones de pigmento y desgaste.
	for row in range(5):
		for column in range(15):
			var point := paved.position + Vector2(column * 12, row * 10)
			var tone := Color("bf8c70").lerp(Color("ae7962"), random.randf())
			draw_rect(Rect2(point + Vector2(0.5, 0.5), Vector2(11, 9)), tone)
			if random.randf() < 0.12:
				draw_line(point + Vector2(3, 2), point + Vector2(6, 5), tone.lightened(0.08), 0.6, true)
	# Tierra de las jardineras y sombras extendidas hacia el corredor.
	for bed in [Rect2(28, 99, 12, 151), Rect2(442, 52, 11, 198), Rect2(212, 132, 232, 8)]:
		draw_rect(bed, Color("8c8463"))
	for shadow in [Rect2(212, 126, 232, 13), Rect2(128, 248, 112, 12)]:
		for edge in range(5):
			draw_rect(shadow.grow(edge), Color(0.22, 0.23, 0.15, 0.026))
	for center in [Vector2(62, 132), Vector2(67, 205), Vector2(415, 242)]:
		for ring in range(5):
			draw_circle(center + Vector2(7, 3), 13 + ring * 2, Color(0.22, 0.28, 0.18, 0.02), true, -1, true)


func _patch(bounds: Rect2, color: Color, grass: bool, seed_value: int) -> void:
	draw_rect(bounds, color)
	var random := RandomNumberGenerator.new()
	random.seed = seed_value
	for speck in range(int(bounds.get_area() / (13 if grass else 28))):
		var point := bounds.position + Vector2(random.randf_range(1, bounds.size.x - 1), random.randf_range(1, bounds.size.y - 1))
		var length := random.randf_range(0.6, 2.5)
		var tone := color.lightened(random.randf_range(0.03, 0.12)) if speck % 3 else color.darkened(0.09)
		draw_line(point, point + Vector2(length, -length * 0.3 if grass else 0.2), tone, 0.55, true)
	if not grass:
		draw_rect(bounds, color.lightened(0.09), false, 0.7)
		for crack in range(int(bounds.get_area() / 750)):
			var point := bounds.position + bounds.size * Vector2(random.randf(), random.randf())
			draw_polyline(PackedVector2Array([point, point + Vector2(2, 1), point + Vector2(3, -0.8)]), color.darkened(0.11), 0.5, true)
