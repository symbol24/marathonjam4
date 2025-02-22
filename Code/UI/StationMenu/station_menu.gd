class_name StationMenu extends RidControl


@onready var btn_debug_complete: Button = %btn_debug_complete


func _ready() -> void:
	btn_debug_complete.pressed.connect(_complete_room)
	Signals.ToggleLoadingScreen.emit(false)

	
func _complete_room() -> void:
	Signals.CompleteRoom.emit()
	Signals.LoadScene.emit("map_selection_menu")
