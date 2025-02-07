extends RidControl


@export var manager_loader:PackedScene


func _ready() -> void:
	Signals.ManagerLoaded.connect(_loading)
	_load_loader()


func _load_loader() -> void:
	if manager_loader != null:
		var loader:ManagerLoader = manager_loader.instantiate()
		get_parent().add_child.call_deferred(loader)
		if not loader.is_node_ready(): await loader.ready
		Signals.LoadManager.emit("data_manager")


func _loading(manager_name:String) -> void:
	match manager_name:
		"data_manager":
			Signals.LoadManager.emit("save_manager")
		"save_manager":
			Signals.LoadManager.emit("scene_manager")
		"scene_manager":
			await get_tree().create_timer(3).timeout
			Signals.LoadScene.emit("logos")
			queue_free()