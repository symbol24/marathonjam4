class_name StoryIntro extends RidControl


func _ready() -> void:
	await get_tree().create_timer(1.5).timeout
	Signals.ToggleLoadingScreen.emit(true, "story_Intro_loading", 75)
	await get_tree().create_timer(0.5).timeout
	Signals.ToggleLoadingScreen.emit(false)