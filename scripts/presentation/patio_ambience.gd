extends Node2D

# Un único reloj ambiental a 12 Hz; cambia transformaciones, nunca redibuja props.
const Assets = preload("res://scripts/presentation/patio_assets.gd")
var trees: Array[Node2D] = []
var clothes: Array[Sprite2D] = []
var leaves: Array[Sprite2D] = []
var butterfly: AnimatedSprite2D
var clock := 0.0
var accumulator := 0.0
var updates := 0


func _ready() -> void:
	for index in range(2):
		var leaf := Assets.sprite(self, "leaf", Rect2(-1, -0.5, 2, 1))
		leaf.modulate.a = 0.7
		leaves.append(leaf)
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	frames.add_animation("flutter")
	frames.set_animation_speed("flutter", 5)
	for asset in ["butterfly_open", "butterfly_closed"]:
		var source := Assets.texture_for(asset)
		var texture := AtlasTexture.new()
		texture.atlas = source.atlas
		texture.region = source.region
		texture.margin = Rect2((Vector2(512, 512) - source.region.size) * 0.5, Vector2(512, 512) - source.region.size)
		texture.filter_clip = true
		frames.add_frame("flutter", texture)
	butterfly = AnimatedSprite2D.new()
	butterfly.name = "Butterfly"
	butterfly.sprite_frames = frames
	butterfly.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	butterfly.scale = Vector2.ONE * 3.0 / 283.0
	add_child(butterfly)
	butterfly.play("flutter")


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		butterfly.pause()
		return
	if not butterfly.is_playing():
		butterfly.play("flutter")
	accumulator += delta
	if accumulator < 1.0 / 12.0:
		return
	clock += accumulator
	accumulator = 0.0
	updates += 1
	for index in range(trees.size()):
		trees[index].position.x = sin(clock * 0.7 + index * 2.3) * 0.35
	for index in range(clothes.size()):
		clothes[index].rotation = sin(clock * 1.1 + index * 1.4) * 0.012
	butterfly.position = Vector2(128 + sin(clock * 0.35) * 24, 170 + cos(clock * 0.46) * 9)
	for index in range(leaves.size()):
		var travel := fmod(clock * 2.1 + index * 31, 76)
		leaves[index].position = Vector2(64 + index * 53 + sin(travel * 0.05) * 4, 119 + travel)
		leaves[index].rotation = sin(clock * 0.8 + index) * 0.3
