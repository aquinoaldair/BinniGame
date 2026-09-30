extends Camera2D

var player: Node2D
var world: Node2D
var patio_active := false


func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = 5.0
	limit_left = 0
	limit_top = 0
	limit_right = 480
	limit_bottom = 270
	limit_smoothed = true
	_sync_zone()
	reset_smoothing()


func _process(_delta: float) -> void:
	var active: bool = world.zone == "patio" and world.modern_patio_enabled
	if active != patio_active:
		_sync_zone()
	if patio_active:
		position = player.position + Vector2(0, -18)


func _sync_zone() -> void:
	patio_active = world.zone == "patio" and world.modern_patio_enabled
	# Margen de encuadre para el cabello de Nisa al llegar al portón.
	limit_top = -24 if patio_active else 0
	zoom = Vector2.ONE * 1.12 if patio_active else Vector2.ONE
	position = player.position + Vector2(0, -18) if patio_active else Vector2(240, 135)
	# Las transiciones de mapa conservan sus coordenadas originales.
	reset_smoothing()
