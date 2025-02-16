class_name MapIconButton  extends TextureButton


var room_data:RoomData = null


func _ready() -> void:
	#Signals.RoomIconBtnPressed.connect(_disable_same_row)
	Signals.CancelRoomIconBtnPressed.connect(_cancel_pressed)
	Signals.ResetRoomIconBtnOnRow.connect(_cancel_from_row)
	Signals.SpaceshipMoveFinished.connect(_disable_same_row)


func _pressed() -> void:
	Signals.RoomIconBtnPressed.emit(room_data)


func select() -> void:
	set_pressed_no_signal(true)
	room_data.selected = true


func _cancel_pressed(_room_data:RoomData) -> void:
	if room_data == _room_data:
		set_pressed_no_signal(false)
		room_data.selected = false
		Signals.ResetRoomIconBtnOnRow.emit(room_data.row)


func _cancel_from_row(row:int) -> void:
	if room_data.row == row:
		disabled = false


func _disable_same_row(_room_data:RoomData) -> void:
	if room_data.row <= _room_data.row and room_data != _room_data:
		set_pressed_no_signal(false)
		disabled = true
