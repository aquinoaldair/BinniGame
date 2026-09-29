extends Node2D

# Relato ficticio provisional: no incluye traducciones ni costumbres atribuidas a la región.
const FAMILY_POSITION := Vector2(240, 92)
const OBJECT_POSITION := Vector2(365, 174)
const INTERACTION_DISTANCE := 32.0

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
@onready var player = get_parent().get_node("Nisa")


func _ready() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 6
	add_child(layer)

	objective = Label.new()
	objective.position = Vector2(12, 39)
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
	if player.position.distance_to(FAMILY_POSITION) <= INTERACTION_DISTANCE:
		return "Hablar"
	if stage == Stage.SEARCH and player.position.distance_to(OBJECT_POSITION) <= INTERACTION_DISTANCE:
		return "Recoger"
	return ""


func _interact() -> void:
	if not dialogue.is_empty():
		return
	var action := _nearby_action()
	if action == "Recoger":
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
				_start_dialogue(["Bixhozegola: Gracias por escucharme, Nisa. Seguiremos recordando juntas."], Stage.COMPLETE)


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
	_update_objective()
	queue_redraw()


func _update_objective() -> void:
	match stage:
		Stage.MEET: objective.text = "Acércate a Bixhozegola junto al banco y habla."
		Stage.SEARCH: objective.text = "Busca el cuaderno al lado derecho del patio."
		Stage.RETURN: objective.text = "Regresa con Bixhozegola y comparte el cuaderno."
		Stage.COMPLETE: objective.text = "Recuerdo compartido · Primer encuentro completado."


func _draw() -> void:
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
