class_name ContextMenuButton extends Button


var id:String = ""


func set_button(new_id:String, _text:String) -> void:
	id = new_id
	text = tr(_text)


func _pressed() -> void:
	Signals.ContextMenuBtnPressed.emit(id)
