extends Node2D

const Assets = preload("res://scripts/presentation/patio_assets.gd")
const Atlas = preload("res://assets/street/fountain_atlas.png")
const SOURCE_SIZE := Vector2(1254, 1254)
var ripples: Array[Line2D] = []
var clock := 0.0
var accumulator := 0.0
var updates := 0


func _ready() -> void:
	y_sort_enabled = true
	var back := Node2D.new()
	back.name = "BasinBack"
	back.position = Vector2(225, 115)
	add_child(back)
	Assets.shadow(back, Vector2(62, 24), Vector2(5, 27))
	_piece(back, Rect2(34, 96, 1188, 351), Rect2(-27, 8, 54, 18.72), "StoneAndWater")
	for index in range(3):
		var ripple := Line2D.new()
		ripple.name = "Ripple%s" % index
		var points := PackedVector2Array()
		for step in range(25):
			var angle := TAU * step / 24.0
			points.append(Vector2(cos(angle) * 3.3, sin(angle) * 1.1))
		ripple.points = points
		ripple.width = 0.35
		ripple.default_color = Color("d6e7dc")
		ripple.antialiased = true
		ripple.position = Vector2(-9 + index * 9, 19 + index % 2 * 3)
		back.add_child(ripple)
		ripples.append(ripple)
	var center := Node2D.new()
	center.name = "CentralSpout"
	center.position = Vector2(225, 143)
	add_child(center)
	_piece(center, Rect2(463, 738, 330, 420), Rect2(-9, -26, 18, 26), "Spout")
	var front := Node2D.new()
	front.name = "BasinFront"
	front.position = Vector2(225, 155)
	add_child(front)
	_piece(front, Rect2(34, 447, 1188, 249), Rect2(-27, -13.28, 54, 13.28), "FrontRim")


func _piece(parent: Node, region: Rect2, bounds: Rect2, node_name: String) -> void:
	var ratio := Atlas.get_size() / SOURCE_SIZE
	var texture := AtlasTexture.new()
	texture.atlas = Atlas
	texture.region = Rect2(region.position * ratio, region.size * ratio)
	texture.filter_clip = true
	var sprite := Sprite2D.new()
	sprite.name = node_name
	sprite.texture = texture
	sprite.centered = false
	sprite.position = bounds.position
	sprite.scale = bounds.size / texture.get_size()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	parent.add_child(sprite)


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	accumulator += delta
	if accumulator < 1.0 / 12.0:
		return
	clock += accumulator
	accumulator = 0.0
	updates += 1
	for index in range(ripples.size()):
		var phase := fmod(clock * 0.45 + index * 0.33, 1.0)
		ripples[index].scale = Vector2.ONE * lerpf(0.65, 1.35, phase)
		ripples[index].modulate.a = sin(phase * PI) * 0.3
