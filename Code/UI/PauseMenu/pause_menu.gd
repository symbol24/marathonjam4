class_name PauseMenu extends Control


@onready var btn_close_pause_menu: Button = %btn_close_pause_menu
@onready var pause_tab_container: TabContainer = %pause_tab_container

var settings:Control = null
var data_manager:DataManager:
	get:
		if data_manager == null: data_manager = get_tree().get_first_node_in_group("data_manager")
		if data_manager == null: Debug.error("Data Manager not found by pause menu")
		return data_manager

func _ready() -> void:
	process_mode = PROCESS_MODE_WHEN_PAUSED
	btn_close_pause_menu.pressed.connect(_btn_close_pause_menu_pressed)
	_setup_settings()


func _btn_close_pause_menu_pressed() -> void:
	Signals.TogglePauseMenu.emit(false)


func _setup_settings() -> void:
	if data_manager != null:
		settings = data_manager.settings.instantiate()
		pause_tab_container.add_child(settings)