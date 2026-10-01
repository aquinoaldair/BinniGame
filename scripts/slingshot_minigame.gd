extends Node2D

signal completed
const Art = preload("res://scripts/presentation/jacinto_assets.gd")
const Assets = preload("res://scripts/presentation/patio_assets.gd")
const Ground = preload("res://scripts/presentation/slingshot_ground.gd")
@export var target_points := PackedVector2Array([Vector2(218, 101), Vector2(278, 55), Vector2(335, 117)])
@export var target_sizes := PackedVector2Array([Vector2(21, 26), Vector2(17, 22), Vector2(14, 18)])
@export var hit_radii := PackedFloat32Array([18, 15, 12])
@export var launcher_origin := Vector2(214, 218)
@export var charge_seconds := 1.25
@export var max_wind := 8.0
@export var target_art := "mango"
@export var tree_art := "mango_tree"
@export var trunk_rect := Rect2(258, 175, 32, 59)
@export var tree_rect := Rect2(154, 0, 242, 240)
var world: Node2D
var player: CharacterBody2D
var active := false
var busy := false
var ending := false
var charging := false
var power := 0.0
var charge_finger := -1
var hits := 0
var settled := 0
var shots := 0
var elapsed := 0.0
var aim := Vector2.ZERO
var fallen: Array[int] = []
var fruits: Array[Sprite2D] = []
var falling_tweens: Array[Tween] = []
var leaves: Array[Sprite2D] = []
var dots: Array[Sprite2D] = []
var overlay: Control
var counter: Label
var wind_label: Label
var hint: Label
var input_area: Control
var reticle: Line2D
var sling: Polygon2D
var bands: Line2D
var pouch: Polygon2D
var loaded_stone: Sprite2D
var stone: Sprite2D
var trail: Line2D
var tree: Node2D
var cover_leaf: Sprite2D
var sound: AudioStreamPlayer
var launch_sound: AudioStreamPlayer
var base_target_points := PackedVector2Array()
var fall_sound: AudioStreamPlayer
var stone_texture: GradientTexture2D
var transition: Tween
var previous_controls_visible := false
var previous_can_move := true
var wind_force := 0.0
var shot_wind := 0.0
var shot_power := 0.0
var shot_aim := Vector2.ZERO
var shot_start := Vector2.ZERO
var flight_time := 0.0
var flight_duration := 0.0
var last_impact := ""
@onready var mode: CanvasLayer = $Mode
@onready var screen: Node2D = $Mode/Screen
@onready var fade: ColorRect = $Mode/Fade


func _ready() -> void:
	base_target_points = target_points.duplicate()
	$Mode/Screen/Background.add_child(Ground.new())
	tree = $Mode/Screen/MangoTree
	Assets.shadow(tree, Vector2(215, 40), Vector2(tree_rect.get_center().x, tree_rect.end.y - 9))
	Art.sprite(tree, tree_art, tree_rect)
	for index in range(target_points.size()):
		var fruit := Art.sprite($Mode/Screen/Targets, target_art, Rect2(-target_sizes[mini(index, target_sizes.size() - 1)] * 0.5, target_sizes[mini(index, target_sizes.size() - 1)]))
		fruit.centered = true
		fruit.position = target_points[index]
		fruits.append(fruit)
	if target_points.size() > 1:
		cover_leaf = Art.sprite($Mode/Screen/Targets, "mango_tree", Rect2(target_points[1] + Vector2(4, -10), Vector2(18, 13)), Rect2(1178, 188, 74, 53))
	_make_sling()
	stone_texture = GradientTexture2D.new()
	stone_texture.width = 16
	stone_texture.height = 16
	stone_texture.fill = GradientTexture2D.FILL_RADIAL
	stone_texture.fill_from = Vector2(0.35, 0.3)
	stone_texture.fill_to = Vector2(0.95, 0.8)
	stone_texture.gradient = Gradient.new()
	stone_texture.gradient.offsets = PackedFloat32Array([0, 0.65, 0.82, 1])
	stone_texture.gradient.colors = PackedColorArray([Color("d4c8b0"), Color("8e8578"), Color("685f54"), Color("685f54", 0)])
	stone = _stone($Mode/Screen/ProjectileLayer)
	loaded_stone = _stone($Mode/Screen/Slingshot)
	trail = Line2D.new()
	trail.width = 1.1
	trail.default_color = Color("ece3c4", 0.38)
	$Mode/Screen/ProjectileLayer.add_child(trail)
	for index in range(10):
		var dot := _stone($Mode/Screen/ProjectileLayer)
		dot.scale = Vector2.ONE * 0.18
		dot.modulate.a = 0.35
		dots.append(dot)
	for index in range(3):
		var leaf := Assets.sprite($Mode/Screen/ProjectileLayer, "leaf", Rect2(-3, -2, 6, 4))
		leaf.hide()
		leaves.append(leaf)
	reticle = Line2D.new()
	reticle.width = 0.7
	reticle.default_color = Color("f2e3be", 0.85)
	for step in range(25):
		reticle.add_point(Vector2(cos(TAU * step / 24), sin(TAU * step / 24)) * 7)
	$Mode/Screen/ProjectileLayer.add_child(reticle)
	sound = _sound(120, 0.10)
	fall_sound = _sound(65, 0.16)
	launch_sound = _sound(850, 0.18, true)
	launch_sound.volume_db = -12
	overlay = $Mode/UI
	input_area = Control.new()
	input_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	input_area.mouse_filter = Control.MOUSE_FILTER_STOP
	input_area.gui_input.connect(_aim_input)
	overlay.add_child(input_area)
	counter = _label(Vector2(14, 10), Vector2(145, 22), 12)
	wind_label = _label(Vector2(174, 12), Vector2(145, 20), 10)
	hint = _label(Vector2(12, 242), Vector2(164, 27), 9)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var exit := Button.new()
	exit.text = "Salir"
	exit.position = Vector2(411, 8)
	exit.size = Vector2(57, 32)
	exit.focus_mode = Control.FOCUS_NONE
	exit.pressed.connect(cancel)
	overlay.add_child(exit)
	mode.hide()
	set_process(false)
	if world == null:
		call_deferred("start")


func _make_sling() -> void:
	# Recorte nativo del marco existente: no se editan los píxeles del atlas.
	sling = Polygon2D.new()
	var outline := PackedVector2Array([Vector2(984, 644), Vector2(1005, 631), Vector2(1037, 630), Vector2(1063, 687), Vector2(1081, 728), Vector2(1114, 763), Vector2(1221, 643), Vector2(1250, 640), Vector2(1277, 663), Vector2(1247, 716), Vector2(1155, 819), Vector2(1136, 970), Vector2(1128, 991), Vector2(1098, 993), Vector2(1060, 982), Vector2(1044, 963), Vector2(1057, 861), Vector2(1063, 817), Vector2(1024, 765), Vector2(1001, 704)])
	var frame_polygon := PackedVector2Array()
	for point in outline:
		frame_polygon.append((point - Vector2(979, 623)) * 0.22)
	sling.polygon = frame_polygon
	sling.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	sling.position = launcher_origin - Vector2(36, 27)
	$Mode/Screen/Slingshot.add_child(sling)
	Art.sprite(sling, "slingshot", Rect2(0, 0, 395 * 0.22, 375 * 0.22))
	bands = Line2D.new()
	bands.width = 3
	bands.antialiased = true
	bands.default_color = Color("d9a257")
	$Mode/Screen/Slingshot.add_child(bands)
	pouch = Polygon2D.new()
	pouch.polygon = PackedVector2Array([Vector2(-7, -3), Vector2(7, -3), Vector2(6, 4), Vector2(-6, 4)])
	pouch.color = Color("694630")
	$Mode/Screen/Slingshot.add_child(pouch)


func _stone(parent: Node) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = stone_texture
	sprite.scale = Vector2.ONE * 0.7
	parent.add_child(sprite)
	return sprite


func _label(at: Vector2, size: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.position = at
	label.size = size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("fff0c9"))
	label.add_theme_color_override("font_outline_color", Color("293c36"))
	label.add_theme_constant_override("outline_size", 3)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(label)
	return label


func _sound(frequency: float, length: float, sweep := false) -> AudioStreamPlayer:
	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_16_BITS
	audio.mix_rate = 16000
	var count := int(audio.mix_rate * length)
	var data := PackedByteArray()
	data.resize(count * 2)
	for sample in range(count):
		var envelope := exp(-float(sample) / (length * 2200))
		var seconds := float(sample) / audio.mix_rate
		var phase := TAU * frequency * seconds
		if sweep:
			phase = TAU * frequency * (seconds - 0.4 * seconds * seconds / length)
		data.encode_s16(sample * 2, int(sin(phase) * envelope * 10000))
	audio.data = data
	var speaker := AudioStreamPlayer.new()
	speaker.stream = audio
	speaker.volume_db = -18
	$Mode/Audio.add_child(speaker)
	return speaker


func start() -> void:
	if active or target_points.is_empty():
		return
	active = true
	ending = false
	busy = false
	charging = false
	power = 0
	hits = 0
	settled = 0
	shots = 0
	elapsed = 0
	wind_force = 0
	fallen.clear()
	for tween in falling_tweens:
		if tween.is_running(): tween.kill()
	falling_tweens.clear()
	_randomize_targets()
	for index in range(fruits.size()):
		fruits[index].position = target_points[index]
		fruits[index].rotation = 0
		fruits[index].show()
	if cover_leaf != null:
		cover_leaf.position = target_points[1] - base_target_points[1]
		cover_leaf.show()
	aim = target_points[0]
	if world != null:
		player = world.get_node("Nisa")
		previous_can_move = player.can_move
		player.can_move = false
		player.velocity = Vector2.ZERO
		previous_controls_visible = world.controls.visible
		world.controls.hide()
		for finger in world.controls.fingers.keys():
			world.controls._release_finger(finger)
	_release_actions()
	screen.show()
	overlay.show()
	mode.show()
	stone.hide()
	trail.clear_points()
	for leaf in leaves: leaf.hide()
	hint.text = "Mantén pulsado, apunta y suelta. Espacio también carga."
	_update_sling()
	_update_feedback()
	fade.color.a = 1
	transition = create_tween()
	transition.tween_property(fade, "color:a", 0, 0.18)
	set_process(true)


func _randomize_targets() -> void:
	# Separate canopy regions keep every fruit reachable and prevent overlap.
	for index in range(base_target_points.size()):
		target_points[index] = base_target_points[index] + Vector2(randf_range(-14, 14), randf_range(-10, 10))


func begin_charge() -> void:
	if not active or busy or ending:
		return
	charging = true
	power = 0


func _aim_input(event: InputEvent) -> void:
	if not active or ending:
		return
	if event is InputEventMouseMotion:
		aim = event.position.clamp(Vector2(12, 35), Vector2(465, 218))
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		aim = event.position.clamp(Vector2(12, 35), Vector2(465, 218))
		if event.pressed: begin_charge()
		else: fire()
	elif event is InputEventScreenTouch:
		if event.pressed and charge_finger == -1:
			charge_finger = event.index
			aim = event.position.clamp(Vector2(12, 35), Vector2(465, 218))
			begin_charge()
		elif not event.pressed and event.index == charge_finger:
			charge_finger = -1
			fire()
	elif event is InputEventScreenDrag and event.index == charge_finger:
		aim = event.position.clamp(Vector2(12, 35), Vector2(465, 218))


func _unhandled_key_input(event: InputEvent) -> void:
	if not active or not event is InputEventKey or event.echo:
		return
	if event.physical_keycode == KEY_SPACE:
		if event.pressed: begin_charge()
		else: fire()
	elif event.pressed:
		match event.physical_keycode:
			KEY_ESCAPE: cancel()
			KEY_LEFT: aim.x -= 5
			KEY_RIGHT: aim.x += 5
			KEY_UP: aim.y -= 5
			KEY_DOWN: aim.y += 5
	get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		charging = false
		charge_finger = -1
		power = 0


func projectile_point(strength: float, at: float, drift: float, target: Vector2, start_point: Vector2) -> Vector2:
	var destination := launcher_origin + (target - launcher_origin) * (0.45 + strength * 0.85)
	var lift := lerpf(24, 68, strength)
	return start_point.lerp(destination, at) + Vector2(drift * at * at, -sin(PI * at) * lift)


func fire() -> void:
	if not active or busy or ending or not charging:
		return
	charging = false
	charge_finger = -1
	busy = true
	shots += 1
	shot_power = power
	launch_sound.pitch_scale = lerpf(0.85, 1.15, power)
	launch_sound.play()
	shot_wind = wind_force
	shot_aim = aim
	shot_start = pouch.position
	flight_time = 0
	flight_duration = lerpf(1.05, 0.65, shot_power)
	stone.position = shot_start
	stone.scale = Vector2.ONE * 0.7
	stone.show()
	loaded_stone.hide()
	trail.clear_points()
	power = 0
	_update_sling()
	_update_feedback()


func _process(delta: float) -> void:
	elapsed += delta
	for index in range(fruits.size()):
		if index not in fallen:
			fruits[index].position = target_points[index] + Vector2(sin(elapsed * 1.1 + index) * (1.5 + index * 0.6), cos(elapsed * 1.3 + index) * 0.8)
			fruits[index].rotation = sin(elapsed * 1.4 + index) * 0.055
	if cover_leaf != null: cover_leaf.position = fruits[1].position + Vector2(4, -10)
	if ending:
		return
	if charging:
		power = minf(1, power + delta / charge_seconds)
	if not busy:
		if hits >= 2 and not charging:
			wind_force = sin(elapsed * 0.13 + shots * 0.25) * max_wind
		_update_sling()
		reticle.position = aim
		for index in range(dots.size()):
			dots[index].visible = charging
			dots[index].position = projectile_point(power, float(index + 1) / 10, wind_force, aim, pouch.position)
	else:
		flight_time += delta
		var t := minf(1, flight_time / flight_duration)
		stone.position = projectile_point(shot_power, t, shot_wind, shot_aim, shot_start)
		stone.scale = Vector2.ONE * lerpf(0.7, 0.5, t)
		trail.add_point(stone.position)
		if trail.get_point_count() > 12: trail.remove_point(0)
		if t == 1:
			_resolve_impact(stone.position)
	_update_feedback()


func _update_sling() -> void:
	var direction := (aim - launcher_origin).normalized()
	pouch.position = launcher_origin - direction * power * 29
	bands.points = PackedVector2Array([launcher_origin + Vector2(-26, -13), pouch.position, launcher_origin + Vector2(23, -13)])
	loaded_stone.position = pouch.position
	loaded_stone.visible = not busy


func _update_feedback() -> void:
	counter.text = "Mangos: %s / %s" % [hits, fruits.size()]
	wind_label.text = "Viento en calma" if absf(wind_force) < 1 else ("← Viento suave" if wind_force < 0 else "→ Viento suave")


func _resolve_impact(point: Vector2) -> void:
	stone.hide()
	trail.clear_points()
	for dot in dots: dot.hide()
	busy = false
	last_impact = "air"
	for index in range(fruits.size()):
		if index not in fallen and point.distance_to(fruits[index].position) <= hit_radii[mini(index, hit_radii.size() - 1)] and shot_power >= minf(0.45, 0.2 + index * 0.08):
			last_impact = "mango"
			_drop_mango(index)
			return
	if trunk_rect.has_point(point):
		last_impact = "trunk"
		sound.pitch_scale = 0.7
		sound.play()
	elif tree_rect.has_point(point):
		last_impact = "branch"
		_shake_tree(point)
	if shots % 4 == 0:
		hint.text = "Don Jacinto: Un poquito más arriba."


func _shake_tree(point: Vector2) -> void:
	sound.pitch_scale = 1.1
	sound.play()
	var shake := create_tween()
	shake.tween_property(tree, "position:x", 2.0, 0.06)
	shake.tween_property(tree, "position:x", -1.5, 0.07)
	shake.tween_property(tree, "position:x", 0.0, 0.08)
	falling_tweens.append(shake)
	for index in range(leaves.size()):
		var leaf := leaves[index]
		leaf.position = point + Vector2(index * 4, -2)
		leaf.show()
		var fall := create_tween()
		fall.set_parallel(true)
		fall.tween_property(leaf, "position", point + Vector2((index - 1) * 13, 30), 0.7)
		fall.tween_property(leaf, "rotation", 0.8, 0.7)
		fall.chain().tween_callback(leaf.hide)
		falling_tweens.append(fall)


func _drop_mango(index: int) -> void:
	fallen.append(index)
	hits += 1
	if index == 1 and cover_leaf != null: cover_leaf.hide()
	_shake_tree(fruits[index].position)
	var fruit := fruits[index]
	var floor_point := Vector2(fruit.position.x, 227 + index * 5)
	var fall := create_tween()
	fall.tween_property(fruit, "position", floor_point, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fall.parallel().tween_property(fruit, "rotation", 0.6, 0.5)
	fall.tween_callback(fall_sound.play)
	fall.tween_property(fruit, "position:y", floor_point.y - 7, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	fall.tween_property(fruit, "position:y", floor_point.y, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fall.tween_callback(_after_fall)
	falling_tweens.append(fall)
	if hits == 1: hint.text = "¡Eso! Mantén un poco más para llegar arriba."
	elif hits == 2: hint.text = "Ahora sopla un poco. Mira los puntos al cargar."


func _after_fall() -> void:
	settled += 1
	if active and settled == fruits.size() and not ending:
		_leave(true)


func cancel(immediate := false) -> void:
	if not active:
		return
	if immediate:
		if transition != null and transition.is_running(): transition.kill()
		_restore(false)
	else:
		_leave(false)


func _leave(success: bool) -> void:
	if ending:
		return
	ending = true
	charging = false
	charge_finger = -1
	busy = false
	stone.hide()
	trail.clear_points()
	for dot in dots: dot.hide()
	if transition != null and transition.is_running(): transition.kill()
	transition = create_tween()
	if success:
		transition.tween_interval(0.8)
	transition.tween_property(fade, "color:a", 1, 0.18)
	transition.tween_callback(func(): screen.hide(); overlay.hide())
	transition.tween_property(fade, "color:a", 0, 0.18)
	transition.tween_callback(_restore.bind(success))


func _restore(success: bool) -> void:
	for tween in falling_tweens:
		if tween.is_running(): tween.kill()
	falling_tweens.clear()
	tree.position = Vector2.ZERO
	active = false
	ending = false
	busy = false
	charging = false
	mode.hide()
	set_process(false)
	if player != null:
		player.can_move = previous_can_move
	if world != null:
		world.controls.visible = previous_controls_visible
	_release_actions()
	if success:
		completed.emit()


func _release_actions() -> void:
	for action in ["move_left", "move_right", "move_up", "move_down"]:
		Input.action_release(action)


func _exit_tree() -> void:
	for speaker in [sound, fall_sound, launch_sound]:
		if is_instance_valid(speaker):
			speaker.stop()
			speaker.stream = null
