extends "res://scripts/presentation/patio_ground.gd"


func _ready() -> void:
	_surface("Earth", 1, PackedVector2Array([Vector2(0, -32), Vector2(480, -32), Vector2(480, 270), Vector2(0, 270)]))
	_surface("CommunityWalk", 2, PackedVector2Array([Vector2(30, 121), Vector2(115, 118), Vector2(172, 121), Vector2(280, 124), Vector2(365, 119), Vector2(450, 125), Vector2(445, 143), Vector2(363, 147), Vector2(278, 150), Vector2(168, 148), Vector2(93, 150), Vector2(32, 145)]))
	_surface("FountainPlaza", 2, PackedVector2Array([Vector2(172, 102), Vector2(199, 96), Vector2(252, 99), Vector2(281, 112), Vector2(301, 141), Vector2(293, 169), Vector2(265, 191), Vector2(228, 198), Vector2(194, 192), Vector2(171, 176), Vector2(156, 146), Vector2(161, 120)]))
	_surface("EntranceWalk", 2, PackedVector2Array([Vector2(112, 253), Vector2(111, 223), Vector2(130, 201), Vector2(155, 175), Vector2(184, 164), Vector2(195, 183), Vector2(166, 204), Vector2(153, 229), Vector2(161, 253)]))
	_surface("JacintoExitWalk", 2, PackedVector2Array([Vector2(292, 141), Vector2(359, 136), Vector2(415, 137), Vector2(480, 145), Vector2(480, 177), Vector2(427, 176), Vector2(367, 164), Vector2(298, 169)]))
	_surface("LeftGarden", 0, PackedVector2Array([Vector2(33, 159), Vector2(57, 152), Vector2(94, 164), Vector2(101, 189), Vector2(95, 226), Vector2(77, 246), Vector2(34, 248)]))
	_surface("RightGarden", 0, PackedVector2Array([Vector2(386, 177), Vector2(442, 180), Vector2(445, 244), Vector2(402, 247), Vector2(378, 230), Vector2(379, 206)]))
	for point in [Vector2(177, 187), Vector2(290, 165), Vector2(97, 132), Vector2(346, 134)]:
		Assets.sprite(self, "dry_patch", Rect2(point - Vector2(8, 4), Vector2(16, 9))).modulate.a = 0.18
	for point in [Vector2(174, 109), Vector2(290, 176), Vector2(194, 196)]:
		Assets.sprite(self, "grass", Rect2(point, Vector2(5, 4))).modulate.a = 0.6
