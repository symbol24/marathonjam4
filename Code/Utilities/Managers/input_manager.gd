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
var mouse_over_element:ElementControl = null
var active_interactible:Interactible = null
var menu_displayed:bool = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_right"):
		if active_prisoner:
			if mouse_over_element:
				if mouse_over_element.can_click:
					_check_element(mouse_over_element)
			else:
				_set_prisoner_move_target(event)


	#if event.is_action_pressed("mouse_left"):
	#	Signals.MouseRightPressed.emit()
	#	if active_prisoner != null: active_prisoner.grab_prisoner_focus()


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	Signals.ContextPopupToggled.connect(_toggle_menu_displayed)
	Signals.SelectPrisoner.connect(_set_active_prisoner)
	Signals.MouseEnteredElement.connect(_mouse_over_element)
	Signals.MouseExitedElement.connect(_mouse_out_of_element)
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



func _set_active_prisoner(_prisoner:Prisoner) -> void:
	active_prisoner = _prisoner


func _toggle_menu_displayed(_id:String, displayed:bool) -> void:
	menu_displayed = displayed


func _mouse_over_element(element:ElementControl) -> void:
	mouse_over_element = element


func _mouse_out_of_element() -> void:
	mouse_over_element = null


func _check_element(element:ElementControl) -> void:
	if element.parent is Interactible:
		#Debug.log("Interactible Type ", Interactible.Type.keys()[element.parent.data.type])
		active_interactible = element.parent
		Signals.DisplayContextPopup.emit(active_interactible)