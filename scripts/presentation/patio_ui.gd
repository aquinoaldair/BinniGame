extends Node

# Presenta los controles existentes; no decide acciones ni avanza el relato.
var world: Node2D
var story: Node2D
var help_button: Button
var help_panel: PanelContainer
var help_text: Label
var active := false
var help_open := false
var last_objective := ""
var mobile := false


func _ready() -> void:
	mobile = DisplayServer.is_touchscreen_available()
	var layer := CanvasLayer.new()
	layer.layer = 8
	add_child(layer)
	help_button = Button.new()
	help_button.text = "?"
	help_button.tooltip_text = "Objetivo y controles"
	help_button.position = Vector2(445, 10)
	help_button.size = Vector2(25, 25)
	help_button.focus_mode = Control.FOCUS_NONE
	_style_button(help_button)
	help_button.pressed.connect(func(): help_open = not help_open)
	layer.add_child(help_button)
	help_panel = PanelContainer.new()
	help_panel.position = Vector2(184, 42)
	help_panel.size = Vector2(286, 70)
	help_panel.add_theme_stylebox_override("panel", _box(Color("293c36", 0.94), 9))
	layer.add_child(help_panel)
	help_text = Label.new()
	help_text.custom_minimum_size = Vector2(260, 50)
	help_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help_text.add_theme_font_size_override("font_size", 10)
	help_text.add_theme_color_override("font_color", Color("f1e4ca"))
	help_panel.add_child(help_text)
	_sync_layout()


func _process(_delta: float) -> void:
	var modern: bool = (world.zone == "patio" and world.modern_patio_enabled) or (world.zone == "street" and world.modern_street_enabled) or world.zone == "jacinto"
	if modern != active:
		_sync_layout()
	if not active:
		return
	if story.is_slingshot_active():
		help_panel.hide()
		help_button.hide()
		world.controls.hide()
		return
	world.controls.visible = mobile or world.preview_touch_controls
	help_panel.visible = help_open and story.dialogue.is_empty()
	help_button.visible = story.dialogue.is_empty()
	if story.objective.text != last_objective:
		last_objective = story.objective.text
		help_text.text = last_objective + "\n\n" + ("Toca las flechas para caminar y el botón para interactuar." if mobile else "WASD / flechas: caminar · E: interactuar / seguir")
	var action: String = story._nearby_action()
	story.action_button.text = action if mobile else "[ E ]  " + action
	story.action_button.size = Vector2(102, 34) if mobile else Vector2(90, 25)
	if mobile:
		story.action_button.position = Vector2(368, 224)
	else:
		var foot: Vector2 = world.get_node("Nisa").get_global_transform_with_canvas().origin
		story.action_button.position = Vector2(clampf(foot.x - 45, 10, 380), clampf(foot.y + 15, 12, 235))


func _sync_layout() -> void:
	active = (world.zone == "patio" and world.modern_patio_enabled) or (world.zone == "street" and world.modern_street_enabled) or world.zone == "jacinto"
	help_button.visible = active
	help_panel.visible = active and help_open
	story.objective.visible = not active
	world.hint.visible = not active
	world.controls.modern = active
	world.controls.visible = not active or mobile or world.preview_touch_controls
	world.controls.queue_redraw()
	story.action_button.focus_mode = Control.FOCUS_NONE
	story.next_button.focus_mode = Control.FOCUS_NONE
	if active:
		story.dialogue_panel.position = Vector2(16, 151)
		story.dialogue_panel.size = Vector2(448, 106)
		story.dialogue_panel.add_theme_stylebox_override("panel", _box(Color("293c36", 0.96), 10))
		story.dialogue_text.position = Vector2(14, 11)
		story.dialogue_text.size = Vector2(420, 59)
		story.dialogue_text.add_theme_color_override("font_color", Color("f4e6cd"))
		story.dialogue_text.add_theme_font_size_override("font_size", 12)
		story.next_button.position = Vector2(302, 73)
		story.next_button.size = Vector2(132, 26)
		_style_button(story.next_button)
		_style_button(story.action_button)
	else:
		story.action_button.position = Vector2(350, 216)
		story.action_button.size = Vector2(118, 42)
		story.dialogue_panel.position = Vector2(10, 145)
		story.dialogue_panel.size = Vector2(460, 115)
		story.dialogue_panel.remove_theme_stylebox_override("panel")
		story.dialogue_text.position = Vector2(12, 8)
		story.dialogue_text.size = Vector2(436, 62)
		story.dialogue_text.remove_theme_color_override("font_color")
		story.next_button.position = Vector2(310, 72)
		story.next_button.size = Vector2(138, 36)
		for button in [story.action_button, story.next_button]:
			for state in ["normal", "hover", "pressed", "focus"]:
				button.remove_theme_stylebox_override(state)
			button.remove_theme_color_override("font_color")
		story.action_button.add_theme_font_size_override("font_size", 12)
		story.next_button.add_theme_font_size_override("font_size", 12)


func _style_button(button: Button) -> void:
	button.add_theme_stylebox_override("normal", _box(Color("293c36", 0.85), 7))
	button.add_theme_stylebox_override("hover", _box(Color("43594b", 0.95), 7))
	button.add_theme_stylebox_override("pressed", _box(Color("637557", 0.95), 7))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_color_override("font_color", Color("f3e7cd"))
	button.add_theme_font_size_override("font_size", 10)


func _box(color: Color, radius: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(radius)
	box.content_margin_left = 10
	box.content_margin_right = 10
	box.content_margin_top = 6
	box.content_margin_bottom = 6
	box.border_color = Color("b4b899", 0.35)
	box.set_border_width_all(1)
	return box
