extends Node2D

const Prop = preload("res://scripts/presentation/patio_prop.gd")
const Ground = preload("res://scripts/presentation/patio_ground.gd")
const HumanArt = preload("res://scripts/presentation/human_art.gd")
const Lighting = preload("res://scripts/presentation/patio_lighting.gd")
var world: Node2D
var book: Node2D
var gate: Node2D
var clock := 0.0
var last_gate_open := false


func _ready() -> void:
	y_sort_enabled = true
	var ground := Ground.new()
	ground.z_index = -10
	add_child(ground)
	_prop("house", Vector2(328, 130), Vector2(232, 89), 1)
	_prop("house", Vector2(184, 252), Vector2(112, 58), 2)
	_prop("bench", Vector2(295, 154), Vector2.ZERO, 0)
	_prop("cloth", Vector2(105, 236), Vector2.ZERO, 3)
	gate = _prop("gate", Vector2(124, 56), Vector2.ZERO, 0)
	_prop("wall", Vector2(18, 57), Vector2(35, 14), 0)
	_prop("wall", Vector2(195, 57), Vector2(267, 14), 0)
	_prop("wall", Vector2(18, 266), Vector2(444, 14), 0)
	# Laterales bajos separados: cada tramo tiene su propio origen sobre el suelo.
	for y in range(66, 253, 12):
		for x in [22, 457]:
			_prop("wall", Vector2(x, y), Vector2(5, 14), y)
	for index in range(10):
		_prop("plant", Vector2(34, 115 + index * 13), Vector2(6, 10), index)
	for index in range(14):
		_prop("plant", Vector2(447, 69 + index * 13), Vector2(6, 11), index + 4)
	for index in range(13):
		if index < 5 or index > 8:
			_prop("plant", Vector2(220 + index * 17, 140), Vector2(7, 9), index + 2)
	_prop("tree", Vector2(62, 132), Vector2(19, 29), 2)
	_prop("tree", Vector2(67, 205), Vector2(21, 32), 5)
	_prop("tree", Vector2(415, 242), Vector2(17, 26), 4)
	_prop("plant", Vector2(269, 176), Vector2(9, 13), 3)
	_prop("plant", Vector2(101, 244), Vector2(9, 13), 8)
	var family := Node2D.new()
	family.name = "BixhozegolaVisual"
	family.position = world.get_node("PatioStory").FAMILY_POSITION
	add_child(family)
	var human := HumanArt.new()
	human.actor = family
	human.observer = world.get_node("Nisa")
	family.add_child(human)
	book = _prop("book", world.get_node("PatioStory").OBJECT_POSITION, Vector2.ZERO, 0)
	var lighting := Lighting.new()
	lighting.name = "PatioLighting"
	lighting.world = world
	add_child(lighting)
	for bounds in [world.MAIN_HOUSE, world.SMALL_HOUSE]:
		var occluder := LightOccluder2D.new()
		var polygon := OccluderPolygon2D.new()
		polygon.polygon = PackedVector2Array([bounds.position, bounds.position + Vector2(bounds.size.x, 0), bounds.end, bounds.position + Vector2(0, bounds.size.y)])
		occluder.occluder = polygon
		add_child(occluder)


func _process(delta: float) -> void:
	visible = world.zone == "patio" and world.modern_patio_enabled
	if not visible:
		return
	clock += delta
	var story = world.get_node("PatioStory")
	book.visible = story.stage == story.Stage.SEARCH
	var opened: bool = story.stage == story.Stage.COMPLETE and world.get_node("Gela").following
	if opened != last_gate_open:
		last_gate_open = opened
		gate.open_gate = opened
		gate.queue_redraw()
	queue_redraw()


func _prop(kind: String, at: Vector2, extent: Vector2, seed_value: int) -> Node2D:
	var prop := Prop.new()
	prop.kind = kind
	prop.position = at
	prop.extent = extent
	prop.seed_value = seed_value
	prop.accent = [Color("d59b90"), Color("e8c980"), Color("d5d8be")][seed_value % 3]
	prop.animate = kind in ["tree", "cloth"] or (kind == "plant" and seed_value % 4 == 0)
	add_child(prop)
	return prop


func _draw() -> void:
	# Dos mariposas y cuatro hojas; amplitud pequeña y sin emisores costosos.
	for index in range(2):
		var phase := clock * 0.45 + index * 3
		var point := Vector2(94 + index * 74 + sin(phase) * 17, 158 + cos(phase * 1.3) * 14)
		var wing := 0.7 + absf(sin(clock * 7 + index)) * 1.1
		draw_circle(point + Vector2(-wing, 0), wing, Color("dfc992"), true, -1, true)
		draw_circle(point + Vector2(wing, 0), wing, Color("d3b879"), true, -1, true)
	for index in range(4):
		var travel := fmod(clock * 3 + index * 21, 90)
		var point := Vector2(45 + index * 49 + travel * 0.3, 120 + travel)
		draw_line(point, point + Vector2(1.8, sin(clock + index) * 0.7), Color(0.6, 0.65, 0.4, 0.45), 0.8, true)
