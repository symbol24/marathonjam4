class_name ContextPopup extends RidPopup


const X_OFFSET:float = 20.0


@onready var vbox: VBoxContainer = %vbox

var option_id:Array[String] = []


func _ready() -> void:
	Signals.ContextMenuBtnPressed.connect(_button_pressed)
	Signals.CloseContextMenu.connect(_close)
	modulate = Color.TRANSPARENT


func display_popup(_id:String = "", options:Dictionary = {}, data_manager:DataManager = null, _position:Vector2 = Vector2.ZERO) -> void:
	if data_manager != null:
		for key in options.keys():
			var new_btn:ContextMenuButton = data_manager.context_button.instantiate()
			vbox.add_child.call_deferred(new_btn)
			if not new_btn.is_node_ready(): await new_btn.ready
			new_btn.set_button(key, options[key])
			option_id.append(key)
		id = _id

	var x:float = _position.x + X_OFFSET if _position.x < ProjectSettings.get_setting("display/window/size/viewport_width") - 200 else _position.x - size.x - X_OFFSET
	var y:float = _position.y if _position.y < ProjectSettings.get_setting("display/window/size/viewport_height") - 200 else _position.y - size.y
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
