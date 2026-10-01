extends Node2D

signal progress_committed
signal encounter_rustle

# Relato ficticio provisional: no incluye traducciones ni costumbres atribuidas a la región.
const FAMILY_POSITION := Vector2(328, 156)
const OBJECT_POSITION := Vector2(398, 188)
const INTERACTION_DISTANCE := 32.0
const GATE_POSITION := Vector2(123, 65)
const STREET_GATE := Vector2(140, 237)
const FOUNTAIN_POSITION := Vector2(225, 153)
const NEIGHBOR_POSITION := Vector2(335, 156)

enum Stage { MEET, SEARCH, RETURN, COMPLETE }

var stage := Stage.MEET
var dialogue: Array[String] = []
var dialogue_index := 0
var pending_stage := Stage.MEET
var action_button: Button
var objective: Label
var dialogue_panel: Panel
var dialogue_text: Label
var next_button: Button
var pending_companion := false
var clue_received := false
var street_progress := 0
var pending_clue := false
var pending_street_progress := -1
var pending_exit := false
var next_clue_received := false
var pending_next_clue := false
var opening_intro_active := false
var memory_observation_active := false
@onready var player = get_parent().get_node("Nisa")
@onready var companion = get_parent().get_node("Gela")


func _ready() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 6
	add_child(layer)

	objective = Label.new()
	objective.position = Vector2(12, 23)
	objective.add_theme_font_size_override("font_size", 9)
	objective.add_theme_color_override("font_color", Color("fff2cb"))
	objective.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(objective)

	action_button = Button.new()
	action_button.position = Vector2(350, 216)
	action_button.size = Vector2(118, 42)
	action_button.add_theme_font_size_override("font_size", 12)
	action_button.pressed.connect(_interact)
	action_button.visible = false
	layer.add_child(action_button)

	dialogue_panel = Panel.new()
	dialogue_panel.position = Vector2(10, 145)
	dialogue_panel.size = Vector2(460, 115)
	dialogue_panel.visible = false
	layer.add_child(dialogue_panel)

	dialogue_text = Label.new()
	dialogue_text.position = Vector2(12, 8)
	dialogue_text.size = Vector2(436, 62)
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_text.add_theme_font_size_override("font_size", 12)
	dialogue_panel.add_child(dialogue_text)

	next_button = Button.new()
	next_button.position = Vector2(310, 72)
	next_button.size = Vector2(138, 36)
	next_button.add_theme_font_size_override("font_size", 12)
	next_button.pressed.connect(_advance_dialogue)
	dialogue_panel.add_child(next_button)
	_update_objective()


func _process(_delta: float) -> void:
	sync_companion_guide()
	action_button.visible = dialogue.is_empty() and _nearby_action() != ""
	action_button.text = _nearby_action() + " [E]"


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_E:
		if dialogue.is_empty():
			_interact()
		else:
			_advance_dialogue()
		get_viewport().set_input_as_handled()


func show_opening_if_needed() -> void:
	if stage != Stage.MEET or not dialogue.is_empty():
		return
	_start_dialogue([
		"Nisa: Qué raro se ve el cielo... Esa franja no se mueve y el viento se quedó quieto. Voy a preguntarle a la abuela."
	], Stage.MEET)
	opening_intro_active = true


func sync_companion_guide() -> void:
	var to_gate: bool = companion.following and not clue_received and get_parent().zone == "patio"
	var to_fountain: bool = companion.following and street_progress == 0 and get_parent().zone == "street"
	var destination := GATE_POSITION if to_gate else FOUNTAIN_POSITION + Vector2(0, 26)
	companion.set_guide(to_gate or to_fountain, destination if to_gate or to_fountain else Vector2.ZERO)


func _nearby_action() -> String:
	if get_parent().zone == "street":
		if player.position.distance_to(STREET_GATE) <= INTERACTION_DISTANCE:
			return "Volver"
		if player.position.distance_to(FOUNTAIN_POSITION) <= INTERACTION_DISTANCE:
			return "Examinar el pozo"
		if player.position.distance_to(NEIGHBOR_POSITION) <= INTERACTION_DISTANCE:
			return "Hablar"
		return ""
	if player.position.distance_to(GATE_POSITION) <= INTERACTION_DISTANCE:
		return "Salir" if stage == Stage.COMPLETE and companion.following else "Portón"
	var action := ""
	var closest := INTERACTION_DISTANCE
	var family_distance: float = player.position.distance_to(FAMILY_POSITION)
	if family_distance <= closest:
		closest = family_distance
		action = "Hablar"
	var object_distance: float = player.position.distance_to(OBJECT_POSITION)
	if stage == Stage.SEARCH and object_distance < closest:
		closest = object_distance
		action = "Recoger"
	var companion_distance: float = player.position.distance_to(companion.position)
	if stage == Stage.COMPLETE and companion.available and not companion.following and companion_distance < closest:
		action = "Saludar"
	return action


func _interact() -> void:
	if not dialogue.is_empty():
		return
	var action := _nearby_action()
	if action == "Salir":
		if clue_received:
			_change_zone("street")
		else:
			pending_clue = true
			pending_exit = true
			_start_dialogue([
				"Gela espera junto al portón y mira a Nisa, como si quisiera mostrarle algo afuera.",
				"Nisa: Voy contigo. Llevaré el cuaderno para comparar lo que encontremos."
			], stage)
	elif action == "Volver":
		_change_zone("patio")
	elif action == "Portón":
		var reminder := "Nisa: Primero hablaré con la abuela junto al banco."
		match stage:
			Stage.SEARCH: reminder = "Nisa: Primero buscaré el cuaderno al lado derecho del patio."
			Stage.RETURN: reminder = "Nisa: Tengo el cuaderno. Primero se lo entregaré a la abuela."
			Stage.COMPLETE: reminder = "Nisa: Algo se movió debajo del árbol. Primero iré a ver qué fue."
		_start_dialogue([reminder], stage)
	elif get_parent().zone == "street":
		_interact_street(action)
	elif action == "Saludar":
		pending_companion = true
		_start_dialogue([
			"Gela sale de entre las hojas y mira hacia el portón. Nisa: ¿Quieres que te siga?",
			"Bixhozegola: Ve con cuidado, Nisa. Y vuelve a contarme qué encontraron."
		], stage)
	elif action == "Recoger":
		_start_dialogue(["Nisa: Aquí está el cuaderno. Hay un pozo dibujado y una frase sin terminar. Se lo llevaré a la abuela."], Stage.RETURN)
	elif action == "Hablar":
		match stage:
			Stage.MEET:
				_start_dialogue([
					"Nisa: Abuela, ¿por qué el cielo tiene esa franja tan pálida? Y el viento se quedó quieto.",
					"Bixhozegola: De pequeña escuché un cuento sobre un cielo así. No lo recuerdo bien... Mi cuaderno podría ayudarnos.",
					"Bixhozegola: Dejé un cuaderno al lado derecho del patio. Tráelo y leamos juntas."
				], Stage.SEARCH)
			Stage.SEARCH:
				_start_dialogue(["Bixhozegola: El cuaderno está al lado derecho del patio. Te espero aquí."], Stage.SEARCH)
			Stage.RETURN:
				_start_dialogue([
					"Nisa: Aquí dice: «Cuando el cielo se detiene, las voces...» La frase quedó incompleta.",
					"Bixhozegola: Falta una palabra en diidxazá y cómo sigue el cuento. Otras personas también recordaban partes.",
					"Nisa: ¿Y cómo encontraremos lo que falta? ... ¿Oíste eso? Algo se mueve debajo del árbol."
				], Stage.COMPLETE)
			Stage.COMPLETE:
				if companion.following and not clue_received:
					pending_clue = true
					_start_dialogue([
						"Bixhozegola: Este dibujo señala el pozo donde nos reuníamos para escuchar el cuento.",
						"Bixhozegola: Está al salir del patio. La vecina suele descansar cerca; quizá recuerde otro fragmento.",
						"Nisa: Iré con Gela. Cuando regrese, te contaré lo que encontremos."
					], Stage.COMPLETE)
				elif street_progress == 2:
					pending_street_progress = 3
					_start_dialogue([
						"Nisa: La vecina recordó: «...encuentran su camino cuando alguien vuelve a escucharlas». Lo contaban juntos.",
						"Bixhozegola: Sí... Esa es una parte. La palabra en diidxazá aún nos falta, pero ya podemos seguir el recuerdo.",
						"Nisa: Lo anotaré para que no se pierda otra vez. Seguiremos escuchando a los demás."
					], Stage.COMPLETE)
				elif street_progress == 3:
					if not next_clue_received:
						pending_next_clue = true
						_start_dialogue([
							"Nisa: Ya anoté lo que recordó la vecina. ¿Quién podría ayudarnos con la palabra que falta?",
							"Bixhozegola: Ahora recuerdo a don Jacinto. Él también contaba ese cuento junto al pozo.",
							"Bixhozegola: Vive junto al árbol grande. Pregúntale qué quería decir esa parte; quizá recuerde la palabra.",
							"Nisa: Llevaré el cuaderno y escucharé cómo lo cuenta. Vamos, Gela."
						], Stage.COMPLETE)
					else:
						_start_dialogue(["Bixhozegola: Busca a don Jacinto junto al árbol grande. Lleva el cuaderno; después podremos leerlo juntas."], Stage.COMPLETE)
				else:
					_start_dialogue(["Bixhozegola: Gracias por escucharme, Nisa. Seguiremos recordando juntas."], Stage.COMPLETE)


func _interact_street(action: String) -> void:
	if action == "Examinar el pozo":
		pending_street_progress = maxi(street_progress, 1)
		_start_dialogue([
			"Gela se detiene junto al pozo. Nisa: ¡Es el lugar del dibujo! ¿Cómo supiste que debíamos venir aquí?",
			"Nisa: En el margen dice: «Aquí nos reuníamos para escuchar el cuento». La vecina está cerca; voy a preguntarle."
		], stage)
	elif action == "Hablar":
		if street_progress == 0:
			_start_dialogue(["Vecina: ¿Buscas el lugar del cuaderno? Mira el pozo de cerca y compara el dibujo. Te espero aquí."], stage)
		elif street_progress == 1:
			pending_street_progress = 2
			_start_dialogue([
				"Nisa: El cielo está extraño. En el cuento del cuaderno dice: «Cuando el cielo se detiene, las voces...» ¿Cómo sigue?",
				"Vecina: «...encuentran su camino cuando alguien vuelve a escucharlas». De niñas lo contábamos entre todos, aquí.",
				"Nisa: ¡Esa parte no estaba! Voy a compartirla con mi abuela. Todavía nos falta una palabra."
			], stage)
		else:
			_start_dialogue(["Vecina: Cada persona recordaba una parte del cuento. Si recuerdo algo más, te lo contaré. Gracias por escuchar."], stage)


func _change_zone(next_zone: String) -> void:
	get_parent().set_zone(next_zone)
	player.position = Vector2(140, 220) if next_zone == "street" else Vector2(123, 88)
	companion.position = Vector2(176, 225) if next_zone == "street" else Vector2(123, 124)
	player.velocity = Vector2.ZERO
	companion.velocity = Vector2.ZERO
	companion.path_timer = 0.0
	companion.path.clear()
	_update_objective()
	sync_companion_guide()
	queue_redraw()
	progress_committed.emit()
	get_parent().queue_redraw()


func _start_dialogue(lines: Array[String], next_stage: Stage) -> void:
	opening_intro_active = false
	memory_observation_active = false
	dialogue = lines
	dialogue_index = 0
	pending_stage = next_stage
	player.can_move = false
	action_button.hide()
	dialogue_panel.show()
	_show_line()


func _show_line() -> void:
	dialogue_text.text = dialogue[dialogue_index]
	if stage == Stage.RETURN and pending_stage == Stage.COMPLETE and dialogue_index == 2:
		encounter_rustle.emit()
	next_button.text = "Cerrar [E]" if dialogue_index == dialogue.size() - 1 else "Siguiente [E]"


func _advance_dialogue() -> void:
	if dialogue.is_empty():
		return
	dialogue_index += 1
	if dialogue_index < dialogue.size():
		_show_line()
		return
	dialogue.clear()
	opening_intro_active = false
	memory_observation_active = false
	dialogue_panel.hide()
	player.can_move = true
	stage = pending_stage
	if stage == Stage.COMPLETE:
		companion.appear()
	if pending_companion:
		companion.start_following(player)
		pending_companion = false
	if pending_clue:
		clue_received = true
		pending_clue = false
	if pending_next_clue:
		next_clue_received = true
		pending_next_clue = false
	var recovered_memory := pending_street_progress == 3 and street_progress < 3
	if pending_street_progress >= 0:
		street_progress = pending_street_progress
		pending_street_progress = -1
	if pending_exit:
		pending_exit = false
		_change_zone("street")
		return
	_update_objective()
	sync_companion_guide()
	queue_redraw()
	progress_committed.emit()
	get_parent().queue_redraw()
	if recovered_memory:
		_start_dialogue([
			"Nisa: La franja cambió un poco... Y volvió una brisa. Todavía falta parte del cuento, pero ya tenemos por dónde seguir."
		], stage)
		memory_observation_active = true


func _update_objective() -> void:
	match stage:
		Stage.MEET: objective.text = "Pregunta a Bixhozegola por el cielo extraño."
		Stage.SEARCH: objective.text = "Busca el cuaderno al lado derecho del patio."
		Stage.RETURN: objective.text = "Regresa con Bixhozegola y comparte el cuaderno."
		Stage.COMPLETE:
			if not companion.following:
				objective.text = "Investiga el ruido debajo del árbol del jardín."
			elif not clue_received:
				objective.text = "Sigue a Gela hacia el portón."
			elif street_progress == 3:
				objective.text = "Busca a don Jacinto junto al árbol grande." if next_clue_received else "Habla con Bixhozegola sobre la palabra pendiente."
			elif get_parent().zone == "patio":
				objective.text = "Comparte el fragmento con la abuela." if street_progress == 2 else "Sal por el portón con Gela y busca el pozo."
			else:
				match street_progress:
					0: objective.text = "Sigue a Gela y examina el pozo."
					1: objective.text = "Pregunta a la vecina cómo sigue el cuento."
					2: objective.text = "Vuelve por el portón y habla con la abuela."


func _draw() -> void:
	if get_parent().zone == "street":
		if not get_parent().modern_street_enabled:
			_draw_neighbor()
		return
	if get_parent().modern_patio_enabled:
		return
	# Bixhozegola: nombre provisional indicado para el personaje; pendiente de verificación lingüística.
	var center := FAMILY_POSITION
	draw_circle(center + Vector2(0, 5), 9, Color(0.2, 0.2, 0.15, 0.3))
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-6, -10), center + Vector2(6, -10),
		center + Vector2(9, 5), center + Vector2(-9, 5)
	]), Color("675879"))
	draw_line(center + Vector2(-8, -7), center + Vector2(-9, 0), Color("ae7453"), 3)
	draw_line(center + Vector2(8, -7), center + Vector2(9, 0), Color("ae7453"), 3)
	draw_circle(center + Vector2(0, -15), 6, Color("ae7453"))
	draw_circle(center + Vector2(5, -20), 3, Color("b5b0a4"))
	draw_rect(Rect2(center + Vector2(-6, -21), Vector2(12, 5)), Color("b5b0a4"))
	draw_circle(center + Vector2(-2, -15), 0.8, Color("28271f"))
	draw_circle(center + Vector2(2, -15), 0.8, Color("28271f"))
	draw_string(ThemeDB.fallback_font, center + Vector2(0, -27), "Bixhozegola", HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color("fff2cb"))

	if stage == Stage.SEARCH:
		draw_arc(OBJECT_POSITION, 12, 0, TAU, 24, Color("fff2cb"), 1)
		draw_rect(Rect2(OBJECT_POSITION + Vector2(-6, -5), Vector2(12, 10)), Color("74462f"))
		draw_rect(Rect2(OBJECT_POSITION + Vector2(-3, -4), Vector2(8, 8)), Color("f0dfab"))
		draw_line(OBJECT_POSITION + Vector2(-1, -1), OBJECT_POSITION + Vector2(3, -1), Color("74462f"), 1)


func _draw_neighbor() -> void:
	var center := NEIGHBOR_POSITION
	draw_circle(center + Vector2(0, 5), 9, Color(0.2, 0.2, 0.15, 0.3))
	draw_rect(Rect2(center + Vector2(-6, -10), Vector2(12, 14)), Color("45677a"))
	draw_line(center + Vector2(-8, -7), center + Vector2(-9, 0), Color("b9815a"), 3)
	draw_line(center + Vector2(8, -7), center + Vector2(9, 0), Color("b9815a"), 3)
	draw_circle(center + Vector2(0, -15), 6, Color("b9815a"))
	draw_rect(Rect2(center + Vector2(-6, -21), Vector2(12, 5)), Color("353329"))
	draw_circle(center + Vector2(-2, -15), 0.8, Color("28271f"))
	draw_circle(center + Vector2(2, -15), 0.8, Color("28271f"))
	draw_string(ThemeDB.fallback_font, center + Vector2(-15, -27), "Vecina", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("fff2cb"))
