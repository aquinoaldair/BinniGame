extends SceneTree

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _run() -> void:
	var world = load("res://scenes/main.tscn").instantiate()
	world.start_menu_enabled = false
	root.add_child(world)
	await process_frame
	await process_frame
	var player = world.get_node("Nisa")
	var story = world.get_node("PatioStory")
	var camera = world.get_node("PatioCamera")
	var presentation = world.get_node("PatioPresentation")
	var ui = world.get_node("PatioUI")
	_check(world.y_sort_enabled and presentation.y_sort_enabled, "El patio no ordena personajes y objetos por su pie.")
	_check(player.scale == Vector2.ONE and player.get_node("CollisionShape2D").shape.radius == 6.5, "El arte alteró las colisiones de Nisa.")
	_check(player.human_art.modern_enabled and player.human_art.VISUAL_SCALE >= 1.5, "No se aplica la nueva representación de Nisa.")
	_check(camera.zoom.x > 1 and camera.position_smoothing_enabled, "No hay cámara cercana con seguimiento suave.")
	_check(not world.hint.visible and not story.objective.visible, "La franja de instrucciones sigue visible.")
	_check(not story.action_button.visible, "La acción aparece lejos de un objeto interactuable.")
	player.position = story.FAMILY_POSITION + Vector2(0, 15)
	await process_frame
	await process_frame
	_check(story.action_button.visible and story.action_button.text.contains("Hablar"), "Falta la indicación contextual para la abuela.")
	ui.help_button.pressed.emit()
	await process_frame
	await process_frame
	_check(ui.help_panel.visible and ui.help_text.text.contains(story.objective.text), "El objetivo no puede consultarse.")
	story.action_button.pressed.emit()
	await process_frame
	await process_frame
	_check(story.dialogue_panel.visible and not player.can_move and not story.action_button.visible, "La interfaz no respeta el diálogo.")
	_check(player.human_art.pose == player.human_art.Pose.INTERACT, "No se activa la pose de interacción.")
	_check(not ui.help_panel.visible, "La ayuda tapa el diálogo.")
	while not story.dialogue.is_empty():
		story.next_button.pressed.emit()
	await process_frame
	await process_frame
	_check(story.stage == story.Stage.SEARCH and presentation.book.visible, "La presentación del cuaderno no sigue la misión.")
	_check(not world.get_node("Gela").visible, "La modernización anticipó a Gela.")
	Input.action_press("move_left")
	await physics_frame
	await physics_frame
	await process_frame
	await process_frame
	_check(player.human_art.pose == player.human_art.Pose.WALK, "No se activa la animación al caminar.")
	Input.action_release("move_left")
	await physics_frame
	await physics_frame
	await process_frame
	await process_frame
	_check(player.human_art.pose == player.human_art.Pose.IDLE, "No se vuelve a la animación de reposo.")
	world.controls.modern = true
	var touch := InputEventScreenTouch.new()
	touch.position = Vector2(25, 223)
	touch.pressed = true
	touch.index = 0
	world.controls._gui_input(touch)
	touch.index = 1
	world.controls._gui_input(touch)
	touch.index = 0
	touch.pressed = false
	world.controls._gui_input(touch)
	_check(Input.is_action_pressed("move_left"), "Soltar un dedo interrumpe el otro.")
	var drag := InputEventScreenDrag.new()
	drag.index = 1
	drag.position = Vector2(69, 223)
	world.controls._gui_input(drag)
	_check(not Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right"), "Arrastrar no cambia la dirección del control.")
	world.controls._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_check(not Input.is_action_pressed("move_right"), "El control queda pulsado al perder foco.")
	_check(world.controls._action_at(Vector2(25, 223)) == "move_left", "La flecha izquierda no coincide con su zona táctil.")
	ui.mobile = true
	ui._sync_layout()
	player.position = story.FAMILY_POSITION + Vector2(0, 15)
	await process_frame
	await process_frame
	_check(world.controls.visible and story.action_button.text == "Hablar" and story.action_button.position == Vector2(368, 224), "Falta el botón contextual móvil.")
	ui.mobile = false
	world.modern_street_enabled = false
	world.set_zone("street")
	await process_frame
	await process_frame
	_check(not presentation.visible and not world.y_sort_enabled and player.human_art.visible, "La calle debe conservar su mapa y el nuevo diseño de Nisa.")
	_check(camera.zoom == Vector2.ONE and world.hint.visible and story.objective.visible, "La calle perdió su presentación original.")
	_check(presentation.get_node("PatioLighting").ambient.color == Color.WHITE, "La iluminación del patio afecta la calle.")
	world.set_zone("patio")
	await process_frame
	await process_frame
	_check(presentation.visible and player.human_art.visible and world.y_sort_enabled, "El patio no recupera su presentación al regresar.")
	world.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: presentación, cámara, colisiones, poses, interfaz contextual, controles y aislamiento de la calle.")
	quit(1 if failures else 0)
