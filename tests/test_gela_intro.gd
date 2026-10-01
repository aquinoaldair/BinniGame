extends SceneTree

var failures := 0
var test_path := "user://gela_intro/%s/partida.json" % OS.get_process_id()


func _initialize() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _finish(story: Node) -> void:
	while not story.dialogue.is_empty():
		story.next_button.pressed.emit()


func _open():
	var world = load("res://scenes/main.tscn").instantiate()
	world.save_path = test_path
	root.add_child(world)
	return world


func _run() -> void:
	var world = _open()
	var session = world.get_node("SaveSession")
	session.new_button.pressed.emit()
	var story = world.get_node("PatioStory")
	var player = world.get_node("Nisa")
	var gela = world.get_node("Gela")
	_finish(story)
	player.position = story.FAMILY_POSITION + Vector2(0, 12)
	story._interact()
	_finish(story)
	player.position = story.OBJECT_POSITION
	story._interact()
	_finish(story)
	player.position = story.FAMILY_POSITION + Vector2(0, 12)
	story._interact()
	story._advance_dialogue()
	story._advance_dialogue()
	var rustle = world.get_node("PatioPresentation/GelaEncounter")
	_check(rustle.is_processing() and rustle.elapsed == 0.0 and not gela.available, "El ruido no anuncia a Gela antes de terminar la entrega.")
	_finish(story)
	_check(gela.available and not gela.following and not gela.guiding, "Gela sale o guía antes de que Nisa investigue el árbol.")
	player.position = gela.position + Vector2(20, 0)
	story._interact()
	_check(story.dialogue[0].contains("¿Quieres que te siga?"), "Nisa no responde a la invitación de Gela.")
	_finish(story)
	_check(gela.guiding and gela.following, "Gela no inicia la guía tras el encuentro.")
	var start: Vector2 = gela.position
	for frame in range(110):
		await physics_frame
	_check(gela.position.distance_to(start) > 15 and gela.position.distance_to(player.position) < 72, "Gela no avanza hacia el portón o abandona a Nisa.")
	var waiting: Vector2 = gela.position
	for frame in range(20):
		await physics_frame
	_check(gela.position.distance_to(waiting) < 0.1, "Gela no espera cuando Nisa se queda atrás.")
	session._save_now()
	world.queue_free()
	paused = false
	await process_frame
	world = _open()
	session = world.get_node("SaveSession")
	session.continue_button.pressed.emit()
	story = world.get_node("PatioStory")
	player = world.get_node("Nisa")
	gela = world.get_node("Gela")
	_check(gela.guiding and not story.clue_received, "Continuar pierde la invitación hacia el portón.")
	player.position = Vector2(123, 108)
	for frame in range(120):
		await physics_frame
	_check(gela.guide_arrived and gela.position.distance_to(gela.guide_destination) < 34, "Gela no espera junto al portón.")
	player.position = gela.position + Vector2(0, 34)
	for frame in range(60):
		await physics_frame
	_check(absf(gela.position.x - player.position.x) >= 26, "Gela queda oculta detrás de Nisa mientras espera.")
	player.position = gela.position
	for frame in range(60):
		await physics_frame
	_check(gela.position.distance_to(player.position) >= 27, "Gela queda encima de Nisa al esperar en el portón.")
	player.position = story.GATE_POSITION
	story._interact()
	var paused_position: Vector2 = gela.position
	for frame in range(10):
		await physics_frame
	_check(gela.position == paused_position, "Gela camina durante el diálogo del portón.")
	_finish(story)
	await process_frame
	_check(world.zone == "street" and gela.guiding, "Gela no continúa hacia la fuente al salir.")
	session._save_now()
	world.queue_free()
	paused = false
	await process_frame
	world = _open()
	session = world.get_node("SaveSession")
	session.continue_button.pressed.emit()
	story = world.get_node("PatioStory")
	player = world.get_node("Nisa")
	gela = world.get_node("Gela")
	_check(world.zone == "street" and gela.guiding and story.street_progress == 0, "Continuar en la calle omite la guía a la fuente.")
	player.position = Vector2(206, 186)
	var crossed := false
	for frame in range(140):
		await physics_frame
		crossed = crossed or world.FOUNTAIN_BOUNDS.grow(3.5).has_point(gela.position)
	_check(not crossed and gela.guide_arrived, "Gela atraviesa la fuente o no alcanza el lugar de la pista.")
	player.position = story.FOUNTAIN_POSITION + Vector2(0, 26)
	story._interact()
	_finish(story)
	_check(story.street_progress == 1 and not gela.guiding and gela.following, "Examinar la fuente no devuelve el seguimiento habitual.")
	world.queue_free()
	paused = false
	await process_frame
	for suffix in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(test_path + suffix):
			DirAccess.remove_absolute(test_path + suffix)
	DirAccess.remove_absolute(test_path.get_base_dir())
	if failures == 0:
		print("PASS: ruido, invitación de Gela, guía, espera, separación, fuente, diálogos y continuar en ambas zonas.")
	quit(1 if failures else 0)
