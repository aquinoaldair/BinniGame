extends CharacterBody2D

const FOLLOW_SPEED := 90.0
const FOLLOW_DISTANCE := 32.0
const MIN_DISTANCE := 28.0
const PATH_REFRESH_TIME := 0.25

var following := false
var available := false
var target: CharacterBody2D
var path := PackedVector2Array()
var path_index := 0
var path_timer := 0.0
var facing := Vector2.RIGHT
var walk_phase := 0.0
var rest_phase := 0.0
var separating := false


func appear() -> void:
	if available:
		return
	available = true
	show()
	$CollisionShape2D.set_deferred("disabled", false)


func start_following(player: CharacterBody2D) -> void:
	if not available:
		return
	target = player
	# Nisa puede cruzar a su compañera: la separación se resuelve sin empujarla.
	add_collision_exception_with(player)
	following = true
	path_timer = 0.0
	queue_redraw()


func _physics_process(delta: float) -> void:
	if not available:
		return
	velocity = Vector2.ZERO
	rest_phase += delta
	if following and is_instance_valid(target) and target.can_move:
		var distance := position.distance_to(target.position)
		if distance < MIN_DISTANCE:
			separating = true
		elif distance >= FOLLOW_DISTANCE - 1.0:
			separating = false
		if separating or distance > FOLLOW_DISTANCE:
			path_timer -= delta
			if path_timer <= 0.0:
				var destination: Vector2 = target.position
				if separating:
					var away := position - target.position
					if away.length_squared() < 0.1:
						away = -target.facing
					destination = get_parent().get_companion_rest_position(target.position, away, FOLLOW_DISTANCE)
				path = get_parent().get_companion_path(position, destination)
				# El primer punto es el centro de la celda actual, no el siguiente paso.
				# Volver a él al recalcular provoca retrocesos al seguir un objetivo móvil.
				path_index = 1 if path.size() > 1 else 0
				path_timer = PATH_REFRESH_TIME
			while path_index < path.size() and position.distance_to(path[path_index]) < 2.0:
				path_index += 1
			if path_index < path.size():
				var offset := path[path_index] - position
				velocity = offset.normalized() * minf(FOLLOW_SPEED, offset.length() / delta)
		else:
			path_timer = 0.0
			facing = (target.position - position).normalized()
	else:
		path_timer = 0.0
	move_and_slide()
	if velocity.length_squared() > 1.0:
		facing = velocity.normalized()
		walk_phase += delta * 12.0
	else:
		walk_phase = 0.0
	queue_redraw()


func _draw() -> void:
	# Iguana de arte provisional: cola larga, cuatro patas y cresta dorsal.
	draw_circle(Vector2(0, 2), 7, Color(0.12, 0.2, 0.1, 0.25))
	draw_set_transform(Vector2.ZERO, facing.angle())
	var step := sin(walk_phase) * 1.5
	var tail_sway := sin(rest_phase * 1.5) * 0.7
	draw_polyline(PackedVector2Array([
		Vector2(-3, 0), Vector2(-10, 1), Vector2(-16, 3 + tail_sway),
		Vector2(-22, 1 + tail_sway)
	]), Color("567e36"), 2.5, true)
	for side in [-1.0, 1.0]:
		draw_line(Vector2(3, side * 3), Vector2(5 + step * side, side * 7), Color("415e2c"), 2)
		draw_line(Vector2(-4, side * 3), Vector2(-6 - step * side, side * 7), Color("415e2c"), 2)
		draw_line(Vector2(5 + step * side, side * 7), Vector2(7 + step * side, side * 7), Color("a2b65d"), 1)
		draw_line(Vector2(-6 - step * side, side * 7), Vector2(-8 - step * side, side * 7), Color("a2b65d"), 1)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-7, 0), Vector2(-4, -4), Vector2(3, -4),
		Vector2(6, 0), Vector2(3, 4), Vector2(-4, 4)
	]), Color("739744"))
	draw_line(Vector2(-5, -2), Vector2(3, -2), Color("a9bd62"), 1)
	for spike in range(5):
		var x := -5.0 + spike * 2.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(x, 0), Vector2(x + 1, -2), Vector2(x + 2, 0)
		]), Color("c1cc78"))
	draw_circle(Vector2(7, 0), 3.5, Color("85a951"))
	draw_circle(Vector2(8, -2), 1.1, Color("e6cb66"))
	draw_circle(Vector2(8.3, -2), 0.55, Color("20291c"))
	draw_line(Vector2(8, 1), Vector2(10, 1), Color("415e2c"), 0.7)
	draw_set_transform(Vector2.ZERO)
	if not following:
		draw_string(ThemeDB.fallback_font, Vector2(-22, -12), "Gela", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("fff2cb"))
