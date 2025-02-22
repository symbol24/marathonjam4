class_name MapSelectionMenu extends RidControl


const POINT_DISTANCE_Y:float = 200.0
const CAMERA_MOVE_SPEED:float = 100.0
const CAMERA_Y_MIN:float = 0.0
const MAP_WIDTH:float = 1250.0
const MAP_MOVE_MESSAGE_TIME:float = 2.0


@onready var scroll_map: ScrollContainer = %scroll_map
@onready var map: Panel = %map

# Ship Status
@onready var ship_name: Label = %ship_name
@onready var registry: Label = %registry
@onready var propulsion: Label = %propulsion
@onready var hull: Label = %hull
@onready var ai_core: Label = %ai_core
@onready var life_support: Label = %life_support
@onready var active_prisoners: Label = %active_prisoners
@onready var cryostasis_prisoner: Label = %cryostasis_prisoner
@onready var dead_prisoners: Label = %dead_prisoners

# Legend
@onready var legend_panel: PanelContainer = %legend_panel
@onready var btn_legend_toggle: Button = %btn_legend_toggle

# Nav
@onready var btn_load_prisoners: Button = %btn_load_prisoners

var data_manager:DataManager:
	get:
		if data_manager == null: data_manager = get_tree().get_first_node_in_group("data_manager")
		if data_manager == null: Debug.error("Data Manager is missing!")
		return data_manager
var save_manager:SaveManager:
	get:
		if save_manager == null: save_manager = get_tree().get_first_node_in_group("save_manager")
		if save_manager == null: Debug.error("Save manager not found")
		return save_manager
var map_generator:MapGenerator = null
var grid:Array[Array] = []
var last_room_coords:Vector2

var can_scroll:bool = false
var get_next_scroll:bool = true
var scroll_movement:Array[bool] = []
var camera_y_max:float = 1.0
var grabbed:bool = false
var previous_mouse_position:Vector2 = Vector2.ZERO
var points:Dictionary = {}
var selected_point:MapIcon


func _ready() -> void:
	hide()
	legend_panel.hide()
	await get_tree().create_timer(0.3).timeout
	Signals.ToggleLoadingScreen.emit(true, "map_selection_ready", 25)
	Signals.MapStuffPlacementComplete.connect(_final_map_selection_prep)
	Signals.LoadRoom.connect(_load_encounter)
	Signals.RoomIconBtnPressed.connect(_check_room_data)
	btn_legend_toggle.pressed.connect(_toggle_legend)
	btn_load_prisoners.pressed.connect(_load_prisoners_selection)
	if save_manager and not save_manager.active_save.current_grid.is_empty():
		Signals.ToggleLoadingScreen.emit(true, "map_selection_retrieving_map", 10)
		_load_map_from_save()
	else:
		_generate_map()


func _place_map_stuff() -> void:
	await get_tree().create_timer(0.3).timeout
	Signals.ToggleLoadingScreen.emit(true, "map_selection_placing_stuff", 25)
	await _place_rooms()
	await _place_lines()
	Signals.MapStuffPlacementComplete.emit()


func _check_room_data(room_data:RoomData) -> void:
	if room_data == selected_point.room_data and not selected_point.room_data.complete:
		Signals.LoadRoom.emit(room_data)
	elif room_data != selected_point.room_data and selected_point.room_data.complete and room_data in selected_point.room_data.next_rooms:
		await _move_popups()
		Signals.LoadRoom.emit(room_data)


func _move_popups() -> void:
	Signals.DisplayPopup.emit(PopupManager.Type.SMALL, "map_select_prepare", PopupManager.Severity.NORMAL, "", tr("map_select_prepare"), MAP_MOVE_MESSAGE_TIME)
	await get_tree().create_timer(MAP_MOVE_MESSAGE_TIME).timeout
	Signals.DisplayPopup.emit(PopupManager.Type.SMALL, "map_select_transit", PopupManager.Severity.NORMAL, "", tr("map_select_transit"), MAP_MOVE_MESSAGE_TIME)
	await get_tree().create_timer(MAP_MOVE_MESSAGE_TIME).timeout
	Signals.DisplayPopup.emit(PopupManager.Type.SMALL, "map_select_arriver", PopupManager.Severity.NORMAL, "", tr("map_select_arrived"), MAP_MOVE_MESSAGE_TIME)
	await get_tree().create_timer(MAP_MOVE_MESSAGE_TIME).timeout


func _place_rooms() -> void:
	var first_and_last_floor_x:float = MAP_WIDTH / 2
	var floor_count:int = 0
	var previous_floor_y:float = POINT_DISTANCE_Y * (MapGenerator.FLOORS + 1)
	map.custom_minimum_size = Vector2(MAP_WIDTH, previous_floor_y)
	for _floor in grid:
		var room_count:int = 1
		var horz_room_seperation:float = MAP_WIDTH / (_floor.size()+1)
		var floor_y:float = previous_floor_y - POINT_DISTANCE_Y

		for room:RoomData in _floor:
			var to_insta:PackedScene = data_manager.map_icon
			if room.type == RoomData.Type.NOT_ASSIGNED: to_insta = null

			if to_insta != null:
				var map_icon:MapIcon = to_insta.instantiate()
				var pos:Vector2
				if floor_count == 0:
					pos = Vector2(first_and_last_floor_x, floor_y)
				elif floor_count == grid.size() - 1:
					#pos = Vector2((horz_room_seperation*j), floor_y)
					pos = Vector2(first_and_last_floor_x, floor_y)
					last_room_coords = pos
					camera_y_max = floor_y
				else:
					pos = Vector2((horz_room_seperation*room_count), floor_y)

				room.coords_on_map = pos
				map.add_child(map_icon)
				if not map_icon.is_node_ready(): await map_icon.ready
				map_icon.name = RoomData.Type.keys()[room.type] + "_" + str(floor_count) + "_" + str(room_count)
				room.button_name = map_icon.name
				map_icon.setup_button(room)

				var offset:Vector2 = map_icon.size/2
				map_icon.position = room.coords_on_map - offset
				points[map_icon.name] = map_icon

			room_count += 1
			
		previous_floor_y = floor_y
		floor_count += 1


func _place_lines() -> void:
	for _floor in grid:
		for room:RoomData in _floor:
			if room.coords_on_map != Vector2.ZERO:
				for next_room:RoomData in room.next_rooms:
					var line:Line2D = data_manager.map_line.instantiate()
					map.add_child(line)
					if not line.is_node_ready(): await line.ready
					line.add_point(room.coords_on_map, 0)
					line.add_point(next_room.coords_on_map, 1)


func _final_map_selection_prep() -> void:
	await get_tree().create_timer(0.3).timeout
	Signals.ToggleLoadingScreen.emit(true, "map_selection_spawning_ship", 15)
	_set_selected_point()
	#_spawn_ship()
	show()
	_setup_labels()
	await get_tree().create_timer(0.3).timeout
	scroll_map.scroll_vertical = int(selected_point.position.y - 400)
	Signals.ToggleLoadingScreen.emit(false)
	can_scroll = true


func _set_selected_point() -> void:
	if not save_manager.active_save.current_grid.is_empty() and save_manager.active_save.current_location != Vector2i.ZERO:
		selected_point = _get_point_from_coords(save_manager.active_save.current_location)
		selected_point.select()
		return
	else:
		for k in points.keys():
			if points[k].room_data.type == RoomData.Type.START:
				selected_point = points[k]
				selected_point.select()
				return
	Debug.error("No Starting point found!")


func _spawn_ship() -> void:
	var ship:MapIconSpaceship = data_manager.map_icon_spaceship.instantiate()
	map.add_child(ship)
	if not ship.is_node_ready(): await ship.ready
	ship.position = Vector2(16,16) + selected_point.position
	ship.current_room = selected_point.room_data


func _load_encounter(_room_data:RoomData) -> void:
	_update_location(_room_data)
	await get_tree().create_timer(0.2).timeout
	var to_load:String = "test_level"
	if _room_data.type == RoomData.Type.SHOP: to_load = "shop_menu"
	elif _room_data.type == RoomData.Type.STATION: to_load = "station_menu"
	elif _room_data.type == RoomData.Type.DERELECT: to_load = "derelect_menu"
	Signals.LoadScene.emit(to_load, true)


func _load_map_from_save() -> void:
	if not save_manager.active_save.current_grid.is_empty():
		grid = save_manager.active_save.current_grid
		_place_map_stuff()
	else:
		Debug.warning("Save file does not contain a grid, generating new map.")
		_generate_map()


func _update_location(_room_data:RoomData) -> void:
	save_manager.active_save.current_location = Vector2i(_room_data.row, _room_data.column)
	save_manager.active_save.current_grid = grid
	Signals.Save.emit()


func _generate_map() -> void:
	Signals.ToggleLoadingScreen.emit(true, "map_selection_generating_map", 10)
	map_generator = data_manager.map_generator.instantiate()
	add_child(map_generator)
	if not map_generator.is_node_ready(): await map_generator.ready
	grid = map_generator.generate_map()
	if grid.is_empty(): Debug.error("Grid not generated.")
	else:
		_place_map_stuff()


func _get_point_from_coords(coords:Vector2i) -> MapIcon:
	for key in points.keys():
		if points[key].room_data.row == coords.x and points[key].room_data.column == coords.y:
			return points[key]
	return null


func _setup_labels() -> void:
	ship_name.text = save_manager.active_save.ship_name
	registry.text = str(save_manager.active_save.current_ship_id)
	propulsion.text = str(save_manager.active_save.current_propulsion) + "%"
	hull.text = str(save_manager.active_save.current_hull_integrity) + "%"
	ai_core.text = str(save_manager.active_save.current_ai_core) + "%"
	life_support.text = str(save_manager.active_save.current_life_support) + "%"
	active_prisoners.text = str(save_manager.active_save.active_prisoners.size())
	dead_prisoners.text = str(save_manager.active_save.get_dead_prisoners())
	cryostasis_prisoner.text = str(save_manager.active_save.get_crystasis_prisoner())


func _toggle_legend() -> void:
	if legend_panel.is_visible():
		legend_panel.hide()
	else:
		legend_panel.show()


func _load_prisoners_selection() -> void:
	Signals.LoadScene.emit("prisoner_select", true)