class_name PrisonerSelectButton extends Control


@onready var headshot: TextureRect = %headshot
@onready var prisoner_name: Label = %prisoner_name
@onready var prisoner_sentence: Label = %prisoner_sentence
@onready var prisoner_doi: Label = %prisoner_doi
@onready var deceased_label: Label = %deceased_label
@onready var btn_select: TextureButton = %btn_select

var prisoner_data:PrisonerData


func _ready() -> void:
	btn_select.pressed.connect(_btn_select_pressed)


func set_data(prisoner:PrisonerData) -> void:
	prisoner_data = prisoner
	headshot.texture = prisoner_data.headshot
	prisoner_name.text = prisoner_data.display_name
	prisoner_doi.text = prisoner_data.doi

	if prisoner_data.current_status == PrisonerData.Health_Status.DEAD:
		deceased_label.show()


func _btn_select_pressed() -> void:
	Signals.BtnSelectPrisonerPressed.emit(prisoner_data)