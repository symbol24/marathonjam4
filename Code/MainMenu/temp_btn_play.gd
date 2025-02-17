extends Button


@export var destination:String


func _pressed() -> void:
	Signals.LoadScene.emit(destination)