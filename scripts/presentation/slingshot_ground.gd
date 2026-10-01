extends "res://scripts/presentation/patio_ground.gd"


func _ready() -> void:
	_surface("Earth", 1, PackedVector2Array([Vector2(0, 0), Vector2(480, 0), Vector2(480, 270), Vector2(0, 270)]))
	_surface("Grass", 0, PackedVector2Array([Vector2(157, 0), Vector2(439, 0), Vector2(442, 183), Vector2(403, 240), Vector2(185, 228), Vector2(140, 166)]))
