extends Node2D

const TouchControls = preload("res://scripts/touch_controls.gd")


func _ready() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)

	var title := Label.new()
	title.text = "BINNI  |  EL CORAZÓN DEL VIENTO"
	title.position = Vector2(12, 9)
	title.add_theme_font_size_override("font_size", 10)
	title.add_theme_color_override("font_color", Color("fff2cb"))
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	title.add_theme_constant_override("shadow_offset_x", 1)
	title.add_theme_constant_override("shadow_offset_y", 1)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(title)

	var hint := Label.new()
	hint.text = "Mueve a Nisa  ·  WASD / flechas  ·  toca las flechas en móvil"
	hint.position = Vector2(12, 25)
	hint.add_theme_font_size_override("font_size", 7)
	hint.add_theme_color_override("font_color", Color("f7edcf"))
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hint)

	var controls := TouchControls.new()
	controls.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(controls)


func _draw() -> void:
	# Patio de Guidxiguie': una escena de prueba, todavía sin arte definitivo.
	draw_rect(Rect2(0, 0, 480, 270), Color("263c32"))
	draw_rect(Rect2(18, 30, 444, 226), Color("d1bd83"))
	draw_rect(Rect2(25, 36, 430, 213), Color("b2ad78"))

	# Variación discreta del suelo para sugerir tierra apisonada.
	for row in range(9):
		for column in range(16):
			if (row * 7 + column * 3) % 5 == 0:
				draw_rect(Rect2(35 + column * 26, 48 + row * 22, 3, 2), Color(0.43, 0.42, 0.29, 0.20))

	# Sendero hacia el portón.
	draw_colored_polygon(PackedVector2Array([
		Vector2(203, 42), Vector2(277, 42), Vector2(304, 254), Vector2(176, 254)
	]), Color("c6ad72"))
	for i in range(7):
		draw_rect(Rect2(225, 60 + i * 26, 30, 1), Color(0.48, 0.39, 0.25, 0.18))

	# Muros, portón y sombra del alero.
	draw_rect(Rect2(18, 28, 444, 12), Color("704c39"))
	draw_rect(Rect2(18, 40, 10, 216), Color("845a40"))
	draw_rect(Rect2(452, 40, 10, 216), Color("845a40"))
	draw_rect(Rect2(28, 236, 174, 20), Color("845a40"))
	draw_rect(Rect2(278, 236, 174, 20), Color("845a40"))
	draw_rect(Rect2(201, 230, 77, 26), Color("493a2c"))
	draw_rect(Rect2(207, 235, 65, 21), Color("a36b3e"))
	draw_rect(Rect2(18, 28, 444, 3), Color("d29a54"))

	# Macetas con plantas en las esquinas.
	_draw_pot(Vector2(62, 77))
	_draw_pot(Vector2(413, 77))
	_draw_pot(Vector2(62, 202))
	_draw_pot(Vector2(413, 202))

	# Banco de madera al fondo del patio.
	draw_rect(Rect2(176, 58, 128, 8), Color("755038"))
	draw_rect(Rect2(183, 66, 7, 14), Color("5b402e"))
	draw_rect(Rect2(290, 66, 7, 14), Color("5b402e"))
	draw_line(Vector2(181, 56), Vector2(299, 56), Color("d2a365"), 2.0)

	# Dos dibujos decorativos provisionales sobre el muro.
	draw_rect(Rect2(82, 46, 18, 14), Color("b9784b"))
	draw_rect(Rect2(380, 46, 18, 14), Color("56836a"))
	draw_circle(Vector2(91, 53), 3, Color("ead390"))
	draw_circle(Vector2(389, 53), 3, Color("ead390"))


func _draw_pot(center: Vector2) -> void:
	draw_circle(center + Vector2(0, -8), 12, Color("426b49"))
	draw_circle(center + Vector2(-7, -12), 7, Color("557e4e"))
	draw_circle(center + Vector2(7, -15), 8, Color("66864f"))
	draw_rect(Rect2(center + Vector2(-8, -2), Vector2(16, 12)), Color("a4593c"))
	draw_rect(Rect2(center + Vector2(-10, -3), Vector2(20, 3)), Color("c27a4b"))
