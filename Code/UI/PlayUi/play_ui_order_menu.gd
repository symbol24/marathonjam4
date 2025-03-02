class_name PlayUiOrderPopupMenu extends PanelContainer


@onready var button_list_vbox: VBoxContainer = %button_list_vbox

var interactible:Interactible
var data_manager:DataManager


func _ready() -> void:
	Signals.ContextMenuBtnPressed.connect(_receive_context_btn_choice)
	Signals.CloseContextMenu.connect(_close)


func build_order_popup(_interactible:Interactible) -> void:
	interactible = _interactible
	if interactible:
		_clear_items()
		for key in interactible.data.options.keys():
			var new_button = data_manager.context_button.instantiate()
			button_list_vbox.add_child(new_button)
			if not new_button.is_node_ready(): await new_button.ready
			new_button.id = key
			new_button.text = tr(key)
		show()


func _item_selected(id:int) -> void:
	Signals.ContextPopupResult.emit(interactible, id)
	hide()


func _clear_items() -> void:
	if button_list_vbox.get_child_count() > 0:
		var children = button_list_vbox.get_children()
		for child in children:
			button_list_vbox.remove_child(child)
			child.queue_free.call_deferred()
		size.y = 40


func _receive_context_btn_choice(btn_id:String) -> void:
	hide()
	Signals.ContextPopupResult.emit(interactible, btn_id)


func _close() -> void:
	hide()