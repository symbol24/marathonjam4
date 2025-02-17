class_name SaveManager extends RidManager


const FOLDER:String = "user://saves/"
const PREFIX:String = "save_"
const EXTENSION:String = "tres"


var data_manager:DataManager
var active_save:PlayerData = null
var all_saves:Dictionary = {}
var hash_id_cached:int = -1


func _ready() -> void:
	Signals.SaveForHashId.connect(_save_for_hash_id)
	Signals.LoadFromHashId.connect(_try_load_for_hash_id)
	Signals.PopupResult.connect(_confirm_popup_result)
	Signals.CreateNewSave.connect(_create_save)
	data_manager = get_tree().get_first_node_in_group("data_manager")
	all_saves = _get_all_saves()


func get_last_save_used() -> PlayerData:
	for hash_id in all_saves.keys():
		if all_saves[hash_id].was_last_used:
			return all_saves[hash_id]
	return null


func _create_save(id:String = "test") -> void:
	var player_data:PlayerData = PlayerData.new()
	player_data.id = id
	var date_time:String = Time.get_datetime_string_from_system()
	player_data.hash_id = hash(id + "_" + date_time)
	player_data.prisoners = data_manager.get_prisoner_duplicates()

	if OS.get_name().contains("HTML"):
		player_data.keyboard_cancel = PlayerData.WEB_CANCEL
	
	active_save = player_data
	_save_for_hash_id(active_save.hash_id)


func _save_for_hash_id(_hash_id:int) -> void:
	if active_save == null:
		Signals.DisplayPopup.emit(PopupManager.Type.SMALL, "save_error_no_save", PopupManager.Severity.ERROR, "", tr("no_save_error_text"), 3)
		return
	
	if active_save.hash_id != _hash_id:
		Signals.DisplayPopup.emit(PopupManager.Type.SMALL, "save_error_wrong_save", PopupManager.Severity.ERROR, "", tr("wrong_save_error_text"), 3)
		return
	
	var date_time:String = Time.get_datetime_string_from_system()
	active_save.last_save_date_time = date_time
	Signals.DisplaySaveIcon.emit()
	_check_folder()
	var result:Error = ResourceSaver.save(active_save, FOLDER + PREFIX + str(_hash_id) + "." + EXTENSION)
	if result != OK:
		Signals.DisplayPopup.emit(PopupManager.Type.SMALL, "save_error_generic", PopupManager.Severity.ERROR, tr("save_error_title"), "save_error_text %s" % result, -1)
		return
	
	_set_last_saved(_hash_id)

	Signals.SaveComplete.emit(_hash_id)


func _set_last_saved(_hash_id:int) -> void:
	var errors:Array[int] = []
	for key in all_saves.keys():
		var save:PlayerData = all_saves[key]
		if save.hash_id == _hash_id: save.was_last_used = true
		else:save.was_last_used = false
		var result:Error = ResourceSaver.save(save)
		if result != OK:
			errors.append(save.hash_id)
	if not errors.is_empty():
		Debug.error("Following save files failed to save: ", errors)


func _try_load_for_hash_id(_hash_id:int) -> void:
	if active_save != null:
		if active_save.hash_id == _hash_id:
			Signals.DisplayPopup.emit(PopupManager.Type.SMALL, "load_error_already_loaded", PopupManager.Severity.WARNING, "", tr("already_loaded_error_text"), 3)
			return
		
		elif active_save.hash_id != _hash_id and active_save.has_unsaved_changes:
			hash_id_cached = _hash_id
			Signals.DisplayPopup.emit(PopupManager.Type.LARGE, "load_error_unsaved_changes", PopupManager.Severity.ERROR, tr("unsaved_changes_load_error_title"), "unsaved_changes_load_error_text", -1)
			return
		
	else:
		_load_for_has_id(_hash_id)


func _load_for_has_id(_hash_id:int) -> void:
	active_save = all_saves[_hash_id]
	if hash_id_cached != -1: hash_id_cached = -1
	Signals.DisplaySaveIcon.emit()
	_set_last_saved(_hash_id)
	Signals.LoadComplete.emit(_hash_id)


func _get_all_saves() -> Dictionary:
	var result:Dictionary = {}

	var dir:DirAccess = DirAccess.open(FOLDER)
	if dir:
		var filenames:PackedStringArray = dir.get_files()
		for f_name in filenames:
			if f_name.get_extension() == EXTENSION:
				var player_data = load(FOLDER + f_name)
				if player_data and player_data is PlayerData: result[player_data.hash_id] = player_data


	return result


func _check_folder() -> DirAccess:
	var dir:DirAccess = DirAccess.open(FOLDER)
	if dir == null:
		var result = DirAccess.make_dir_absolute(FOLDER)
		if result != OK:
			Debug.error("Error ", result, " creating save folder.")
		dir = DirAccess.open(FOLDER)
	return dir


func _confirm_popup_result(id:String, result:bool) -> void:
	match id:
		"save_error_no_save":
			pass
		"save_error_wrong_save":
			pass
		"save_error_generic":
			pass
		"load_error_already_loaded":
			pass
		"load_error_unsaved_changes":
			if result: _load_for_has_id(hash_id_cached)
		_:
			pass