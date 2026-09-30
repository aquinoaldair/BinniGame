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
	var player = world.get_node("Nisa")
	var art = player.human_art
	var sprite: AnimatedSprite2D = art.sprite
	var frames := sprite.sprite_frames
	_check(frames.get_animation_names().size() == 8, "El atlas debe tener ocho animaciones.")
	_check(player.scale == Vector2.ONE and player.get_node("CollisionShape2D").shape.radius == 6.5, "Los sprites cambiaron la escala física o la colisión.")
	_check(player.collision_layer == 1 and player.collision_mask == 1 and player.WALK_SPEED == 78.0, "El rediseño alteró las propiedades del controlador.")
	var names := ["down", "up", "left", "right"]
	var axes := [Vector2.DOWN, Vector2.UP, Vector2.LEFT, Vector2.RIGHT]
	for index in range(4):
		var direction: String = names[index]
		_check(frames.get_frame_count("idle_" + direction) == 2, "Faltan fotogramas de reposo: " + direction)
		_check(frames.get_frame_count("walk_" + direction) == 4, "Faltan fotogramas de caminata: " + direction)
		for animation in ["idle_" + direction, "walk_" + direction]:
			for frame in range(frames.get_frame_count(animation)):
				var texture := frames.get_frame_texture(animation, frame)
				var lateral_walk: bool = animation in ["walk_left", "walk_right"]
				var canvas := Vector2(640, 640) if lateral_walk else Vector2(320, 320)
				_check(texture is AtlasTexture and texture.get_size() == canvas, "Los fotogramas no comparten el lienzo previsto para su atlas.")
		player.position = Vector2(155, 165)
		player.facing = axes[index]
		await process_frame
		await process_frame
		_check(sprite.animation == "idle_" + direction and not sprite.flip_h, "La vista de reposo no respeta su dirección.")
		var action := "move_" + direction
		Input.action_press(action)
		for frame in range(20):
			await physics_frame
		_check(sprite.animation == "walk_" + direction and sprite.is_playing(), "La caminata no respeta su dirección.")
		var texture := frames.get_frame_texture(sprite.animation, sprite.frame)
		var origin: Vector2 = texture.get_meta("foot_origin", Vector2(160, 304))
		var reference_height: float = texture.get_meta("reference_height", art.ATLAS_REFERENCE_HEIGHT)
		_check((sprite.position + origin * sprite.scale).is_equal_approx(Vector2.ZERO), "Cambiar de resolución desplaza los pies respecto al cuerpo.")
		_check(is_equal_approx(reference_height * sprite.scale.y, art.PREVIOUS_HEIGHT * art.VISUAL_SCALE), "La caminata cambia el tamaño visual del personaje.")
		_check(sprite.frame > 0, "La animación de caminata no avanza.")
		_check(player.velocity.is_equal_approx(axes[index] * 78.0), "La animación altera la velocidad del controlador.")
		Input.action_release(action)
		await physics_frame
		await physics_frame
		await process_frame
		await process_frame
		_check(sprite.animation == "idle_" + direction, "Al detenerse pierde la orientación.")
		player.can_move = false
		await process_frame
		await process_frame
		_check(art.pose == art.Pose.INTERACT and sprite.animation == "idle_" + direction, "Los diálogos alteran o hacen caminar el sprite.")
		player.can_move = true
	var atlas_image: Image = load("res://assets/characters/nisa/nisa_atlas.png").get_image()
	_check(atlas_image.get_pixel(0, 0).a == 0, "El fondo del atlas no es transparente.")
	world.set_zone("street")
	await process_frame
	await process_frame
	_check(art.visible and sprite.sprite_frames == frames, "El diseño de Nisa cambia al salir del patio.")
	world.set_zone("patio")
	player.position = Vector2(123, 59)
	var camera: Camera2D = world.get_node("PatioCamera")
	await process_frame
	await process_frame
	camera.reset_smoothing()
	camera.force_update_scroll()
	var head: Vector2 = player.get_global_transform_with_canvas() * Vector2(0, -80)
	_check(head.y >= 0, "El nuevo tamaño corta el cabello en el borde superior del patio.")
	world.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: ocho animaciones, direcciones, fotogramas, transparencia, encuadre y controlador intacto.")
	quit(1 if failures else 0)
