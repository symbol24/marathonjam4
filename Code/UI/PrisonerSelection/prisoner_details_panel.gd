class_name PrisonerDetailsPanel extends PanelContainer


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
@onready var prisoner_criminal_record: RichTextLabel = %prisoner_criminal_record
@onready var prisoner_hp: Label = %hp
@onready var prisoner_speed: Label = %speed
@onready var btn_select_prisoner: Button = %btn_select_prisoner

var prisoner_data:PrisonerData


func _ready() -> void:
	Signals.BtnSelectPrisonerPressed.connect(_update_prisoner_detail)
	Signals.PrisonerActivated.connect(_update_health_status)
	btn_select_prisoner.pressed.connect(_btn_select_prisoner_pressed)


func _update_prisoner_detail(new_prisoner:PrisonerData) -> void:
	prisoner_data = new_prisoner
	if prisoner_details_vbox.is_visible():
		prisoner_details_vbox.hide()
	
	prisoner_headshot.texture = prisoner_data.headshot_normal
	prisoner_name.text = tr(prisoner_data.display_name)
	prisoner_status.text = tr(PrisonerData.Health_Status.keys()[prisoner_data.current_health_status])
	prisoner_height.text = str(prisoner_data.height) + "cm"
	prisoner_weight.text = str(prisoner_data.weight) + "kg"
	prisoner_dob.text = prisoner_data.dob
	prisoner_doi.text = prisoner_data.doi
	prisoner_sentence.text = tr(prisoner_data.sentence)
	prisoner_loo.text = tr(prisoner_data.location_of_origin)
	prisoner_loe.text = tr(prisoner_data.education)
	prisoner_criminality_rating.text = str(prisoner_data.base_criminality)
	prisoner_sr.text = str(prisoner_data.base_strength)
	prisoner_ar.text = str(prisoner_data.base_agility)
	prisoner_cr.text = str(prisoner_data.base_constitution)
	prisoner_ir.text = str(prisoner_data.base_intelligence)
	prisoner_criminal_record.text = tr(prisoner_data.criminal_record)
	prisoner_hp.text = str(prisoner_data.current_hp) + "/" + str(prisoner_data.base_hp)
	prisoner_speed.text = str(prisoner_data.move_speed)

	await get_tree().create_timer(0.2).timeout

	prisoner_details_vbox.show()


func _btn_select_prisoner_pressed() -> void:
	Signals.ActivatePrisonerData.emit(prisoner_data)


func _update_health_status(data:PrisonerData) -> void:
	if data == prisoner_data:
		prisoner_status.text = tr(PrisonerData.Health_Status.keys()[prisoner_data.current_health_status])