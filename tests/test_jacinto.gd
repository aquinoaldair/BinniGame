extends SceneTree

var failures := 0
var test_path := "user://jacinto_tests/%s/partida.json" % OS.get_process_id()
var world: Node2D
var story: Node2D
var session: Node
var player: CharacterBody2D
var game: Node2D


func _initialize() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _open(continuing := false) -> void:
	world = load("res://scenes/main.tscn").instantiate()
	world.save_path = test_path
	root.add_child(world)
	story = world.get_node("PatioStory")
	session = world.get_node("SaveSession")
	player = world.get_node("Nisa")
	game = world.get_node("JacintoPresentation/Slingshot")
	if continuing:
		session.continue_button.pressed.emit()
	else:
		session.new_button.pressed.emit()
	await process_frame
	await process_frame


func _close() -> void:
	world.queue_free()
	paused = false
	await process_frame


func _finish_dialogue() -> void:
	while not story.dialogue.is_empty():
		story._advance_dialogue()


func _run() -> void:
	await _open()
	_finish_dialogue()
	story.stage = story.Stage.COMPLETE
	story.pending_stage = story.stage
	story.street_progress = 3
	story.clue_received = true
	world.get_node("Gela").appear()
	world.get_node("Gela").start_following(player)
	world.set_zone("street")
	player.position = story.JACINTO_ROUTE
	_check(story._nearby_action() == "", "Se puede visitar a Jacinto antes de la pista de Bixhozegola.")
	world.set_zone("patio")
	player.position = story.FAMILY_POSITION + Vector2(0, 12)
	story._interact()
	_check(not story.next_clue_received, "La misión comienza antes de cerrar la pista.")
	_finish_dialogue()
	_check(story.next_clue_received and story.jacinto_progress == 0, "La pista no activa la búsqueda.")
	world.set_zone("street")
	player.position = story.JACINTO_ROUTE
	story._interact()
	await process_frame
	await process_frame
	_check(world.zone == "jacinto" and world.get_node("JacintoPresentation").visible, "No se accede a la nueva zona.")
	_check(world._blocked_buildings() == world.JACINTO_BOUNDS and world.get_companion_path(Vector2(100, 231), Vector2(238, 187)).size() > 1, "Las colisiones o rutas no corresponden a Jacinto.")
	player.position = story.JACINTO_POSITION + Vector2(0, 12)
	story._interact()
	_check(story.dialogue.size() == 5 and story.jacinto_progress == 0, "Jacinto entrega el recuerdo antes de ayudarlo.")
	story._advance_dialogue()
	session._save_now()
	await _close()
	await _open(true)
	_check(story.jacinto_progress == 0 and world.zone == "jacinto", "Continuar confirma un diálogo incompleto o pierde la zona.")
	story._interact()
	_finish_dialogue()
	_check(story.jacinto_progress == 1 and session.store.load_game().get("jacinto_progress") == 1, "El primer diálogo no guarda el objetivo de ayuda.")
	player.position = story.MANGO_POSITION
	story._interact()
	_check(game.active and not player.can_move and game.hits == 0, "El minijuego no limita el movimiento.")
	game.aim = Vector2(40, 60)
	game.begin_charge()
	game.power = 0.65
	game.fire()
	_check(game.stone.visible and game.busy, "La piedra no aparece al soltar.")
	await create_timer(1.1).timeout
	_check(game.hits == 0 and game.shots == 1, "Un fallo se cuenta como mango.")
	session._save_now()
	game.cancel()
	await create_timer(0.5).timeout
	_check(player.can_move and story.jacinto_progress == 1 and not game.is_processing(), "Cancelar no restaura el movimiento y pausa el modo.")
	await _close()
	await _open(true)
	_check(not game.active and player.can_move and story.jacinto_progress == 1, "Continuar queda atrapado en apuntado.")
	player.position = story.MANGO_POSITION
	story._interact()
	game.aim = Vector2(40, 60)
	for attempt in range(7):
		game.begin_charge()
		game.power = 0.65
		game.fire()
		await create_timer(1.1).timeout
	_check(game.active and game.shots == 7 and story.dialogue.is_empty(), "La munición sigue obligando a reiniciar.")
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = game.target_points[0]
	game._aim_input(touch)
	_check(game.aim.distance_to(game.target_points[0]) < 0.1 and game.charging, "El toque no apunta y comienza la carga.")
	game.power = 0.65
	touch.pressed = false
	game._aim_input(touch)
	await create_timer(1.7).timeout
	_check(game.hits == 1 and story.jacinto_progress == 1, "Un mango confirma la misión completa.")
	for index in [1, 2]:
		game.aim = game.target_points[index] - Vector2(game.wind_force, 0)
		var key := InputEventKey.new()
		key.physical_keycode = KEY_SPACE
		key.pressed = true
		game._unhandled_key_input(key)
		game.power = 0.65
		key.pressed = false
		game._unhandled_key_input(key)
		await create_timer(1.7 if index == 1 else 2.9).timeout
	_check(game.hits == 3 and not game.active and player.can_move and story.jacinto_progress == 2, "Tres mangos no devuelven el control y desbloquean el diálogo.")
	_check(session.store.load_game().get("jacinto_progress") == 2, "Los mangos completados no se guardan.")
	Input.action_press("move_right")
	var before: Vector2 = player.position
	await create_timer(0.1).timeout
	Input.action_release("move_right")
	_check(player.position.x > before.x, "Nisa no puede caminar tras terminar el minijuego.")
	player.position = story.JACINTO_POSITION + Vector2(0, 12)
	story._interact()
	_check(story.dialogue[0].contains("huanacaxtle") and story.dialogue[2].contains("[PENDIENTE_DE_VERIFICACION]"), "El recuerdo no conecta con el árbol o inventa la palabra.")
	story._advance_dialogue()
	session._save_now()
	await _close()
	await _open(true)
	_check(story.jacinto_progress == 2, "Un recuerdo interrumpido se guarda como recibido.")
	story._interact()
	_finish_dialogue()
	_check(story.jacinto_progress == 3 and session.store.load_game().get("jacinto_progress") == 3, "La nueva pista no se confirma al cerrar.")
	player.position = story.JACINTO_EXIT
	story._interact()
	await process_frame
	_check(world.zone == "street" and world._blocked_buildings() == world.STREET_HOUSES + [world.FOUNTAIN_BOUNDS], "Regresar no restaura el pozo y sus colisiones.")
	player.position = story.STREET_GATE
	story._interact()
	player.position = story.FAMILY_POSITION + Vector2(0, 12)
	story._interact()
	_finish_dialogue()
	_check(story.jacinto_progress == 4 and story.context_progress == 0 and story.objective.text.contains("vecina"), "Compartir la palabra no habilita la búsqueda del contexto.")
	var invalid: Dictionary = session._capture_state()
	invalid["next_clue_received"] = false
	_check(session.store.write_game(invalid) == ERR_INVALID_DATA, "Se acepta progreso de Jacinto sin la misión activada.")
	await _close()
	await _open(true)
	_check(story.jacinto_progress == 4 and player.can_move, "Continuar pierde la misión completada.")
	await _close()
	for suffix in ["", ".bak", ".tmp"]:
		DirAccess.remove_absolute(test_path + suffix)
	DirAccess.remove_absolute(test_path.get_base_dir())
	if failures == 0:
		print("PASS: activación, ruta, conversaciones, resortera, toque, fallos, tres mangos, movimiento, guardado y regreso.")
	quit(1 if failures else 0)
