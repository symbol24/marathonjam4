class_name DataManager extends RidManager


@export_group("Gameplay")


@export_group("Prisoners")
@export var prisoner_datas:Array[PrisonerData] = []
@export var prisoner_scene:PackedScene
@export var prisoner_target_move_scene:PackedScene

@export_group("UI")
@export var large_popup:PackedScene
@export var small_popup:PackedScene
@export var context_popup:PackedScene
@export var context_button:PackedScene
@export var play_ui:PackedScene
@export var pause_menu:PackedScene
@export var settings:PackedScene
@export var normal_font:Resource
@export var dyslexia_friendly_font:Resource
@export var default_theme:Theme
@export var save_icon:PackedScene

@export_group("Map Generation")
@export var map_generator:PackedScene
@export var map_icon:PackedScene
@export var map_line:PackedScene


func _ready() -> void:
	Signals.LoadPrisonerHeadshots.connect(load_prisoner_headshots)


func get_prisoner_duplicates() -> Array[PrisonerData]:
	var result:Array[PrisonerData] = []
	for prisoner in prisoner_datas:
		var new_data:PrisonerData = prisoner.duplicate(true)
		result.append(new_data)

	return result


func load_prisoner_headshots(prisoner_array:Array[PrisonerData]) -> void:
	var loaded_count:int = 0
	var errors:Array = []
	for prisoner in prisoner_array:
		if prisoner.headshot_normal == null:
			prisoner.headshot_normal = ResourceLoader.load(prisoner.headshot_normal_path)
		
		if prisoner.headshot_small == null:
			prisoner.headshot_small = ResourceLoader.load(prisoner.headshot_small_path)
		
		if prisoner.headshot_normal != null and prisoner.headshot_small != null:
			loaded_count += 1
		else:
			errors.append(prisoner)
	
	if not errors.is_empty():
		for each:PrisonerData in errors:
			Debug.log("%s has '%s' as normal path." % [each.display_name, each.headshot_normal_path])
			Debug.log("%s has '%s' as small path." % [each.display_name, each.headshot_small_path])

	if loaded_count == prisoner_datas.size():
		Signals.PrisonerHeadshotsLoaded.emit()