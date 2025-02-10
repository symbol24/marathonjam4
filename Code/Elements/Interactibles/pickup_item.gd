class_name PickupItem extends Interactible


var displayed:bool = false


func _ready() -> void:
	Signals.ContextPopupToggled.connect(_check_displayed)


func _mouse_enter() -> void:
	Debug.log("mouse enter")
	if not displayed:
		
		Signals.DisplayContextPopup.emit(name, {"pickup":"pickup"}, global_position)


func _check_displayed(id:StringName, _displayed:bool = false) -> void:
	if id == name:
		displayed = _displayed