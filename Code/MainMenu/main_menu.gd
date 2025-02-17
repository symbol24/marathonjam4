class_name MainMenu extends RidControl


@onready var btn_continue: Button = %btn_continue
@onready var btn_new_game: Button = %btn_new_game
@onready var btn_load_game: Button = %btn_load_game
@onready var btn_settings: Button = %btn_settings
@onready var btn_credits: Button = %btn_credits
@onready var load_panel: LoadPanel = %LoadPanel

var continue_id:int = -1

var save_manager:SaveManager = null

func _ready() -> void:
	Signals.LoadComplete.connect(_load_complete)
	btn_continue.pressed.connect(_continue_pressed)
	btn_new_game.pressed.connect(_new_game_pressed)
	btn_load_game.pressed.connect(_load_game_pressed)
	btn_settings.pressed.connect(_settings_pressed)
	btn_credits.pressed.connect(_credits_pressed)
	save_manager = get_tree().get_first_node_in_group("save_manager")
	if save_manager == null: Debug.error("Main menu unable to find save manager.")
	else:
		var save:PlayerData = save_manager.get_last_save_used()
		if save == null:
			btn_continue.disabled = true
			btn_new_game.grab_focus()
		else:
			continue_id = save.hash_id
			btn_continue.grab_focus()
	

func _continue_pressed() -> void:
	_untoggle_panels()
	Signals.LoadFromHashId.emit(continue_id)


func _new_game_pressed() -> void:
	_untoggle_panels()
	Signals.LoadScene.emit("story_intro")


func _load_game_pressed() -> void:
	_untoggle_panels("load")
	Signals.ToggleLoadPanel.emit(true)


func _settings_pressed() -> void:
	_untoggle_panels("settings")
	pass


func _credits_pressed() -> void:
	_untoggle_panels("credits")
	pass


func _load_complete(hash_id:int) -> void:
	if hash_id == continue_id:
		Signals.LoadScene.emit("map_selection_menu")


func _untoggle_panels(panel_called:String = "") -> void:
	if panel_called != "load" and load_panel.displayed: Signals.ToggleLoadPanel.emit(false)