class_name PlayerData extends Resource


const WEB_CANCEL:Key = KEY_BACKSPACE


@export_category("Basics")
@export var id:String = ""
@export var hash_id:int = -1
@export var last_save_date_time:String
@export var was_last_used:bool = false
@export var playtime:float = 0.0
@export var is_new_save:bool = true

@export_category("Active Run")
@export var has_active_run:bool = false

@export_group("Ship")
@export var current_ship_id:int = -1
@export var ship_name:String = ""
@export var current_propulsion:float = 1.0
@export var current_hull_integrity:float = 1.0
@export var current_ai_core:float = 1.0
@export var current_life_support:float = 1.0

@export_group("Prisonser")
@export var prisoners:Array[PrisonerData] = []
@export var active_prisoners:Array[String] = []
var current_prisoners:Array[PrisonerData] = []

@export_group("Progression Map")
@export var current_grid:Array[Array] = []
@export var current_location:Vector2i = Vector2i.ZERO

@export_category("System Settings")
@export_group("General")
@export var language:String = "en"
var language_default:String = "en"

@export_group("Visual")
var platform:String = "Windows"
@export var window_mode:Settings.Window_Mode = Settings.Window_Mode.FULLSCREEN
var window_mode_default:Settings.Window_Mode = Settings.Window_Mode.FULLSCREEN if OS.get_name() != "Web" else Settings.Window_Mode.WINDOWED
@export var window_size:Vector2i = Vector2i(1920, 1080)
var window_size_default:Vector2i = Vector2i(1920, 1080)
@export var display_monitor:int = 1
var default_display_monitor:int = 1

@export_group("Audio")
@export var master_volume:float = 0.5
@export var music_volume:float = 0.5
@export var sfx_volume:float = 0.5

@export_group("Accessibility")
@export var colorblind_mode:int = 0
var colorblind_mode_default:int = 0
@export var dyslexic_font:bool = false
var dyslexic_font_default:bool = false
@export var filters_active:bool = true
var filters_active_default:bool = true
@export var flashes_active:bool = true
var flashes_active_default:bool = true

@export_group("Controls")
@export_subgroup("Mouse and Keyboard")
@export var click = MOUSE_BUTTON_LEFT
var click_default = MOUSE_BUTTON_LEFT
@export var deselect = MOUSE_BUTTON_RIGHT
var deselect_default = MOUSE_BUTTON_RIGHT
@export var keyboard_move_left:Key = KEY_A
@export var keyboard_move_lup:Key = KEY_W
@export var keyboard_move_right:Key = KEY_D
@export var keyboard_move_down:Key = KEY_S
@export var keyboard_confirm:Key = KEY_ENTER
@export var keyboard_cancel:Key = KEY_ESCAPE
var keyboard_cancel_default:Key = WEB_CANCEL if OS.get_name() == "Web" else KEY_ESCAPE

@export_subgroup("Controller")
@export var joy_axis_left_x:JoyAxis = JOY_AXIS_LEFT_X
@export var joy_axis_right_x:JoyAxis = JOY_AXIS_RIGHT_X
@export var joy_move_left:JoyButton = JOY_BUTTON_DPAD_LEFT
@export var joy_move_right:JoyButton = JOY_BUTTON_DPAD_RIGHT
@export var joy_move_up:JoyButton = JOY_BUTTON_DPAD_UP
@export var joy_move_down:JoyButton = JOY_BUTTON_DPAD_DOWN
@export var joy_confirm:JoyButton = JOY_BUTTON_A
@export var joy_cancel:JoyButton = JOY_BUTTON_B

var has_unsaved_changes:bool = false


func get_prisoner_data_from_id(_id:String) -> PrisonerData:
	for pd:PrisonerData in prisoners:
		if pd.id == _id:
			return pd
	return null


func activate_prisoner_from_id(prisoner_id:String) -> Dictionary:
	var result:Dictionary = {}
	var prisoner:PrisonerData = get_prisoner_data_from_id(prisoner_id)

	if prisoner != null:
		if not current_prisoners.has(prisoner):
			current_prisoners.append(prisoner)
			result["result"] = true
		else:
			result["result"] = false
			result["reason"] = "present"
	else:
		result["result"] = false
		result["reason"] = "not_found"

	return result


func reset() -> void:
	has_active_run = false
	prisoners = []
	current_grid = []
	current_prisoners = []
	active_prisoners = []
	current_ship_id = -1
	ship_name = ""
	current_propulsion = 1
	current_hull_integrity = 1
	current_life_support = 1
	current_ai_core = 1
	current_location = Vector2i.ZERO
