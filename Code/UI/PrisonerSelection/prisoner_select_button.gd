class_name PrisonerSelectButton extends Control

const PANELNORMAL:String = "PrisonerSelectButtonPanel"
const PANELHOVER:String = "PrisonerSelectButtonHover"
const TEXTNORMAL:String = "PrisonerDetailsLabelSmall"
const TEXTHOVER:String = "PrisonerDetailsLabelSmallHover"


@onready var panel_background: PanelContainer = %panel_background
@onready var headshot: TextureRect = %headshot
@onready var l_prisoner_name: Label = %l_prisoner_name
@onready var prisoner_name: Label = %prisoner_name
@onready var l_prisoner_sentence: Label = %l_prisoner_sentence
@onready var prisoner_sentence: Label = %prisoner_sentence
@onready var l_prisoner_doi: Label = %l_prisoner_doi
@onready var prisoner_doi: Label = %prisoner_doi
@onready var deceased_label: Label = %deceased_label
@onready var btn_select: TextureButton = %btn_select

var prisoner_data:PrisonerData


func _ready() -> void:
	btn_select.pressed.connect(_btn_select_pressed)
	btn_select.mouse_entered.connect(_mouse_enter)
	btn_select.mouse_exited.connect(_mouse_exit)


func set_data(prisoner:PrisonerData) -> void:
	prisoner_data = prisoner
	headshot.texture = prisoner_data.headshot_small
	prisoner_name.text = prisoner_data.display_name
	prisoner_sentence.text = prisoner_data.sentence
	prisoner_doi.text = prisoner_data.doi

	if prisoner_data.current_health_status == PrisonerData.Health_Status.DEAD:
		deceased_label.show()


func _btn_select_pressed() -> void:
	Signals.BtnSelectPrisonerPressed.emit(prisoner_data)


func _mouse_enter() -> void:
	panel_background.theme_type_variation = PANELHOVER
	prisoner_name.theme_type_variation = TEXTHOVER
	prisoner_sentence.theme_type_variation = TEXTHOVER
	prisoner_doi.theme_type_variation = TEXTHOVER
	l_prisoner_name.theme_type_variation = TEXTHOVER
	l_prisoner_sentence.theme_type_variation = TEXTHOVER
	l_prisoner_doi.theme_type_variation = TEXTHOVER

	
func _mouse_exit() -> void:
	panel_background.theme_type_variation = PANELNORMAL
	prisoner_name.theme_type_variation = TEXTNORMAL
	prisoner_sentence.theme_type_variation = TEXTNORMAL
	prisoner_doi.theme_type_variation = TEXTNORMAL
	l_prisoner_name.theme_type_variation = TEXTNORMAL
	l_prisoner_sentence.theme_type_variation = TEXTNORMAL
	l_prisoner_doi.theme_type_variation = TEXTNORMAL