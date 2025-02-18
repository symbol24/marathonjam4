class_name SceneManager extends RidManager


@export var scenes_to_load:ScenesToLoadData

var active_scene:RidControl = null
var progress:Array = []
var to_load:String = ""
var scene_name:String = ""
var load_status:int = 0
var loading:bool = true


func _ready() -> void:
	Signals.LoadScene.connect(_load_scene)
	if scenes_to_load == null: push_error("Scenes to load resource is missing from Scene Manager.")
	else: scenes_to_load.setup_dict_for_scenes()


func _process(_delta: float) -> void:
	if loading:
		load_status = ResourceLoader.load_threaded_get_status(to_load)
		if not progress.is_empty(): Debug.log("Loading ", scene_name, " at ", floori(progress[0]*100))
		if load_status == ResourceLoader.THREAD_LOAD_LOADED: _complete_load()


func _load_scene(_scene_name:String = "", display_loading_screen:bool = false) -> void:
	if scenes_to_load != null:
		scene_name = _scene_name
		to_load = scenes_to_load.get_scene_by_name(scene_name)
		if to_load != "":
			loading = true
			if display_loading_screen: Signals.ToggleLoadingScreen.emit(true, "scene_load", 25)
			ResourceLoader.load_threaded_request(to_load)


func _complete_load() -> void:
	var to_insta = ResourceLoader.load_threaded_get(to_load)
	var new_scene = to_insta.instantiate()
	add_child(new_scene)
	if not new_scene.is_node_ready(): await new_scene.ready
	if active_scene != null:
		var temp = active_scene
		temp.queue_free.call_deferred()
	active_scene = new_scene
	loading = false
	Signals.SceneLoadComplete.emit(scene_name)
