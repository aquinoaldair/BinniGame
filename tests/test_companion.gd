extends SceneTree

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _follow_to(scene: Node2D, start: Vector2, destination: Vector2) -> void:
	var player = scene.get_node("Nisa")
	var companion = scene.get_node("Gela")
	player.position = destination
	companion.position = start
	companion.path_timer = 0.0
	var crossed_house := false
	for frame in range(300):
		await physics_frame
		crossed_house = crossed_house or scene.MAIN_HOUSE.grow(3.5).has_point(companion.position)
		crossed_house = crossed_house or scene.SMALL_HOUSE.grow(3.5).has_point(companion.position)
	_check(not crossed_house, "Gela atravesó una casa.")
	_check(companion.position.distance_to(player.position) <= 34.0, "Gela no llegó a Nisa rodeando la casa.")
	_check(companion.position.distance_to(player.position) >= 28.0, "Gela se detiene demasiado cerca de Nisa.")
	var resting_position: Vector2 = companion.position
	for frame in range(30):
		await physics_frame
	_check(companion.position.distance_to(resting_position) < 0.1, "Gela no descansa junto a Nisa.")


func _check_gate_following(scene: Node2D) -> void:
	var player = scene.get_node("Nisa")
	var companion = scene.get_node("Gela")
	player.position = Vector2(110, 125)
	companion.position = player.position
	companion.path_timer = 0.0
	for frame in range(90):
		await physics_frame
	_check(companion.position.distance_to(player.position) >= 28.0, "Gela permanece encima de Nisa en vez de apartarse.")
	Input.action_press("move_up")
	for frame in range(90):
		await physics_frame
	Input.action_release("move_up")
	for frame in range(90):
		await physics_frame
	_check(companion.position.distance_to(player.position) >= 28.0, "Gela tapa a Nisa al llegar al portón.")
	var previous_position: Vector2 = companion.position
	Input.action_press("move_down")
	for frame in range(95):
		await physics_frame
	Input.action_release("move_down")
	for frame in range(90):
		await physics_frame
	_check(companion.position.distance_to(previous_position) > 20.0, "Gela no reanuda el seguimiento después del portón.")
	_check(companion.position.distance_to(player.position) <= 34.0, "Gela pierde a Nisa después de cambiar de dirección.")


func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	scene.start_menu_enabled = false
	root.add_child(scene)
	await process_frame
	var player = scene.get_node("Nisa")
	var story = scene.get_node("PatioStory")
	var companion = scene.get_node("Gela")
	_check(not companion.available and not companion.visible, "Gela aparece antes de entregar el cuaderno.")
	_check(companion.get_node("CollisionShape2D").disabled, "Gela tiene colisión antes de aparecer.")
	var initial_position: Vector2 = companion.position
	player.position = initial_position + Vector2(20, 0)
	_check(story._nearby_action() == "", "Se puede saludar a Gela antes de entregar el cuaderno.")
	story._interact()
	_check(story.dialogue.is_empty(), "Se abrió el saludo antes de completar la misión.")
	for frame in range(10):
		await physics_frame
	_check(companion.position == initial_position, "Gela se mueve antes de aparecer.")

	player.position = story.FAMILY_POSITION + Vector2(0, 12)
	story._interact()
	for line in range(3):
		story._advance_dialogue()
	_check(story.stage == story.Stage.SEARCH and not companion.available, "Gela aparece al iniciar la búsqueda.")
	player.position = story.OBJECT_POSITION
	story._interact()
	story._advance_dialogue()
	_check(story.stage == story.Stage.RETURN and not companion.visible, "Gela aparece al recoger el cuaderno.")
	player.position = story.FAMILY_POSITION + Vector2(0, 12)
	story._interact()
	story._advance_dialogue()
	story._advance_dialogue()
	_check(not companion.available, "Gela aparece antes de cerrar la entrega.")
	story._advance_dialogue()
	await process_frame
	_check(story.stage == story.Stage.COMPLETE and companion.available and companion.visible, "Gela no aparece tras entregar el cuaderno.")
	_check(not companion.following, "Gela sigue a Nisa antes de saludarla.")
	_check(not companion.get_node("CollisionShape2D").disabled, "No se activó la colisión de Gela.")

	player.position = companion.position + Vector2(20, 0)
	await process_frame
	await process_frame
	_check(story.action_button.visible and story.action_button.text.contains("Saludar"), "No aparece la interacción con Gela.")
	story.action_button.pressed.emit()
	_check(not player.can_move and not companion.following, "El encuentro no espera a cerrar el diálogo.")
	story.next_button.pressed.emit()
	story.next_button.pressed.emit()
	_check(companion.following and player.can_move, "Gela no se incorporó tras el saludo.")
	_check(story.stage == story.Stage.COMPLETE, "El saludo cambió el progreso del cuaderno.")
	_check(companion.guiding, "Gela no guía a Nisa hacia el portón.")
	# A partir de la pista del cuaderno conserva el seguimiento normal del patio.
	story.clue_received = true
	story.sync_companion_guide()

	await _follow_to(scene, Vector2(180, 85), Vector2(370, 175))
	await _follow_to(scene, Vector2(105, 238), Vector2(285, 238))

	await _check_gate_following(scene)

	# Volver a hablar con la abuela pausa a ambas y no reinicia a Gela.
	player.position = story.FAMILY_POSITION + Vector2(0, 12)
	story._interact()
	var paused_position: Vector2 = companion.position
	for frame in range(20):
		await physics_frame
	_check(companion.position == paused_position, "Gela se mueve durante el diálogo.")
	while not story.dialogue.is_empty():
		story._advance_dialogue()
	_check(story.stage == story.Stage.COMPLETE and companion.following, "Hablar con la abuela reinició la misión o a Gela.")
	_check(companion.position == paused_position, "Gela reapareció en el jardín al repetir la conversación.")

	scene.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: Gela aparece solo tras la entrega; saludo, seguimiento, descanso y conversaciones funcionan.")
	quit(1 if failures else 0)
