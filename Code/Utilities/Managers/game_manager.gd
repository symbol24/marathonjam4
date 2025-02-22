class_name GameManager extends RidManager


@export var use_debug:bool = false

var data_manager:DataManager:
	get:
		if data_manager == null:
			data_manager = get_tree().get_first_node_in_group("data_manager")
			if data_manager == null: 
				push_error("Data Manager is missing!")
				return null
			else: return data_manager
		else: return data_manager

var save_manager:SaveManager:
	get:
		if save_manager == null: 
			save_manager = get_tree().get_first_node_in_group("save_manager")
			if save_manager == null: 
				push_error("Save Manager is missing!")
				return null
			else: return save_manager
		else: return save_manager

var current_prisoners:Array[PrisonerData]


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	Signals.ActivatePrisonerData.connect(_activate_prisoner)
	Signals.SelectShipAndName.connect(_select_ship_and_name)
	Signals.AbandonCurrentRun.connect(_abandon_current_run)
	Signals.TogglePauseGame.connect(_toggle_pause_game)


func _toggle_pause_game(pause:bool = false) -> void:
	get_tree().paused = pause


func _activate_prisoner(new_prisoner:PrisonerData) -> void:
	if save_manager.active_save.current_prisoners.has(new_prisoner):
		Debug.warning("Save current prisoners already contains prisoner %s. Prisoner not added" % new_prisoner.id)
	else:
		save_manager.active_save.current_prisoners.append(new_prisoner)

	if save_manager.active_save.active_prisoners.has(new_prisoner.id):
			Debug.warning("Save active prisoners already contains prisoner %s. Prisoner not added" % new_prisoner.id)
	else:
		save_manager.active_save.active_prisoners.append(new_prisoner.id)
	
	Signals.UpdateActivePrisonersPanel.emit(save_manager.active_save.current_prisoners)
	# TODO: Make sure the prisoner name is displayed in popup
	Signals.DisplayPopup.emit(PopupManager.Type.SMALL, "activated_prisoner", PopupManager.Severity.NORMAL, "", tr("popup_activated_prisoner_text"), 3)

	
func _select_ship_and_name(ship_name:String = "SS Botany Bay", ship_id:int = 1701) -> void:
	save_manager.active_save.has_active_run = true
	save_manager.active_save.ship_name = ship_name
	save_manager.active_save.current_ship_id = ship_id
	Signals.Save.emit()


func _abandon_current_run() -> void:
	Debug.log(save_manager.active_save.has_active_run)
	if save_manager.active_save.has_active_run:
		save_manager.active_save.reset()
		Signals.Save.emit()