class_name Logos extends RidControl


func _ready() -> void:
	await get_tree().create_timer(2).timeout
	Signals.LoadScene.emit("main_menu")