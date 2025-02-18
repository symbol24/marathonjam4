class_name MainMenu extends RidControl


@onready var btn_new_run: Button = %btn_new_run
@onready var btn_continue_run: Button = %btn_continue_run
@onready var btn_abandon_run: Button = %btn_abandon_run
@onready var btn_new_game: Button = %btn_new_game
@onready var btn_load_game: Button = %btn_load_game
@onready var btn_settings: Button = %btn_settings
@onready var btn_credits: Button = %btn_credits

var save_manager:SaveManager:
	get:
		if save_manager == null: 
			save_manager = get_tree().get_first_node_in_group("save_manager")
			if save_manager == null: 
				push_error("Save Manager is missing!")
				return null
			else: return save_manager
		else: return save_manager

func _ready() -> void:
	Signals.PopupResult.connect(_check_popup_result)
	Signals.SaveComplete.connect(_toggle_buttons)
	btn_new_run.pressed.connect(_btn_new_run_pressed)
	btn_continue_run.pressed.connect(_btn_continue_run_pressed)
	btn_abandon_run.pressed.connect(_btn_abandon_run_pressed)
	btn_new_game.pressed.connect(_new_game_pressed)
	btn_load_game.pressed.connect(_load_game_pressed)
	btn_settings.pressed.connect(_settings_pressed)
	btn_credits.pressed.connect(_credits_pressed)
	if save_manager == null: Debug.error("Main menu unable to find save manager.")
	else: _toggle_buttons(-1)
	

func _btn_new_run_pressed() -> void:
	_untoggle_panels()
	Signals.LoadScene.emit("ship_naming", false)


func _btn_continue_run_pressed() -> void:
	_untoggle_panels()
	Signals.LoadScene.emit("continue_loader", true)


func _btn_abandon_run_pressed() -> void:
	_untoggle_panels()
	Signals.DisplayPopup.emit(PopupManager.Type.LARGE, "abandon_run", PopupManager.Severity.WARNING, tr("abandon_run_popup_title"), tr("abandon_run_popup_text"), 0)


func _new_game_pressed() -> void:
	_untoggle_panels()
	Signals.LoadScene.emit("story_intro", true)


func _load_game_pressed() -> void:
	_untoggle_panels("load")
	Signals.ToggleLoadPanel.emit(true)


func _settings_pressed() -> void:
	_untoggle_panels("settings")
	pass


func _credits_pressed() -> void:
	_untoggle_panels("credits")
	pass


func _untoggle_panels(_panel_called:String = "") -> void:
	pass


func _toggle_buttons(_hash_id:int) -> void:
	if save_manager.active_save != null:
		if save_manager.active_save.has_active_run:
			btn_new_run.hide()
			btn_continue_run.show()
			btn_abandon_run.show()
			btn_continue_run.grab_focus()
			btn_new_game.hide()
		else:
			if not save_manager.active_save.is_new_save:
				btn_new_run.show()
				btn_new_run.grab_focus()
				btn_continue_run.hide()
				btn_abandon_run.hide()
				btn_new_game.hide()
			else:
				btn_new_run.hide()
				btn_continue_run.hide()
				btn_abandon_run.hide()
				btn_new_game.show()
				btn_new_game.grab_focus()
	else:
		Signals.CreateNewSave.emit(Time.get_date_string_from_system())
		btn_new_run.hide()
		btn_continue_run.hide()
		btn_abandon_run.hide()
		btn_new_game.show()
		btn_new_game.grab_focus()


func _check_popup_result(popup_id:String, result:bool) -> void:
	match popup_id:
		"abandon_run":
			if result:
				Debug.log("Abandoning run")
				Signals.AbandonCurrentRun.emit()
		_:
			pass