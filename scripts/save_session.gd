extends Node

const SaveStore = preload("res://scripts/save_store.gd")
const AUTOSAVE_INTERVAL := 10.0

var store := SaveStore.new()
var saved_game: Dictionary = {}
var running := false
var elapsed := 0.0
var status_time := 0.0
var menu_layer: CanvasLayer
var continue_button: Button
var new_button: Button
var menu_message: Label
var confirmation: ConfirmationDialog
var save_status: Label
@onready var world = get_parent()
@onready var player = world.get_node("Nisa")
@onready var companion = world.get_node("Gela")
@onready var story = world.get_node("PatioStory")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	store.save_path = world.save_path
	saved_game = store.load_game()
	story.progress_committed.connect(_save_now)
	get_tree().auto_accept_quit = false
	_build_menu()
	get_tree().paused = true
	if continue_button.disabled:
		new_button.grab_focus()
	else:
		continue_button.grab_focus()


func _build_menu() -> void:
	menu_layer = CanvasLayer.new()
	menu_layer.layer = 20
	add_child(menu_layer)
	var background := ColorRect.new()
	background.color = Color(0.08, 0.14, 0.11, 0.96)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_layer.add_child(background)
	var title := Label.new()
	title.text = "BINNI"
	title.position = Vector2(40, 26)
	title.size = Vector2(400, 36)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	menu_layer.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "El corazón del viento"
	subtitle.position = Vector2(40, 66)
	subtitle.size = Vector2(400, 20)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 12)
	menu_layer.add_child(subtitle)
	continue_button = Button.new()
	continue_button.text = "Continuar"
	continue_button.position = Vector2(135, 101)
	continue_button.size = Vector2(210, 42)
	continue_button.disabled = saved_game.is_empty()
	continue_button.pressed.connect(_continue_game)
	menu_layer.add_child(continue_button)
	new_button = Button.new()
	new_button.text = "Nueva partida"
	new_button.position = Vector2(135, 152)
	new_button.size = Vector2(210, 42)
	new_button.pressed.connect(_request_new_game)
	menu_layer.add_child(new_button)
	menu_message = Label.new()
	menu_message.position = Vector2(40, 206)
	menu_message.size = Vector2(400, 48)
	menu_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	menu_message.add_theme_font_size_override("font_size", 11)
	if store.used_backup:
		menu_message.text = "Continuar recuperará la última copia de respaldo."
	elif saved_game.is_empty():
		menu_message.text = "No se encontró una partida válida." if store.has_files() else "Comienza una nueva aventura. Tu progreso se guardará automáticamente."
	else:
		menu_message.text = "Tu partida está lista para continuar."
	menu_layer.add_child(menu_message)
	confirmation = ConfirmationDialog.new()
	confirmation.title = "Nueva partida"
	confirmation.dialog_text = "Se reemplazará la partida guardada. ¿Empezar de nuevo?"
	confirmation.dialog_autowrap = true
	confirmation.ok_button_text = "Empezar"
	confirmation.cancel_button_text = "Cancelar"
	confirmation.confirmed.connect(_new_game)
	menu_layer.add_child(confirmation)
	var status_layer := CanvasLayer.new()
	status_layer.layer = 7
	add_child(status_layer)
	save_status = Label.new()
	save_status.position = Vector2(12, 258)
	save_status.add_theme_font_size_override("font_size", 8)
	save_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_layer.add_child(save_status)


func _request_new_game() -> void:
	if store.has_files():
		confirmation.popup_centered(Vector2i(350, 130))
	else:
		_new_game()


func _new_game() -> void:
	var error := store.write_game(_capture_state(), true)
	if error != OK:
		menu_message.text = "No se pudo guardar la nueva partida. Intenta nuevamente."
		return
	_begin_play()


func _continue_game() -> void:
	if saved_game.is_empty():
		return
	world.set_zone(saved_game["scene"])
	player.position = world.safe_save_position(_vector(saved_game["nisa_position"]))
	story.stage = int(saved_game["stage"])
	story.pending_stage = story.stage
	story.clue_received = saved_game["clue_received"]
	story.street_progress = int(saved_game["street_progress"])
	if saved_game["gela"]["available"]:
		companion.position = world.safe_save_position(_vector(saved_game["gela"]["position"]))
		companion.appear()
	if saved_game["gela"]["following"]:
		companion.start_following(player)
	story._update_objective()
	story.queue_redraw()
	_begin_play()


func _begin_play() -> void:
	running = true
	player.can_move = true
	menu_layer.hide()
	# Suelta entradas mantenidas mientras se pulsaban los botones del menú.
	for action in ["move_left", "move_right", "move_up", "move_down"]:
		Input.action_release(action)
	get_tree().paused = false
	story.show_opening_if_needed()
	story.sync_companion_guide()
	_save_now()


func _capture_state() -> Dictionary:
	# Durante un diálogo, stage sigue siendo el último objetivo completado.
	return {
		"version": SaveStore.SAVE_VERSION,
		"scene": world.zone,
		"stage": story.stage,
		"clue_received": story.clue_received,
		"street_progress": story.street_progress,
		"nisa_position": [player.position.x, player.position.y],
		"gela": {
			"available": companion.available,
			"following": companion.following,
			"position": [companion.position.x, companion.position.y],
		},
	}


func _vector(value: Array) -> Vector2:
	return Vector2(value[0], value[1])


func _save_now() -> void:
	if not running:
		return
	var error := store.write_game(_capture_state())
	elapsed = 0.0
	save_status.text = "Partida guardada" if error == OK else "No se pudo guardar la partida"
	status_time = 2.5 if error == OK else 10.0


func _process(delta: float) -> void:
	if not running:
		return
	elapsed += delta
	status_time -= delta
	if status_time <= 0:
		save_status.text = ""
	if elapsed >= AUTOSAVE_INTERVAL:
		_save_now()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_save_now()
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_now()
		get_tree().quit()
