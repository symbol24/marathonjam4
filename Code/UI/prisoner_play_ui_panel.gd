class_name PrisonerPlayUiPanelBtn extends PanelContainer


const PANELNORMAL:String = "PrisonerSelectButtonPanel"
const PANELHOVER:String = "PrisonerSelectButtonHover"
const TEXTNORMAL:String = "PrisonerDetailsLabelSmall"
const TEXTHOVER:String = "PrisonerDetailsLabelSmallHover"


@onready var headshot: TextureRect = %headshot
@onready var prisoner_id_label: Label = %prisoner_id_label
@onready var prisoner_display_id: Label = %prisoner_display_id
@onready var prisoner_health_label: Label = %prisoner_health_label
@onready var prisoner_health: Label = %prisoner_health
@onready var prisoner_status_label: Label = %prisoner_status_label
@onready var prisoner_status: Label = %prisoner_status
@onready var prisoner_play_panel_btn: TextureButton = %prisoner_play_panel_btn
@onready var inventory_btn: Button = %inventory_btn

var prisoner_data:PrisonerData


func _ready() -> void:
	prisoner_play_panel_btn.mouse_entered.connect(_prisoner_play_panel_btn_mouse_entered)
	prisoner_play_panel_btn.mouse_exited.connect(_prisoner_play_panel_btn_mouse_exited)
	prisoner_play_panel_btn.pressed.connect(_prisoner_play_panel_btn_pressed)
	inventory_btn.pressed.connect(_inventory_btn_pressed)


func setup_panel(data:PrisonerData) -> void:
	prisoner_data = data
	headshot.texture = prisoner_data.headshot_small
	prisoner_display_id.text = str(prisoner_data.display_id)
	_update_prisoner_hp(prisoner_data)
	_update_status(prisoner_data)


func _inventory_btn_pressed() -> void:
	Signals.ToggleInventoryForPrisonerData.emit(prisoner_data)


func _update_prisoner_hp(data:PrisonerData) -> void:
	if prisoner_data == data:
		prisoner_health.text = str(prisoner_data.current_hp) + "/" + str(prisoner_data.base_hp)


func _update_status(data:PrisonerData) -> void:
	if prisoner_data == data:
		prisoner_status.text = tr("prisoner_action_state_" + str(PrisonerData.Action_State.keys()[prisoner_data.current_action_state]))


func _prisoner_play_panel_btn_pressed() -> void:
	Signals.SelecetPrisonerByData.emit(prisoner_data)


func _prisoner_play_panel_btn_mouse_entered() -> void:
	theme_type_variation = PANELHOVER
	prisoner_id_label.theme_type_variation = TEXTHOVER
	prisoner_display_id.theme_type_variation = TEXTHOVER
	prisoner_health_label.theme_type_variation = TEXTHOVER
	prisoner_health.theme_type_variation = TEXTHOVER
	prisoner_status_label.theme_type_variation = TEXTHOVER
	prisoner_status.theme_type_variation = TEXTHOVER


func _prisoner_play_panel_btn_mouse_exited() -> void:
	theme_type_variation = PANELNORMAL
	prisoner_id_label.theme_type_variation = TEXTNORMAL
	prisoner_display_id.theme_type_variation = TEXTNORMAL
	prisoner_health_label.theme_type_variation = TEXTNORMAL
	prisoner_health.theme_type_variation = TEXTNORMAL
	prisoner_status_label.theme_type_variation = TEXTNORMAL
	prisoner_status.theme_type_variation = TEXTNORMAL