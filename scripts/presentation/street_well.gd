extends Node2D

const Assets = preload("res://scripts/presentation/patio_assets.gd")
const Atlas = preload("res://assets/street/well.png")
const SOURCE_SIZE := Vector2(1536, 1024)
const REGION := Rect2(300, 46, 930, 914)
const WORLD_WIDTH := 58.0


func _ready() -> void:
	y_sort_enabled = true
	var base := Node2D.new()
	base.name = "WellBase"
	base.y_sort_enabled = true
	add_child(base)
	var back := _layer(base, "BackRim", 115)
	Assets.shadow(back, Vector2(64, 25), Vector2(5, 27))
	_piece(back, 370, 700)
	var structure := _layer(self, "WellStructure", 134)
	_piece(structure, int(REGION.position.y), 370)
	var front := _layer(base, "FrontRim", 155)
	_piece(front, 700, int(REGION.end.y))
	var bucket := _layer(self, "Bucket", 156)
	bucket.position.x = 258
	Assets.shadow(bucket, Vector2(13, 5))
	Assets.sprite(bucket, "bucket", Rect2(-5.5, -14, 11, 14))


func _layer(parent: Node, node_name: String, depth: float) -> Node2D:
	var layer := Node2D.new()
	layer.name = node_name
	layer.position = Vector2(225, depth)
	parent.add_child(layer)
	return layer


func _piece(parent: Node2D, top: int, bottom: int) -> void:
	var source := Rect2(REGION.position.x, top, REGION.size.x, bottom - top)
	var ratio := Atlas.get_size() / SOURCE_SIZE
	var texture := AtlasTexture.new()
	texture.atlas = Atlas
	texture.region = Rect2(source.position * ratio, source.size * ratio)
	texture.filter_clip = true
	var sprite := Sprite2D.new()
	sprite.name = "Artwork"
	sprite.texture = texture
	sprite.centered = false
	var world_scale := WORLD_WIDTH / REGION.size.x
	sprite.position = Vector2(-WORLD_WIDTH * 0.5, 155 - parent.position.y - (REGION.end.y - top) * world_scale)
	sprite.scale = source.size * world_scale / texture.get_size()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	parent.add_child(sprite)
