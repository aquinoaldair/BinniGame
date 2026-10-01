extends RefCounted

const Props = preload("res://assets/jacinto/props_atlas.png")
const Portrait = preload("res://assets/characters/jacinto/jacinto.png")
const REGIONS := {
	"huanacaxtle": Rect2(12, 18, 979, 589),
	"mango_tree": Rect2(997, 15, 535, 599),
	"mango": Rect2(292, 630, 359, 363),
	"slingshot": Rect2(979, 623, 395, 375),
	"jacinto": Rect2(267, 29, 499, 1487),
}


static func texture_for(asset: String, region := Rect2()) -> AtlasTexture:
	var source: Texture2D = Portrait if asset == "jacinto" else Props
	var original := Vector2(1024, 1536) if asset == "jacinto" else Vector2(1536, 1024)
	var ratio := source.get_size() / original
	var crop: Rect2 = REGIONS[asset] if region.size == Vector2.ZERO else region
	var texture := AtlasTexture.new()
	texture.atlas = source
	texture.region = Rect2(crop.position * ratio, crop.size * ratio)
	texture.filter_clip = true
	return texture


static func sprite(parent: Node, asset: String, bounds: Rect2, region := Rect2()) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture_for(asset, region)
	sprite.centered = false
	sprite.position = bounds.position
	sprite.scale = bounds.size / sprite.texture.get_size()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	parent.add_child(sprite)
	return sprite
