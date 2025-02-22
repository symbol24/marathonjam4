class_name MapIcon extends Control


const BOSS_STYLE:String = "MapIconBoss"
const DERELECT_STYLE:String = "MapIconDerelect"
const ENCOUNTER_STYLE:String = "MapIconEncounter"
const SHOP_STYLE:String = "MapIconShop"
const START_STYLE:String = "MapIconStart"
const STATION_STYLE:String = "MapIconStation"
const BOSS_TEXT:String = "!!!"
const DERELECT_TEXT:String = "?"
const ENCOUNTER_TEXT:String = "!"
const SHOP_TEXT:String = "$"
const START_TEXT:String = "<>"
const STATION_TEXT:String = "[]"


@onready var selected: Panel = %selected
@onready var icon: Panel = %icon
@onready var icon_letter_label: Label = %icon_letter_label
@onready var complete: Panel = %complete
@onready var btn_map_icon: Button = %btn_map_icon

var room_data:RoomData


func _ready() -> void:
	Signals.RoomIconBtnPressed.connect(_check_deselect)
	btn_map_icon.pressed.connect(_btn_pressed)
	btn_map_icon.mouse_entered.connect(_mouse_entered)
	btn_map_icon.mouse_exited.connect(_mouse_exited)


func setup_button(data:RoomData) -> void:
	room_data = data
	if room_data.complete: complete.show()
	#Debug.log("Room %s is type: %s" % [name, RoomData.Type.keys()[room_data.type]])
	match room_data.type:
		RoomData.Type.BOSS:
			icon.theme_type_variation = BOSS_STYLE
			icon_letter_label.text = BOSS_TEXT
		RoomData.Type.DERELECT:
			icon.theme_type_variation = DERELECT_STYLE
			icon_letter_label.text = DERELECT_TEXT
		RoomData.Type.SHOP:
			icon.theme_type_variation = SHOP_STYLE
			icon_letter_label.text = SHOP_TEXT
		RoomData.Type.START:
			icon.theme_type_variation = START_STYLE
			icon_letter_label.text = START_TEXT
		RoomData.Type.STATION:
			icon.theme_type_variation = STATION_STYLE
			icon_letter_label.text = STATION_TEXT
		_:
			icon.theme_type_variation = ENCOUNTER_STYLE
			icon_letter_label.text = ENCOUNTER_TEXT


func select() -> void:
	room_data.selected = true
	selected.show()


func deselect() -> void:
	room_data.selected = false
	selected.hide()


func _btn_pressed() -> void:
	Signals.RoomIconBtnPressed.emit(room_data)


func _check_deselect(data:RoomData) -> void:
	if data != room_data and not room_data.selected:
		deselect()


func _mouse_entered() -> void:
	selected.show()


func _mouse_exited() -> void:
	if not room_data.selected: selected.hide()