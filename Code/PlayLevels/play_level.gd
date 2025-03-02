class_name PlayLevel extends RidControl


@onready var btn_debug_complete: Button = %btn_debug_complete

var save_manager:SaveManager:
	get:
		if save_manager == null:
			save_manager = get_tree().get_first_node_in_group("save_manager")
			if save_manager == null: Debug.error("Save manager not found by Play Level, ", id)
		return save_manager
var data_manager:DataManager:
	get:
		if data_manager == null:
			data_manager = get_tree().get_first_node_in_group("data_manager")
			if data_manager == null: Debug.error("Data manager not found by Play Level, ", id)
		return data_manager


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	Signals.AllPrisonersSpawned.connect(_prisoners_all_spawned)
	Signals.AllUnknownContactsSpawned.connect(_all_ucs_spawned)
	Signals.PlayUiDisplayed.connect(_play_level_loading_complete)
	Signals.ManagerLoaded.connect(_load_managers)
	btn_debug_complete.pressed.connect(_complete_room)
	if save_manager.active_save.prisoners[0].headshot_normal == null: 
		await get_tree().create_timer(0.3).timeout
		Signals.ToggleLoadingScreen.emit(true, "play_level_loading_headshots", 5)
		data_manager.load_prisoner_headshots(save_manager.active_save.prisoners)
	await get_tree().create_timer(0.3).timeout
	Signals.ToggleLoadingScreen.emit(true, "play_level_starting", 5)
	await get_tree().create_timer(0.3).timeout
	Signals.ToggleLoadingScreen.emit(true, "play_level_loading_manager", 5)
	_load_managers()


func _exit_tree() -> void:
	Signals.SendQueueFreeOfPlayManagers.emit()
	Signals.TogglePlayUi.emit(false)


func _load_managers(manager:String = "start"):
	match manager:
		"start":
			await get_tree().create_timer(0.3).timeout
			Signals.ToggleLoadingScreen.emit(true, "play_level_input", 5)
			Signals.LoadManager.emit("input_manager")
		"input_manager":
			await get_tree().create_timer(0.3).timeout
			Signals.ToggleLoadingScreen.emit(true, "play_level_spawn_manager", 5)
			Signals.LoadManager.emit("spawn_manager")
		"spawn_manager":
			await get_tree().create_timer(0.3).timeout
			Signals.ToggleLoadingScreen.emit(true, "play_level_spawn_prisoners", 5)
			Signals.SpawnPrisoners.emit()
		_:
			pass


func _prisoners_all_spawned() -> void:
	await get_tree().create_timer(0.5).timeout
	Signals.ToggleLoadingScreen.emit(true, "play_level_done", 5)
	Signals.TogglePlayUi.emit(true)
	Signals.SpawnUnknownContacts.emit()


func _all_ucs_spawned() -> void:
	Signals.ToggleLoadingScreen.emit(true, "play_level_done", 5)
	#Signals.TogglePlayUi.emit(true)


func _play_level_loading_complete() -> void:
	Signals.ToggleLoadingScreen.emit(false)


func _complete_room() -> void:
	Signals.CompleteRoom.emit()
	Signals.LoadScene.emit("map_selection_menu")
