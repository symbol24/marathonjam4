class_name ElementControl extends Control


@export  var can_click:bool = true

@onready var parent = get_parent()


func _ready() -> void:
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)


func _mouse_entered() -> void:
	#Debug.log("Mouse entered: ", name)
	Signals.MouseEnteredElement.emit(self)


func _mouse_exited() -> void:
	#Debug.log("Mouse exited: ", name)
	Signals.MouseExitedElement.emit()