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
	var story = world.get_node("PatioStory")
	var player = world.get_node("Nisa")
	var family = world.get_node("PatioPresentation/BixhozegolaVisual")
	var sprite: AnimatedSprite2D = family.sprite
	var frames := sprite.sprite_frames
	_check(family.position == story.FAMILY_POSITION and family.scale == Vector2.ONE, "La presentación desplazó el punto de interacción de la abuela.")
	_check(world.y_sort_enabled and family.get_parent().y_sort_enabled, "La abuela perdió la profundidad compartida con Nisa.")
	_check(frames.get_animation_names().size() == 2 and frames.has_animation("idle_down") and frames.has_animation("talk_down"), "La abuela necesita reposo y conversación frontal.")
	for animation in ["idle_down", "talk_down"]:
		_check(frames.get_frame_count(animation) == 3 and frames.get_animation_loop(animation), "La animación no tiene tres fotogramas en bucle.")
		for index in range(3):
			var texture := frames.get_frame_texture(animation, index)
			_check(texture is AtlasTexture and texture.get_size() == Vector2(320, 544), "Los fotogramas no comparten lienzo y alineación.")
	_check(sprite.position.is_equal_approx(Vector2(-160, -512) * family.SPRITE_SCALE) and not sprite.flip_h, "Se cambió el origen de los pies o se reflejó el bordado.")
	var image: Image = load("res://assets/characters/bixhozegola/bixhozegola_atlas.png").get_image()
	_check(image.get_pixel(0, 0).a == 0, "El atlas de la abuela no es transparente.")
	_check(sprite.animation == "idle_down" and not family.speaking, "La abuela habla fuera del diálogo.")
	player.position = story.FAMILY_POSITION + Vector2(0, 15)
	_check(story._nearby_action() == "Hablar", "No se puede hablar en el punto original.")
	story._interact()
	await process_frame
	await process_frame
	_check(sprite.animation == "talk_down" and family.speaking and not player.can_move, "El gesto de conversación no coincide con el turno de Bixhozegola.")
	story._advance_dialogue()
	await process_frame
	await process_frame
	_check(sprite.animation == "idle_down" and not family.speaking, "La abuela mueve la boca durante el turno de Nisa.")
	story._advance_dialogue()
	await process_frame
	await process_frame
	_check(sprite.animation == "talk_down" and family.speaking, "La abuela no retoma su conversación.")
	story._advance_dialogue()
	await process_frame
	await process_frame
	_check(story.stage == story.Stage.SEARCH and sprite.animation == "idle_down", "El rediseño alteró el objetivo o dejó la boca animada.")
	player.position = story.OBJECT_POSITION
	story._interact()
	await process_frame
	await process_frame
	_check(not family.speaking and sprite.animation == "idle_down", "La abuela habla durante la recogida del cuaderno.")
	story._advance_dialogue()
	_check(story.stage == story.Stage.RETURN, "El cuaderno no conserva su progreso.")
	world.set_zone("street")
	await process_frame
	await process_frame
	_check(not family.is_visible_in_tree() and not sprite.is_playing(), "La abuela se muestra o anima en la calle.")
	world.set_zone("patio")
	await process_frame
	await process_frame
	_check(family.is_visible_in_tree() and sprite.is_playing() and sprite.animation == "idle_down", "La abuela no recupera su presentación al regresar.")
	_check(family.position == story.FAMILY_POSITION, "El sprite introdujo movimiento en la abuela.")
	world.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: Bixhozegola, atlas, pies, turnos de voz, punto de interacción y aislamiento de la calle.")
	quit(1 if failures else 0)
