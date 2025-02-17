class_name BtnLoadReference extends Button


var hash_id:int = -1


func _ready() -> void:
	Signals.SelectHashIdForLoad.connect(_deselect_if_not)


func _pressed() -> void:
	Signals.SelectHashIdForLoad.emit(hash_id)


func _deselect_if_not(_hash_id:int) -> void:
	if hash_id != _hash_id:
		set_pressed_no_signal(false)