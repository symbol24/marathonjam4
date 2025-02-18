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
@export var current_progression_map:Array[Array] = []
@export var current_location:Vector2 = Vector2.ZERO

@export_category("System Settings")
@export_group("General")
@export var difficulty:int = 0

@export_group("Visual")
@export var window_mode:int = 0
@export var window_size:Vector2i = Vector2i(1920, 1080)

@export_group("Audio")
@export var master_volume:float = 0.5
@export var music_volume:float = 0.5
@export var sfx_volume:float = 0.5

@export_group("Accessibility")
@export var colorblind_mode:int = 0
@export var dyslexic_font:bool = false
@export var filters_active:bool = true
@export var flashes_active:bool = true

@export_group("Controls")
@export_subgroup("Mouse and Keyboard")
@export var mouse_left:MouseButton = MOUSE_BUTTON_LEFT
@export var mouse_right:MouseButton = MOUSE_BUTTON_RIGHT
@export var keyboard_move_left:Key = KEY_A
@export var keyboard_move_lup:Key = KEY_W
@export var keyboard_move_right:Key = KEY_D
@export var keyboard_move_down:Key = KEY_S
@export var keyboard_confirm:Key = KEY_ENTER
@export var keyboard_cancel:Key = KEY_ESCAPE

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