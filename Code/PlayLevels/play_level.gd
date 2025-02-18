class_name PlayLevel extends RidControl


func _ready() -> void:
	Signals.AllPrisonersSpawned.connect(_prisoners_spawned)
	Signals.ManagerLoaded.connect(_load_managers)
	await get_tree().create_timer(1).timeout
	Signals.ToggleLoadingScreen.emit(true, "play_level_starting", 5)
	await get_tree().create_timer(1).timeout
	Signals.ToggleLoadingScreen.emit(true, "play_level_loading_manager", 5)
	_load_managers()


func _load_managers(manager:String = "start"):
	match manager:
		"start":
			await get_tree().create_timer(1).timeout
			Signals.ToggleLoadingScreen.emit(true, "play_level_input", 5)
			Signals.LoadManager.emit("input_manager")
		"input_manager":
			await get_tree().create_timer(1).timeout
			Signals.ToggleLoadingScreen.emit(true, "play_level_spawn_manager", 5)
			Signals.LoadManager.emit("spawn_manager")
		"spawn_manager":
			await get_tree().create_timer(1).timeout
			Signals.ToggleLoadingScreen.emit(true, "play_level_spawn_prisoners", 5)
			Signals.SpawnPrisoners.emit()
		_:
			pass


func _prisoners_spawned() -> void:
	Debug.log("Prisoner Spawn complete signal received")
	Signals.ToggleLoadingScreen.emit(false)