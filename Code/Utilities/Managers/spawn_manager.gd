class_name SpawnManager extends Node2D


var data_manager:DataManager:
	get:
		if data_manager == null: data_manager = get_tree().get_first_node_in_group("data_manager")
		return data_manager
var active_level:PlayLevel:
	get:
		if active_level == null: active_level = get_tree().get_first_node_in_group("play_level")
		return active_level
var save_manager:SaveManager:
	get:
		if save_manager == null: save_manager = get_tree().get_first_node_in_group("save_manager")
		return save_manager
var game_manager:GameManager:
	get:
		if game_manager == null: game_manager = get_tree().get_first_node_in_group("game_manager")
		return game_manager
var to_spawn_count:int = -1
var current_count:int = 0


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	Signals.SpawnPrisoners.connect(_spawn_prisoner)
	Signals.SpawnUnknownContacts.connect(_spawn_unknown_contacts)
	Signals.SendQueueFreeOfPlayManagers.connect(queue_free)


func _spawn_prisoner() -> void:
	#Debug.log(save_manager.active_save.current_prisoners)
	to_spawn_count = save_manager.active_save.current_prisoners.size()
	current_count = 0
	for each in save_manager.active_save.current_prisoners:
		_spawn_a_prisoner(each)


func _spawn_a_prisoner(prisoner_data:PrisonerData) -> void:
	#Debug.log(prisoner_data)
	if prisoner_data != null:
		var new:Prisoner = data_manager.prisoner_scene.instantiate()
		active_level.add_child.call_deferred(new)
		if not new.is_node_ready(): await new.ready
		prisoner_data.display_id = current_count + 1
		new.setup_prisoner(prisoner_data)
		new.global_position = Vector2(randi_range(100,200), randi_range(100,200))
		new.name = prisoner_data.id
		current_count += 1
		if current_count >= to_spawn_count:
			Signals.AllPrisonersSpawned.emit()
			
		#Debug.log("Prisoner %s spawned" % prisoner_data.display_name)


func _spawn_unknown_contacts() -> void:
	var ucs:Array = get_tree().get_nodes_in_group("enemy_spawn_tag")
	var spawn_count:int = 0
	for contact in ucs:
		var data:UnknownContactData = UnknownContactData.new()
		data.setup_data()
		var new_enemy:UnknownContact = data_manager.unknown_contact_scene.instantiate()
		active_level.add_child(new_enemy)
		if not new_enemy.is_node_ready(): await new_enemy.ready
		new_enemy.setup_uc(data, contact.global_position, spawn_count)
		spawn_count += 1
		if spawn_count >= ucs.size()-1:
			Signals.AllUnknownContactsSpawned.emit()
