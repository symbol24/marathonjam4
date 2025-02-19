class_name UIManager extends CanvasLayer


var play_ui:PlayUi = null
var data_manager:DataManager:
	get:
		if data_manager == null:
			data_manager = get_tree().get_first_node_in_group("data_manager")
			if data_manager == null: Debug.error("Data manager missing in Ui Manager")
		return data_manager


func _ready() -> void:
	Signals.TogglePlayUi.connect(_toggle_play_ui)


func _toggle_play_ui(display:bool = false) -> void:
	if display:
		if play_ui == null:
			play_ui = data_manager.play_ui.instantiate()
			if play_ui:
				add_child.call_deferred(play_ui)
				if not play_ui.is_node_ready(): await play_ui.ready
				play_ui.hide()
		
		play_ui.generate_prisoner_ui()
		play_ui.show()
	else:
		play_ui.hide()
		remove_child.call_deferred(play_ui)