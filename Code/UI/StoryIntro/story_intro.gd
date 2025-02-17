class_name StoryIntro extends RidControl


func _ready() -> void:
	Signals.LoadManager.emit("game_manager")