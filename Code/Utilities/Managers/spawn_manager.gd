class_name SpawnManager extends Node2D


var data_manager:DataManager
var active_level:PlayLevel
var game_manager:GameManager
var save_manager:SaveManager
var to_spawn_count:int = -1
var current_count:int = 0


func _ready() -> void:
	Signals.SpawnPrisoners.connect(_spawn_prisoner)
	data_manager = get_tree().get_first_node_in_group("data_manager")
	if data_manager == null: push_error("Data Manager is missing!")
	active_level = get_tree().get_first_node_in_group("play_level")
	if active_level == null: push_error("Play Level is missing!")
	game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager == null: push_error("Game_manager is missing!")
	save_manager = get_tree().get_first_node_in_group("save_manager")
	if save_manager == null: push_error("save_manager is missing!")


func _spawn_prisoner() -> void:
	to_spawn_count = save_manager.active_save.current_prisoners.size()
	current_count = 0
	for each in save_manager.active_save.current_prisoners:
		_spawn_a_prisoner(each)


func _spawn_a_prisoner(prisoner_data:PrisonerData) -> void:
	if prisoner_data != null:
		var new:Prisoner = data_manager.prisoner_scene.instantiate()
		active_level.add_child.call_deferred(new)
		if not new.is_node_ready(): await new.ready
		new.global_position = Vector2(randi_range(100,200), randi_range(100,200))
		new.name = "prisoner_" + prisoner_data.id
		current_count += 1
		if current_count >= to_spawn_count:
			Signals.AllPrisonersSpawned.emit()
		Debug.log("Prisoner %s spawned" % prisoner_data.display_name)
