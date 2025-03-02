class_name RidPopupManager extends Control


enum Severity {
				NORMAL = 0,
				WARNING = 1,
				ERROR = 2,
			}

enum Type {
			LARGE = 0,
			SMALL = 1,
			CONTEXT = 2,
		}

var large_popup:LargePopup = null
var small_popup:SmallPopup = null
var context_popup:PlayUiOrderPopupMenu = null
var data_manager:DataManager:
	get:
		if data_manager == null:
			data_manager = get_tree().get_first_node_in_group("data_manager")
			if data_manager == null: 
				push_error("Data Manager is missing!")
				return null
			else: return data_manager
		else: return data_manager
var input_manager:InputManager:
	get:
		if input_manager == null: input_manager = get_tree().get_first_node_in_group("input_manager")
		if input_manager == null: Debug.log("Popup Manager is unable to get input manager.")
		return input_manager


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	Signals.DisplayPopup.connect(_display_popup)
	Signals.DisplayContextPopup.connect(_display_context_popup)
	var break_count:int = 0
	while data_manager == null:
		data_manager = get_tree().get_first_node_in_group("data_manager")
		break_count += 1
		if break_count == 100: break


func _display_popup(_type:RidPopupManager.Type, _id:String, _severity:RidPopupManager.Severity, _title:String, _text:String, _timer:int) -> void:
	#Debug.log(get_parent().get_child_count()-1)
	if get_index() < get_parent().get_child_count()-1:
		get_parent().move_child(self, get_child_count()-1)
	match _type:
		Type.LARGE:
			_display_large_popup(_id, _severity, _timer, _title, _text)
		Type.SMALL:
			_display_small_popup(_timer, _text)
		_:
			pass


func _display_large_popup(_id:String, _severity:RidPopupManager.Severity = RidPopupManager.Severity.NORMAL , _timer:int = 0, _title:String = "", _text:String = "") -> void:
	if large_popup == null and data_manager != null:
		large_popup = data_manager.large_popup.instantiate()
		add_child.call_deferred(large_popup)
		if not large_popup.is_node_ready(): await large_popup.ready
		#large_popup.position = Vector2(640, 300)
	
	if large_popup != null: 
		large_popup.display_popup(_id, _severity, _timer, _title, _text)
	else: Debug.error("Large Popup null")


func _display_small_popup(_timer:int, _text:String) -> void:
	if small_popup == null and data_manager != null:
		small_popup = data_manager.small_popup.instantiate()
		add_child.call_deferred(small_popup)
		if not small_popup.is_node_ready(): await small_popup.ready
		small_popup.position = Vector2(640, 200)
	
	if small_popup != null: small_popup.display_popup(_timer, _text)
	else: Debug.error("Small Popup null")


func _display_context_popup(interactible:Interactible) -> void:
	if input_manager and input_manager.active_prisoner:
		if context_popup == null:
			context_popup = data_manager.order_menu.instantiate()
			add_child(context_popup)
			if not context_popup.is_node_ready(): await context_popup.ready
			context_popup.data_manager = data_manager
			context_popup.hide()
		
		if context_popup == null:
			return
		
		context_popup.position = get_local_mouse_position()
		context_popup.build_order_popup(interactible)
