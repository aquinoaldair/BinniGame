extends Node2D

# Construcción por capas; sus colisiones permanecen en world.gd.
const Assets = preload("res://scripts/presentation/patio_assets.gd")
@export var small := false
var roof: Sprite2D
var facade: Node2D
var projection: Rect2


func _ready() -> void:
	var width := 112.0 if small else 232.0
	# La casa inferior deja libre el acceso norte, junto al punto inicial de Nisa.
	var wall_height := 16.0 if small else 55.0
	var roof_height := 24.0 if small else 52.0
	Assets.shadow(self, Vector2(width + 16, 20), Vector2(8, 5))
	facade = Node2D.new()
	facade.name = "Facade"
	add_child(facade)
	Assets.sprite(facade, "porch", Rect2(-width * 0.5 - 3, -3, width + 6, 11), "Porch")
	Assets.sprite(facade, "wall_blue" if small else "wall_clay", Rect2(-width * 0.5, -wall_height, width, wall_height), "WallBase")
	var openings := Node2D.new()
	openings.name = "Openings"
	facade.add_child(openings)
	var door_height := wall_height - 4
	Assets.sprite(openings, "door_wood" if small else "door_jade", Rect2(-door_height * 0.33, -door_height, door_height * 0.66, door_height), "Door")
	var window_size := Vector2(15, 10) if small else Vector2(30, 31)
	for side in [-1.0, 1.0]:
		Assets.sprite(openings, "window_shutters" if small else "window_bars", Rect2(Vector2(side * width * 0.29 - window_size.x * 0.5, -wall_height + (3 if small else 7)), window_size), "WindowLeft" if side < 0 else "WindowRight")
	# Una única sombra de alero, sin luces por prop.
	var eave := Polygon2D.new()
	eave.name = "EaveShadow"
	eave.polygon = PackedVector2Array([Vector2(-width / 2, -wall_height), Vector2(width / 2, -wall_height), Vector2(width / 2, -wall_height + 7), Vector2(-width / 2, -wall_height + 7)])
	eave.color = Color(0.25, 0.22, 0.17, 0.18)
	facade.add_child(eave)
	var supports := Node2D.new()
	supports.name = "PorchSupports"
	facade.add_child(supports)
	for side in [-1.0, 1.0]:
		Assets.sprite(supports, "column", Rect2(side * (width * 0.5 - 12) - 3.5, -wall_height + 1, 7, wall_height + 3))
	projection = Rect2(-width * 0.5 - 4, -wall_height - roof_height, width + 8, roof_height)
	roof = Assets.sprite(self, "roof_small" if small else "roof_large", projection, "Roof")


func update_occlusion(player_position: Vector2) -> void:
	# La proyección del tejado puede tapar a Nisa fuera de la colisión del edificio.
	var foot := to_local(player_position)
	var silhouette := Rect2(foot - Vector2(15, 76), Vector2(30, 78))
	var obscured := foot.y < 0 and projection.intersects(silhouette)
	roof.modulate.a = 0.48 if obscured else 1.0
