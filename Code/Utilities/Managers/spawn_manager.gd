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
var prisoners:Array[Prisoner] = []
var ucs:Array[UnknownContact] = []


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	Signals.SpawnPrisoners.connect(_spawn_prisoner)
	Signals.SpawnUnknownContacts.connect(_spawn_unknown_contacts)
	Signals.SendQueueFreeOfPlayManagers.connect(queue_free)
	Signals.SpawnProjectile.connect(_spawn_projectile)
	Signals.PrisonerDeath.connect(_remove_prisoner)
	Signals.UnknownContactDeath.connect(_remove_unknown_contact)


func _spawn_prisoner() -> void:
	#Debug.log(save_manager.active_save.current_prisoners)
	to_spawn_count = save_manager.active_save.current_prisoners.size()
	current_count = 0
	for each in save_manager.active_save.current_prisoners:
		_spawn_a_prisoner(each)


func _spawn_a_prisoner(prisoner_data:PrisonerData) -> void:
	if prisoner_data != null and not prisoner_data.current_health_status in [PrisonerData.Health_Status.CRYO, PrisonerData.Health_Status.DEAD]:
		var prisoner:Prisoner = data_manager.prisoner_scene.instantiate()
		active_level.add_child.call_deferred(prisoner)
		if not prisoner.is_node_ready(): await prisoner.ready
		prisoner_data.display_id = current_count + 1
		prisoner.setup_prisoner(prisoner_data)
		prisoner.global_position = Vector2(randi_range(100,200), randi_range(100,200))
		prisoner.name = prisoner_data.id
		prisoners.append(prisoner)

	current_count += 1
	if current_count >= to_spawn_count:
		Signals.AllPrisonersSpawned.emit()


func _spawn_unknown_contacts() -> void:
	var spawn_points:Array = get_tree().get_nodes_in_group("enemy_spawn_tag")
	var spawn_count:int = 0
	for contact in spawn_points:
		var data:UnknownContactData = UnknownContactData.new()
		data.setup_data()
		var enemy:UnknownContact = data_manager.unknown_contact_scene.instantiate()
		active_level.add_child(enemy)
		if not enemy.is_node_ready(): await enemy.ready
		enemy.setup_uc(data, contact.global_position, spawn_count)
		ucs.append(enemy)
		spawn_count += 1
		if spawn_count >= spawn_points.size()-1:
			Signals.AllUnknownContactsSpawned.emit()


func _spawn_projectile(origin_pos:Vector2, target_pos:Vector2) -> void:
	var proj:Projectile = data_manager.projectile.instantiate()
	add_child.call_deferred(proj)
	if not proj.is_node_ready(): await proj.ready
	proj.global_position = origin_pos
	proj.setup_projectile(target_pos)


func _remove_prisoner(data:PrisonerData) -> void:
	var prisoner:Prisoner
	for each in prisoners:
		if each != null and each.data == data:
			prisoner = each
			break

	if prisoner != null: 
		prisoners.remove_at(prisoners.find(prisoner))
		active_level.remove_child.call_deferred(prisoner)


func _remove_unknown_contact(data:UnknownContactData) -> void:
	var uc:UnknownContact
	for each in ucs:
		if each != null and each.data == data:
			uc = each
			break

	if uc != null: 
		ucs.remove_at(ucs.find(uc))
		active_level.remove_child.call_deferred(uc)