class_name ShipNaming extends RidControl


const MIN_CHARS:int = 4


@onready var spaceship_name: LineEdit = %spaceship_name
@onready var btn_confirm: Button = %btn_confirm


func _ready() -> void:
	Signals.SaveComplete.connect(_save_complete)
	spaceship_name.text_changed.connect(_name_length_check)
	btn_confirm.pressed.connect(_confirm_pressed)
	btn_confirm.disabled = true


func _confirm_pressed() -> void:
	Signals.CreateNewSave.emit(spaceship_name.text)


func _save_complete(_hash_id:int) -> void:
	Signals.LoadScene.emit("prisoner_select")


func _name_length_check(text:String) -> void:
	if text.length() >= MIN_CHARS: btn_confirm.disabled = false
	else: btn_confirm.disabled = true