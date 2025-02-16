class_name MapGenerator extends Node


const X_DIST := 30
const Y_DIST := 25
const PLACEMENT_RANDOMNESS := 5
const FLOORS := 16
const MAP_WIDTH := 7
const PATHS := 6
const ENCOUNTER_ROOM_WEIGHT := 10.0
const STATION_ROOM_WEIGHT := 5.0
const SHOP_ROOM_WEIGHT := 4.0
const DERILECT_FLOOR:int = 8
const MIN_STATION_ROW:int = 3


@export var debug_print:bool = false

var random_room_type_weights = {
								RoomData.Type.ENCOUNTER: 0.0,
								RoomData.Type.STATION: 0.0,
								RoomData.Type.SHOP: 0.0,
								}
var random_room_type_total_weight:float = 0.0
var map_data:Array[Array] = []


func generate_map() -> Array[Array]:
	map_data = _generate_initial_grid()
	var starting_points:Array[int] = _get_starting_points()

	var f:int = 1
	for j in starting_points:
		var current_j:int = j
		while f < FLOORS - 1:
			current_j = _setup_connection(f, current_j)
			f += 1
		f = 0

	_setup_room_weights()
	_setup_room_types()
	_setup_start_room()
	_setup_boss_room()

	# DEBUG PRINT
	if debug_print:
		var i := 0
		for _floor in map_data:
			Debug.log("floor ", i)
			var used = _floor.filter(
				func(room:RoomData): return room.next_rooms.size() > 0
			)
			Debug.log(used)
			i += 1

	return map_data


func _generate_initial_grid() -> Array[Array]:
	var result:Array[Array] = []

	for i in FLOORS:
		var adjacent_rooms:Array[RoomData] = []

		for j in MAP_WIDTH:
			var current_room:RoomData = RoomData.new()
			var offset:Vector2 = Vector2(randf(), randf()) * PLACEMENT_RANDOMNESS
			current_room.position = Vector2(j * X_DIST, i * -Y_DIST) + offset
			current_room.row = i
			current_room.column = j

			if i == FLOORS - 1:
				current_room.position.y = (i + 1) * Y_DIST
			
			adjacent_rooms.append(current_room)
		
		result.append(adjacent_rooms)

	return result


func _get_starting_points() -> Array[int]:
	var result: Array[int] = []
	var unique_points:int = 0

	while unique_points < 2:
		unique_name_in_owner = 0
		result = []
		
		for i in PATHS:
			var starting_point:int = randi_range(0, MAP_WIDTH-1)
			if not result.has(starting_point):
				unique_points += 1

			result.append(starting_point)
	
	return result


func _setup_connection(i:int, j:int) -> int:
	var next_room:RoomData = null
	var current_room:RoomData = map_data[i][j]

	while not next_room or _would_cross_exisiting_path(i, j, next_room):
		var random_j:int = clampi(randi_range(j-1, j+1), 0, MAP_WIDTH-1)
		next_room = map_data[i+1][random_j]

	current_room.next_rooms.append(next_room)

	return next_room.column


func _would_cross_exisiting_path(i:int, j:int, room:RoomData) -> bool:
	var left:RoomData = null
	var right:RoomData = null

	if j > 0:
		left = map_data[i][j-1]

	if j < MAP_WIDTH -1:
		right = map_data[i][j+1]

	if right and room.column > j:
		for next_room:RoomData in right.next_rooms:
			if next_room.column < room.column:
				return true
	
	if left and room.column < j:
		for next_room in left.next_rooms:
			if next_room.column > room.column:
				return true

	return false


func _setup_start_room() -> void:
	for room:RoomData in map_data[0]:
		room.next_rooms = []

	var middle:int = floori(MAP_WIDTH * 0.5)
	var start_room:RoomData = map_data[0][middle]
	start_room.type = RoomData.Type.START

	for room:RoomData in map_data[1]:
		if room.next_rooms:
			start_room.next_rooms.append(room)

	
func _setup_boss_room() -> void:
	for room:RoomData in map_data[FLOORS - 1]:
		room.next_rooms = []
		room.type = RoomData.Type.NOT_ASSIGNED

	var middle:int = floori(MAP_WIDTH * 0.5)
	var boss_room:RoomData = map_data[FLOORS-1][middle]
	boss_room.type = RoomData.Type.BOSS

	for room:RoomData in map_data[FLOORS - 2]:
		if room.next_rooms:
			room.next_rooms = []
			room.next_rooms.append(boss_room)


func _setup_room_weights() -> void:
	random_room_type_weights[RoomData.Type.ENCOUNTER] = ENCOUNTER_ROOM_WEIGHT
	random_room_type_weights[RoomData.Type.STATION] = ENCOUNTER_ROOM_WEIGHT + STATION_ROOM_WEIGHT
	random_room_type_weights[RoomData.Type.SHOP] = ENCOUNTER_ROOM_WEIGHT + STATION_ROOM_WEIGHT + SHOP_ROOM_WEIGHT

	random_room_type_total_weight = random_room_type_weights[RoomData.Type.SHOP]


func _setup_room_types() -> void:
	# First Floor rooms
	for room:RoomData in map_data[1]:
		if not room.next_rooms.is_empty():
			room.type = RoomData.Type.ENCOUNTER
	
	# DERILECT FLOOR
	for room:RoomData in map_data[DERILECT_FLOOR]:
		if not room.next_rooms.is_empty():
			room.type = RoomData.Type.TREASURE
	
	# Second to last floor
	for room:RoomData in map_data[FLOORS - 2]:
		#Debug.log("Room ", RoomData.Type.keys()[room.type], " is not empty? ", not room.next_rooms.is_empty())
		if not room.next_rooms.is_empty():
			room.type = RoomData.Type.STATION
	
	# REST of rooms
	for current_floor in map_data:
		for room:RoomData in current_floor:
			for next:RoomData in room.next_rooms:
				if next.type == RoomData.Type.NOT_ASSIGNED:
					_set_room_type(next)

	#var boss_room:RoomData = null
	#for room:RoomData in map_data[FLOORS - 1]:
	#	if room.type != RoomData.Type.BOSS:
	#		room.type = RoomData.Type.NOT_ASSIGNED
	#	else:
	#		boss_room = room
	
	#for room:RoomData in map_data[FLOORS - 2]:
	#	room.next_rooms = [boss_room]


func _set_room_type(room:RoomData) -> void:
	var station_below_rule:bool = true
	var consequetive_station:bool = true
	var consequetive_shop:bool = true
	var station_on_second_to_last:bool = true

	var candidate_type:RoomData.Type = RoomData.Type.NOT_ASSIGNED

	while station_below_rule or consequetive_station or consequetive_shop or station_on_second_to_last:
		candidate_type = _get_room_by_weight()

		var is_station:bool = candidate_type == RoomData.Type.STATION
		var has_station_parent:bool = _room_has_parent_of_type(room, RoomData.Type.STATION)
		var is_shop:bool = candidate_type == RoomData.Type.SHOP
		var has_shop_parent:bool = _room_has_parent_of_type(room, RoomData.Type.SHOP)

		station_below_rule = is_station and room.row < MIN_STATION_ROW
		consequetive_station = is_station and has_station_parent
		consequetive_shop = is_shop and has_shop_parent
		station_on_second_to_last = is_station and room.row < FLOORS - 2
	
	room.type = candidate_type


func _room_has_parent_of_type(room:RoomData, type:RoomData.Type) -> bool:
	var parents:Array[RoomData] = []

	if room.column > 0 and room.row > 0:
		var parent_candidate:RoomData = map_data[room.row - 1][room.column - 1]
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)

	if room.row > 0:
		var parent_candidate:RoomData = map_data[room.row - 1][room.column]
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)

	if room.column < MAP_WIDTH - 1 and room.row > 0:
		var parent_candidate:RoomData = map_data[room.row - 1][room.column + 1]
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)

	for parent:RoomData in parents:
		if parent.type == type:
			return true

	return false


func _get_room_by_weight() -> RoomData.Type:
	var roll:float = randf_range(0.0, random_room_type_total_weight)

	for type:RoomData.Type in random_room_type_weights:
		if random_room_type_weights[type] > roll:
			return type
	
	return RoomData.Type.ENCOUNTER

