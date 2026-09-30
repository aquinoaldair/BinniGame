extends Node2D

# Objetos visuales con origen en el suelo para ordenar correctamente por Y.
var kind := "plant"
var extent := Vector2(15, 18)
var accent := Color("d58093")
var seed_value := 0
var clock := 0.0
var animate := false
var open_gate := false
var redraw_timer := 0.0


func _process(delta: float) -> void:
	if animate and is_visible_in_tree():
		clock += delta
		redraw_timer += delta
		if redraw_timer >= 1.0 / 24.0:
			redraw_timer = 0.0
			queue_redraw()


func _draw() -> void:
	match kind:
		"house": _house()
		"tree": _tree()
		"plant": _plant()
		"bench": _bench()
		"wall": _wall()
		"gate": _gate()
		"book": _book()
		"cloth": _cloth()


func _house() -> void:
	var half := extent.x * 0.5
	var height := extent.y
	var facade_height := 31.0 if half > 80 else 22.0
	# Corredor y base: la fachada termina exactamente en el pie del edificio.
	draw_colored_polygon(PackedVector2Array([Vector2(-half - 2, -2), Vector2(half + 2, -2), Vector2(half + 8, 8), Vector2(-half - 6, 8)]), Color("c7b79b"))
	draw_line(Vector2(-half, 6), Vector2(half + 6, 6), Color("f3e4c3"), 1.1, true)
	draw_rect(Rect2(-half + 3, -facade_height, extent.x - 6, facade_height), Color("e7d8b8"))
	draw_rect(Rect2(-half + 3, -9, extent.x - 6, 9), Color("bc8e75"))
	draw_rect(Rect2(half - 10, -facade_height, 8, facade_height), Color("b9ab8e"))
	var door_height := facade_height - 6
	draw_rect(Rect2(-9, -door_height, 18, door_height), Color("384f49"))
	draw_rect(Rect2(-7, -door_height + 1, 14, door_height - 1), Color("53776b"))
	for plank in range(4):
		draw_line(Vector2(-6 + plank * 4, -door_height + 2), Vector2(-6 + plank * 4, -1), Color("38594e"), 0.65, true)
	_ellipse(Vector2(4, -11), Vector2(0.9, 1), Color("d6b273"))
	for side in [-1.0, 1.0]:
		var window_x: float = side * half * 0.53
		draw_rect(Rect2(window_x - 11, -facade_height + 7, 22, 15), Color("b59776"))
		draw_rect(Rect2(window_x - 9, -facade_height + 8, 18, 12), Color("45665e"))
		draw_rect(Rect2(window_x - 7, -facade_height + 9, 5, 10), Color("a8c0a1"))
		for bar in range(4):
			draw_line(Vector2(window_x - 8 + bar * 5, -facade_height + 7), Vector2(window_x - 8 + bar * 5, -facade_height + 20), Color("465447"), 0.8, true)
		draw_line(Vector2(window_x - 12, -facade_height + 22), Vector2(window_x + 12, -facade_height + 22), Color("f5e7c7"), 2, true)
	# Sombra del alero, columnas y tejado inclinado, con tejas menos uniformes.
	draw_rect(Rect2(-half + 2, -facade_height, extent.x - 4, 7), Color(0.21, 0.16, 0.12, 0.15))
	for side in [-1.0, 1.0]:
		var x: float = side * (half - 17)
		draw_rect(Rect2(x - 2, -facade_height + 2, 4, facade_height + 3), Color("dac8a4"))
		draw_line(Vector2(x - 1.3, -facade_height + 2), Vector2(x - 1.3, 3), Color("f4e5c2"), 1.0, true)
		draw_rect(Rect2(x - 3, 2, 6, 2), Color("bca987"))
	var top := -height
	var edge := -facade_height - 1
	var ridge := top + 10
	var inset := minf(25, extent.x * 0.16)
	draw_colored_polygon(PackedVector2Array([Vector2(-half + inset, top), Vector2(half - inset, top), Vector2(half + 4, edge), Vector2(-half - 4, edge)]), Color("a86546"))
	var random := RandomNumberGenerator.new()
	random.seed = seed_value + 87
	var rows := int((edge - ridge) / 5.0)
	for row in range(rows):
		var y := ridge + row * 5
		var widening := float(row + 1) / maxf(rows, 1)
		var left := -half + inset * (1 - widening)
		var right := half - inset * (1 - widening)
		for column in range(int((right - left) / 6)):
			var x := left + column * 6
			var color := Color("c57c55").lerp(Color("ad6244"), random.randf())
			_ellipse(Vector2(x + 3, y + 2.8), Vector2(3.0, 3), color)
			draw_line(Vector2(x + 1.7, y), Vector2(x + 1.3, y + 3), color.lightened(0.16), 0.65, true)
	draw_line(Vector2(-half + inset, top), Vector2(half - inset, top), Color("da9970"), 4, true)
	draw_line(Vector2(-half - 4, edge), Vector2(half + 4, edge), Color("864e38"), 3, true)
	draw_line(Vector2(-half - 4, edge - 1), Vector2(half + 4, edge - 1), Color("d4986d"), 1.4, true)
	for side in [-1.0, 1.0]:
		draw_line(Vector2(side * (half - inset), top), Vector2(side * (half + 4), edge), Color("d18d64"), 3, true)


func _tree() -> void:
	var sway := sin(clock * 0.7 + seed_value) * 0.9
	# Tronco visible, ramificación y copa por encima del punto de apoyo.
	draw_line(Vector2(0, -1), Vector2(-1, -22), Color("786244"), 5, true)
	draw_line(Vector2(-1, -14), Vector2(-10, -25), Color("786244"), 2.2, true)
	draw_line(Vector2(-1, -18), Vector2(8, -29), Color("917855"), 2, true)
	var center := Vector2(sway, -extent.y)
	_ellipse(center + Vector2(2, 4), Vector2(extent.x, extent.x * 0.74), Color("365747"))
	for leaf in range(18):
		var angle := leaf * 2.4 + seed_value
		var spread := 0.4 + float(leaf % 4) * 0.15
		var point := center + Vector2(cos(angle), sin(angle) * 0.65) * extent.x * spread
		var color := Color("6b8d55") if leaf % 3 == 0 else Color("4e7750")
		_ellipse(point, Vector2(extent.x * 0.38, extent.x * 0.26), color)
		if leaf % 4 == 0:
			draw_line(point - Vector2(2, 1), point + Vector2(3, 0), color.lightened(0.18), 1, true)


func _plant() -> void:
	var sway := sin(clock + seed_value) * 0.6
	_ellipse(Vector2(0, -2), Vector2(extent.x * 0.6, 3), Color("8d684b"))
	if seed_value % 3 == 0:
		draw_colored_polygon(PackedVector2Array([Vector2(-5, -10), Vector2(5, -10), Vector2(3.5, -1), Vector2(-3.5, -1)]), Color("ba8060"))
		draw_line(Vector2(-5, -10), Vector2(5, -10), Color("d49d75"), 2, true)
	for leaf in range(9):
		var angle := leaf * 2.4 + seed_value
		var center := Vector2(sway + cos(angle) * extent.x * 0.65, -extent.y + sin(angle) * extent.y * 0.4)
		draw_line(Vector2(0, -4), center, Color("537755"), 0.8, true)
		_ellipse(center, Vector2(extent.x * 0.4, extent.y * 0.25), Color("779a61") if leaf % 3 == 0 else Color("4d7652"))
		if leaf % 3 == 0:
			for petal in range(4):
				var phase := petal * PI * 0.5
				_ellipse(center + Vector2(cos(phase), sin(phase)) * 1.2, Vector2(1.4, 1.1), accent)
			_ellipse(center, Vector2(0.6, 0.6), Color("e6c881"))


func _bench() -> void:
	for side in [-1.0, 1.0]:
		draw_line(Vector2(side * 12, 0), Vector2(side * 12, -10), Color("514e3d"), 2.3, true)
	draw_rect(Rect2(-17, -19, 34, 7), Color("967355"))
	draw_line(Vector2(-16, -16), Vector2(16, -16), Color("b58f66"), 1, true)
	draw_colored_polygon(PackedVector2Array([Vector2(-17, -10), Vector2(17, -10), Vector2(20, -6), Vector2(-18, -6)]), Color("b18a64"))
	draw_line(Vector2(-18, -6), Vector2(20, -6), Color("70583f"), 2, true)


func _wall() -> void:
	draw_rect(Rect2(0, -14, extent.x, 14), Color("c4b394"))
	draw_rect(Rect2(0, -14, extent.x, 3), Color("eee0bc"))
	draw_line(Vector2(0, -1), Vector2(extent.x, -1), Color("9d9676"), 1.2, true)


func _gate() -> void:
	var width := 141.0
	var gap := 48.0 if open_gate else 0.0
	for side in [-1.0, 1.0]:
		var left := -width * 0.5 if side < 0 else gap
		var right := -gap if side < 0 else width * 0.5
		draw_rect(Rect2(left, -17, right - left, 17), Color("40574f"))
		for x in range(int(left) + 2, int(right), 7):
			draw_line(Vector2(x, -16), Vector2(x, -1), Color("7e8e73"), 0.8, true)
		draw_line(Vector2(left, -17), Vector2(right, -17), Color("a6aa8b"), 1.1, true)


func _book() -> void:
	_ellipse(Vector2(1, 2), Vector2(7, 2.5), Color(0.25, 0.2, 0.15, 0.18))
	draw_rect(Rect2(-6, -6, 12, 7), Color("816047"))
	draw_rect(Rect2(-4, -5, 9, 5), Color("ebdcba"))
	draw_line(Vector2(-3, -3), Vector2(3, -3), Color("b79e79"), 0.7, true)
	draw_line(Vector2(-6, -6), Vector2(-6, 1), Color("bd885e"), 1.5, true)


func _cloth() -> void:
	draw_line(Vector2(-16, -12), Vector2(17, -12), Color("a89b7b"), 0.6, true)
	var sway := sin(clock * 1.2) * 1.7
	draw_colored_polygon(PackedVector2Array([Vector2(-12, -12), Vector2(1, -12), Vector2(2 + sway, -1), Vector2(-11 + sway, -2)]), Color("c7baa1"))
	draw_colored_polygon(PackedVector2Array([Vector2(5, -12), Vector2(13, -12), Vector2(14 + sway, -4), Vector2(6 + sway, -4)]), Color("719287"))


func _ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in range(24):
		var angle := TAU * index / 24.0
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(points, color)
	points.append(points[0])
	draw_polyline(points, color, 0.4, true)
