class_name PopupManager extends Control


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
var context_popup:ContextPopup = null
var data_manager:DataManager = null


func _ready() -> void:
	Signals.DisplayPopup.connect(_display_popup)
	Signals.DisplayContextPopup.connect(_display_context_popup)
	var break_count:int = 0
	while data_manager == null:
		data_manager = get_tree().get_first_node_in_group("data_manager")
		break_count += 1
		if break_count == 100: break


func _display_popup(_type:PopupManager.Type, _id:String, _severity:PopupManager.Severity, _title:String, _text:String, _timer:int) -> void:
	match _type:
		Type.LARGE:
			_display_large_popup(_id, _severity, _timer, _title, _text)
		Type.SMALL:
			_display_small_popup(_timer, _text)
		_:
			pass


func _display_large_popup(_id:String, _severity:PopupManager.Severity = PopupManager.Severity.NORMAL , _timer:int = 0, _title:String = "", _text:String = "") -> void:
	if large_popup == null and data_manager != null:
		large_popup = data_manager.large_popup.instantiate()
		add_child.call_deferred(large_popup)
		if not large_popup.is_node_ready(): await large_popup.ready
	
	if large_popup != null: large_popup.display_popup(_id, _severity, _timer, _title, _text)
	else: Debug.error("Large Popup null")


func _display_small_popup(_timer:int, _text:String) -> void:
	if small_popup == null and data_manager != null:
		small_popup = data_manager.small_popup.instantiate()
		add_child.call_deferred(small_popup)
		if not small_popup.is_node_ready(): await small_popup.ready
	
	if small_popup != null: small_popup.display_popup(_timer, _text)
	else: Debug.error("Small Popup null")


func _display_context_popup(_id:String, _options:Dictionary, _pos:Vector2) -> void:
	if context_popup == null and data_manager != null:
		context_popup = data_manager.context_popup.instantiate()
		add_child.call_deferred(context_popup)
		if not context_popup.is_node_ready(): await context_popup.ready

	if context_popup != null: context_popup.display_popup(_id, _options, data_manager, _pos)
	else: Debug.error("Context Popup null")