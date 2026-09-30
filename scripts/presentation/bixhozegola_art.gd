extends Node2D

# Representación de la abuela: no mueve al NPC ni decide interacciones.
const SpriteAnimations = preload("res://assets/characters/bixhozegola/sprite_frames.tres")
const DRAW_HEIGHT := 86.0
const ATLAS_REFERENCE_HEIGHT := 465.5
const SPRITE_SCALE := DRAW_HEIGHT / ATLAS_REFERENCE_HEIGHT

var world: Node2D
var story: Node2D
var sprite: AnimatedSprite2D
var speaking := false


func _ready() -> void:
	story = world.get_node("PatioStory")
	sprite = AnimatedSprite2D.new()
	sprite.name = "AnimatedSprite2D"
	sprite.sprite_frames = SpriteAnimations
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.scale = Vector2.ONE * SPRITE_SCALE
	# Lienzo común; el origen visual es el suelo entre los pies.
	sprite.position = Vector2(-160, -512) * SPRITE_SCALE
	add_child(sprite)
	sprite.play("idle_down")
	queue_redraw()


func _process(_delta: float) -> void:
	if not is_visible_in_tree():
		sprite.pause()
		return
	# Lee el turno de voz existente sin cambiar texto, progreso ni posición.
	speaking = not story.dialogue.is_empty() and story.dialogue_index < story.dialogue.size() and story.dialogue[story.dialogue_index].begins_with("Bixhozegola:")
	var animation := "talk_down" if speaking else "idle_down"
	if sprite.animation != animation or not sprite.is_playing():
		sprite.play(animation)


func _draw() -> void:
	for ring in range(5):
		var points := PackedVector2Array()
		for index in range(32):
			var angle := TAU * index / 32.0
			points.append(Vector2(cos(angle) * (11 + ring), sin(angle) * (2.7 + ring * 0.6)))
		draw_colored_polygon(points, Color(0.13, 0.19, 0.13, 0.025))
