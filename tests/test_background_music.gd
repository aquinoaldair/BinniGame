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
	var music = world.get_node("BackgroundMusic")
	var story = world.get_node("PatioStory")
	var speaker = music.speaker
	_check(speaker.playing and speaker.stream.loop and speaker.stream.get_length() >= 48, "La música no inicia en bucle.")
	var lines: Array[String] = ["Nisa: Escucho el viento."]
	story._start_dialogue(lines, story.stage)
	await create_timer(0.6).timeout
	_check(is_equal_approx(speaker.volume_db, music.QUIET_VOLUME), "La música no baja durante el diálogo.")
	story._advance_dialogue()
	await create_timer(0.6).timeout
	_check(is_equal_approx(speaker.volume_db, music.EXPLORATION_VOLUME), "La música no recupera el volumen al explorar.")
	var stream = speaker.stream
	world.set_zone("street")
	world.set_zone("jacinto")
	_check(speaker.stream == stream and speaker.playing, "Cambiar de zona reinicia o corta la música.")
	var game = world.get_node("JacintoPresentation/Slingshot")
	game.start()
	await create_timer(0.6).timeout
	_check(is_equal_approx(speaker.volume_db, music.QUIET_VOLUME), "La música tapa los efectos de la resortera.")
	game.cancel(true)
	var ui = world.get_node("PatioUI")
	ui.music_button.pressed.emit()
	_check(music.muted and is_zero_approx(speaker.volume_linear) and speaker.playing, "El botón no silencia la música manteniendo el bucle.")
	ui.music_button.pressed.emit()
	_check(not music.muted and speaker.volume_linear > 0, "El botón no reactiva la música.")
	world.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: bucle instrumental, volumen contextual, continuidad entre zonas y botón de silencio.")
	quit(1 if failures else 0)
