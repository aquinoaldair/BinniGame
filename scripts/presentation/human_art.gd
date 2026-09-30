extends Node2D

# Solo representación: las colisiones, posiciones y movimiento pertenecen al actor.
enum Pose { IDLE, WALK, INTERACT }
var protagonist := false
var actor: Node2D
var observer: Node2D
var pose := Pose.IDLE
var clock := 0.0
var modern_enabled := true
const VISUAL_SCALE := 1.65


func _process(delta: float) -> void:
	if not modern_enabled or not is_visible_in_tree():
		return
	clock += delta
	if protagonist:
		pose = Pose.INTERACT if not actor.can_move else (Pose.WALK if actor.velocity.length_squared() > 1 else Pose.IDLE)
	else:
		pose = Pose.INTERACT if observer != null and not observer.can_move and actor.position.distance_to(observer.position) < 50 else Pose.IDLE
	queue_redraw()


func _draw() -> void:
	if not modern_enabled:
		return
	# Sombra en el suelo: no se agranda con el cuerpo.
	for ring in range(5):
		_ellipse(Vector2(1, 0), Vector2(13 + ring, 3.0 + ring * 0.65), Color(0.13, 0.19, 0.13, 0.024))
	var walking := pose == Pose.WALK
	var step := sin(actor.walk_phase) * 1.5 if walking else 0.0
	var breath := sin(clock * 2.1) * 0.22
	var bob := absf(step) * 0.25 if walking else breath
	draw_set_transform(Vector2(0, -6.0 * VISUAL_SCALE - bob), 0, Vector2.ONE * VISUAL_SCALE)
	var skin := Color("b77e5b") if protagonist else Color("ad795b")
	var hair := Color("302b27") if protagonist else Color("c0b8a9")
	var dress := Color("242728") if protagonist else Color("64576b")
	# Piernas y sandalias visibles por debajo del vestido.
	for side in [-1.0, 1.0]:
		var x: float = side * 3.0 + step * side * 0.45
		draw_line(Vector2(x, -1), Vector2(x, 5.8), skin, 2.8, true)
		_ellipse(Vector2(x + 0.3, 6), Vector2(2.6, 1.1), Color("6b4434"))
		draw_line(Vector2(x - 1.6, 5.1), Vector2(x + 1.6, 5.1), Color("bb9570"), 0.7, true)
	# Cabello detrás del torso, sin bloques rectangulares.
	_ellipse(Vector2(0, -16), Vector2(6.2, 8), hair)
	if protagonist:
		draw_colored_polygon(PackedVector2Array([Vector2(-6, -17), Vector2(6, -17), Vector2(7, -7), Vector2(3, -6), Vector2(-6, -7)]), hair)
	else:
		_ellipse(Vector2(4.8, -22), Vector2(3, 2.7), hair)
	# Falda, cintura y pliegues; el negro conserva contraste con la blusa.
	draw_colored_polygon(PackedVector2Array([Vector2(-4.5, -7), Vector2(4.5, -7), Vector2(7.1, 3), Vector2(2, 4), Vector2(-7.1, 3)]), dress)
	for fold in [-3.5, 0.0, 3.5]:
		draw_line(Vector2(fold * 0.65, -5), Vector2(fold, 2), Color("3e4140") if protagonist else Color("807080"), 0.55, true)
	# Brazos, mangas y manos: siluetas redondeadas y balanceo opuesto.
	for side in [-1.0, 1.0]:
		var hand := Vector2(side * 7.2, -3 + step * side)
		if pose == Pose.INTERACT:
			hand += Vector2(-side * 1.1, -2.4)
		draw_line(Vector2(side * 5.3, -12), hand, skin.darkened(0.07), 2.8, true)
		_ellipse(hand, Vector2(1.5, 1.8), skin)
		_ellipse(hand + Vector2(-side * 0.8, -0.5), Vector2(0.6, 0.8), skin.lightened(0.13))
		_ellipse(Vector2(side * 5.2, -11.8), Vector2(2.1, 2.8), Color("303435") if protagonist else Color("726379"))
	# Blusa negra con cuello y motivos florales ficticios.
	_ellipse(Vector2(0, -10), Vector2(5.2, 5.1), Color("202526") if protagonist else Color("6f6177"))
	draw_line(Vector2(-3.3, -6), Vector2(3.3, -6), Color("889077"), 0.6, true)
	_ellipse(Vector2(0, -14.4), Vector2(2.2, 1.9), skin)
	if protagonist:
		_flower(Vector2(-2.6, -11.8), Color("d97791"))
		_flower(Vector2(2.5, -11.6), Color("82b1c1"))
		_flower(Vector2(0, -8.5), Color("dbb05e"))
		_flower(Vector2(-3.4, -7.6), Color("ae85b4"))
		_flower(Vector2(3.3, -7.5), Color("d88262"))
	else:
		draw_line(Vector2(-3, -11), Vector2(3, -9), Color("baaa9f"), 1.2, true)
	# Cabeza, orejas y un pequeño brillo cálido en el rostro.
	_ellipse(Vector2(0, -19), Vector2(4.9, 5.4), skin)
	_ellipse(Vector2(-0.5, -20), Vector2(3.7, 3.9), skin.lightened(0.08))
	_ellipse(Vector2(-4.7, -18.3), Vector2(0.85, 1.3), skin)
	_ellipse(Vector2(4.7, -18.3), Vector2(0.85, 1.3), skin)
	var look: Vector2 = actor.facing if protagonist else Vector2.DOWN
	if not protagonist and observer != null:
		look = (observer.position - actor.position).normalized()
	# Al caminar hacia arriba se ve el cabello, no una cara mirando a la cámara.
	if protagonist and look.y < -0.5:
		_ellipse(Vector2(0, -20), Vector2(5.2, 5.2), hair)
		draw_line(Vector2(-2, -23), Vector2(-1, -16), hair.lightened(0.12), 0.6, true)
	else:
		var eye := Vector2(look.x * 0.8, look.y * 0.3)
		for side in [-1.0, 1.0]:
			_ellipse(Vector2(side * 1.8, -19.3) + eye, Vector2(0.65, 0.9), Color("332d29"))
		draw_line(Vector2(-1.2, -16.5), Vector2(1, -16.3), Color("885442"), 0.55, true)
		_ellipse(Vector2(0, -23), Vector2(5.2, 2.5), hair)
		if protagonist:
			_ellipse(Vector2(-4.2, -20.5), Vector2(1.1, 3.4), hair)
			_ellipse(Vector2(4.2, -20.5), Vector2(1.1, 3.4), hair)
	if protagonist:
		_flower(Vector2(4.7, -23), Color("d97791"))
	draw_set_transform(Vector2.ZERO)


func _ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in range(32):
		var angle := TAU * index / 32.0
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(points, color)
	points.append(points[0])
	draw_polyline(points, color, 0.4, true)


func _flower(center: Vector2, color: Color) -> void:
	draw_line(center, center + Vector2(0.8, 2), Color("708f60"), 0.6, true)
	for petal in range(5):
		var angle := TAU * petal / 5.0
		_ellipse(center + Vector2(cos(angle), sin(angle)) * 0.8, Vector2(0.6, 0.7), color)
	_ellipse(center, Vector2(0.35, 0.35), Color("e6c67c"))
