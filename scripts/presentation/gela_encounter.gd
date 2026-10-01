extends Node2D

const Assets = preload("res://scripts/presentation/patio_assets.gd")
const RUSTLE_DURATION := 0.65
var world: Node2D
var leaves: Array[Sprite2D] = []
var sound: AudioStreamPlayer
var elapsed := RUSTLE_DURATION


func _ready() -> void:
	position = world.get_node("Gela").position
	for index in range(3):
		var leaf := Assets.sprite(self, "leaf", Rect2(-2, -1, 4, 2))
		leaf.hide()
		leaves.append(leaf)
	sound = AudioStreamPlayer.new()
	sound.volume_db = -18.0
	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_16_BITS
	audio.mix_rate = 16000
	var bytes := PackedByteArray()
	var count := int(audio.mix_rate * RUSTLE_DURATION)
	bytes.resize(count * 2)
	var random := RandomNumberGenerator.new()
	random.seed = 731
	var filtered := 0.0
	for sample in range(count):
		var time := float(sample) / audio.mix_rate
		var noise := random.randf_range(-1.0, 1.0)
		filtered = lerpf(filtered, noise, 0.16)
		var envelope := sin(PI * time / RUSTLE_DURATION) * (0.35 + 0.65 * absf(sin(time * 24.0)))
		bytes.encode_s16(sample * 2, int((noise - filtered) * envelope * 12000))
	audio.data = bytes
	sound.stream = audio
	add_child(sound)
	world.get_node("PatioStory").encounter_rustle.connect(_rustle)
	set_process(false)


func _rustle() -> void:
	if world.zone != "patio" or not world.modern_patio_enabled:
		return
	elapsed = 0.0
	sound.play()
	set_process(true)


func _process(delta: float) -> void:
	elapsed += delta
	var active: bool = elapsed < RUSTLE_DURATION and is_visible_in_tree()
	for index in range(leaves.size()):
		leaves[index].visible = active
		leaves[index].position = Vector2((index - 1) * 5 + sin(elapsed * 28 + index) * 2, -5 - index * 2)
		leaves[index].rotation = sin(elapsed * 24 + index) * 0.5
	if not active:
		sound.stop()
		set_process(false)
