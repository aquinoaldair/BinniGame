extends Node2D

const Assets = preload("res://scripts/presentation/patio_assets.gd")
const Portrait = preload("res://assets/characters/vecina/vecina.png")
const SOURCE_SIZE := Vector2(1024, 1536)
const REGION := Rect2(226, 58, 603, 1428)


func _ready() -> void:
	Assets.shadow(self, Vector2(29, 9))
	var ratio := Portrait.get_size() / SOURCE_SIZE
	var texture := AtlasTexture.new()
	texture.atlas = Portrait
	texture.region = Rect2(REGION.position * ratio, REGION.size * ratio)
	texture.filter_clip = true
	var sprite := Sprite2D.new()
	sprite.name = "Portrait"
	sprite.texture = texture
	sprite.centered = false
	var visual_scale := 79.0 / texture.get_height()
	sprite.scale = Vector2.ONE * visual_scale
	sprite.position = Vector2(-texture.get_width() * 0.5, -texture.get_height()) * visual_scale
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	add_child(sprite)
