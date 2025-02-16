class_name MapSelectionMenu extends RidControl


const POINT_DISTANCE_Y:float = -200.0
const CAMERA_MOVE_SPEED:float = 100.0
const CAMERA_Y_MIN:float = 0.0


@onready var camera: Camera2D = %camera

var data_manager:DataManager = null
var map_generator:MapGenerator = null
var grid:Array[Array] = []
var last_room_coords:Vector2

var can_scroll:bool = false
var get_next_scroll:bool = true
var scroll_movement:Array[bool] = []
var camera_y_max:float = 1.0
var grabbed:bool = false
var previous_mouse_position:Vector2 = Vector2.ZERO


func _input(event: InputEvent) -> void:
	if can_scroll:
		if event.is_action_pressed("mouse_scroll_up"):
			scroll_movement.append(true)
		elif event.is_action_pressed("mouse_scroll_down"):
			scroll_movement.append(false)
		elif event.is_action_pressed("mouse_left"):
			grabbed = true
			previous_mouse_position = get_local_mouse_position()
		elif event.is_action_released("mouse_left"):
			grabbed = false
		#elif grabbed and event is InputEventMouseMotion:
		#	previous_mouse_position = _mouse_move_camera(previous_mouse_position, event.position)


func _ready() -> void:
	Signals.MapStuffPlacementComplete.connect(_allow_scrolling)
	data_manager = get_tree().get_first_node_in_group("data_manager")
	if data_manager == null: Debug.error("Map Generator cannot find Data Manager.")
	else:
		map_generator = data_manager.map_generator.instantiate()
		add_child(map_generator)
		if not map_generator.is_node_ready(): await map_generator.ready
		grid = map_generator.generate_map()
		if grid.is_empty(): Debug.error("Grid not generated.")
		else:
			_place_map_stuff()


func _physics_process(delta: float) -> void:
	if can_scroll and get_next_scroll:
		if not scroll_movement.is_empty():
			_move_camera(scroll_movement.pop_front(), delta)
		
		if grabbed and get_next_scroll:
			_mouse_move_camera(delta)


func _place_map_stuff() -> void:
	await _place_rooms()
	await _place_lines()

	Signals.MapStuffPlacementComplete.emit()


func _place_rooms() -> void:
	var last_floor_x:float = 1920.0 / 2
	var i:int = 0
	var previous_floor_y:float = 0.0
	for _floor in grid:

		#Debug.log("Floor %s: %s" % [i, _floor])

		var j:int = 1
		var floor_seperation:float = 1920.0 / (_floor.size()+1)
		var floor_y:float = previous_floor_y + POINT_DISTANCE_Y

		for room:RoomData in _floor:
			var to_insta:PackedScene = data_manager.map_icon_btn_encounter
			match room.type:
				RoomData.Type.TREASURE:
					to_insta = data_manager.map_icon_btn_treasure
				RoomData.Type.SHOP:
					to_insta = data_manager.map_icon_btn_shop
				RoomData.Type.STATION:
					to_insta = data_manager.map_icon_btn_station
				RoomData.Type.BOSS:
					to_insta = data_manager.map_icon_btn_boss
				RoomData.Type.NOT_ASSIGNED:
					to_insta = null
				RoomData.Type.START:
					to_insta = data_manager.map_icon_btn_start
				_:
					pass

			if to_insta != null:
				var map_icon_btn:MapIconButton = to_insta.instantiate()
				var pos:Vector2
				if i == 0:
					var x:float = floor_seperation * j
					pos = Vector2(x, 0)
				elif i == grid.size() - 1:
					#pos = Vector2((floor_seperation*j), floor_y)
					pos = Vector2(last_floor_x, floor_y)
					last_room_coords = pos
					camera_y_max = floor_y
				else:
					pos = Vector2((floor_seperation*j), floor_y)

				room.coords_on_map = pos
				

				map_icon_btn.room_data = room
				add_child(map_icon_btn)
				if not map_icon_btn.is_node_ready(): await map_icon_btn.ready

				var offset:Vector2 = map_icon_btn.texture_normal.get_size()/2
				map_icon_btn.global_position = room.coords_on_map - offset
				map_icon_btn.name = RoomData.Type.keys()[room.type] + "_" + str(i) + "_" + str(j)

			j += 1
			
		previous_floor_y = floor_y
		i += 1


func _place_lines() -> void:
	for _floor in grid:
		for room:RoomData in _floor:
			if room.coords_on_map != Vector2.ZERO:
				for next_room:RoomData in room.next_rooms:
					var line:Line2D = data_manager.map_line.instantiate()
					add_child(line)
					if not line.is_node_ready(): await line.ready
					line.add_point(room.coords_on_map, 0)
					line.add_point(next_room.coords_on_map, 1)


func _move_camera(is_up:bool = true, delta:float = 0.0) -> void:
	get_next_scroll = false
	var direction:float = -1.0 if is_up else 1.0
	#Debug.log("Camera Y:", camera.global_position.y)

	var new_y:float = camera.global_position.y + direction * CAMERA_MOVE_SPEED
	new_y = clampf(new_y, camera_y_max, CAMERA_Y_MIN)
	var new_pos:Vector2 = Vector2(camera.global_position.x, new_y)

	var tween:Tween = create_tween()
	tween.tween_property(camera, "global_position", new_pos, delta)
	await tween.finished
	get_next_scroll = true


func _mouse_move_camera(delta:float) -> Vector2:
	get_next_scroll = false
	var current_mouse:Vector2 = get_local_mouse_position()
	var new_y:float = camera.global_position.y + (previous_mouse_position.y - current_mouse.y)
	var new_pos:Vector2 = Vector2(camera.global_position.x, new_y)

	var tween:Tween = create_tween()
	tween.tween_callback(func(): get_next_scroll = true)
	tween.tween_property(camera, "global_position", new_pos, delta)

	previous_mouse_position = current_mouse
	return Vector2(new_pos.x, new_y)


func _allow_scrolling() -> void:
	can_scroll = true