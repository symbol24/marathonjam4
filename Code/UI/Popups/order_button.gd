class_name OrdeButton extends Button


var id:String = ""


func _pressed() -> void:
	Signals.ContextMenuBtnPressed.emit(id)