class_name GameManager extends RidManager


@export var use_debug:bool = false

var data_manager:DataManager
var save_manager:SaveManager
var current_prisoners:Array[PrisonerData]


func _ready() -> void:
	Signals.ActivatePrisonerData.connect(_activate_prisoner)
	data_manager = get_tree().get_first_node_in_group("data_manager")
	if data_manager == null: push_error("Data Manager is missing!")
	save_manager = get_tree().get_first_node_in_group("save_manager")
	if save_manager == null: push_error("Save Manager is missing!")


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
	
	