class_name ContextPopup extends RidPopup


const X_OFFSET:float = 20.0


@onready var vbox: VBoxContainer = %vbox

var option_id:Array[String] = []
var top_left:Vector2:
	get: return global_position
var bottom_right:Vector2:
	get: return global_position + size


func _ready() -> void:
	Signals.ContextMenuBtnPressed.connect(_button_pressed)
	Signals.CloseContextMenu.connect(_close)
	Signals.MouseRightPressed.connect(_close)
	modulate = Color.TRANSPARENT


func display_popup(interactible:Interactible, data_manager) -> void:
	if data_manager != null:
		for key in interactible.data.options.keys():
			var new_btn:ContextMenuButton = data_manager.context_button.instantiate()
			vbox.add_child.call_deferred(new_btn)
			if not new_btn.is_node_ready(): await new_btn.ready
			new_btn.set_button(key, interactible.data.options[key])
			option_id.append(key)
		id = interactible.name

	var x:float = interactible.global_position.x + X_OFFSET if interactible.global_position.x < ProjectSettings.get_setting("display/window/size/viewport_width") - 200 else interactible.global_position.x - size.x - X_OFFSET
	var y:float = interactible.global_position.y if interactible.global_position.y < ProjectSettings.get_setting("display/window/size/viewport_height") - 200 else interactible.global_position.y - size.y
	var pos:Vector2 = Vector2(x, y)

	global_position = pos
	var tween:Tween = create_tween()
	tween.finished.connect(show)
	tween.tween_property(self, "modulate", Color.WHITE, FADETIME)
	Signals.ContextPopupToggled.emit(id, true)


func _clear_context_menu() -> void:
	option_id.clear()
	var children:Array[Node] = vbox.get_children()
	if not children.is_empty():
		for child in children:
			vbox.remove_child.call_deferred(child)
			if child.is_inside_tree(): await child.tree_exited
			child.queue_free.call_deferred()


func _button_pressed(_id:String) -> void:
	if option_id.has(_id):
		_close()


func _close() -> void:
	var tween:Tween = create_tween()
	tween.finished.connect(hide)
	tween.finished.connect(_clear_context_menu)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, FADETIME)
	Signals.ContextPopupToggled.emit(id, false)
