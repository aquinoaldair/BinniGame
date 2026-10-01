extends SceneTree

var failures := 0
var test_path := "user://context_memory_tests/%s/partida.json" % OS.get_process_id()


func _initialize() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _finish(story: Node) -> void:
	while not story.dialogue.is_empty():
		story._advance_dialogue()


func _open_world() -> Node2D:
	var world = load("res://scenes/main.tscn").instantiate()
	world.save_path = test_path
	root.add_child(world)
	return world


func _run() -> void:
	var world = _open_world()
	var session = world.get_node("SaveSession")
	session.new_button.pressed.emit()
	var story = world.get_node("PatioStory")
	var player = world.get_node("Nisa")
	_finish(story)
	story.stage = story.Stage.COMPLETE
	story.pending_stage = story.stage
	story.clue_received = true
	story.gate_opened = true
	story.street_progress = 3
	story.next_clue_received = true
	var gela = world.get_node("Gela")
	gela.appear()
	gela.start_following(player)
	world.set_zone("street")
	player.position = story.MEMORY_BENCH
	_check(story._nearby_action() != "Comparar el banco", "La actividad aparece antes de compartir con la abuela.")
	story.jacinto_progress = story.JacintoProgress.MEMORY_RECEIVED
	world.set_zone("patio")
	player.position = story.FAMILY_POSITION + Vector2(0, 12)
	story._interact()
	_check(story.dialogue[1].contains("No la reconozco") and story.jacinto_progress == 3, "La abuela reconoce la palabra o adelanta el progreso.")
	_finish(story)
	_check(story.jacinto_progress == 4 and story.context_progress == 0 and story.objective.text.contains("vecina"), "No se activa la siguiente búsqueda.")
	var legacy: Dictionary = session._capture_state()
	legacy.erase("context_progress")
	legacy.erase("context_clues")
	_check(session.store.write_game(legacy) == OK, "Las partidas anteriores dejan de ser válidas.")
	session.saved_game = session.store.load_game()
	session._continue_game()
	_check(story.context_progress == 0 and story.context_clues == 0, "Las partidas anteriores omiten la nueva misión.")
	world.set_zone("street")
	player.position = story.NEIGHBOR_POSITION + Vector2(0, 12)
	story._interact()
	_check(story.context_progress == 0, "Se guarda la misión antes de cerrar la conversación.")
	_finish(story)
	_check(story.context_progress == 1, "La vecina no habilita las pistas.")
	player.position = story.MEMORY_TREE
	_check(story._nearby_action() == "Comparar el árbol", "No se puede examinar el árbol.")
	story._interact()
	story._advance_dialogue()
	session._save_now()
	_check(session.store.load_game()["context_clues"] == 0, "Una observación interrumpida se guarda como completa.")
	world.queue_free()
	paused = false
	await process_frame
	world = _open_world()
	session = world.get_node("SaveSession")
	session.continue_button.pressed.emit()
	story = world.get_node("PatioStory")
	player = world.get_node("Nisa")
	_check(story.context_progress == 1 and story.context_clues == 0, "Continuar pierde la misión o adelanta las pistas.")
	story._interact()
	_check(story.dialogue_index == 0, "La observación interrumpida no se puede repetir.")
	_finish(story)
	_check(story.context_clues == 2 and story._nearby_action() != "Comparar el árbol", "La pista del árbol se duplica o no se confirma.")
	player.position = story.NEIGHBOR_POSITION + Vector2(0, 12)
	story._interact()
	_finish(story)
	_check(story.context_progress == 1, "La vecina entrega el fragmento sin las dos pistas.")
	player.position = story.MEMORY_BENCH
	_check(story._nearby_action() == "Comparar el banco", "No se puede examinar el banco después del árbol.")
	story._interact()
	_finish(story)
	_check(story.context_clues == 3 and story.objective.text.contains("vecina"), "Las dos pistas no habilitan la reconstrucción.")
	player.position = story.NEIGHBOR_POSITION + Vector2(0, 12)
	story._interact()
	_finish(story)
	_check(story.context_progress == 2 and story.objective.text.contains("Bixhozegola"), "No se recibe el fragmento completo.")
	world.set_zone("patio")
	player.position = story.FAMILY_POSITION + Vector2(0, 12)
	story._interact()
	_check(story.dialogue[1].contains("Lidxi Gula") and story.context_progress == 2, "La abuela no conecta el fragmento o confirma antes de cerrar.")
	_finish(story)
	_check(story.context_progress == 3 and session.store.load_game()["context_progress"] == 3 and player.can_move, "No se completa o guarda la misión.")
	var invalid: Dictionary = session._capture_state()
	invalid["context_clues"] = 1
	_check(session.store.write_game(invalid) == ERR_INVALID_DATA, "El guardado acepta un fragmento sin ambas pistas.")
	invalid = session._capture_state()
	invalid["jacinto_progress"] = 3
	_check(session.store.write_game(invalid) == ERR_INVALID_DATA, "El guardado acepta la misión sin compartir el recuerdo de Jacinto.")
	story._interact()
	_finish(story)
	_check(story.context_progress == 3, "La conversación repetida retrocede el progreso.")
	story.context_progress = story.ContextProgress.SEARCH
	story.context_clues = 0
	world.set_zone("street")
	player.position = story.MEMORY_BENCH
	story._interact()
	_finish(story)
	player.position = story.MEMORY_TREE
	story._interact()
	_finish(story)
	_check(story.context_clues == 3, "Las pistas solo funcionan en un orden.")
	world.queue_free()
	paused = false
	await process_frame
	await create_timer(0.1).timeout
	for suffix in ["", ".bak", ".tmp"]:
		DirAccess.remove_absolute(test_path + suffix)
	if failures == 0:
		print("PASS: continuación de Jacinto, pistas en orden libre, interrupción, reconstrucción, regreso y guardado compatible.")
	quit(1 if failures else 0)
