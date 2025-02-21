class_name InputManager extends Node2D


var data_manager:DataManager:
	get:
		if data_manager == null:
			data_manager = get_tree().get_first_node_in_group("data_manager")
			if data_manager == null: 
				push_error("Data Manager is missing!")
				return null
			else: return data_manager
		else: return data_manager
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
	process_mode = PROCESS_MODE_ALWAYS
	Signals.SelectPrisoner.connect(_set_active_prisoner)
	data_manager = get_tree().get_first_node_in_group("data_manager")
	if data_manager == null: push_error("Data Manager missing.")


func _set_prisoner_move_target(event:InputEvent) -> void:
	var pos:Vector2 = event.position
	if data_manager:
		var target_icon = data_manager.prisoner_target_move_scene.instantiate()
		add_child(target_icon)
		pos = pos - (target_icon.texture.get_size()/2)
		target_icon.global_position = pos
		target_icon.name = "target_" + str(target_count)
		target_count += 1
		Signals.PrisonerMoveTo.emit(active_prisoner, target_icon.global_position)


func _display_context_menu() -> void:
	Debug.log("Trying to display context")
	Signals.DisplayContextPopup.emit(active_interactible)


func _set_active_prisoner(_prisoner:Prisoner) -> void:
	active_prisoner = _prisoner


func _check_can_click(event:InputEvent) -> bool:
	var result:bool = true
	if event is InputEventMouse:
		var elements = get_tree().get_nodes_in_group("element")
		var mouse_pos:Vector2 = get_local_mouse_position()
		for each in elements:
			if each.get("top_left") != null and each.get("bottom_right") != null:
				if mouse_pos.x >= each.top_left.x and mouse_pos.y >= each.top_left.y and mouse_pos.x <= each.bottom_right.x and mouse_pos.x <= each.bottom_right.x:
					result = false
	return result