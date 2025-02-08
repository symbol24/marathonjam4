class_name ManagerLoader extends RidManager


const DATAMANAGER:String = "res://Scenes/utilities/Managers/data_manager.tscn"
const SCENEMANAGER:String = "res://Scenes/utilities/Managers/scene_manager.tscn"
const SAVEMANAGER:String = "res://Scenes/utilities/Managers/save_manager.tscn"
const INPUTMANAGER:String = "res://Scenes/utilities/Managers/input_manager.tscn"
const SPAWNMANAGER:String = "res://Scenes/utilities/Managers/spawn_manager.tscn"
const GAMEMANAGER:String = "res://Scenes/utilities/Managers/game_manager.tscn"
const UIMANAGER:String = "res://Scenes/utilities/Managers/ui_manager.tscn"


var progress:Array = []
var to_load:String
var manager_name:String = ""
var load_status = 0
var loading:bool = false


func _ready() -> void:
	Signals.LoadManager.connect(_load_manager)


func _process(_delta: float) -> void:
	if loading:
		load_status = ResourceLoader.load_threaded_get_status(to_load, progress)
		if load_status == ResourceLoader.THREAD_LOAD_LOADED:
			_complete_load()


func _load_manager(_manager_name:String) -> void:
	manager_name = _manager_name
	to_load = ""
	match manager_name:
		"data_manager":
			to_load = DATAMANAGER
		"save_manager":
			to_load = SAVEMANAGER
		"scene_manager":
			to_load = SCENEMANAGER
		"input_manager":
			to_load = INPUTMANAGER
		"spawn_manager":
			to_load = SPAWNMANAGER
		"game_manager":
			to_load = GAMEMANAGER
		"ui_manager":
			to_load = UIMANAGER
		_:
			pass
	
	if to_load == "":
		push_warning("No Manager to load.")
		return

	loading = true
	ResourceLoader.load_threaded_request(to_load)


func _complete_load() -> void:
	var to_insta = ResourceLoader.load_threaded_get(to_load)
	var new_manager = to_insta.instantiate()
	add_child(new_manager)
	if not new_manager.is_node_ready(): await new_manager.ready
	loading = false
	Signals.ManagerLoaded.emit(manager_name)
