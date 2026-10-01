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
	var art = world.get_node("StreetPresentation")
	var story = world.get_node("PatioStory")
	var stage = story.stage
	_check(not art.visible, "La calle se dibuja sobre el patio.")
	world.set_zone("street")
	await process_frame
	await process_frame
	_check(art.visible and world.y_sort_enabled and art.y_sort_enabled, "La calle no activa el orden por profundidad.")
	_check(not world.get_node("PatioPresentation").visible and story.stage == stage, "La presentación cambia la historia o mezcla zonas.")
	_check(world.STREET_HOUSES == [Rect2(28, 52, 143, 65), Rect2(325, 52, 124, 65)] and world.FOUNTAIN_BOUNDS == Rect2(205, 115, 40, 40), "El rediseño cambia las colisiones originales.")
	_check(art.find_children("*", "CollisionObject2D", true, false).is_empty(), "La decoración añade obstáculos.")
	var ground = art.get_node("Ground")
	_check(not ground.is_processing() and ground.layers.size() >= 4, "El terreno no usa superficies estáticas de tiles.")
	for layer in ground.layers:
		_check(not layer.collision_enabled and not layer.navigation_enabled and layer.get_used_cells().size() > 0, "Los tiles bloquean el recorrido o están vacíos.")
	_check(art.get_node("Vecina").position == story.NEIGHBOR_POSITION and not art.get_node("Vecina").is_processing(), "La vecina cambia de posición o ejecuta comportamiento nuevo.")
	_check(world.get_companion_path(Vector2(176, 225), Vector2(225, 179)).size() > 1, "El pozo interrumpe el recorrido de Gela.")
	var well = art.get_node("Well")
	_check(well.y_sort_enabled and well.has_node("WellBase/BackRim") and well.has_node("WellBase/FrontRim") and well.has_node("WellStructure"), "El pozo no separa brocal y estructura.")
	_check(not well.is_processing() and well.has_node("Bucket"), "El pozo ejecuta animaciones innecesarias o no reutiliza la cubeta.")
	world.get_node("Nisa").position = story.FOUNTAIN_POSITION + Vector2(0, 26)
	_check(story._nearby_action() == "Examinar el pozo", "La interacción todavía muestra el nombre anterior.")
	for path in ["res://assets/street/well.png", "res://assets/characters/vecina/vecina.png"]:
		var texture: Texture2D = load(path)
		_check(texture.get_width() <= 512 and texture.get_height() <= 512, "El recurso móvil supera el límite de importación.")
	world.set_zone("patio")
	await process_frame
	await process_frame
	_check(not art.visible, "El pozo sigue visible fuera de la calle.")
	world.modern_street_enabled = false
	world.set_zone("street")
	await process_frame
	await process_frame
	_check(not art.visible, "El dibujo anterior y la presentación ilustrada se superponen.")
	world.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: calle ilustrada, colisiones, terreno, profundidad, vecina, rutas y pozo estático.")
	quit(1 if failures else 0)
