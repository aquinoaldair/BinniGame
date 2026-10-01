extends Node2D

const PropScene = preload("res://scenes/props/patio_prop.tscn")
const HouseScene = preload("res://scenes/props/patio_house.tscn")
const Ground = preload("res://scripts/presentation/patio_ground.gd")
const BixhozegolaArt = preload("res://scripts/presentation/bixhozegola_art.gd")
const Lighting = preload("res://scripts/presentation/patio_lighting.gd")
const Ambience = preload("res://scripts/presentation/patio_ambience.gd")
const PatioSky = preload("res://scripts/presentation/patio_sky.gd")
const GelaEncounter = preload("res://scripts/presentation/gela_encounter.gd")
var world: Node2D
var book: Node2D
var gate: Node2D
var trees: Array[Node2D] = []
var houses: Array[Node2D] = []
var ambience: Node2D
var sky: Node2D
var last_gate_open := false
var last_book_visible := false
var occlusion_timer := 0.0


func _ready() -> void:
	y_sort_enabled = true
	var ground := Ground.new()
	ground.name = "Ground"
	ground.z_index = -10
	add_child(ground)
	sky = PatioSky.new()
	sky.name = "Sky"
	sky.z_index = -9
	add_child(sky)
	_house("MainHouse", Vector2(328, 130), false)
	_house("SmallHouse", Vector2(184, 252), true)
	_prop("bench", Vector2(295, 154), Vector2.ZERO, 0)
	var laundry := _prop("cloth", Vector2(105, 236), Vector2.ZERO, 0)
	gate = _prop("gate", Vector2(124, 56), Vector2.ZERO, 0)
	_prop("wall", Vector2(18, 57), Vector2(35, 14), 0)
	_prop("wall", Vector2(195, 57), Vector2(267, 14), 0)
	_prop("wall", Vector2(18, 266), Vector2(444, 14), 0)
	# Dos tiras laterales; no un nodo por segmento de muro.
	for x in [22.0, 457.0]:
		var wall := _prop("wall", Vector2(x, 253), Vector2(202, 14), 0)
		wall.z_index = -2
		wall.get_node("Wall").rotation = PI * 0.5
		wall.get_node("Wall").position = Vector2(0, -202)
	for index in range(8):
		_prop("plant", Vector2(35, 117 + index * 18), Vector2(7, 10), index)
	for index in range(10):
		_prop("plant", Vector2(447, 76 + index * 18), Vector2(7, 11), index + 3)
	for index in [0, 1, 2, 3, 10, 11, 12]:
		_prop("plant", Vector2(220 + index * 17, 141), Vector2(7, 10), index + 2)
	trees.append(_prop("tree", Vector2(62, 132), Vector2(63, 78), 0))
	# Copas bajas junto al encuentro y al cuaderno: mantienen ambos objetivos legibles.
	trees.append(_prop("tree", Vector2(67, 205), Vector2(57, 50), 2))
	trees.append(_prop("tree", Vector2(415, 242), Vector2(45, 44), 1))
	_prop("plant", Vector2(269, 176), Vector2(9, 13), 4)
	_prop("plant", Vector2(101, 244), Vector2(7, 10), 3)
	# Objetos domésticos junto a las construcciones, fuera de objetivos/caminos.
	_prop("bucket", Vector2(427, 149), Vector2.ZERO, 0)
	_prop("broom", Vector2(438, 145), Vector2.ZERO, 0)
	_prop("chair", Vector2(367, 151), Vector2.ZERO, 0)
	_prop("jars", Vector2(221, 254), Vector2.ZERO, 0)
	var family := BixhozegolaArt.new()
	family.world = world
	family.name = "BixhozegolaVisual"
	family.position = world.get_node("PatioStory").FAMILY_POSITION
	add_child(family)
	book = _prop("book", world.get_node("PatioStory").OBJECT_POSITION, Vector2.ZERO, 0)
	book.name = "Notebook"
	book.visible = false
	ambience = Ambience.new()
	ambience.name = "Ambience"
	ambience.z_index = 2
	for tree in trees:
		ambience.trees.append(tree.canopy)
	ambience.clothes.assign(laundry.cloths)
	add_child(ambience)
	var encounter := GelaEncounter.new()
	encounter.name = "GelaEncounter"
	encounter.world = world
	encounter.z_index = 2
	add_child(encounter)
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
	var story = world.get_node("PatioStory")
	sky.set_memory_recovered(story.street_progress >= 3)
	ambience.set_wind_still(story.street_progress < 3)
	var show_book: bool = story.stage == story.Stage.SEARCH
	if show_book != last_book_visible:
		last_book_visible = show_book
		book.visible = show_book
	var opened: bool = story.stage == story.Stage.COMPLETE and world.get_node("Gela").following
	if opened != last_gate_open:
		last_gate_open = opened
		gate.open_gate = opened
	occlusion_timer += delta
	if occlusion_timer >= 1.0 / 12.0:
		occlusion_timer = 0.0
		var player_position: Vector2 = world.get_node("Nisa").position
		for tree in trees:
			tree.update_occlusion(player_position)
		for house in houses:
			house.update_occlusion(player_position)


func _house(node_name: String, at: Vector2, is_small: bool) -> void:
	var house = HouseScene.instantiate()
	house.name = node_name
	house.small = is_small
	house.position = at
	add_child(house)
	houses.append(house)


func _prop(kind: String, at: Vector2, extent: Vector2, seed_value: int) -> Node2D:
	var prop = PropScene.instantiate()
	prop.kind = kind
	prop.position = at
	prop.extent = extent
	prop.seed_value = seed_value
	add_child(prop)
	return prop
