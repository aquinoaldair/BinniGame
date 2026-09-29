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
	_check(companion.position.distance_to(player.position) <= 25.0, "Gela no llegó a Nisa rodeando la casa.")
	var resting_position: Vector2 = companion.position
	for frame in range(30):
		await physics_frame
	_check(companion.position.distance_to(resting_position) < 0.1, "Gela no descansa junto a Nisa.")


func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
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
	_check(story.action_button.text == "Saludar [E]", "No aparece la interacción con Gela.")
	story.action_button.pressed.emit()
	_check(not player.can_move and not companion.following, "El encuentro no espera a cerrar el diálogo.")
	story.next_button.pressed.emit()
	story.next_button.pressed.emit()
	_check(companion.following and player.can_move, "Gela no se incorporó tras el saludo.")
	_check(story.stage == story.Stage.COMPLETE, "El saludo cambió el progreso del cuaderno.")

	await _follow_to(scene, Vector2(180, 85), Vector2(370, 175))
	await _follow_to(scene, Vector2(105, 238), Vector2(285, 238))

	# Volver a hablar con la abuela pausa a ambas y no reinicia a Gela.
	player.position = story.FAMILY_POSITION + Vector2(0, 12)
	story._interact()
	var paused_position: Vector2 = companion.position
	for frame in range(20):
		await physics_frame
	_check(companion.position == paused_position, "Gela se mueve durante el diálogo.")
	story._advance_dialogue()
	_check(story.stage == story.Stage.COMPLETE and companion.following, "Hablar con la abuela reinició la misión o a Gela.")
	_check(companion.position == paused_position, "Gela reapareció en el jardín al repetir la conversación.")

	scene.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: Gela aparece solo tras la entrega; saludo, seguimiento, descanso y conversaciones funcionan.")
	quit(1 if failures else 0)
