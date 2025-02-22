class_name MapIconSpaceship extends TextureRect


enum State {
				IDLE = 0,
				MOVING = 1,
			}


const MOVE_TIME:float = 5.0
const IDLE_DISTANCE:float = 20.0
const IDLE_TIME:float = 4.0


var current_state:State = State.IDLE
var current_room:RoomData = null
var target_room:RoomData = null
var last_idle_direcion:Vector2 = Vector2.ZERO
var idling:bool = false


func _ready() -> void:
	Signals.MoveSpaceshipTo.connect(_set_new_target)


func _process(_delta: float) -> void:
	if current_state == State.IDLE and not idling:
		_idle()


func _set_new_target(room_data:RoomData) -> void:
	if current_state != State.MOVING and current_room.next_rooms.has(room_data):
		target_room = room_data
		_move_to_target(target_room.coords_on_map)
	else:
		Signals.CancelRoomIconBtnPressed.emit(room_data)


func _move_to_target(target_pos:Vector2) -> void:
	idling = false
	current_state = State.MOVING
	var tween:Tween = create_tween()
	tween.finished.connect(_move_finished)
	tween.tween_property(self, "position", target_pos, MOVE_TIME)


func _move_finished() -> void:
	current_room = target_room
	target_room = null
	idling = false
	current_state = State.IDLE
	Signals.LoadRoom.emit(current_room)


func _idle() -> void:
	idling = true
	var directions:Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	var new_direction:Vector2 = last_idle_direcion
	while new_direction == last_idle_direcion:
		new_direction = directions.pick_random()
	
	if current_room:
		var tween:Tween = create_tween()
		tween.finished.connect(func(): idling = false)
		tween.tween_property(self, "position", current_room.coords_on_map + (new_direction * IDLE_DISTANCE), IDLE_TIME)
	else:
		Debug.error("Current room of %s has been removed?" % name)
