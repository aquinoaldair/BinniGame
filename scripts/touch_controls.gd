extends Control

const BUTTON_RADIUS := 13.0
const PAD_CENTER := Vector2(61, 215)

var fingers: Dictionary = {}
var active_actions: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()


func _draw() -> void:
	var directions := {
		"move_left": PAD_CENTER + Vector2(-29, 0),
		"move_right": PAD_CENTER + Vector2(29, 0),
		"move_up": PAD_CENTER + Vector2(0, -29),
		"move_down": PAD_CENTER + Vector2(0, 29),
	}
	for action in directions:
		var center: Vector2 = directions[action]
		var pressed := active_actions.has(action)
		draw_circle(center, BUTTON_RADIUS, Color(0.08, 0.12, 0.10, 0.78 if pressed else 0.55))
		draw_arc(center, BUTTON_RADIUS, 0.0, TAU, 24, Color("e8d7a5", 0.72), 1.0)
		var arrow := "•"
		match action:
			"move_left": arrow = "◀"
			"move_right": arrow = "▶"
			"move_up": arrow = "▲"
			"move_down": arrow = "▼"
		draw_string(ThemeDB.fallback_font, center + Vector2(-4, 3), arrow, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("fff4d3"))


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_set_finger_action(event.index, _action_at(event.position))
		else:
			_release_finger(event.index)
		accept_event()
	elif event is InputEventScreenDrag:
		_set_finger_action(event.index, _action_at(event.position))
		accept_event()


func _action_at(point: Vector2) -> String:
	var centers := {
		"move_left": PAD_CENTER + Vector2(-29, 0),
		"move_right": PAD_CENTER + Vector2(29, 0),
		"move_up": PAD_CENTER + Vector2(0, -29),
		"move_down": PAD_CENTER + Vector2(0, 29),
	}
	for action in centers:
		if point.distance_to(centers[action]) <= BUTTON_RADIUS + 5.0:
			return action
	return ""


func _set_finger_action(finger_id: int, action: String) -> void:
	var previous: String = fingers.get(finger_id, "")
	if previous == action:
		return
	if previous != "":
		_release_action(previous)
	if action != "":
		fingers[finger_id] = action
		_press_action(action)
	else:
		fingers.erase(finger_id)
	queue_redraw()


func _release_finger(finger_id: int) -> void:
	var action: String = fingers.get(finger_id, "")
	if action != "":
		fingers.erase(finger_id)
		_release_action(action)
	queue_redraw()


func _press_action(action: String) -> void:
	var count: int = active_actions.get(action, 0)
	active_actions[action] = count + 1
	Input.action_press(action)


func _release_action(action: String) -> void:
	var count: int = active_actions.get(action, 0) - 1
	if count <= 0:
		active_actions.erase(action)
		Input.action_release(action)
	else:
		active_actions[action] = count
