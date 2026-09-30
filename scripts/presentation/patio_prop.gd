extends Node2D

# Props ilustrados reutilizables; no crean colisiones ni ejecutan _process.
const Assets = preload("res://scripts/presentation/patio_assets.gd")
@export var kind := "plant"
@export var extent := Vector2(15, 18)
@export var seed_value := 0
var canopy: Node2D
var cloths: Array[Sprite2D] = []
var gate_leaves: Array[Sprite2D] = []
var open_gate := false:
	set(value):
		open_gate = value
		_sync_gate()


func _ready() -> void:
	match kind:
		"tree": _tree()
		"plant": _plant()
		"bench": _object("bench", Vector2(36, 28))
		"bucket": _object("bucket", Vector2(11, 14))
		"broom": _object("broom", Vector2(10, 29))
		"chair": _object("chair", Vector2(17, 26))
		"jars": _object("jars", Vector2(19, 15))
		"wall": _wall()
		"gate": _gate()
		"book": _object("book", Vector2(13, 7))
		"cloth": _cloth()


func _object(asset: String, size: Vector2) -> Sprite2D:
	Assets.shadow(self, Vector2(size.x * 1.25, maxf(5, size.y * 0.22)))
	return Assets.sprite(self, asset, Rect2(Vector2(-size.x * 0.5, -size.y), size))


func _plant() -> void:
	var variants := ["bush_small", "flowers", "pot_small", "herb", "pot_pink", "bush_flower", "pot_yellow", "pot_blue", "pot_medium", "grass", "bush_large"]
	var asset: String = variants[posmod(seed_value, variants.size())]
	var width := extent.x * 2.0
	var height := extent.y * 1.7
	_object(asset, Vector2(width, height)).modulate = Color.WHITE.lerp(Color("e3e8d9"), float(posmod(seed_value, 3)) * 0.035)


func _tree() -> void:
	var asset := "tree_" + str(posmod(seed_value, 3) + 1)
	var texture := Assets.texture_for(asset)
	var full := texture.region
	var split := floorf(full.size.y * 0.75)
	var width := extent.x
	var height := extent.y
	Assets.shadow(self, Vector2(width * 1.25, height * 0.32), Vector2(9, 4))
	var base := Node2D.new()
	base.name = "TreeBase"
	add_child(base)
	var trunk_texture := AtlasTexture.new()
	trunk_texture.atlas = texture.atlas
	trunk_texture.region = Rect2(full.position + Vector2(0, split), Vector2(full.size.x, full.size.y - split))
	trunk_texture.filter_clip = true
	var trunk := Sprite2D.new()
	trunk.name = "Trunk"
	trunk.texture = trunk_texture
	trunk.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	trunk.centered = false
	trunk.scale = Vector2(width, height) / full.size
	trunk.position = Vector2(-width * 0.5, -height + split * trunk.scale.y)
	base.add_child(trunk)
	canopy = Node2D.new()
	canopy.name = "TreeCanopy"
	add_child(canopy)
	var crown_texture := AtlasTexture.new()
	crown_texture.atlas = texture.atlas
	crown_texture.region = Rect2(full.position, Vector2(full.size.x, split + 3))
	crown_texture.filter_clip = true
	var crown := Sprite2D.new()
	crown.name = "Leaves"
	crown.texture = crown_texture
	crown.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	crown.centered = false
	crown.scale = trunk.scale
	crown.position = Vector2(-width * 0.5, -height)
	canopy.add_child(crown)


func update_occlusion(player_position: Vector2) -> void:
	if canopy == null:
		return
	var foot := to_local(player_position)
	# Orden por Y en el tronco; solo la copa se suaviza cuando tapa a la protagonista.
	canopy.modulate.a = 0.63 if foot.y < 0 and foot.y > -extent.y and absf(foot.x) < extent.x * 0.5 + 8 else 1.0


func _wall() -> void:
	# Tiras horizontales compartidas, sin un nodo por bloque o ladrillo.
	Assets.sprite(self, "wall_strip", Rect2(0, -14, extent.x, 14), "Wall")


func _gate() -> void:
	Assets.shadow(self, Vector2(152, 11), Vector2(5, 2))
	for side in [-1.0, 1.0]:
		Assets.sprite(self, "pillar", Rect2(side * 74 - 4, -32, 8, 33))
	gate_leaves.append(Assets.sprite(self, "gate_left", Rect2(-70.5, -27, 70.5, 27), "GateLeft"))
	gate_leaves.append(Assets.sprite(self, "gate_right", Rect2(0, -27, 70.5, 27), "GateRight"))
	_sync_gate()


func _sync_gate() -> void:
	if gate_leaves.size() != 2:
		return
	for index in range(2):
		var leaf := gate_leaves[index]
		leaf.scale.x = (14.0 if open_gate else 70.5) / leaf.texture.get_width()
		leaf.position.x = -70.5 if index == 0 else (56.5 if open_gate else 0.0)


func _cloth() -> void:
	Assets.shadow(self, Vector2(36, 8), Vector2(4, 1))
	for x in [-19.0, 19.0]:
		Assets.sprite(self, "column", Rect2(x - 1, -22, 2, 23)).modulate = Color("aa8d66")
	var rope := Line2D.new()
	rope.name = "Clothesline"
	rope.points = PackedVector2Array([Vector2(-19, -21), Vector2(0, -19.5), Vector2(19, -21)])
	rope.width = 0.5
	rope.default_color = Color("83745b")
	add_child(rope)
	cloths.append(Assets.sprite(self, "cloth_cream", Rect2(-15, -21, 17, 18)))
	cloths.append(Assets.sprite(self, "cloth_teal", Rect2(5, -21, 11, 15)))
