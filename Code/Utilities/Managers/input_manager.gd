class_name InputManager extends Node2D


var data_manager:DataManager
var target_count:int = 0
var active_prisoner:Prisoner = null
var active_interactible:Interactible = null


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_right"):
		Signals.MouseRightPressed.emit()

	if event.is_action_pressed("mouse_left") and _check_can_click(event):
		if active_prisoner != null:
			_set_prisoner_move_target(event)


func _ready() -> void:
	Signals.SelectPrisoner.connect(_set_active_prisoner)
	data_manager = get_tree().get_first_node_in_group("data_manager")
	if data_manager == null: push_error("Data Manager missing.")


func _set_prisoner_move_target(event:InputEvent) -> void:
	var pos:Vector2 = event.position
	if data_manager:
		var target_icon = data_manager.prisoner_target_move_scene.instantiate()
		add_child(target_icon)
		target_icon.global_position = pos
		target_icon.name = "target_" + str(target_count)
		target_count += 1
		Signals.PrisonerMoveTo.emit(active_prisoner, target_icon)


func _display_context_menu() -> void:
	Debug.log("Trying to display context")
	Signals.DisplayContextPopup.emit(active_interactible)


func _set_active_prisoner(_prisoner:Prisoner) -> void:
	active_prisoner = _prisoner


func _check_can_click(event:InputEvent) -> bool:
	var result:bool = true
	if event is InputEventMouse:
		var elements = get_tree().get_nodes_in_group("element")
		for each in elements:
			if each.get("top_left") != null and each.get("bottom_right") != null:
				if event.position.x >= each.top_left.x and event.position.y >= each.top_left.y and event.position.x <= each.bottom_right.x and event.position.x <= each.bottom_right.x:
					result = false
	return result