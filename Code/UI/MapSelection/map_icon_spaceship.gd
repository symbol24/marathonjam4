class_name MapIconSpaceship extends TextureRect


const MOVE_TIME:float = 5.0

var current_room:RoomData = null
var target_room:RoomData = null


func _ready() -> void:
	Signals.RoomIconBtnPressed.connect(_set_new_target)


func _set_new_target(room_data:RoomData) -> void:
	target_room = room_data
	_move_to_target(target_room.coords_on_map)


func _move_to_target(target_pos:Vector2) -> void:
	var tween:Tween = create_tween()
	tween.finished.connect(_move_finished)
	tween.tween_property(self, "global_position", target_pos, MOVE_TIME)


func _move_finished() -> void:
	current_room = target_room
	target_room = null
	Signals.SpaceshipMoveFinished.emit(target_room)