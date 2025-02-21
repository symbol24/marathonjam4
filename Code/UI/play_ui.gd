class_name PlayUi extends Control


const LEGEND_START_POS:Vector2 = Vector2(20, 920)


@export var panel_btn:PackedScene

@onready var prioner_list: VBoxContainer = %prioner_list
@onready var spacer: Control = %spacer
@onready var prisoner_info_toggle_btn: Button = %prisoner_info_toggle_btn
@onready var legend: PanelContainer = %legend
@onready var legend_grid: GridContainer = %legend_grid
@onready var btn_legend_toggle: Button = %btn_legend_toggle

var legend_visible:bool = false
var save_manager:SaveManager:
	get:
		if save_manager == null:
			save_manager = get_tree().get_first_node_in_group("save_manager")
			if save_manager == null: Debug.error("Save manager not found by Play Ui")
		return save_manager
var prisoner_panels:Array[PrisonerPlayUiPanelBtn] = []

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	visibility_changed.connect(_visibility_changed)
	prisoner_info_toggle_btn.pressed.connect(_prisoner_info_toggle_btn_pressed)
	btn_legend_toggle.pressed.connect(_toggle_legend)


func generate_prisoner_ui() -> void:
	for prisoner in save_manager.active_save.current_prisoners:
		await _generate_prisoner_panel(prisoner)
		
	prioner_list.show()
	spacer.show()


func _generate_prisoner_panel(data:PrisonerData) -> void:
	if data != null and panel_btn != null:
		var new:PrisonerPlayUiPanelBtn = panel_btn.instantiate()
		prioner_list.add_child.call_deferred(new)
		if not new.is_node_ready(): await new.ready
		new.setup_panel(data)
		prisoner_panels.append(new)


func _prisoner_info_toggle_btn_pressed() -> void:
	if prioner_list.visible:
		prisoner_info_toggle_btn.text = tr("show")
		prioner_list.hide()
		spacer.hide()
		prisoner_info_toggle_btn.release_focus()
	else:
		prisoner_info_toggle_btn.text = tr("hide")
		prioner_list.show()
		spacer.show()
		prisoner_info_toggle_btn.release_focus()


func _visibility_changed() -> void:
	if visible: Signals.PlayUiDisplayed.emit()


func _exit_tree() -> void:
	queue_free.call_deferred()


func _toggle_legend() -> void:
	if legend_visible:
		legend_grid.hide()
		btn_legend_toggle.text = tr("legend_show")
		legend_visible = false
		btn_legend_toggle.release_focus()
	else:
		legend_grid.show()
		btn_legend_toggle.text = tr("legend_hide")
		legend_visible = true
		btn_legend_toggle.release_focus()