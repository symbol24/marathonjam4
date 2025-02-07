class_name PlayLevel extends RidControl


func _ready() -> void:
	Signals.ManagerLoaded.connect(_load_managers)
	_load_managers()


func _load_managers(manager:String = "start"):
	match manager:
		"start":
			Signals.LoadManager.emit("input_manager")
		"input_manager":
			Signals.LoadManager.emit("spawn_manager")
		"spawn_manager":
			Signals.SpawnPrisoners.emit()
		_:
			pass


func _prisoners_spawned() -> void:
	pass