extends Button


func _pressed() -> void:
	Signals.LoadManager.emit("game_manager")
	Signals.LoadScene.emit("map_selection_menu")