class_name ScenesToLoadData extends Resource


@export var scenes_to_load:Array[SceneData]

var scenes:Dictionary = {}


func get_scene_by_name(scene_name:String = "") -> SceneData:
	if scenes.is_empty():
		push_warning("Scenes dictionnary is empty.")
		return null

	if scenes.has(scene_name): return scenes[scene_name]
	
	push_warning("Scene not found with name %s." % scene_name)
	return null


func setup_dict_for_scenes() -> void:
	for scene in scenes_to_load:
		if not scenes.has(scene.id):
			scenes[scene.id] = scene