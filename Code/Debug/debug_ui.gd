class_name DebugUi extends Control


@onready var debug_command_menu: DebugCommandMenu = %DebugCommandMenu

var can_display_cmd:bool = true


func _input(event: InputEvent) -> void:
	if can_display_cmd and event.is_action_pressed("debug"):
		if debug_command_menu.visible: debug_command_menu.hide()
		else: debug_command_menu.show()
		get_viewport().set_input_as_handled()