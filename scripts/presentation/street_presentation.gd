extends Node2D

const PropScene = preload("res://scenes/props/patio_prop.tscn")
const HouseScene = preload("res://scenes/props/patio_house.tscn")
const Ground = preload("res://scripts/presentation/street_ground.gd")
const Well = preload("res://scripts/presentation/street_well.gd")
const VecinaArt = preload("res://scripts/presentation/vecina_art.gd")
var world: Node2D
var houses: Array[Node2D] = []
var trees: Array[Node2D] = []
var occlusion_timer := 0.0
var last_context_clues := -1
var last_context_active := false


func _ready() -> void:
	y_sort_enabled = true
	var ground := Ground.new()
	ground.name = "Ground"
	ground.z_index = -10
	add_child(ground)
	for index in range(2):
		var bounds: Rect2 = world.STREET_HOUSES[index]
		var house = HouseScene.instantiate()
		house.name = "House%s" % index
		house.custom_width = bounds.size.x
		house.custom_wall_height = 48.0 if index == 0 else 45.0
		house.custom_roof_height = 38.0 if index == 0 else 40.0
		house.wall_asset = "wall_clay" if index == 0 else "wall_blue"
		house.door_asset = "door_wood" if index == 0 else "door_jade"
		house.window_asset = "window_shutters" if index == 0 else "window_bars"
		house.roof_asset = "roof_large" if index == 0 else "roof_small"
		house.position = Vector2(bounds.get_center().x, bounds.end.y)
		add_child(house)
		houses.append(house)
	var well := Well.new()
	well.name = "Well"
	add_child(well)
	var neighbor := VecinaArt.new()
	neighbor.name = "Vecina"
	neighbor.position = world.get_node("PatioStory").NEIGHBOR_POSITION
	add_child(neighbor)
	trees.append(_prop("tree", Vector2(61, 220), Vector2(59, 74), 1))
	trees.append(_prop("tree", Vector2(419, 241), Vector2(53, 68), 0))
	for point in [Vector2(41, 128), Vector2(160, 128), Vector2(331, 128), Vector2(438, 129)]:
		_prop("plant", point, Vector2(6, 9), 2 if point.x < 200 else 8)
	_prop("plant", Vector2(96, 240), Vector2(7, 10), 4)
	_prop("plant", Vector2(434, 188), Vector2(8, 11), 5)
	_prop("bench", Vector2(380, 178), Vector2.ZERO, 0)
	_prop("bucket", Vector2(430, 142), Vector2.ZERO, 0)
	_prop("broom", Vector2(442, 139), Vector2.ZERO, 0)
	var gate := _prop("gate", Vector2(140, 260), Vector2.ZERO, 0)
	gate.scale = Vector2(0.48, 0.48)
	gate.open_gate = true
	_prop("wall", Vector2(27, 262), Vector2(74, 14), 0)
	_prop("wall", Vector2(181, 262), Vector2(271, 14), 0)
	visible = world.zone == "street" and world.modern_street_enabled


func _process(delta: float) -> void:
	visible = world.zone == "street" and world.modern_street_enabled
	if not visible:
		return
	var story = world.get_node("PatioStory")
	var context_active: bool = story.context_progress == story.ContextProgress.SEARCH
	if last_context_clues != story.context_clues or last_context_active != context_active:
		last_context_clues = story.context_clues
		last_context_active = context_active
		queue_redraw()
	occlusion_timer += delta
	if occlusion_timer < 1.0 / 12.0:
		return
	occlusion_timer = 0.0
	var player_position: Vector2 = world.get_node("Nisa").position
	for tree in trees:
		tree.update_occlusion(player_position)
	for house in houses:
		house.update_occlusion(player_position)


func _prop(kind: String, at: Vector2, extent: Vector2, variant: int) -> Node2D:
	var prop = PropScene.instantiate()
	prop.kind = kind
	prop.position = at
	prop.extent = extent
	prop.seed_value = variant
	add_child(prop)
	return prop


func _draw() -> void:
	if not last_context_active:
		return
	var story = world.get_node("PatioStory")
	var locations: Array[Vector2] = [story.MEMORY_BENCH, story.MEMORY_TREE]
	for index in range(locations.size()):
		if (last_context_clues & (1 << index)) != 0:
			continue
		var at := locations[index] + Vector2(0, 9)
		draw_circle(at, 7, Color("293c36", 0.85))
		draw_rect(Rect2(at - Vector2(3, 4), Vector2(6, 8)), Color("f1e4ca"), false, 1)
		draw_line(at + Vector2(-1, -1), at + Vector2(2, -1), Color("f1e4ca"), 1)
		draw_line(at + Vector2(-1, 2), at + Vector2(2, 2), Color("f1e4ca"), 1)
