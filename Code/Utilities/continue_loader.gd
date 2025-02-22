class_name ContinueLoader extends RidControl


var save_manager:SaveManager:
	get:
		if save_manager == null:
			save_manager = get_tree().get_first_node_in_group("save_manager")
			if save_manager == null:
				Debug.error("Save Manager not found")
		return save_manager


func _ready() -> void:
	await get_tree().create_timer(0.3).timeout
	if save_manager.active_save.active_prisoners.is_empty():
		Signals.ToggleLoadingScreen.emit(true, "continue_loader_redirect_prisoner_select", 5)
		await get_tree().create_timer(0.5).timeout
		Signals.LoadScene.emit("prisoner_select", true)
	else:
		Signals.ToggleLoadingScreen.emit(true, "continue_loader_prisoner_loading", 5)
		await _load_prisoners_from_active()
		Signals.ToggleLoadingScreen.emit(true, "continue_loader_loading_map_location", 5)
		await get_tree().create_timer(0.5).timeout
		Signals.LoadScene.emit("map_selection_menu")


func _load_prisoners_from_active() -> void:
	for _id in save_manager.active_save.active_prisoners:
		Signals.ToggleLoadingScreen.emit(true, "continue_loader_prisoner_loading", 5)
		var result:Dictionary = save_manager.active_save.activate_prisoner_from_id(_id)
		if not result["result"]:
			Debug.warning(tr(result["reason"]))
		await get_tree().create_timer(0.2).timeout
