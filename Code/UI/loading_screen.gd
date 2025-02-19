class_name LoadingScreen extends Control


@onready var progression_text: Label = %progression_text
@onready var loading_bar: ProgressBar = %loading_bar


func _ready() -> void:
	Signals.ToggleLoadingScreen.connect(_toggle_loading_screen)


func _toggle_loading_screen(display:bool = false, message:String = "normal_loading", progress:float = 5.0) -> void:
	if display:
		show()
		progression_text.text = tr(message)
		loading_bar.value += progress
	else:
		hide()
		progression_text.text = ""
		loading_bar.value = 0

