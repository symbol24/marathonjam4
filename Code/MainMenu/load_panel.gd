class_name LoadPanel extends PanelContainer


const TRANSITION_TIME:float = 0.5
const ONSCREEEN_X:float = 1220.0
const OFFSCREEN_X:float = 1990.0
const BTN_LOAD_SAVE_FILE:String = "res://Scenes/MainMenu/btn_load_reference.tscn"


@onready var load_vbox: VBoxContainer = %load_vbox
@onready var btn_load_file: Button = %btn_load_file
@onready var btn_load_cancel: Button = %btn_load_cancel

var data_manager:DataManager
var save_manager:SaveManager
var selected_hash_id:int = -1
var buttons:Array[BtnLoadReference] = []
var displayed:bool = false

var load_button:BtnLoadReference = null

func _ready() -> void:
	position.x = OFFSCREEN_X
	Signals.SelectHashIdForLoad.connect(_set_selected_hash_id)
	Signals.ToggleLoadPanel.connect(_toggle_load_panel)
	btn_load_cancel.pressed.connect(_toggle_load_panel)
	btn_load_file.pressed.connect(_load_btn_pressed)
	data_manager = get_tree().get_first_node_in_group("data_manager")
	save_manager = get_tree().get_first_node_in_group("save_manager")
	load_button = load(BTN_LOAD_SAVE_FILE).instantiate()
	if load_button == null: Debug.log("Load save file button not instantiated")


func _toggle_load_panel(_display:bool = false) -> void:
	if _display and not displayed:
		btn_load_file.disabled = true
		_setup_buttons()
		_transition_in()
	elif not _display and displayed:
		_transition_out()
		btn_load_file.disabled = true


func _setup_buttons() -> void:
	if save_manager:
		_clear_buttons()
		for key in save_manager.all_saves.keys():
			var btn:BtnLoadReference = load_button.duplicate()
			load_vbox.add_child(btn)
			if not btn.is_node_ready(): await btn.ready
			btn.hash_id = key
			buttons.append(btn)


func _set_selected_hash_id(hash_id:int) -> void:
	selected_hash_id = hash_id
	btn_load_file.disabled = false


func _clear_buttons() -> void:
	var children = load_vbox.get_children()
	if children:
		for child in children:
			load_vbox.remove_child(child)
			child.queue_free.call_deferred()
	buttons.clear()


func _transition_in() -> void:
	var tween:Tween = create_tween()
	tween.tween_property(self, "position", Vector2(ONSCREEEN_X+10, position.y), TRANSITION_TIME)
	tween.tween_property(self, "position", Vector2(ONSCREEEN_X-10, position.y), 0.05)
	tween.tween_property(self, "position", Vector2(ONSCREEEN_X, position.y), 0.05)
	await tween.finished
	displayed = true


func _transition_out() -> bool:
	var tween:Tween = create_tween()
	tween.tween_property(self, "position", Vector2(ONSCREEEN_X-10, position.y), 0.05)
	tween.tween_property(self, "position", Vector2(ONSCREEEN_X+10, position.y), 0.05)
	tween.tween_property(self, "position", Vector2(OFFSCREEN_X, position.y), TRANSITION_TIME)
	await tween.finished
	displayed = false
	return true


func _load_btn_pressed() -> void:
	await _transition_out()
	Debug.log("Sending load signal for hash id: ", selected_hash_id)
	Signals.LoadFromHashId.emit(selected_hash_id)