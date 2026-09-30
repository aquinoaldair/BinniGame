extends Node2D

# Superficies estáticas: TileMapLayer con recortes orgánicos, sin física.
const Tiles = preload("res://assets/patio/ground_tileset.tres")
const Assets = preload("res://scripts/presentation/patio_assets.gd")
const WORLD_TILE_SIZE := 16.0
const TEXTURE_TILE_SIZE := Vector2(159, 153)
var layers: Array[TileMapLayer] = []


func _ready() -> void:
	_surface("OuterEarth", 1, PackedVector2Array([Vector2(0, -32), Vector2(480, -32), Vector2(480, 270), Vector2(0, 270)]))
	_surface("GardenLeft", 0, PackedVector2Array([Vector2(40, 101), Vector2(83, 99), Vector2(139, 102), Vector2(192, 99), Vector2(192, 142), Vector2(206, 153), Vector2(235, 155), Vector2(237, 179), Vector2(234, 207), Vector2(118, 210), Vector2(115, 246), Vector2(84, 251), Vector2(39, 248)]))
	_surface("GardenRight", 0, PackedVector2Array([Vector2(254, 226), Vector2(320, 224), Vector2(377, 226), Vector2(441, 224), Vector2(443, 250), Vector2(255, 250)]))
	_surface("GateWalkway", 2, PackedVector2Array([Vector2(51, 51), Vector2(197, 51), Vector2(195, 99), Vector2(158, 98), Vector2(116, 101), Vector2(52, 98)]))
	_surface("HouseWalkway", 2, PackedVector2Array([Vector2(195, 52), Vector2(209, 52), Vector2(209, 139), Vector2(443, 139), Vector2(443, 158), Vector2(254, 157), Vector2(253, 212), Vector2(444, 211), Vector2(444, 225), Vector2(241, 226), Vector2(237, 207), Vector2(239, 156), Vector2(197, 156), Vector2(194, 148)]))
	_surface("HomeWalkway", 2, PackedVector2Array([Vector2(116, 209), Vector2(239, 209), Vector2(241, 219), Vector2(117, 217)]))
	_surface("ClayPatio", 3, PackedVector2Array([Vector2(258, 161), Vector2(307, 159), Vector2(356, 162), Vector2(435, 160), Vector2(438, 180), Vector2(435, 209), Vector2(258, 210), Vector2(256, 188)]))
	# Pequeños desgastes irregulares; no se añaden obstáculos ni senderos nuevos.
	for point in [Vector2(100, 131), Vector2(160, 181), Vector2(91, 218), Vector2(375, 236)]:
		Assets.sprite(self, "dry_patch", Rect2(point - Vector2(10, 6), Vector2(21, 13))).modulate.a = 0.33
	for point in [Vector2(54, 161), Vector2(135, 198), Vector2(407, 230)]:
		Assets.sprite(self, "leaves", Rect2(point, Vector2(8, 5))).modulate.a = 0.65
	for point in [Vector2(129, 126), Vector2(178, 177), Vector2(354, 239)]:
		Assets.sprite(self, "flowers", Rect2(point, Vector2(4, 3))).modulate.a = 0.55


func _surface(node_name: String, material_id: int, outline: PackedVector2Array) -> void:
	var mask := Polygon2D.new()
	mask.name = node_name
	_feather_mask(mask, outline)
	mask.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	add_child(mask)
	var layer := TileMapLayer.new()
	layer.name = "Tiles"
	layer.tile_set = Tiles
	layer.scale = Vector2.ONE * WORLD_TILE_SIZE / TEXTURE_TILE_SIZE
	layer.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	layer.collision_enabled = false
	layer.navigation_enabled = false
	layer.occlusion_enabled = false
	mask.add_child(layer)
	layers.append(layer)
	var bounds := Rect2(outline[0], Vector2.ZERO)
	for point in outline:
		bounds = bounds.expand(point)
	for y in range(floori(bounds.position.y / WORLD_TILE_SIZE), ceili(bounds.end.y / WORLD_TILE_SIZE)):
		for x in range(floori(bounds.position.x / WORLD_TILE_SIZE), ceili(bounds.end.x / WORLD_TILE_SIZE)):
			var atlas := Vector2i(posmod(x, 4), posmod(y, 4))
			# Variantes contiguas: las pinceladas cruzan las celdas sin cortes aleatorios.
			layer.set_cell(Vector2i(x, y), material_id, atlas)


func _feather_mask(mask: Polygon2D, outline: PackedVector2Array) -> void:
	var inside := PackedVector2Array()
	var colors := PackedColorArray()
	var count := outline.size()
	for index in range(count):
		var previous := (outline[index] - outline[posmod(index - 1, count)]).normalized()
		var next := (outline[(index + 1) % count] - outline[index]).normalized()
		var normal := Vector2(-next.y, next.x)
		var bisector := (Vector2(-previous.y, previous.x) + normal).normalized()
		inside.append(outline[index] + bisector * 1.4 / maxf(0.25, bisector.dot(normal)))
		colors.append(Color(1, 1, 1, 0))
	var points := outline.duplicate()
	points.append_array(inside)
	var triangles := Geometry2D.triangulate_polygon(inside)
	var polygons: Array[PackedInt32Array] = []
	for index in range(0, triangles.size(), 3):
		polygons.append(PackedInt32Array([count + triangles[index], count + triangles[index + 1], count + triangles[index + 2]]))
	for index in range(count):
		var next := (index + 1) % count
		polygons.append(PackedInt32Array([index, next, count + next, count + index]))
		colors.append(Color.WHITE)
	mask.polygon = points
	mask.vertex_colors = colors
	mask.polygons = polygons
