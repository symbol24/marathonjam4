class_name LoadingScreen extends Control



func _ready() -> void:
	Signals.ToggleLoadingScreen.connect(_toggle_loading_screen)


func _toggle_loading_screen(display:bool = false) -> void:
	if display:
		show()
	else:
		hide()