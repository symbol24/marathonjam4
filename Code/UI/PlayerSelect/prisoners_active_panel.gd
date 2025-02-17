extends PanelContainer


const ACTIVE_PANEL_OUT_X:float = 2020.0
const ACTIVE_PANEL_IN_X:float = 1420.0
const ACTIVE_PANEL_SLIDE_TIME:float = 0.4


@onready var active_prisoners_panel_btn: Button = %active_prisoners_panel_btn
@onready var prisoners_active_list: VBoxContainer = %prisoners_active_list

var displayed:bool = false
var sliding:bool = false


func _ready() -> void:
	Signals.ToggleActivePrisonersPanel.connect(_toggle_active_prisoner_panel)
	active_prisoners_panel_btn.pressed.connect(_toggle_active_prisoner_panel)


func _toggle_active_prisoner_panel() -> void:
	Debug.log("receiving ToggleActivePrisonersPanel signal")
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