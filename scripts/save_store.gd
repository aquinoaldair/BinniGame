extends RefCounted

const SAVE_VERSION := 2

var save_path := "user://partida.json"
var used_backup := false


func load_game() -> Dictionary:
	used_backup = false
	var data := _read_valid(save_path)
	if data.is_empty():
		data = _read_valid(save_path + ".bak")
		used_backup = not data.is_empty()
	return data


func has_files() -> bool:
	return FileAccess.file_exists(save_path) or FileAccess.file_exists(save_path + ".bak")


func write_game(data: Dictionary, reset_backup := false) -> Error:
	if not _is_valid(data):
		return ERR_INVALID_DATA
	var directory := ProjectSettings.globalize_path(save_path).get_base_dir()
	var error := DirAccess.make_dir_recursive_absolute(directory)
	if error != OK:
		return error
	var temporary := save_path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data, "\t"))
	file.flush()
	error = file.get_error()
	file.close()
	if error != OK:
		return error
	# Una partida dañada nunca reemplaza el respaldo que todavía es válido.
	if not _read_valid(save_path).is_empty():
		error = DirAccess.copy_absolute(save_path, save_path + ".bak")
		if error != OK:
			return error
	error = DirAccess.rename_absolute(temporary, save_path)
	if error != OK:
		return error
	if reset_backup or not FileAccess.file_exists(save_path + ".bak"):
		return DirAccess.copy_absolute(save_path, save_path + ".bak")
	return OK


func _read_valid(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > 65536:
		return {}
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK or not _is_valid(json.data):
		return {}
	var data: Dictionary = json.data
	if data["version"] == 1:
		data["version"] = SAVE_VERSION
		data["clue_received"] = false
		data["street_progress"] = 0
	return data


func _is_valid(data: Variant) -> bool:
	if not data is Dictionary or (data.get("version") != 1 and data.get("version") != SAVE_VERSION):
		return false
	if data.get("scene") not in ["patio", "street"] or not _is_number(data.get("stage")):
		return false
	var stage: float = data["stage"]
	if stage != floorf(stage) or stage < 0 or stage > 3:
		return false
	if not _is_position(data.get("nisa_position")):
		return false
	var gela: Variant = data.get("gela")
	if not gela is Dictionary or not _is_position(gela.get("position")):
		return false
	if not gela.get("available") is bool or not gela.get("following") is bool:
		return false
	if gela["available"] != (stage == 3) or (gela["following"] and not gela["available"]):
		return false
	if data["version"] == 1:
		return data["scene"] == "patio"
	if not data.get("clue_received") is bool or not _is_number(data.get("street_progress")):
		return false
	var progress: float = data["street_progress"]
	if progress != floorf(progress) or progress < 0 or progress > 3:
		return false
	if data["clue_received"] and (stage != 3 or not gela["following"]):
		return false
	if (progress > 0 or data["scene"] == "street") and not data["clue_received"]:
		return false
	return true


func _is_number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))


func _is_position(value: Variant) -> bool:
	if not value is Array or value.size() != 2:
		return false
	return _is_number(value[0]) and _is_number(value[1]) and value[0] >= 0 and value[0] <= 480 and value[1] >= 0 and value[1] <= 270
