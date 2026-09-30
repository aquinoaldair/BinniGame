extends RefCounted

# Regiones del PNG original; no se alteran los píxeles generados.
const ATLASES := {
	"vegetation": preload("res://assets/patio/vegetation_atlas.png"),
	"architecture": preload("res://assets/patio/architecture_atlas.png"),
	"details": preload("res://assets/patio/details_atlas.png"),
}
const REGIONS := {
	"tree_1": ["vegetation", Rect2(6, 28, 321, 348)],
	"tree_2": ["vegetation", Rect2(334, 56, 294, 316)],
	"tree_3": ["vegetation", Rect2(638, 79, 328, 293)],
	"bush_large": ["vegetation", Rect2(964, 145, 287, 237)],
	"bush_small": ["vegetation", Rect2(32, 433, 275, 211)],
	"bush_flower": ["vegetation", Rect2(332, 405, 288, 238)],
	"herb": ["vegetation", Rect2(649, 457, 293, 182)],
	"flowers": ["vegetation", Rect2(976, 466, 263, 178)],
	"pot_small": ["vegetation", Rect2(67, 701, 194, 224)],
	"pot_medium": ["vegetation", Rect2(328, 654, 291, 281)],
	"pot_pink": ["vegetation", Rect2(665, 675, 275, 263)],
	"pot_yellow": ["vegetation", Rect2(1007, 705, 206, 230)],
	"grass": ["vegetation", Rect2(33, 960, 277, 256)],
	"dry_patch": ["vegetation", Rect2(336, 976, 283, 234)],
	"leaves": ["vegetation", Rect2(677, 995, 254, 184)],
	"pot_blue": ["vegetation", Rect2(1003, 965, 225, 246)],
	"roof_large": ["architecture", Rect2(12, 105, 384, 151)],
	"roof_small": ["architecture", Rect2(398, 102, 281, 153)],
	"wall_clay": ["architecture", Rect2(686, 88, 297, 185)],
	"wall_blue": ["architecture", Rect2(998, 85, 231, 190)],
	"door_jade": ["architecture", Rect2(76, 338, 209, 275)],
	"door_wood": ["architecture", Rect2(394, 341, 206, 272)],
	"window_bars": ["architecture", Rect2(694, 354, 216, 248)],
	"window_shutters": ["architecture", Rect2(1006, 353, 201, 240)],
	"column": ["architecture", Rect2(100, 644, 89, 249)],
	"porch": ["architecture", Rect2(249, 783, 362, 91)],
	"wall_strip": ["architecture", Rect2(630, 724, 448, 136)],
	"pillar": ["architecture", Rect2(1090, 646, 101, 226)],
	"bench": ["architecture", Rect2(55, 961, 286, 220)],
	"bucket": ["architecture", Rect2(429, 974, 171, 208)],
	"broom": ["architecture", Rect2(715, 898, 126, 306)],
	"chair": ["architecture", Rect2(985, 922, 180, 276)],
	"gate_left": ["details", Rect2(44, 167, 272, 287)],
	"gate_right": ["details", Rect2(316, 167, 276, 287)],
	"cloth_cream": ["details", Rect2(618, 95, 330, 386)],
	"cloth_teal": ["details", Rect2(1024, 133, 278, 325)],
	"jars": ["details", Rect2(1368, 175, 378, 303)],
	"book": ["details", Rect2(74, 572, 481, 249)],
	"leaf": ["details", Rect2(671, 634, 266, 132)],
	"butterfly_open": ["details", Rect2(1037, 583, 283, 207)],
	"butterfly_closed": ["details", Rect2(1449, 561, 219, 225)],
}
static var textures: Dictionary = {}
static var shadow_texture: GradientTexture2D


static func texture_for(asset: String) -> AtlasTexture:
	if not textures.has(asset):
		var texture := AtlasTexture.new()
		texture.atlas = ATLASES[REGIONS[asset][0]]
		texture.region = REGIONS[asset][1]
		texture.filter_clip = true
		textures[asset] = texture
	return textures[asset]


static func sprite(parent: Node, asset: String, bounds: Rect2, node_name: String = "") -> Sprite2D:
	var image := Sprite2D.new()
	image.name = node_name if not node_name.is_empty() else asset.to_pascal_case()
	image.texture = texture_for(asset)
	image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS if REGIONS[asset][0] == "vegetation" else CanvasItem.TEXTURE_FILTER_LINEAR
	image.centered = false
	image.position = bounds.position
	image.scale = bounds.size / image.texture.get_size()
	parent.add_child(image)
	return image


static func shadow(parent: Node, size: Vector2, at: Vector2 = Vector2(4, 2)) -> Sprite2D:
	if shadow_texture == null:
		var gradient := Gradient.new()
		gradient.offsets = PackedFloat32Array([0, 0.5, 1])
		gradient.colors = PackedColorArray([Color(0.16, 0.20, 0.13, 0.17), Color(0.16, 0.20, 0.13, 0.08), Color(0.16, 0.20, 0.13, 0)])
		shadow_texture = GradientTexture2D.new()
		shadow_texture.gradient = gradient
		shadow_texture.width = 64
		shadow_texture.height = 64
		shadow_texture.fill = GradientTexture2D.FILL_RADIAL
		shadow_texture.fill_from = Vector2(0.5, 0.5)
		shadow_texture.fill_to = Vector2(1, 0.5)
	var image := Sprite2D.new()
	image.name = "GroundShadow"
	image.texture = shadow_texture
	image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	image.position = at
	image.scale = size / Vector2(64, 64)
	image.z_index = -5
	parent.add_child(image)
	return image
