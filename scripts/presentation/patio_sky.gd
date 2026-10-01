extends Node2D

# Cielo ficticio de la apertura; solo lee el recuerdo ya completado.
var memory_recovered := false
var gradient: Gradient
var ribbons: Array[Line2D] = []


func _ready() -> void:
	gradient = Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.6, 1.0])
	gradient.colors = PackedColorArray([Color("778c9d"), Color("b5c3c4"), Color("ded5ba")])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 64
	texture.height = 128
	texture.fill_from = Vector2(0, 0)
	texture.fill_to = Vector2(0, 1)
	var background := Sprite2D.new()
	background.name = "Horizon"
	background.texture = texture
	background.position = Vector2(240, -8)
	background.scale = Vector2(480.0 / 64.0, 104.0 / 128.0)
	background.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	background.light_mask = 0
	add_child(background)
	for points in [
		PackedVector2Array([Vector2(8, 28), Vector2(58, 27), Vector2(113, 28), Vector2(165, 28)]),
		PackedVector2Array([Vector2(181, 28), Vector2(226, 27), Vector2(273, 28), Vector2(309, 28)]),
		PackedVector2Array([Vector2(325, 28), Vector2(374, 27), Vector2(420, 28), Vector2(474, 28)])
	]:
		for width in [7.0, 2.5]:
			var ribbon := Line2D.new()
			ribbon.points = points
			ribbon.width = width
			ribbon.default_color = Color("f8efda")
			ribbon.modulate.a = 0.2 if width > 3 else 0.85
			ribbon.begin_cap_mode = Line2D.LINE_CAP_ROUND
			ribbon.end_cap_mode = Line2D.LINE_CAP_ROUND
			ribbon.antialiased = true
			ribbon.light_mask = 0
			add_child(ribbon)
			ribbons.append(ribbon)


func set_memory_recovered(recovered: bool) -> void:
	if memory_recovered == recovered:
		return
	memory_recovered = recovered
	gradient.set_color(0, Color("8faebe") if recovered else Color("778c9d"))
	gradient.set_color(1, Color("cbd5ce") if recovered else Color("b5c3c4"))
	gradient.set_color(2, Color("eee0c3") if recovered else Color("ded5ba"))
	# El primer fragmento abre la franja; la anomalía todavía no desaparece.
	for index in range(ribbons.size()):
		ribbons[index].position.y = (floorf(index / 2.0) - 1.0) * 3.0 if recovered else 0.0
		ribbons[index].modulate.a = (0.12 if recovered else 0.2) if index % 2 == 0 else (0.5 if recovered else 0.85)
