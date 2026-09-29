extends Node2D

const TouchControls = preload("res://scripts/touch_controls.gd")
const SaveSession = preload("res://scripts/save_session.gd")

@export var start_menu_enabled := true
@export var save_path := "user://partida.json"


const MAIN_HOUSE := Rect2(212, 54, 232, 76)
const SMALL_HOUSE := Rect2(128, 216, 112, 36)
const WALKABLE_BOUNDS := Rect2(Vector2(34, 59), Vector2(411, 186))
const PATH_CELL_SIZE := 6.0

var companion_grid := AStarGrid2D.new()


func _ready() -> void:
	_add_building_collision(MAIN_HOUSE)
	_add_building_collision(SMALL_HOUSE)
	_build_companion_grid()
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)

	var hint := Label.new()
	hint.text = "Mueve a Nisa  ·  WASD / flechas  ·  toca las flechas en móvil"
	hint.position = Vector2(12, 9)
	hint.add_theme_font_size_override("font_size", 7)
	hint.add_theme_color_override("font_color", Color("f7edcf"))
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hint)

	var controls := TouchControls.new()
	controls.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(controls)
	if start_menu_enabled:
		var session := SaveSession.new()
		session.name = "SaveSession"
		add_child(session)


func _draw() -> void:
	# Composición ficticia inspirada en la referencia; sin rótulos sobre el mapa.
	draw_rect(Rect2(0, 0, 480, 270), Color("454943"))
	draw_rect(Rect2(18, 43, 444, 217), Color("b9b3a2"))
	draw_rect(Rect2(27, 51, 426, 201), Color("8d795a"))

	# Jardín izquierdo y pequeño jardín junto a la casa inferior.
	_draw_lawn(Rect2(40, 100, 197, 110))
	_draw_lawn(Rect2(40, 210, 77, 40))
	_draw_lawn(Rect2(253, 225, 190, 25))

	# Sendero desde el portón, ramal frente a la casa y división entre patios.
	_draw_path(Rect2(52, 51, 143, 49))
	_draw_path(Rect2(195, 51, 13, 102))
	_draw_path(Rect2(195, 140, 248, 17))
	_draw_path(Rect2(239, 151, 15, 101))
	_draw_path(Rect2(117, 210, 122, 6))
	_draw_path(Rect2(254, 211, 189, 14))

	# Patio de losetas rojizas con juntas claras.
	var paved := Rect2(257, 160, 180, 50)
	draw_rect(paved.grow(3), Color("d3c7ad"))
	draw_rect(paved, Color("af583d"))
	for row in range(5):
		for column in range(15):
			var origin := paved.position + Vector2(column * 12, row * 10)
			var tone := Color("b96144") if (row + column) % 3 == 0 else Color("a64f38")
			draw_rect(Rect2(origin + Vector2.ONE, Vector2(10, 8)), tone)
			draw_line(origin, origin + Vector2(12, 0), Color("e1b99a"), 0.7)
			draw_line(origin, origin + Vector2(0, 10), Color("e1b99a"), 0.7)

	# Jardineras, arbustos y flores distribuidos sin invadir el sendero.
	draw_rect(Rect2(28, 99, 12, 151), Color("645a40"))
	draw_rect(Rect2(442, 52, 11, 198), Color("645a40"))
	draw_rect(Rect2(212, 132, 232, 8), Color("645a40"))
	var flower_colors := [Color("e9b83d"), Color("d5649b"), Color("f2e6ba")]
	for index in range(11):
		_draw_shrub(Vector2(34, 107 + index * 13), 7.0, flower_colors[index % 3], index)
	for index in range(14):
		_draw_shrub(Vector2(447, 62 + index * 13), 6.0, flower_colors[(index + 1) % 3], index)
	for index in range(14):
		if index < 6 or index > 8:
			_draw_shrub(Vector2(220 + index * 16, 135), 5.0, flower_colors[index % 3], index)
	_draw_shrub(Vector2(71, 121), 16.0, Color("e9b83d"), 2)
	_draw_shrub(Vector2(64, 190), 18.0, Color("d5649b"), 5)
	_draw_shrub(Vector2(101, 231), 10.0, Color("f2e6ba"), 3)
	_draw_shrub(Vector2(417, 236), 12.0, Color("e9b83d"), 4)

	# Fachadas y techos de teja con cuatro pendientes.
	_draw_house(MAIN_HOUSE)
	_draw_house(SMALL_HOUSE)

	# Banco frente a la casa principal, junto al personaje de la historia.
	draw_rect(Rect2(284, 143, 27, 7), Color("704b32"))
	draw_line(Vector2(285, 142), Vector2(310, 142), Color("bc9362"), 2)
	draw_rect(Rect2(286, 150, 3, 3), Color("493627"))
	draw_rect(Rect2(305, 150, 3, 3), Color("493627"))

	# Muro perimetral y portón superior izquierdo (todavía sin salida jugable).
	draw_rect(Rect2(18, 43, 35, 8), Color("ddd4bf"))
	draw_rect(Rect2(195, 43, 267, 8), Color("ddd4bf"))
	draw_rect(Rect2(18, 51, 9, 209), Color("d3c9b1"))
	draw_rect(Rect2(453, 51, 9, 209), Color("d3c9b1"))
	draw_rect(Rect2(18, 252, 444, 8), Color("ddd4bf"))
	draw_rect(Rect2(53, 44, 142, 7), Color("282c29"))
	for slat in range(18):
		draw_line(Vector2(56 + slat * 8, 45), Vector2(56 + slat * 8, 50), Color("656b61"), 1)

	# Franja de interfaz separada del jardín.
	draw_rect(Rect2(0, 0, 480, 40), Color("25362d"))
	draw_line(Vector2(0, 40), Vector2(480, 40), Color("77846a"), 1)


func _add_building_collision(bounds: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = bounds.get_center()
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = bounds.size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)


func _build_companion_grid() -> void:
	companion_grid.region = Rect2i(0, 0, 80, 45)
	companion_grid.cell_size = Vector2.ONE * PATH_CELL_SIZE
	companion_grid.offset = Vector2.ONE * PATH_CELL_SIZE * 0.5
	companion_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	companion_grid.update()
	# Margen para que el cuerpo de la iguana no roce ni atraviese las casas.
	for x in range(80):
		for y in range(45):
			var cell := Vector2i(x, y)
			var point := companion_grid.get_point_position(cell)
			var blocked := not WALKABLE_BOUNDS.has_point(point)
			blocked = blocked or MAIN_HOUSE.grow(6).has_point(point)
			blocked = blocked or SMALL_HOUSE.grow(6).has_point(point)
			companion_grid.set_point_solid(cell, blocked)


func get_companion_path(from: Vector2, to: Vector2) -> PackedVector2Array:
	return companion_grid.get_point_path(_nearest_walkable_cell(from), _nearest_walkable_cell(to))


func safe_save_position(point: Vector2) -> Vector2:
	var clamped := Vector2(
		clampf(point.x, WALKABLE_BOUNDS.position.x, WALKABLE_BOUNDS.end.x),
		clampf(point.y, WALKABLE_BOUNDS.position.y, WALKABLE_BOUNDS.end.y)
	)
	if MAIN_HOUSE.grow(7).has_point(clamped) or SMALL_HOUSE.grow(7).has_point(clamped):
		return companion_grid.get_point_position(_nearest_walkable_cell(clamped))
	return clamped


func get_companion_rest_position(player_position: Vector2, away: Vector2, distance: float) -> Vector2:
	var desired := player_position + away.normalized() * distance
	var closest := desired
	var best_score := INF
	for x in range(80):
		for y in range(45):
			var cell := Vector2i(x, y)
			if companion_grid.is_point_solid(cell):
				continue
			var point := companion_grid.get_point_position(cell)
			if point.distance_to(player_position) < distance:
				continue
			var score := point.distance_squared_to(desired)
			if score < best_score:
				best_score = score
				closest = point
	return closest


func _nearest_walkable_cell(point: Vector2) -> Vector2i:
	var closest := Vector2i.ZERO
	var best_distance := INF
	# El patio es pequeño; esto también resuelve destinos pegados al muro o al techo.
	for x in range(80):
		for y in range(45):
			var cell := Vector2i(x, y)
			if companion_grid.is_point_solid(cell):
				continue
			var distance := point.distance_squared_to(companion_grid.get_point_position(cell))
			if distance < best_distance:
				best_distance = distance
				closest = cell
	return closest


func _draw_lawn(bounds: Rect2) -> void:
	draw_rect(bounds, Color("52753b"))
	var random := RandomNumberGenerator.new()
	random.seed = int(bounds.position.x * 1000 + bounds.position.y)
	for blade in range(int(bounds.get_area() / 9.0)):
		var point := bounds.position + Vector2(random.randf() * bounds.size.x, random.randf() * bounds.size.y)
		var tone := Color("71934a") if blade % 3 == 0 else Color("3e6231")
		draw_line(point, point + Vector2(0.6, -1.2), tone, 0.6)


func _draw_path(bounds: Rect2) -> void:
	draw_rect(bounds, Color("c4bead"))
	draw_rect(bounds, Color("e0d8c5"), false, 1)
	if bounds.size.x > bounds.size.y:
		for joint in range(1, int(bounds.size.x / 20)):
			var x := bounds.position.x + joint * 20
			draw_line(Vector2(x, bounds.position.y), Vector2(x, bounds.end.y), Color("a29f90"), 0.6)
	else:
		for joint in range(1, int(bounds.size.y / 18)):
			var y := bounds.position.y + joint * 18
			draw_line(Vector2(bounds.position.x, y), Vector2(bounds.end.x, y), Color("a29f90"), 0.6)


func _draw_shrub(center: Vector2, radius: float, flowers: Color, seed_value: int) -> void:
	draw_circle(center + Vector2(2, 3), radius, Color(0.13, 0.2, 0.1, 0.35))
	draw_circle(center, radius, Color("294e2d"))
	for leaf in range(12):
		var angle := float(leaf) * 2.4 + seed_value
		var offset := Vector2(cos(angle), sin(angle)) * radius * (0.35 + float(leaf % 3) * 0.2)
		draw_circle(center + offset, radius * 0.28, Color("668b40") if leaf % 2 == 0 else Color("416b34"))
		if leaf % 3 == 0:
			draw_circle(center + offset, 1.5, flowers)
			draw_circle(center + offset, 0.5, Color("f5d784"))


func _draw_house(roof: Rect2) -> void:
	draw_rect(Rect2(roof.position + Vector2(3, 5), roof.size), Color(0.12, 0.13, 0.1, 0.4))
	draw_rect(Rect2(roof.position + Vector2(2, roof.size.y), Vector2(roof.size.x - 4, 7)), Color("dbccb0"))
	var door := Vector2(roof.get_center().x - 5, roof.end.y)
	draw_rect(Rect2(door, Vector2(10, 7)), Color("4c3a2b"))
	draw_rect(roof.grow(2), Color("e6d9bf"))
	draw_rect(roof, Color("a74f31"))
	for column in range(int(roof.size.x / 6)):
		for row in range(int(roof.size.y / 5)):
			var point := roof.position + Vector2(column * 6, row * 5)
			var tone := Color("ce7046") if (row + column) % 3 != 0 else Color("bb5e3a")
			draw_rect(Rect2(point + Vector2(1, 0), Vector2(4, 5)), tone)
			draw_line(point + Vector2(2, 0), point + Vector2(2, 4), Color("e68a56"), 0.7)
			draw_line(point + Vector2(0, 4), point + Vector2(6, 4), Color("88422d"), 0.6)
	var inset := roof.size.y * 0.45
	var left_ridge := Vector2(roof.position.x + inset, roof.get_center().y)
	var right_ridge := Vector2(roof.end.x - inset, roof.get_center().y)
	draw_colored_polygon(PackedVector2Array([
		roof.position, roof.position + Vector2(roof.size.x, 0), right_ridge, left_ridge
	]), Color(1, 0.8, 0.5, 0.12))
	draw_colored_polygon(PackedVector2Array([
		roof.end, roof.position + Vector2(roof.size.x, 0), right_ridge
	]), Color(0.2, 0.1, 0.05, 0.2))
	var edges := [
		[roof.position, left_ridge],
		[roof.position + Vector2(0, roof.size.y), left_ridge],
		[roof.position + Vector2(roof.size.x, 0), right_ridge],
		[roof.end, right_ridge],
		[left_ridge, right_ridge],
	]
	for edge in edges:
		draw_line(edge[0] + Vector2(0, 1), edge[1] + Vector2(0, 1), Color("7f3d2b"), 4)
		draw_line(edge[0], edge[1], Color("de8352"), 3)
