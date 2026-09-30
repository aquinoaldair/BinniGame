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
