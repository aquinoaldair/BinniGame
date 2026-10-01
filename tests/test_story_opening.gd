extends SceneTree

var failures := 0
var test_path := "user://opening_tests/%s_%s/partida.json" % [OS.get_process_id(), Time.get_unix_time_from_system()]
var world: Node2D
var story: Node2D
var session: Node
var player: CharacterBody2D
var companion: CharacterBody2D
var sky: Node2D
var ambience: Node2D


func _initialize() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _open_scene(continuing := false) -> void:
	world = load("res://scenes/main.tscn").instantiate()
	world.save_path = test_path
	root.add_child(world)
	story = world.get_node("PatioStory")
	session = world.get_node("SaveSession")
	player = world.get_node("Nisa")
	companion = world.get_node("Gela")
	sky = world.get_node("PatioPresentation/Sky")
	ambience = world.get_node("PatioPresentation/Ambience")
	if continuing:
		session.continue_button.pressed.emit()
	else:
		session.new_button.pressed.emit()
	await process_frame
	await process_frame


func _close_scene() -> void:
	world.queue_free()
	paused = false
	await process_frame


func _finish_dialogue() -> void:
	while not story.dialogue.is_empty():
		story.next_button.pressed.emit()


func _interact_at(point: Vector2) -> void:
	player.position = point
	story._interact()


func _run() -> void:
	await _open_scene()
	_check(story.opening_intro_active and story.dialogue_text.text.contains("cielo"), "La nueva partida omite la observación del cielo.")
	_check(player.position == Vector2(184, 208) and not player.can_move, "La apertura mueve a Nisa de su casa o permite caminar durante el diálogo.")
	_check(world.get_node("PatioCamera").position.y == 96, "La cámara no muestra el cielo durante la apertura.")
	_check(story.stage == story.Stage.MEET and not companion.available and not sky.memory_recovered and ambience.wind_still, "La apertura adelanta la misión o recupera el cielo.")
	var original_color: Color = sky.gradient.get_color(0)
	var wind_time: float = ambience.wind_clock
	for tick in range(12):
		ambience._process(0.1)
	_check(ambience.wind_clock == wind_time and not ambience.leaves[0].visible, "El viento y las hojas se mueven antes de recuperar un recuerdo.")
	for tree in ambience.trees:
		_check(is_zero_approx(tree.position.x), "La copa se mueve mientras Nisa observa que el viento se detuvo.")
	for cloth in ambience.clothes:
		_check(is_zero_approx(cloth.rotation), "La tela se mueve mientras el viento está detenido.")
	session._save_now()
	await _close_scene()
	await _open_scene(true)
	_check(story.opening_intro_active and story.stage == story.Stage.MEET, "Continuar durante la apertura pierde o completa la primera conversación.")
	# La misma tecla del juego cierra la observación y devuelve el seguimiento.
	var interact_key := InputEventKey.new()
	interact_key.physical_keycode = KEY_E
	interact_key.pressed = true
	story._unhandled_key_input(interact_key)
	await process_frame
	await process_frame
	_check(not story.opening_intro_active and player.can_move and story.stage == story.Stage.MEET, "Cerrar la apertura adelanta el objetivo o mantiene bloqueado el movimiento.")
	_check(world.get_node("PatioCamera").position == player.position + Vector2(0, -18), "La cámara no vuelve a seguir a Nisa.")
	_interact_at(story.FAMILY_POSITION + Vector2(0, 12))
	_check(story.dialogue[0].begins_with("Nisa:") and story.dialogue[0].contains("cielo"), "La primera conversación no comienza con la pregunta de Nisa.")
	story._advance_dialogue()
	_check(story.dialogue_text.text.contains("cuaderno"), "La abuela no relaciona el recuerdo con su cuaderno.")
	session._save_now()
	_check(session.store.load_game()["stage"] == story.Stage.MEET, "Interrumpir la primera conversación completa el objetivo.")
	await _close_scene()
	await _open_scene(true)
	_finish_dialogue()
	_interact_at(story.FAMILY_POSITION + Vector2(0, 12))
	_check(story.dialogue_index == 0, "La conversación inicial no se puede repetir después de interrumpirla.")
	_finish_dialogue()
	_interact_at(story.OBJECT_POSITION)
	_finish_dialogue()
	_interact_at(story.FAMILY_POSITION + Vector2(0, 12))
	_check(story.dialogue_text.text.contains("las voces"), "El cuaderno no presenta el recuerdo incompleto.")
	story._advance_dialogue()
	_check(story.dialogue_text.text.contains("diidxazá") and not companion.available, "La palabra pendiente no aparece o Gela llega antes de la entrega.")
	_finish_dialogue()
	_check(story.stage == story.Stage.COMPLETE and companion.available and not companion.following, "La entrega no conserva el encuentro con Gela.")
	_check(not sky.memory_recovered and ambience.wind_still, "Entregar el cuaderno recupera el cielo antes de buscar el fragmento.")
	_interact_at(companion.position + Vector2(20, 0))
	_finish_dialogue()
	_interact_at(story.GATE_POSITION)
	_check(world.zone == "patio" and not story.clue_received, "El portón omite la lectura pendiente del cuaderno.")
	_finish_dialogue()
	_check(world.zone == "street" and companion.following and story.clue_received, "El portón bloquea el viaje después de entregar el cuaderno y saludar a Gela.")
	_interact_at(story.FOUNTAIN_POSITION + Vector2(0, 14))
	_finish_dialogue()
	_interact_at(story.NEIGHBOR_POSITION + Vector2(0, 12))
	story._advance_dialogue()
	_check(story.dialogue_text.text.contains("escucharlas"), "La vecina no aporta la continuación del recuerdo.")
	_check(story.street_progress == 1, "La conversación con la vecina se guarda antes de terminar.")
	_finish_dialogue()
	_interact_at(story.STREET_GATE)
	_interact_at(story.FAMILY_POSITION + Vector2(0, 12))
	story._advance_dialogue()
	session._save_now()
	await process_frame
	await process_frame
	_check(story.street_progress == 2 and not sky.memory_recovered and ambience.wind_still, "Compartir solo una línea recupera el cielo o el viento.")
	await _close_scene()
	await _open_scene(true)
	_check(story.dialogue.is_empty() and not story.opening_intro_active and story.street_progress == 2, "Continuar un progreso avanzado reinicia la apertura o completa el recuerdo pendiente.")
	_check(not sky.memory_recovered and ambience.wind_still, "El guardado interrumpido no mantiene el cielo incompleto.")
	_interact_at(story.FAMILY_POSITION + Vector2(0, 12))
	for line in range(3):
		story._advance_dialogue()
	await process_frame
	await process_frame
	_check(story.memory_observation_active and story.dialogue_text.text.contains("brisa") and world.get_node("PatioCamera").position.y == 96, "La recuperación no muestra el cielo y el regreso de la brisa.")
	_check(story.street_progress == 3 and sky.memory_recovered and not ambience.wind_still, "Cerrar la conversación final no recupera el primer fragmento y la brisa.")
	_check(sky.gradient.get_color(0) != original_color and story.objective.text.contains("Aún falta una palabra"), "El cielo no cambia o el objetivo da por resuelta la palabra pendiente.")
	wind_time = ambience.wind_clock
	ambience._process(0.2)
	_check(ambience.wind_clock > wind_time and ambience.leaves[0].visible, "La brisa no vuelve después del primer recuerdo.")
	_check(session.store.load_game()["version"] == 2 and session.store.load_game()["street_progress"] == 3, "El recuerdo rompe el formato o no se guarda.")
	# El fragmento ya está guardado aunque se cierre durante esta observación.
	await _close_scene()
	await _open_scene(true)
	_check(story.street_progress == 3 and sky.memory_recovered and not ambience.wind_still and not story.opening_intro_active, "Continuar pierde el cielo recuperado o repite la apertura.")
	world.set_zone("street")
	await process_frame
	await process_frame
	wind_time = ambience.wind_clock
	ambience._process(0.2)
	_check(ambience.wind_clock == wind_time and not sky.is_visible_in_tree(), "El nuevo ambiente del patio sigue activo en la calle.")
	await _close_scene()
	for suffix in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(test_path + suffix):
			DirAccess.remove_absolute(test_path + suffix)
	DirAccess.remove_absolute(test_path.get_base_dir())
	if failures == 0:
		print("PASS: cielo extraño, pregunta inicial, cuaderno, fragmento compartido, brisa, interrupciones y continuar.")
	quit(1 if failures else 0)
