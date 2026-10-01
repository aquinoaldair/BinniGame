extends Node

# Original ambient composition; presentation only, independent of saved progress.
const TRACK = preload("res://assets/audio/exploration.ogg")
const EXPLORATION_VOLUME := -18.0
const QUIET_VOLUME := -26.0
var world: Node2D
var speaker: AudioStreamPlayer
var muted := false


func _ready() -> void:
	speaker = AudioStreamPlayer.new()
	speaker.name = "Instrumental"
	var music := TRACK.duplicate() as AudioStreamOggVorbis
	music.loop = true
	speaker.stream = music
	speaker.volume_db = EXPLORATION_VOLUME
	add_child(speaker)
	speaker.play()


func _process(delta: float) -> void:
	var story = world.get_node("PatioStory")
	var quiet: bool = not story.dialogue.is_empty() or story.is_slingshot_active()
	var target := QUIET_VOLUME if quiet else EXPLORATION_VOLUME
	speaker.volume_db = move_toward(speaker.volume_db, target, delta * 16.0)


func set_muted(value: bool) -> void:
	muted = value
	# Keep playback running silently so enabling music never restarts the loop.
	speaker.volume_linear = 0.0 if muted else db_to_linear(EXPLORATION_VOLUME)
	set_process(not muted)


func _exit_tree() -> void:
	if is_instance_valid(speaker):
		speaker.stop()
		speaker.stream = null
