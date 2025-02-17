class_name ScenesToLoadData extends Resource


@export var scenes_to_load:Array[SceneData]
@export var scenes_dict:Dictionary = {}

var scenes:Dictionary = {}


func get_scene_by_name(scene_name:String = "") -> String:
	if scenes_dict.is_empty():
		Debug.warning("Scenes dictionnary is empty.")
		return ""

	if scenes_dict.has(scene_name): return scenes_dict[scene_name]
	
	Debug.warning("Scene not found with name %s." % scene_name)
	return ""


func setup_dict_for_scenes() -> void:
	for scene in scenes_to_load:
		if not scenes.has(scene.id):
			scenes[scene.id] = scene