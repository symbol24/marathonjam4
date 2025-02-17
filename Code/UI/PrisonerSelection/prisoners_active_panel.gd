class_name PrisonerActivePanel extends PanelContainer


const ACTIVE_PANEL_OUT_X:float = 2020.0
const ACTIVE_PANEL_IN_X:float = 1420.0
const ACTIVE_PANEL_SLIDE_TIME:float = 0.4
const PRISONER_ACTIVE_DISPLAY:String = "res://Scenes/UI/PrisonerSelection/prisoner_active_display.tscn"


@onready var active_prisoners_panel_btn: Button = %active_prisoners_panel_btn
@onready var prisoners_active_list: VBoxContainer = %prisoners_active_list

var displayed:bool = false
var sliding:bool = false
var pad:PrisonerActiveDisplay = null
var save_manager:SaveManager


func _ready() -> void:
	Signals.ToggleActivePrisonersPanel.connect(_toggle_active_prisoner_panel)
	Signals.UpdateActivePrisonersPanel.connect(_update_active_prisoners)
	active_prisoners_panel_btn.pressed.connect(_toggle_active_prisoner_panel)
	pad = load(PRISONER_ACTIVE_DISPLAY).instantiate()
	if pad == null: Debug.warning("Prisoner Active Display not instantiated in prisoner active panel")
	save_manager = get_tree().get_first_node_in_group("save_manager")
	_update_active_prisoners(save_manager.active_save.current_prisoners)


func _toggle_active_prisoner_panel() -> void:
	if displayed:
		_slide_out_active_panel()
	else:
		_slide_in_active_panel()


func _slide_out_active_panel() -> void:
	if not sliding:
		sliding = true
		var tween:Tween = create_tween()
		tween.tween_property(self, "position", Vector2(position.x + 10, position.y), 0.05)
		tween.tween_property(self, "position", Vector2(position.x - 20, position.y), 0.05)
		tween.tween_property(self, "position", Vector2(ACTIVE_PANEL_OUT_X, position.y), ACTIVE_PANEL_SLIDE_TIME)
		await tween.finished
		displayed = false
		sliding = false


func _slide_in_active_panel() -> void:
	if not sliding:
		sliding = true
		var tween:Tween = create_tween()
		tween.tween_property(self, "position", Vector2(ACTIVE_PANEL_IN_X - 10, position.y), ACTIVE_PANEL_SLIDE_TIME)
		tween.tween_property(self, "position", Vector2(ACTIVE_PANEL_IN_X + 10, position.y), 0.05)
		tween.tween_property(self, "position", Vector2(ACTIVE_PANEL_IN_X, position.y), 0.05)
		await tween.finished
		displayed = true
		sliding = false


func _update_active_prisoners(prisoners:Array[PrisonerData]) -> void:
	if pad != null:
		_clear_prisoners()
		for prisoner in prisoners:
			var new_prisoner:PrisonerActiveDisplay = pad.duplicate()
			prisoners_active_list.add_child(new_prisoner)
			if not new_prisoner.is_node_ready(): await new_prisoner.ready
			new_prisoner.setup_data(prisoner)


func _clear_prisoners() -> void:
	if prisoners_active_list.get_child_count() > 0:
		for child in prisoners_active_list.get_children():
			prisoners_active_list.remove_child(child)
			child.queue_free.call_deferred()