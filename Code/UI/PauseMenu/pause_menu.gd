class_name PauseMenu extends Control


@onready var btn_close_pause_menu: Button = %btn_close_pause_menu
@onready var pause_tab_container: TabContainer = %pause_tab_container

var settings:Settings = null
var data_manager:DataManager:
	get:
		if data_manager == null: data_manager = get_tree().get_first_node_in_group("data_manager")
		if data_manager == null: Debug.error("Data Manager not found by pause menu")
		return data_manager


func _ready() -> void:
	process_mode = PROCESS_MODE_WHEN_PAUSED
	btn_close_pause_menu.pressed.connect(_btn_close_pause_menu_pressed)
	_setup_settings()


func toggle_pause_menu(display:bool = false) -> void:
	if display:
		Signals.TogglePauseGame.emit(true)
		settings.toggle_display(display)
		show()
	else:
		if not settings.pending_changes:
			Signals.TogglePauseGame.emit(false)
			settings.toggle_display(display)
			hide()
		else:
			Signals.DisplayPopup.emit(PopupManager.Type.LARGE, "pause_settings_pending_changes", PopupManager.Severity.WARNING, tr("pause_settings_pending_changes_title"), tr("pause_settings_pending_changes_text"), 0)


func _btn_close_pause_menu_pressed() -> void:
	toggle_pause_menu(false)


func _setup_settings() -> void:
	if data_manager != null:
		settings = data_manager.settings.instantiate()
		pause_tab_container.add_child(settings)
		settings.floating_control.show()
		settings.btn_main_menu_settings_close.hide()


func _check_popup_results(popup_id:String, result:bool) -> void:
	match popup_id:
		"pause_settings_pending_changes":
			if result:
				await get_tree().create_timer(0.1).timeout
				toggle_pause_menu(false)
		_:
			pass