extends Node2D

# Solo presentación: el controlador conserva toda decisión de movimiento e interacción.
enum Pose { IDLE, WALK, INTERACT }
const VISUAL_SCALE := 1.5
const PREVIOUS_HEIGHT := 51.0
const ATLAS_REFERENCE_HEIGHT := 234.0
const SPRITE_SCALE := PREVIOUS_HEIGHT * VISUAL_SCALE / ATLAS_REFERENCE_HEIGHT
const SpriteAnimations = preload("res://assets/characters/nisa/sprite_frames.tres")

var protagonist := true
var actor: Node2D
var modern_enabled := true
var pose := Pose.IDLE
var direction := "down"
var sprite: AnimatedSprite2D


func _ready() -> void:
	sprite = AnimatedSprite2D.new()
	sprite.name = "AnimatedSprite2D"
	sprite.sprite_frames = SpriteAnimations
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.scale = Vector2.ONE * SPRITE_SCALE
	# El atlas base usa este origen; el lateral declara su geometría en metadatos.
	sprite.position = Vector2(-160, -304) * SPRITE_SCALE
	add_child(sprite)
	sprite.play("idle_down")
	_sync_frame_geometry()
	queue_redraw()


func _process(_delta: float) -> void:
	if not modern_enabled or not is_visible_in_tree():
		return
	# Usa la dirección que ya mantiene player.gd, incluso al detenerse.
	var facing: Vector2 = actor.facing
	if absf(facing.x) > absf(facing.y):
		direction = "left" if facing.x < 0 else "right"
	else:
		direction = "up" if facing.y < 0 else "down"
	pose = Pose.INTERACT if not actor.can_move else (Pose.WALK if actor.velocity.length_squared() > 1 else Pose.IDLE)
	var base_animation := "walk" if pose == Pose.WALK else ("talk" if pose == Pose.INTERACT else "idle")
	var animation := base_animation + "_" + direction
	# Permite añadir talk_* después sin cambiar el controlador ni los diálogos.
	if not sprite.sprite_frames.has_animation(animation):
		animation = "idle_" + direction
	if sprite.animation != animation or not sprite.is_playing():
		sprite.play(animation)
	_sync_frame_geometry()


func _sync_frame_geometry() -> void:
	# Cada atlas declara su resolución de origen; el tamaño en el mundo se conserva.
	var texture := sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	var origin: Vector2 = texture.get_meta("foot_origin", Vector2(160, 304))
	var reference_height: float = texture.get_meta("reference_height", ATLAS_REFERENCE_HEIGHT)
	sprite.scale = Vector2.ONE * PREVIOUS_HEIGHT * VISUAL_SCALE / reference_height
	sprite.position = -origin * sprite.scale


func _draw() -> void:
	# Sombra separada del atlas: no se agranda el cuerpo de colisión.
	for ring in range(5):
		var points := PackedVector2Array()
		for index in range(32):
			var angle := TAU * index / 32.0
			points.append(Vector2(cos(angle) * (10 + ring), sin(angle) * (2.5 + ring * 0.6)))
		draw_colored_polygon(points, Color(0.13, 0.19, 0.13, 0.025))
