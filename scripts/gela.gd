extends CharacterBody2D

const FOLLOW_SPEED := 90.0
const FOLLOW_DISTANCE := 32.0
const MIN_DISTANCE := 28.0
const PATH_REFRESH_TIME := 0.25
const GUIDE_SPEED := 54.0
const GUIDE_WAIT_DISTANCE := 68.0

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
var guiding := false
var guide_destination := Vector2.ZERO
var guide_arrived := false


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
	if guiding and following and is_instance_valid(target) and target.can_move:
		_guide_step(delta)
	elif following and is_instance_valid(target) and target.can_move:
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


func set_guide(active: bool, destination := Vector2.ZERO) -> void:
	if guiding == active and guide_destination == destination:
		return
	guiding = active
	guide_destination = destination
	guide_arrived = false
	path.clear()
	path_timer = 0.0
	separating = false


func _guide_step(delta: float) -> void:
	# Espera mirando a Nisa si se retrasa, o cuando alcanza el lugar de la pista.
	guide_arrived = guide_arrived or position.distance_to(guide_destination) < 5.0
	var distance := position.distance_to(target.position)
	var destination := guide_destination
	var nisa_behind := target.position.distance_to(guide_destination) > position.distance_to(guide_destination)
	# Su cuerpo bajo queda oculto detrás de la ilustración alta de Nisa.
	var hidden_by_nisa := target.position.y > position.y and target.position.y - position.y < 72 and absf(target.position.x - position.x) < 26
	if guide_arrived and (distance < MIN_DISTANCE or hidden_by_nisa):
		var away := position - target.position
		if away.length_squared() < 0.1:
			away = -target.facing
		destination = get_parent().get_companion_rest_position(target.position, away, FOLLOW_DISTANCE)
		if hidden_by_nisa:
			destination = get_parent().safe_save_position(Vector2(target.position.x + FOLLOW_DISTANCE, position.y))
	elif guide_arrived or (distance > GUIDE_WAIT_DISTANCE and nisa_behind):
		facing = (target.position - position).normalized()
		return
	path_timer -= delta
	if path_timer <= 0.0:
		path = get_parent().get_companion_path(position, destination)
		path_index = 1 if path.size() > 1 else 0
		path_timer = PATH_REFRESH_TIME
	while path_index < path.size() and position.distance_to(path[path_index]) < 2.0:
		path_index += 1
	if path_index < path.size():
		var offset := path[path_index] - position
		velocity = offset.normalized() * minf(GUIDE_SPEED, offset.length() / delta)
