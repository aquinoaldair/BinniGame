extends "res://scripts/presentation/patio_ground.gd"


func _ready() -> void:
	_surface("Earth", 1, PackedVector2Array([Vector2(0, -32), Vector2(480, -32), Vector2(480, 270), Vector2(0, 270)]))
	_surface("Garden", 0, PackedVector2Array([Vector2(161, 40), Vector2(280, 39), Vector2(300, 75), Vector2(284, 113), Vector2(304, 146), Vector2(290, 172), Vector2(169, 173), Vector2(154, 138)]))
	_surface("MangoGarden", 0, PackedVector2Array([Vector2(318, 49), Vector2(433, 52), Vector2(437, 154), Vector2(413, 188), Vector2(337, 183), Vector2(305, 136)]))
	_surface("Walk", 2, PackedVector2Array([Vector2(0, 204), Vector2(163, 193), Vector2(225, 181), Vector2(288, 188), Vector2(337, 201), Vector2(338, 219), Vector2(225, 215), Vector2(152, 222), Vector2(0, 239)]))
	_surface("HouseWalk", 2, PackedVector2Array([Vector2(37, 119), Vector2(143, 121), Vector2(153, 200), Vector2(127, 212), Vector2(119, 138), Vector2(37, 140)]))
