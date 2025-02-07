class_name InputManager extends Node2D


var data_manager:DataManager
var hover_prisoner = null
var active_prisoner = null


func _input(event: InputEvent) -> void:
	if hover_prisoner != null:
		if event.is_action_pressed("mouse_left"):
			active_prisoner = hover_prisoner

	elif hover_prisoner == null and active_prisoner!= null:
		if event.is_action_pressed("mouse_left"):
			_set_prisoner_move_target(event)


func _ready() -> void:
	Signals.MouseEnterPrisoner.connect(_mouse_enter_prisoner)
	Signals.MouseExitPrisoner.connect(_mouse_exit_prisoner)
	data_manager = get_tree().get_first_node_in_group("data_manager")
	if data_manager == null: push_error("Data Manager missing.")


func _mouse_enter_prisoner(prisoner) -> void:
	hover_prisoner = prisoner


func _mouse_exit_prisoner() -> void:
	hover_prisoner = null


func _set_prisoner_move_target(event:InputEvent) -> void:
	var pos:Vector2 = event.position
	Signals.PrisonerMoveTo.emit(active_prisoner, pos)
	if data_manager:
		var target_icon = data_manager.prisoner_target_move_scene.instantiate()
		add_child(target_icon)
		target_icon.global_position = pos
