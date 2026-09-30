extends SceneTree

const SaveStore = preload("res://scripts/save_store.gd")
var failures := 0
var test_path := "user://street_tests/%s_%s/partida.json" % [OS.get_process_id(), Time.get_unix_time_from_system()]


func _initialize() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _open_scene():
	var scene = load("res://scenes/main.tscn").instantiate()
	scene.save_path = test_path
	root.add_child(scene)
	return scene


func _finish_dialogue(story: Node) -> void:
	while not story.dialogue.is_empty():
		story._advance_dialogue()


func _close_scene(scene: Node) -> void:
	scene.queue_free()
	paused = false
	await process_frame


func _run() -> void:
	var scene = _open_scene()
	var session = scene.get_node("SaveSession")
	session.new_button.pressed.emit()
	var story = scene.get_node("PatioStory")
	var player = scene.get_node("Nisa")
	var companion = scene.get_node("Gela")
	player.position = story.GATE_POSITION
	story._interact()
	_check(scene.zone == "patio", "El portón permite salir antes de completar el cuaderno.")
	_finish_dialogue(story)
	player.position = story.FAMILY_POSITION + Vector2(0, 12)
	story._interact()
	_finish_dialogue(story)
	player.position = story.OBJECT_POSITION
	story._interact()
	_finish_dialogue(story)
	player.position = story.FAMILY_POSITION + Vector2(0, 12)
	story._interact()
	_finish_dialogue(story)
	player.position = companion.position + Vector2(20, 0)
	story._interact()
	_finish_dialogue(story)
	player.position = story.GATE_POSITION
	_check(story._nearby_action() == "Salir", "El portón exige volver a hablar con la abuela después de encontrar a Gela.")
	player.position = story.FAMILY_POSITION + Vector2(0, 12)
	story._interact()
	_check(not story.clue_received, "La pista se completa antes de cerrar el diálogo.")
	_finish_dialogue(story)
	_check(story.clue_received, "No se recibió la pista del dibujo.")
	player.position = story.GATE_POSITION
	story._interact()
	await physics_frame
	_check(scene.zone == "street" and companion.following, "No se sale a la calle con Gela.")
	_check(session.store.load_game()["scene"] == "street", "El cambio de escenario no se guardó.")
	_check(player.test_move(player.transform, Vector2(0, -200)), "Las casas de la calle no bloquean el paso.")
	player.position = Vector2(264, 143)
	companion.position = Vector2(183, 143)
	companion.path_timer = 0.0
	var crossed_fountain := false
	for frame in range(100):
		await physics_frame
		crossed_fountain = crossed_fountain or scene.FOUNTAIN_BOUNDS.grow(3.5).has_point(companion.position)
	_check(not crossed_fountain, "Gela atraviesa la fuente en vez de rodearla.")
	_check(companion.position.distance_to(player.position) <= 34.0, "Gela no sigue a Nisa alrededor de la fuente.")
	player.position = story.NEIGHBOR_POSITION + Vector2(0, 12)
	story._interact()
	_finish_dialogue(story)
	_check(story.street_progress == 0, "Hablar antes de examinar omite el indicio del olvido.")
	player.position = story.FOUNTAIN_POSITION + Vector2(0, 14)
	story._interact()
	_finish_dialogue(story)
	_check(story.street_progress == 1, "No se registró el azulejo ausente.")
	await _close_scene(scene)

	scene = _open_scene()
	session = scene.get_node("SaveSession")
	session.continue_button.pressed.emit()
	story = scene.get_node("PatioStory")
	player = scene.get_node("Nisa")
	companion = scene.get_node("Gela")
	_check(scene.zone == "street" and story.street_progress == 1 and companion.following, "Continuar perdió el escenario o la pista.")
	player.position = story.NEIGHBOR_POSITION + Vector2(0, 12)
	story._interact()
	_finish_dialogue(story)
	_check(story.street_progress == 2, "La conversación con la vecina no avanza el objetivo.")
	player.position = story.STREET_GATE
	story._interact()
	_check(scene.zone == "patio", "No se puede volver al patio.")
	player.position = story.FAMILY_POSITION + Vector2(0, 12)
	story._interact()
	_finish_dialogue(story)
	_check(story.street_progress == 3, "Compartir la pista no completa el paseo.")
	_check(session.store.load_game()["street_progress"] == 3, "El paseo completado no se guardó.")
	await _close_scene(scene)

	# Las partidas de la versión anterior conservan el cuaderno y a Gela.
	var store := SaveStore.new()
	store.save_path = test_path
	var legacy := store.load_game()
	legacy["version"] = 1
	legacy["scene"] = "patio"
	legacy.erase("clue_received")
	legacy.erase("street_progress")
	var file := FileAccess.open(test_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy))
	file.close()
	scene = _open_scene()
	session = scene.get_node("SaveSession")
	session.continue_button.pressed.emit()
	story = scene.get_node("PatioStory")
	_check(story.stage == story.Stage.COMPLETE and scene.get_node("Gela").following, "La migración perdió el progreso anterior.")
	_check(not story.clue_received and story.street_progress == 0, "La migración omitió la nueva pista.")
	_check(store.load_game()["version"] == 2, "Continuar no actualizó el formato del guardado.")
	player = scene.get_node("Nisa")
	player.position = story.GATE_POSITION
	_check(story._nearby_action() == "Salir", "El portón sigue bloqueado al continuar una partida anterior con Gela.")
	story._interact()
	_check(scene.zone == "patio" and not story.clue_received, "La pista del portón se omite antes de terminar el diálogo.")
	_finish_dialogue(story)
	_check(scene.zone == "street" and story.clue_received, "No se puede salir tras entregar el cuaderno y saludar a Gela sin otra conversación.")
	_check(store.load_game()["scene"] == "street" and store.load_game()["clue_received"], "La salida directa no se guardó.")
	await _close_scene(scene)
	for suffix in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(test_path + suffix):
			DirAccess.remove_absolute(test_path + suffix)
	DirAccess.remove_absolute(test_path.get_base_dir())
	if failures == 0:
		print("PASS: pista, portón, calle, fuente, vecina, regreso, guardado y migración de partidas anteriores.")
	quit(1 if failures else 0)
