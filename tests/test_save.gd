extends SceneTree

const SaveStore = preload("res://scripts/save_store.gd")
var failures := 0
var test_path := "user://test_saves/%s_%s/partida.json" % [OS.get_process_id(), Time.get_unix_time_from_system()]


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


func _close_scene(scene: Node) -> void:
	scene.queue_free()
	paused = false
	await process_frame


func _run() -> void:
	var store := SaveStore.new()
	store.save_path = test_path
	var scene = _open_scene()
	var session = scene.get_node("SaveSession")
	_check(paused and session.continue_button.disabled, "El menú sin partida no bloquea el juego o permite continuar.")
	_check(not store.has_files(), "Abrir el menú creó una partida sin elegir Nueva partida.")
	session.new_button.pressed.emit()
	_check(not paused and session.running, "Nueva partida no inicia el juego.")
	_check(store.load_game().get("stage") == 0, "No se guardó la partida inicial.")
	var player = scene.get_node("Nisa")
	var story = scene.get_node("PatioStory")
	player.position = story.FAMILY_POSITION + Vector2(0, 12)
	story._interact()
	for line in range(3):
		story._advance_dialogue()
	_check(store.load_game().get("stage") == 1, "No se autoguardó el objetivo del cuaderno.")
	player.position = story.OBJECT_POSITION
	story._interact()
	session._save_now()
	_check(store.load_game().get("stage") == 1, "El guardado en medio del diálogo adelantó el objetivo.")
	await _close_scene(scene)

	scene = _open_scene()
	session = scene.get_node("SaveSession")
	_check(not session.continue_button.disabled, "Continuar no reconoce la partida válida.")
	session.continue_button.pressed.emit()
	player = scene.get_node("Nisa")
	story = scene.get_node("PatioStory")
	var companion = scene.get_node("Gela")
	_check(story.stage == story.Stage.SEARCH and story.dialogue.is_empty() and player.can_move, "No se restauró el último objetivo completo.")
	_check(player.position == story.OBJECT_POSITION and not companion.available, "No se restauró la posición o Gela apareció antes de tiempo.")
	story._interact()
	story._advance_dialogue()
	_check(store.load_game().get("stage") == 2, "Recoger el cuaderno no se guardó.")
	player.position = story.FAMILY_POSITION + Vector2(0, 12)
	story._interact()
	for line in range(3):
		story._advance_dialogue()
	_check(store.load_game()["gela"]["available"], "La aparición de Gela no se guardó.")
	player.position = companion.position + Vector2(20, 0)
	story._interact()
	story._advance_dialogue()
	story._advance_dialogue()
	_check(store.load_game()["gela"]["following"], "El saludo a Gela no se guardó.")
	player.position = Vector2(110, 125)
	companion.position = Vector2(145, 130)
	session._process(session.AUTOSAVE_INTERVAL)
	_check(session._vector(store.load_game()["nisa_position"]) == Vector2(110, 125), "El autoguardado periódico perdió la posición.")
	player.position = Vector2(112, 126)
	session._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	_check(session._vector(store.load_game()["nisa_position"]) == Vector2(112, 126), "Pasar a segundo plano no guarda la partida.")
	await _close_scene(scene)

	scene = _open_scene()
	session = scene.get_node("SaveSession")
	session.continue_button.pressed.emit()
	_check(scene.get_node("Gela").following and scene.get_node("Gela").visible, "Continuar no restaura a Gela como compañera.")
	_check(scene.get_node("Nisa").position == Vector2(112, 126), "Continuar perdió la posición de Nisa.")
	await _close_scene(scene)

	# Corrupción del archivo principal: se recupera el respaldo válido.
	var file := FileAccess.open(test_path, FileAccess.WRITE)
	file.store_string("{archivo incompleto")
	file.close()
	scene = _open_scene()
	session = scene.get_node("SaveSession")
	_check(session.store.used_backup and not session.continue_button.disabled, "No se recuperó el respaldo.")
	session.continue_button.pressed.emit()
	_check(scene.get_node("Gela").following, "La recuperación perdió el encuentro con Gela.")
	_check(not store.load_game().is_empty() and not store.used_backup, "Continuar no reparó el archivo principal.")
	await _close_scene(scene)

	scene = _open_scene()
	session = scene.get_node("SaveSession")
	var previous := FileAccess.get_file_as_string(test_path)
	session.new_button.pressed.emit()
	_check(session.confirmation.visible and paused, "Nueva partida no confirma el reemplazo.")
	session.confirmation.canceled.emit()
	session.confirmation.hide()
	_check(FileAccess.get_file_as_string(test_path) == previous, "Cancelar reemplazó la partida.")
	session.new_button.pressed.emit()
	session.confirmation.confirmed.emit()
	session.confirmation.hide()
	_check(store.load_game().get("stage") == 0 and not scene.get_node("Gela").available, "Nueva partida no reinició el progreso.")
	await _close_scene(scene)
	# El respaldo también debe reiniciarse para no recuperar la aventura anterior.
	file = FileAccess.open(test_path, FileAccess.WRITE)
	file.store_string("[]")
	file.close()
	_check(store.load_game().get("stage") == 0 and store.used_backup, "El respaldo de Nueva partida conserva el progreso anterior.")
	file = FileAccess.open(test_path + ".bak", FileAccess.WRITE)
	file.store_string('{"version":99}')
	file.close()
	scene = _open_scene()
	session = scene.get_node("SaveSession")
	_check(session.continue_button.disabled, "Continuar acepta archivos inválidos o versiones desconocidas.")
	await _close_scene(scene)
	for suffix in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(test_path + suffix):
			DirAccess.remove_absolute(test_path + suffix)
	DirAccess.remove_absolute(test_path.get_base_dir())
	if failures == 0:
		print("PASS: menú, nueva partida, continuar, autoguardado, Gela, diálogos, respaldo y archivos inválidos.")
	quit(1 if failures else 0)
