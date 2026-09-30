extends Node2D

# Gancho visual para un futuro ciclo horario; no introduce tiempo en los guardados.
@export_range(0.0, 1.0) var daylight := 1.0
var world: Node2D
var ambient: CanvasModulate
var sunlight: PointLight2D
var previous_daylight := -1.0
var previous_active := false


func _ready() -> void:
	ambient = CanvasModulate.new()
	add_child(ambient)
	var gradient := Gradient.new()
	gradient.set_color(0, Color.WHITE)
	gradient.set_color(1, Color(1, 1, 1, 0))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 256
	texture.height = 256
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1, 0.5)
	sunlight = PointLight2D.new()
	sunlight.texture = texture
	sunlight.position = Vector2(165, 90)
	sunlight.texture_scale = 3.8
	sunlight.color = Color("fff0d1")
	sunlight.energy = 0.17
	sunlight.shadow_enabled = true
	sunlight.shadow_filter = Light2D.SHADOW_FILTER_PCF13
	sunlight.shadow_filter_smooth = 2.0
	sunlight.shadow_color = Color(0.18, 0.20, 0.17, 0.16)
	add_child(sunlight)
	_update_light()


func _process(_delta: float) -> void:
	var active: bool = world.zone == "patio" and world.modern_patio_enabled
	if active != previous_active or not is_equal_approx(daylight, previous_daylight):
		_update_light()


func _update_light() -> void:
	previous_active = world.zone == "patio" and world.modern_patio_enabled
	previous_daylight = daylight
	ambient.color = Color("697888").lerp(Color("e4e5d9"), daylight) if previous_active else Color.WHITE
	sunlight.enabled = previous_active
	sunlight.energy = lerpf(0.05, 0.17, daylight)
