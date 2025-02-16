class_name MapIconButton  extends TextureButton


var room_data:RoomData = null


func _pressed() -> void:
	Signals.RoomIconBtnPressed.emit(room_data)