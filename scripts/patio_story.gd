extends Node2D

signal progress_committed

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
	action_button.visible = dialogue.is_empty() and _nearby_action() != ""
	action_button.text = _nearby_action() + " [E]"


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_E:
		if dialogue.is_empty():
			_interact()
		else:
			_advance_dialogue()
		get_viewport().set_input_as_handled()


func _nearby_action() -> String:
	if get_parent().zone == "street":
		if player.position.distance_to(STREET_GATE) <= INTERACTION_DISTANCE:
			return "Volver"
		if player.position.distance_to(FOUNTAIN_POSITION) <= INTERACTION_DISTANCE:
			return "Examinar"
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
				"Nisa: Antes de salir, revisaré el cuaderno. Aquí hay un dibujo de una fuente con una flor azul.",
				"Nisa: Podemos buscarla en la calle y preguntar si alguien recuerda el relato de la abuela. ¡Vamos, Gela!"
			], stage)
	elif action == "Volver":
		_change_zone("patio")
	elif action == "Portón":
		var reminder := "Nisa: Primero hablaré con la abuela junto al banco."
		match stage:
			Stage.SEARCH: reminder = "Nisa: Primero buscaré el cuaderno al lado derecho del patio."
			Stage.RETURN: reminder = "Nisa: Tengo el cuaderno. Primero se lo entregaré a la abuela."
			Stage.COMPLETE: reminder = "Nisa: El cuaderno ya está entregado. Me falta saludar a Gela en el jardín para que venga conmigo."
		_start_dialogue([reminder], stage)
	elif get_parent().zone == "street":
		_interact_street(action)
	elif action == "Saludar":
		pending_companion = true
		_start_dialogue([
			"Nisa: ¡Hola, Gela! ¿Quieres explorar el patio conmigo?",
			"Gela se acerca a Nisa y se queda a su lado."
		], stage)
	elif action == "Recoger":
		_start_dialogue(["Nisa: Aquí está el cuaderno. Quizá sus páginas nos ayuden a recordar."], Stage.RETURN)
	elif action == "Hablar":
		match stage:
			Stage.MEET:
				_start_dialogue([
					"Bixhozegola: Nisa, quiero contarte un relato que escuchaba de pequeña. Hoy no logro recordar una de sus palabras.",
					"Nisa: Podemos buscarla juntas. ¿Hay algo que te ayude a recordar?",
					"Bixhozegola: Dejé un cuaderno al lado derecho del patio. Tráelo y leamos juntas."
				], Stage.SEARCH)
			Stage.SEARCH:
				_start_dialogue(["Bixhozegola: El cuaderno está al lado derecho del patio. Te espero aquí."], Stage.SEARCH)
			Stage.RETURN:
				_start_dialogue([
					"Nisa: Encontré el cuaderno. ¿Podemos leer el relato juntas?",
					"Bixhozegola: Sí. Ahora recuerdo cómo empezaba. La palabra aún se me escapa, pero podemos seguir buscándola.",
					"Nisa: Voy a escucharte y a guardar lo que recuerdes."
				], Stage.COMPLETE)
			Stage.COMPLETE:
				if companion.following and not clue_received:
					pending_clue = true
					_start_dialogue([
						"Bixhozegola: Mira este dibujo del cuaderno: una fuente con una flor azul. Recuerdo un relato sobre ese lugar, pero una parte se me escapa.",
						"Bixhozegola: La fuente está al salir del patio. Una vecina suele descansar cerca; quizá recuerde otra parte.",
						"Nisa: Iré con Gela. Cuando regrese, te contaré lo que encontremos."
					], Stage.COMPLETE)
				elif street_progress == 2:
					pending_street_progress = 3
					_start_dialogue([
						"Nisa: La flor del dibujo no está en la fuente. La vecina recuerda que alguien la pintó, pero ha olvidado quién.",
						"Bixhozegola: Entonces reunamos lo que cada persona recuerde. No tenemos que encontrar toda la historia de una vez.",
						"Nisa: Lo anotaré en el cuaderno. Seguiremos buscando juntas."
					], Stage.COMPLETE)
				else:
					_start_dialogue(["Bixhozegola: Gracias por escucharme, Nisa. Seguiremos recordando juntas."], Stage.COMPLETE)


func _interact_street(action: String) -> void:
	if action == "Examinar":
		pending_street_progress = maxi(street_progress, 1)
		_start_dialogue([
			"Nisa: Es la fuente del cuaderno... pero aquí no está la flor azul del dibujo.",
			"Gela se detiene junto al azulejo vacío. Nisa compara el lugar con la página del cuaderno."
		], stage)
	elif action == "Hablar":
		if street_progress == 0:
			_start_dialogue(["Vecina: ¿Traes un dibujo de la fuente? Mírala de cerca y luego me cuentas qué encontraste."], stage)
		elif street_progress == 1:
			pending_street_progress = 2
			_start_dialogue([
				"Nisa: En este dibujo hay una flor azul. En la fuente solo queda un espacio vacío.",
				"Vecina: Recuerdo esa flor. Alguien la pintó mientras nos contaba una historia... pero no logro recordar quién era.",
				"Nisa: Mi abuela recuerda otra parte. Voy a contarle lo que me dijiste."
			], stage)
		else:
			_start_dialogue(["Vecina: Si recuerdo algo más sobre la flor, te lo contaré. Gracias por escuchar."], stage)


func _change_zone(next_zone: String) -> void:
	get_parent().set_zone(next_zone)
	player.position = Vector2(140, 220) if next_zone == "street" else Vector2(123, 88)
	companion.position = Vector2(176, 225) if next_zone == "street" else Vector2(123, 124)
	player.velocity = Vector2.ZERO
	companion.velocity = Vector2.ZERO
	companion.path_timer = 0.0
	companion.path.clear()
	_update_objective()
	queue_redraw()
	progress_committed.emit()
	get_parent().queue_redraw()


func _start_dialogue(lines: Array[String], next_stage: Stage) -> void:
	dialogue = lines
	dialogue_index = 0
	pending_stage = next_stage
	player.can_move = false
	action_button.hide()
	dialogue_panel.show()
	_show_line()


func _show_line() -> void:
	dialogue_text.text = dialogue[dialogue_index]
	next_button.text = "Cerrar [E]" if dialogue_index == dialogue.size() - 1 else "Siguiente [E]"


func _advance_dialogue() -> void:
	if dialogue.is_empty():
		return
	dialogue_index += 1
	if dialogue_index < dialogue.size():
		_show_line()
		return
	dialogue.clear()
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
	if pending_street_progress >= 0:
		street_progress = pending_street_progress
		pending_street_progress = -1
	if pending_exit:
		pending_exit = false
		_change_zone("street")
		return
	_update_objective()
	queue_redraw()
	progress_committed.emit()
	get_parent().queue_redraw()


func _update_objective() -> void:
	match stage:
		Stage.MEET: objective.text = "Acércate a Bixhozegola junto al banco y habla."
		Stage.SEARCH: objective.text = "Busca el cuaderno al lado derecho del patio."
		Stage.RETURN: objective.text = "Regresa con Bixhozegola y comparte el cuaderno."
		Stage.COMPLETE:
			if not companion.following:
				objective.text = "Busca a Gela en el jardín y salúdala."
			elif not clue_received:
				objective.text = "Sal por el portón con Gela; revisarán el cuaderno antes de salir."
			elif street_progress == 3:
				objective.text = "Primer paseo completado · El cuaderno guarda una nueva pista."
			elif get_parent().zone == "patio":
				objective.text = "Comparte la pista con la abuela." if street_progress == 2 else "Sal por el portón con Gela y busca la fuente."
			else:
				match street_progress:
					0: objective.text = "Examina la fuente y compárala con el dibujo."
					1: objective.text = "Pregunta a la vecina por la flor azul."
					2: objective.text = "Vuelve por el portón y habla con la abuela."


func _draw() -> void:
	if get_parent().zone == "street":
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
