extends SceneTree

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _close_dialogue(story: Node) -> void:
	while not story.dialogue.is_empty():
		story._advance_dialogue()


func _run() -> void:
	var world = load("res://scenes/main.tscn").instantiate()
	world.start_menu_enabled = false
	root.add_child(world)
	await process_frame
	await process_frame
	var player = world.get_node("Nisa")
	var story = world.get_node("PatioStory")
	var companion = world.get_node("Gela")
	var art = companion.get_node("GelaArt")
	var sprite: AnimatedSprite2D = art.sprite
	var frames := sprite.sprite_frames
	_check(companion.position == Vector2(66, 151), "El encuentro no está en el suelo debajo del árbol izquierdo.")
	_check(not companion.available and not companion.visible and not sprite.is_playing(), "El arte muestra o anima a Gela antes de la entrega.")
	_check(companion.scale == Vector2.ONE and companion.collision_layer == 2 and companion.collision_mask == 1, "El arte cambió el cuerpo físico de Gela.")
	_check(companion.get_node("CollisionShape2D").shape.radius == 4.0 and companion.get_node("CollisionShape2D").disabled, "El arte modificó o activó la colisión inicial.")
	_check(companion.FOLLOW_SPEED == 90.0 and companion.FOLLOW_DISTANCE == 32.0 and companion.MIN_DISTANCE == 28.0, "El rediseño cambió el seguimiento.")
	_check(frames.get_animation_names().size() == 8, "Gela necesita ocho animaciones direccionales.")
	var directions := ["down", "up", "left", "right"]
	var axes := [Vector2.DOWN, Vector2.UP, Vector2.LEFT, Vector2.RIGHT]
	for direction in directions:
		for kind in ["idle", "walk"]:
			var animation: String = kind + "_" + direction
			var count: int = 3 if kind == "idle" else 6
			_check(frames.get_frame_count(animation) == count and frames.get_animation_loop(animation), "Faltan poses del ciclo: " + animation)
			for index in range(count):
				var texture := frames.get_frame_texture(animation, index)
				_check(texture is AtlasTexture and texture.get_size().is_equal_approx(Vector2(512, 512)), "Los fotogramas no comparten un lienzo uniforme.")
	var image: Image = load("res://assets/characters/gela/gela_atlas.png").get_image()
	_check(image.get_pixel(0, 0).a == 0, "El atlas de Gela no es transparente.")
	player.position = story.FAMILY_POSITION + Vector2(0, 12)
	story._interact()
	_close_dialogue(story)
	player.position = story.OBJECT_POSITION
	story._interact()
	_close_dialogue(story)
	player.position = story.FAMILY_POSITION + Vector2(0, 12)
	story._interact()
	_check(not companion.available, "Gela aparece antes de cerrar la entrega.")
	_close_dialogue(story)
	await process_frame
	await process_frame
	_check(companion.available and companion.visible and sprite.is_playing(), "La entrega no activa el nuevo arte.")
	_check(not companion.get_node("CollisionShape2D").disabled and not companion.following, "El encuentro alteró la activación o anticipó el seguimiento.")
	var resting_position: Vector2 = companion.position
	for index in range(4):
		companion.facing = axes[index]
		await process_frame
		await process_frame
		_check(sprite.animation == "idle_" + directions[index] and not sprite.flip_h and art.rotation == 0, "El reposo no respeta la dirección ilustrada.")
		_check(companion.position == resting_position, "La animación desplaza el cuerpo.")
		_check((sprite.position + art.FLOOR_ORIGIN * sprite.scale).is_equal_approx(Vector2.ZERO), "La respiración desplaza el origen del suelo.")
	player.position = companion.position + Vector2(20, 0)
	story._interact()
	_close_dialogue(story)
	_check(companion.following, "El saludo no conserva la incorporación de Gela.")
	story.clue_received = true
	story.sync_companion_guide()
	for index in range(4):
		companion.position = Vector2(110, 145)
		player.position = companion.position + axes[index] * 70
		companion.path_timer = 0.0
		for tick in range(18):
			await physics_frame
		await process_frame
		await process_frame
		_check(sprite.animation == "walk_" + directions[index] and sprite.is_playing(), "El seguimiento no selecciona la caminata real.")
		_check(sprite.frame > 0 and companion.velocity.length_squared() > 1, "El ciclo no avanza mientras Gela camina.")
		_check(art.position == Vector2.ZERO and companion.scale == Vector2.ONE, "El movimiento visual cambió el origen o la escala física.")
	player.position = story.FAMILY_POSITION + Vector2(0, 12)
	story._interact()
	await physics_frame
	await physics_frame
	await process_frame
	var paused_position: Vector2 = companion.position
	for tick in range(8):
		await physics_frame
	_check(sprite.animation.begins_with("idle_") and companion.position == paused_position, "Gela camina o se desplaza durante el diálogo.")
	_close_dialogue(story)
	for tick in range(20):
		await physics_frame
	_check(companion.position.distance_to(paused_position) > 1, "El arte impide reanudar el seguimiento.")
	world.set_zone("street")
	await process_frame
	await process_frame
	_check(art.is_visible_in_tree() and sprite.sprite_frames == frames, "Gela pierde su diseño al salir del patio.")
	world.set_zone("patio")
	art.direction = "right"
	_check(art._direction_for(Vector2(0.71, 0.70)) == "right" and art._direction_for(Vector2(0.70, 0.71)) == "right", "El dibujo cambia de vista por ruido al caminar diagonalmente.")
	world.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: Gela, ocho animaciones, 36 poses, entrega, saludo, seguimiento, pausa, suelo y continuidad entre zonas.")
	quit(1 if failures else 0)
