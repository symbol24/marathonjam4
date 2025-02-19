class_name PrisonerSelectionMenu extends RidControl


const ACTIVE_PANEL_OUT_X:float = 2020.0
const ACTIVE_PANEL_IN_X:float = 1420.0
const ACTIVE_PANEL_SLIDE_TIME:float = 0.4
const PRISONER_SELECT_BUTTON:String = "res://Scenes/UI/PrisonerSelection/prisoner_select_button.tscn"

@onready var prisoner_list_vbox: VBoxContainer = %prisoner_list_vbox
@onready var btn_confirm: Button = %btn_confirm
@onready var btn_display_active: Button = %btn_display_active
@onready var prisoners_active_list: VBoxContainer = %prisoners_active_list
@onready var active_prisoners_panel_btn: Button = %active_prisoners_panel_btn
@onready var prisoners_active_panel: PanelContainer = %prisoners_active

var button:PrisonerSelectButton = null
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


func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	Signals.ToggleLoadingScreen.emit(true, "prisoner_selection_ready", 25)
	Signals.PrisonerHeadshotsLoaded.connect(_populate_prisoners)
	btn_display_active.pressed.connect(_active_panel_toggle_btn)
	btn_confirm.pressed.connect(_btn_confirm_pressed)
	button = load(PRISONER_SELECT_BUTTON).instantiate()
	if button == null: Debug.warning("Prisoner selection button not loading")
	if save_manager.active_save.prisoners.is_empty():
		save_manager.active_save.prisoners = data_manager.get_prisoner_duplicates()
	Signals.LoadPrisonerHeadshots.emit(save_manager.active_save.prisoners)


func _active_panel_toggle_btn() -> void:
	Signals.ToggleActivePrisonersPanel.emit()


func _populate_prisoners() -> void:
	await get_tree().create_timer(0.5).timeout
	Signals.ToggleLoadingScreen.emit(true, "prisoner_selection_populate", 25)
	for prisoner in save_manager.active_save.prisoners:
		var new_button:PrisonerSelectButton = button.duplicate()
		prisoner_list_vbox.add_child(new_button)
		if not new_button.is_node_ready(): await new_button.ready
		new_button.set_data(prisoner)
	
	await get_tree().create_timer(1).timeout
	Signals.ToggleLoadingScreen.emit(true, "prisoner_selection_populate_done", 25)
	await get_tree().create_timer(1).timeout
	Signals.ToggleLoadingScreen.emit(false)


func _btn_confirm_pressed() -> void:
	if save_manager.active_save.active_prisoners.is_empty():
		Signals.DisplayPopup.emit(PopupManager.Type.SMALL, "no_prisoners_selected", PopupManager.Severity.NORMAL, "", tr("prisoner_selection_no_prisoners"), 3)
	else:
		Signals.LoadScene.emit("map_selection_menu", true)