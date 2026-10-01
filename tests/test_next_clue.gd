extends SceneTree

var failures := 0
var test_path := "user://next_clue_tests/%s/partida.json" % OS.get_process_id()


func _initialize() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _open_world() -> Node2D:
	var world = load("res://scenes/main.tscn").instantiate()
	world.save_path = test_path
	root.add_child(world)
	return world


func _run() -> void:
	var world = _open_world()
	var session = world.get_node("SaveSession")
	var story = world.get_node("PatioStory")
	var player = world.get_node("Nisa")
	var gela = world.get_node("Gela")
	session.new_button.pressed.emit()
	while not story.dialogue.is_empty():
		story._advance_dialogue()
	story.stage = story.Stage.COMPLETE
	story.pending_stage = story.stage
	story.clue_received = true
	story.street_progress = 3
	gela.appear()
	gela.start_following(player)
	player.position = story.FAMILY_POSITION + Vector2(0, 12)
	story._update_objective()
	var old_data: Dictionary = session._capture_state()
	old_data.erase("next_clue_received")
	_check(session.store.write_game(old_data) == OK, "Una partida versión 2 anterior deja de ser válida.")
	session.saved_game = session.store.load_game()
	session._continue_game()
	_check(not story.next_clue_received and story.objective.text.contains("Bixhozegola"), "Continuar omite la nueva conversación.")
	story._interact()
	_check(story.dialogue.size() == 4 and story.dialogue[1].contains("Jacinto") and not player.can_move, "La nueva pista no se presenta mediante conversación.")
	story._advance_dialogue()
	session._save_now()
	_check(not session.store.load_game().get("next_clue_received", false), "Se guarda una pista antes de terminar el diálogo.")
	world.queue_free()
	paused = false
	await process_frame
	world = _open_world()
	session = world.get_node("SaveSession")
	story = world.get_node("PatioStory")
	player = world.get_node("Nisa")
	session.continue_button.pressed.emit()
	story._interact()
	_check(story.dialogue_index == 0 and story.dialogue.size() == 4, "El diálogo interrumpido no puede repetirse.")
	while not story.dialogue.is_empty():
		story._advance_dialogue()
	_check(story.next_clue_received and story.street_progress == 3 and story.objective.text.contains("Jacinto") and player.can_move, "Cerrar la conversación no activa el objetivo o cambia el recuerdo recuperado.")
	var saved: Dictionary = session.store.load_game()
	_check(saved.get("next_clue_received", false), "La pista completada no se guarda.")
	var invalid: Dictionary = saved.duplicate(true)
	invalid["street_progress"] = 2
	_check(session.store.write_game(invalid) == ERR_INVALID_DATA, "Se acepta una pista posterior sin recuperar el fragmento.")
	session.saved_game = saved
	session._continue_game()
	_check(story.next_clue_received and story.objective.text.contains("Jacinto"), "Continuar pierde el nuevo objetivo.")
	story._interact()
	_check(story.dialogue.size() == 1 and story.dialogue[0].contains("Jacinto"), "Hablar de nuevo no recuerda el destino.")
	world.queue_free()
	paused = false
	await process_frame
	for suffix in ["", ".bak", ".tmp"]:
		DirAccess.remove_absolute(test_path + suffix)
	if failures == 0:
		print("PASS: nueva pista, partida anterior, interrupción, objetivo, recordatorio y guardado.")
	quit(1 if failures else 0)
