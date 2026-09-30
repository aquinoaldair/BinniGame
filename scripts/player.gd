extends CharacterBody2D

const WALK_SPEED := 78.0
const ROOM_BOUNDS := Rect2(Vector2(34, 59), Vector2(411, 186))

var facing := Vector2.DOWN
var walk_phase := 0.0
var can_move := true
var human_art: Node2D # Conserva la referencia usada por la presentación del patio.
const NisaArt = preload("res://scripts/presentation/nisa_art.gd")


func _ready() -> void:
	human_art = NisaArt.new()
	human_art.name = "HumanArt"
	human_art.protagonist = true
	human_art.actor = self
	add_child(human_art)
	sync_presentation()


func sync_presentation() -> void:
	if human_art != null:
		human_art.modern_enabled = true
		human_art.visible = human_art.modern_enabled
	queue_redraw()


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if not can_move:
		direction = Vector2.ZERO
	velocity = direction * WALK_SPEED
	if direction.length_squared() > 0.0:
		facing = direction.normalized()
		walk_phase += delta * 11.0
	else:
		walk_phase = 0.0

	move_and_slide()
	position.x = clampf(position.x, ROOM_BOUNDS.position.x, ROOM_BOUNDS.end.x)
	position.y = clampf(position.y, ROOM_BOUNDS.position.y, ROOM_BOUNDS.end.y)
	queue_redraw()


func _draw() -> void:
	if human_art != null and human_art.modern_enabled:
		return
	var skin := Color("ae7453")
	var step := 0.0
	if velocity.length_squared() > 1.0:
		step = sin(walk_phase) * 2.0

	# Sombra y silueta dibujadas con formas simples mientras definimos el arte final.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-9, 8), Vector2(-5, 5), Vector2(5, 5), Vector2(9, 8),
		Vector2(5, 11), Vector2(-5, 11)
	]), Color(0.20, 0.23, 0.18, 0.30))

	# Piernas y sandalias.
	draw_rect(Rect2(Vector2(-5 + step, 0), Vector2(4, 8)), skin)
	draw_rect(Rect2(Vector2(1 - step, 0), Vector2(4, 8)), skin)
	draw_rect(Rect2(Vector2(-6 + step, 6), Vector2(5, 2)), Color("6b4933"))
	draw_rect(Rect2(Vector2(1 - step, 6), Vector2(5, 2)), Color("6b4933"))

	# Cabello largo detrás de los hombros.
	draw_rect(Rect2(Vector2(-7, -16), Vector2(14, 11)), Color("28271f"))

	# Falda con silueta acampanada y pliegues suaves.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-5, -1), Vector2(5, -1), Vector2(8, 5), Vector2(-8, 5)
	]), Color("171719"))
	draw_line(Vector2(-3, 0), Vector2(-4, 4), Color("303034"), 1.0)
	draw_line(Vector2(3, 0), Vector2(4, 4), Color("303034"), 1.0)

	# Brazos separados del torso; las manos acompañan los pasos.
	var left_hand := Vector2(-9, -1 - step * 0.5)
	var right_hand := Vector2(9, -1 + step * 0.5)
	draw_line(Vector2(-8, -7), left_hand, skin, 3.0)
	draw_line(Vector2(8, -7), right_hand, skin, 3.0)
	draw_circle(left_hand, 1.8, skin)
	draw_circle(right_hand, 1.8, skin)
	draw_circle(left_hand + Vector2(1, -0.7), 0.8, Color("c58e68"))
	draw_circle(right_hand + Vector2(-1, -0.7), 0.8, Color("c58e68"))

	# Blusa negra con flores de colores y mangas ligeramente iluminadas.
	# Motivos ficticios provisionales, sin atribución a una prenda regional.
	draw_rect(Rect2(Vector2(-6, -10), Vector2(12, 10)), Color("171719"))
	draw_rect(Rect2(Vector2(-10, -10), Vector2(4, 5)), Color("242427"))
	draw_rect(Rect2(Vector2(6, -10), Vector2(4, 5)), Color("242427"))
	draw_circle(Vector2(0, -10), 2.0, skin)
	_draw_flower(Vector2(-3, -7), Color("dc5281"))
	_draw_flower(Vector2(3, -7), Color("638ad9"))
	_draw_flower(Vector2(0, -4), Color("e29b35"))
	_draw_flower(Vector2(-4, -2), Color("9c61c9"))
	_draw_flower(Vector2(4, -2), Color("d95649"))
	draw_rect(Rect2(Vector2(-6, 0), Vector2(12, 1)), Color("303034"))

	# Cabeza y cabello. La mirada cambia según la dirección del movimiento.
	draw_circle(Vector2(0, -14), 6.0, skin)
	draw_rect(Rect2(Vector2(-6, -19), Vector2(12, 4)), Color("28271f"))
	draw_line(Vector2(-5, -17), Vector2(-6, -9), Color("28271f"), 2.0)
	draw_line(Vector2(5, -17), Vector2(6, -9), Color("28271f"), 2.0)
	draw_circle(Vector2(5, -18), 1.5, Color("dc5281"))
	var eye_offset := Vector2.ZERO
	if absf(facing.x) > absf(facing.y):
		eye_offset.x = signf(facing.x) * 2.0
	else:
		eye_offset.y = signf(facing.y) * 1.5
	draw_circle(Vector2(eye_offset.x - 2, -14 + eye_offset.y), 0.8, Color("201e1a"))
	draw_circle(Vector2(eye_offset.x + 2, -14 + eye_offset.y), 0.8, Color("201e1a"))

	# Nombre temporal para reconocer al personaje en esta primera prueba.
	draw_string(ThemeDB.fallback_font, Vector2(-9, -25), "NISA", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color("fff2cb"))


func _draw_flower(center: Vector2, petal_color: Color) -> void:
	draw_line(center + Vector2(0, 1), center + Vector2(0.5, 2), Color("426b49"), 0.7)
	for petal in range(5):
		var angle := TAU * float(petal) / 5.0
		var offset := Vector2(cos(angle), sin(angle)) * 1.1
		draw_circle(center + offset, 0.8, petal_color)
	draw_circle(center, 0.6, Color("f5d35c"))
