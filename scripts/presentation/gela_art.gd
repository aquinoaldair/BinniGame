extends Node2D

# Capa visual: solamente lee el estado de la compañera.
const SpriteAnimations = preload("res://assets/characters/gela/sprite_frames.tres")
const BODY_LENGTH := 18.0
const SOURCE_BODY_LENGTH := 100.0
const SPRITE_SCALE := BODY_LENGTH / SOURCE_BODY_LENGTH
const FLOOR_ORIGIN := Vector2(256, 384)
const WALK_REFERENCE_SPEED := 90.0

var companion: CharacterBody2D
var sprite: AnimatedSprite2D
var direction := "right"
var breath_time := 0.0


func _ready() -> void:
	companion = get_parent()
	sprite = AnimatedSprite2D.new()
	sprite.name = "AnimatedSprite2D"
	sprite.sprite_frames = SpriteAnimations
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.scale = Vector2.ONE * SPRITE_SCALE
	sprite.position = -FLOOR_ORIGIN * sprite.scale
	add_child(sprite)
	sprite.play("idle_right")
	queue_redraw()


func _process(delta: float) -> void:
	if not companion.get("available") or not is_visible_in_tree():
		sprite.pause()
		return
	var facing: Vector2 = companion.get("facing")
	direction = _direction_for(facing)
	var walking := companion.velocity.length_squared() > 1.0
	var animation := ("walk_" if walking else "idle_") + direction
	if sprite.animation != animation or not sprite.is_playing():
		sprite.play(animation)
	sprite.speed_scale = clampf(companion.velocity.length() / WALK_REFERENCE_SPEED, 0.35, 1.0) if walking else 1.0
	breath_time += delta
	var breath := 1.0 if walking else 1.0 + sin(breath_time * 1.8) * 0.008
	sprite.scale = Vector2(1, breath) * SPRITE_SCALE
	# La respiración conserva el punto del suelo bajo el centro del cuerpo.
	sprite.position = -FLOOR_ORIGIN * sprite.scale


func _direction_for(facing: Vector2) -> String:
	if facing.length_squared() < 0.001:
		return direction
	# Evita alternar vistas por diferencias mínimas al recorrer celdas diagonales.
	if absf(absf(facing.x) - absf(facing.y)) < 0.08:
		var axes := {"left": Vector2.LEFT, "right": Vector2.RIGHT, "up": Vector2.UP, "down": Vector2.DOWN}
		if facing.dot(axes[direction]) > 0.3:
			return direction
	if absf(facing.x) > absf(facing.y):
		return "left" if facing.x < 0 else "right"
	return "up" if facing.y < 0 else "down"


func _draw() -> void:
	for ring in range(5):
		var points := PackedVector2Array()
		for index in range(32):
			var angle := TAU * index / 32.0
			points.append(Vector2(cos(angle) * (7 + ring * 0.7), sin(angle) * (2 + ring * 0.3)))
		draw_colored_polygon(points, Color(0.13, 0.19, 0.13, 0.025))
