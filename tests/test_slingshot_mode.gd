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
	var story = world.get_node("PatioStory")
	var player = world.get_node("Nisa")
	var gela = world.get_node("Gela")
	var game = world.get_node("JacintoPresentation/Slingshot")
	story.stage = story.Stage.COMPLETE
	story.pending_stage = story.stage
	story.clue_received = true
	story.street_progress = 3
	gela.appear()
	gela.start_following(player)
	world.set_zone("street")
	player.position = Vector2(444, 161)
	await process_frame
	_check(world.zone == "street", "La salida adelanta la misión antes de recibir la pista.")
	story.next_clue_received = true
	player.facing = Vector2.RIGHT
	await process_frame
	_check(world.zone == "jacinto" and player.position.x < 55 and player.facing == Vector2.RIGHT, "La salida al borde no conserva entrada y orientación.")
	player.position = Vector2(35, 225)
	player.facing = Vector2.LEFT
	await process_frame
	_check(world.zone == "street" and player.position.x > 420 and player.facing == Vector2.LEFT, "La salida de regreso no conecta los lados correctos.")
	world.set_zone("jacinto")
	player.position = story.MANGO_POSITION
	story.jacinto_progress = story.JacintoProgress.HELP
	var camera = world.get_node("PatioCamera")
	await process_frame
	var camera_zoom: Vector2 = camera.zoom
	var camera_position: Vector2 = camera.position
	var map_position: Vector2 = player.position
	game.start()
	var first_layout: PackedVector2Array = game.target_points.duplicate()
	for index in range(first_layout.size()):
		_check(first_layout[index].distance_to(game.base_target_points[index]) <= 18, "Un mango sale de su región alcanzable.")
	await create_timer(0.25).timeout
	_check(game.active and game.mode.visible and game.screen.visible and not player.can_move and game.sling.polygon.size() > 0, "El modo no muestra su pantalla y resortera.")
	var old_fruit: Vector2 = game.fruits[0].position
	await create_timer(0.25).timeout
	_check(game.fruits[0].position != old_fruit, "El mango sigue completamente estático.")
	var touch := InputEventScreenTouch.new()
	touch.index = 3
	touch.pressed = true
	touch.position = game.target_points[0]
	game._aim_input(touch)
	var initial_pouch: Vector2 = game.pouch.position
	await create_timer(0.4).timeout
	_check(game.charging and game.power > 0.2 and game.loaded_stone.visible and game.pouch.position != initial_pouch, "Mantener el toque no estira las gomas ni carga potencia.")
	var other := InputEventScreenTouch.new()
	other.index = 4
	other.pressed = true
	other.position = Vector2(50, 50)
	game._aim_input(other)
	_check(game.charge_finger == 3 and game.aim == touch.position, "Otro dedo sustituye el apuntado principal.")
	touch.pressed = false
	game._aim_input(touch)
	_check(game.launch_sound.playing, "Lanzar la piedra no reproduce sonido.")
	_check(game.busy and game.stone.visible and not game.charging, "Soltar no lanza la piedra.")
	var launched: Vector2 = game.stone.position
	await create_timer(0.16).timeout
	_check(game.stone.position != launched and game.trail.get_point_count() > 1, "La piedra no recorre la trayectoria con estela.")
	var low: Vector2 = game.projectile_point(0.2, 1, 0, game.target_points[1], game.launcher_origin)
	var high: Vector2 = game.projectile_point(0.9, 1, 0, game.target_points[1], game.launcher_origin)
	_check(high.distance_to(game.launcher_origin) > low.distance_to(game.launcher_origin) + 50, "La potencia no modifica el alcance.")
	var calm: Vector2 = game.projectile_point(0.65, 1, 0, game.target_points[1], game.launcher_origin)
	var windy: Vector2 = game.projectile_point(0.65, 1, 8, game.target_points[1], game.launcher_origin)
	_check(is_equal_approx(windy.x - calm.x, 8), "El viento no desvía el proyectil.")
	var midpoint: Vector2 = game.projectile_point(0.65, 0.5, 0, game.target_points[1], game.launcher_origin)
	_check(midpoint.y < game.launcher_origin.lerp(calm, 0.5).y - 30, "La trayectoria sigue siendo una línea recta.")
	game.cancel(true)
	_check(not game.active and player.can_move and not game.is_processing() and not game.mode.visible, "Cancelar durante el vuelo no restaura controles y procesamiento.")
	_check(player.position == map_position and camera.zoom == camera_zoom and camera.position == camera_position, "Salir del modo desplaza al personaje o altera la cámara.")
	game.start()
	game.shot_power = 0.65
	game._resolve_impact(Vector2(275, 200))
	_check(game.last_impact == "trunk", "El impacto en el tronco no distingue el sonido seco.")
	game._resolve_impact(Vector2(180, 155))
	_check(game.last_impact == "branch" and game.leaves[0].visible, "Una rama no reacciona ni desprende hojas.")
	game.cancel(true)
	game.start()
	for index in range(game.target_points.size()):
		game.aim = game.target_points[index]
		game.begin_charge()
		game.power = 0.65
		game.fire()
		await create_timer(1.7 if index < 2 else 1.1).timeout
		if index == 0:
			_check(game.hits == 1 and game.fruits[0].visible and game.fruits[0].position.y > 220, "El mango no cae al suelo y permanece visible.")
		elif index == 1:
			_check(game.hits == 2, "El segundo mango no responde al disparo.")
		else:
			_check(game.active and not player.can_move and game.hits == 3, "No se conserva la pausa para observar la última caída.")
	await create_timer(1.9).timeout
	_check(not game.active and not game.mode.visible and player.can_move and story.jacinto_progress == 2, "El tercer mango no regresa al mapa y habilita el recuerdo.")
	_check(camera.zoom == camera_zoom and camera.position == camera_position and player.position == map_position, "La transición final altera el encuadre del mapa.")
	_check(story._nearby_action() == "Usar resortera", "La resortera deja de estar disponible después de ganar.")
	story.jacinto_progress = story.JacintoProgress.SHARED
	story._interact_jacinto("Usar resortera")
	_check(game.active and game.target_points != first_layout and game.hits == 0 and game.fallen.is_empty(), "Rejugar no reinicia mangos o no cambia sus posiciones.")
	game.cancel(true)
	story.complete_mango_game()
	_check(story.jacinto_progress == story.JacintoProgress.SHARED, "Rejugar retrocede el progreso narrativo.")
	world.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: sendero y bordes, pantalla propia, carga, toque, trayectoria, viento, impactos, caída y restauración.")
	quit(1 if failures else 0)
