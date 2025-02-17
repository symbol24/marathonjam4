class_name PrisonerSelectionMenu extends RidControl


const ACTIVE_PANEL_OUT_X:float = 2020.0
const ACTIVE_PANEL_IN_X:float = 1420.0
const ACTIVE_PANEL_SLIDE_TIME:float = 0.4
const PRISONER_SELECT_BUTTON:String = "res://Scenes/UI/PrisonerSelection/prisoner_select_button.tscn"

@onready var prisoner_list_vbox: VBoxContainer = %prisoner_list_vbox
@onready var prisoner_details_vbox: VBoxContainer = %prisoner_details_vbox
@onready var prisoner_headshot: TextureRect = %prisoner_headshot
@onready var prisoner_name: Label = %prisoner_name
@onready var prisoner_status: Label = %prisoner_status
@onready var prisoner_height: Label = %prisoner_height
@onready var prisoner_weight: Label = %prisoner_weight
@onready var prisoner_dob: Label = %prisoner_dob
@onready var prisoner_doi: Label = %prisoner_doi
@onready var prisoner_sentence: Label = %prisoner_sentence
@onready var prisoner_loo: Label = %prisoner_loo
@onready var prisoner_loe: Label = %prisoner_loe
@onready var prisoner_criminality_rating: Label = %prisoner_criminality_rating
@onready var prisoner_sr: Label = %prisoner_sr
@onready var prisoner_ar: Label = %prisoner_ar
@onready var prisoner_cr: Label = %prisoner_cr
@onready var prisoner_ir: Label = %prisoner_ir
@onready var btn_confirm: Button = %btn_confirm
@onready var btn_display_active: Button = %btn_display_active
@onready var btn_select_prisoner: Button = %btn_select_prisoner
@onready var prisoners_active_list: VBoxContainer = %prisoners_active_list
@onready var active_prisoners_panel_btn: Button = %active_prisoners_panel_btn
@onready var prisoners_active_panel: PanelContainer = %prisoners_active

var button:PrisonerSelectButton = null


func _ready() -> void:
	btn_display_active.pressed.connect(_active_panel_toggle_btn)
	button = load(PRISONER_SELECT_BUTTON).instantiate()
	if button == null: Debug.warning("Prisoner selection button not loading")


func _active_panel_toggle_btn() -> void:
	Debug.log("Sending ToggleActivePrisonersPanel signal")
	Signals.ToggleActivePrisonersPanel.emit()