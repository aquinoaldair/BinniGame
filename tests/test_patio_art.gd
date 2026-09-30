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
	var presentation = world.get_node("PatioPresentation")
	var ground = presentation.get_node("Ground")
	var player = world.get_node("Nisa")
	var companion = world.get_node("Gela")
	var story = world.get_node("PatioStory")
	_check(world.MAIN_HOUSE == Rect2(212, 54, 232, 76) and world.SMALL_HOUSE == Rect2(128, 216, 112, 36), "El arte cambió las dimensiones jugables de las casas.")
	_check(world.building_bodies.size() == 5, "Se añadieron obstáculos físicos a la escena.")
	_check(presentation.find_children("*", "CollisionObject2D", true, false).is_empty(), "Un prop decorativo añade colisiones o bloquea un camino.")
	_check(player.position == Vector2(184, 208) and companion.position == Vector2(66, 151) and story.FAMILY_POSITION == Vector2(328, 156), "El escenario desplaza a los personajes.")
	_check(player.scale == Vector2.ONE and player.WALK_SPEED == 78.0, "La presentación modifica el movimiento o tamaño físico de Nisa.")
	_check(not ground.is_processing() and ground.layers.size() >= 4, "El suelo no es estático o no utiliza capas de tiles.")
	for layer in ground.layers:
		_check(layer is TileMapLayer and not layer.collision_enabled and not layer.navigation_enabled, "Los tiles afectan la física o la navegación de Gela.")
		_check(layer.tile_set.get_physics_layers_count() == 0 and layer.tile_set.get_navigation_layers_count() == 0, "El TileSet contiene obstáculos nuevos.")
		_check(layer.get_used_cells().size() > 0, "Una superficie no tiene tiles.")
	var tiles: TileSet = ground.layers[0].tile_set
	_check(tiles.get_source_count() == 4, "Falta un material de suelo.")
	for source in range(4):
		_check(tiles.get_source(source).get_tiles_count() == 16, "El material no incluye sus variantes reutilizables.")
	_check(presentation.trees.size() == 3, "Faltan las variantes de árboles.")
	_check(presentation.trees[1].position.y - presentation.trees[1].extent.y > companion.position.y + 2, "La copa inferior oculta el punto de encuentro con Gela.")
	_check(presentation.trees[2].position.y - presentation.trees[2].extent.y > story.OBJECT_POSITION.y, "La copa derecha oculta el cuaderno.")
	var tree = presentation.trees[0]
	_check(tree.has_node("TreeBase/Trunk") and tree.has_node("TreeCanopy/Leaves"), "El árbol no separa tronco y copa.")
	for prop in presentation.get_children():
		if prop.get_script() == load("res://scripts/presentation/patio_prop.gd"):
			_check(not prop.is_processing(), "Los props estáticos ejecutan lógica por fotograma.")
	var house = presentation.get_node("MainHouse")
	_check(house.has_node("Facade/WallBase") and house.has_node("Facade/Openings/Door") and house.has_node("Facade/PorchSupports") and house.has_node("Roof"), "La casa no conserva sus capas independientes.")
	var small_house = presentation.get_node("SmallHouse")
	_check(small_house.position.y + small_house.projection.position.y > player.position.y + 2, "El tejado cruza los pies de Nisa al iniciar.")
	var original_position: Vector2 = player.position
	player.position = tree.position + Vector2(0, -12)
	presentation._process(0.1)
	_check(tree.canopy.modulate.a < 1, "La copa que tapa a Nisa no mejora su legibilidad.")
	player.position = tree.position + Vector2(0, 12)
	presentation._process(0.1)
	_check(tree.canopy.modulate.a == 1 and tree.position == Vector2(62, 132), "Caminar delante del árbol altera su orden o punto de apoyo.")
	player.position = original_position
	_check(world.get_companion_path(Vector2(66, 151), story.FAMILY_POSITION + Vector2(0, 12)).size() > 1, "La decoración interrumpe el camino de Gela.")
	var ambience = presentation.get_node("Ambience")
	var starting_updates: int = ambience.updates
	for tick in range(120):
		ambience._process(1.0 / 120.0)
	_check(ambience.updates - starting_updates <= 13, "El ambiente actualiza los props a una frecuencia excesiva.")
	world.set_zone("street")
	await process_frame
	await process_frame
	var previous_clock: float = ambience.clock
	var previous_updates: int = ambience.updates
	for tick in range(12):
		await process_frame
	_check(not presentation.visible and ambience.clock == previous_clock and ambience.updates == previous_updates and not ambience.butterfly.is_playing(), "El ambiente del patio se sigue animando en la calle.")
	_check(presentation.get_node("PatioLighting").ambient.color == Color.WHITE, "La luz cálida se filtra a la calle.")
	world.set_zone("patio")
	await process_frame
	await process_frame
	_check(presentation.visible and ambience.butterfly.is_playing(), "El patio no recupera su ambiente al regresar.")
	world.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: TileMapLayer, variantes, capas, punto inicial, oclusión, props sin colisión, rutas y pausa ambiental.")
	quit(1 if failures else 0)
