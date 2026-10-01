extends Node2D

const Assets = preload("res://scripts/presentation/patio_assets.gd")
const JacintoAssets = preload("res://scripts/presentation/jacinto_assets.gd")
const Ground = preload("res://scripts/presentation/jacinto_ground.gd")
const HouseScene = preload("res://scenes/props/patio_house.tscn")
const PropScene = preload("res://scenes/props/patio_prop.tscn")
const SlingshotScene = preload("res://scenes/slingshot_minigame.tscn")
var world: Node2D
var minigame: Node2D
var trees: Array[Node2D] = []
var canopies: Array[Node2D] = []
var occlusion_timer := 0.0
var map_fruits: Array[Sprite2D] = []


func _ready() -> void:
	y_sort_enabled = true
	var ground := Ground.new()
	ground.name = "Ground"
	ground.z_index = -10
	add_child(ground)
	var house = HouseScene.instantiate()
	house.name = "JacintoHouse"
	house.small = true
	house.position = Vector2(90, 118)
	house.custom_width = 120
	house.custom_wall_height = 34
	house.custom_roof_height = 32
	add_child(house)
	_tree("huanacaxtle", Vector2(202, 154), Vector2(182, 110))
	_tree("mango_tree", Vector2(357, 178), Vector2(108, 122))
	var man := Node2D.new()
	man.name = "DonJacinto"
	man.position = world.get_node("PatioStory").JACINTO_POSITION
	add_child(man)
	Assets.shadow(man, Vector2(29, 9))
	JacintoAssets.sprite(man, "jacinto", Rect2(-14, -83, 28, 83))
	_prop("bench", Vector2(264, 175))
	_prop("chair", Vector2(169, 181))
	_prop("bucket", Vector2(285, 181))
	_prop("plant", Vector2(40, 143))
	_prop("plant", Vector2(130, 142))
	_prop("plant", Vector2(435, 232))
	for point in [Vector2(329, 108), Vector2(357, 91), Vector2(386, 115)]:
		var fruit := JacintoAssets.sprite(self, "mango", Rect2(point - Vector2(4.5, 6), Vector2(9, 12)))
		fruit.z_index = 2
		map_fruits.append(fruit)
	minigame = SlingshotScene.instantiate()
	minigame.name = "Slingshot"
	minigame.world = world
	add_child(minigame)
	minigame.completed.connect(world.get_node("PatioStory").complete_mango_game)
	visible = world.zone == "jacinto"


func _tree(asset: String, at: Vector2, size: Vector2) -> void:
	var tree := Node2D.new()
	tree.position = at
	add_child(tree)
	trees.append(tree)
	Assets.shadow(tree, Vector2(size.x * 1.05, size.y * 0.4), Vector2(8, 0))
	var crop: Rect2 = JacintoAssets.REGIONS[asset]
	var split := crop.size.y * 0.77
	JacintoAssets.sprite(tree, asset, Rect2(-size.x * 0.5, -size.y * 0.23, size.x, size.y * 0.23), Rect2(crop.position + Vector2(0, split), Vector2(crop.size.x, crop.size.y - split)))
	var canopy := Node2D.new()
	canopy.name = "Canopy"
	tree.add_child(canopy)
	JacintoAssets.sprite(canopy, asset, Rect2(-size.x * 0.5, -size.y, size.x, size.y * 0.77), Rect2(crop.position, Vector2(crop.size.x, split)))
	canopies.append(canopy)


func _prop(kind: String, at: Vector2) -> void:
	var prop = PropScene.instantiate()
	prop.kind = kind
	prop.position = at
	prop.extent = Vector2(7, 9)
	add_child(prop)


func _process(delta: float) -> void:
	visible = world.zone == "jacinto"
	if minigame.active and not visible:
		minigame.cancel(true)
	for fruit in map_fruits:
		fruit.visible = visible
	if not visible:
		return
	occlusion_timer += delta
	if occlusion_timer < 1.0 / 12.0:
		return
	occlusion_timer = 0.0
	var foot: Vector2 = world.get_node("Nisa").position
	for index in range(trees.size()):
		var at: Vector2 = trees[index].position
		canopies[index].modulate.a = 0.65 if foot.y < at.y and foot.y > at.y - 100 and absf(foot.x - at.x) < (80 if index == 0 else 45) else 1.0
