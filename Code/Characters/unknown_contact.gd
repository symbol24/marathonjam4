class_name UnknownContact extends CharacterBody2D


const ACCELERATION:float = 400
const FRICTION:float = 1500
const FAR_DETECTION_TIME:float = 2.0
const MOVE_TO_DETECTION_TIME:float = 1.0
const COMBAT_DETECTION_TIME:float = 0.33


@export var display_debug:bool = false

@onready var nav_agent: NavigationAgent2D = %nav_agent
@onready var uc_id: Label = %uc_id
@onready var uc_icon: Panel = %uc_icon
@onready var uc_top_label: Label = %uc_top_label
@onready var flash_panel: Panel = %flash_panel
@onready var hp_bar: ProgressBar = %hp_bar
@onready var right_melee: Control = %right_melee
@onready var left_melee: Control = %left_melee

var data:UnknownContactData
var is_alive:bool = true
var origin_coords:Vector2
var prisoners:Array = []
var current_attack_target:Prisoner = null
var can_attack:bool = true
var detection_timer:float = 2.0:
	set(value):
		detection_timer = value
		if detection_timer <= 0.0:
			_detect()
			detection_timer = _get_detection_time()
var melee_flashing:bool = false


func _ready() -> void:
	process_mode = PROCESS_MODE_PAUSABLE
	nav_agent.path_desired_distance = 1.0
	nav_agent.target_desired_distance = 32.0
	nav_agent.path_max_distance = 30.0


func _process(delta: float) -> void:
	detection_timer -= delta


func _physics_process(_delta: float) -> void:
	if nav_agent.is_navigation_finished():
		return

	var next_position = nav_agent.get_next_path_position()
	
	var new_velocity: Vector2 = (next_position - global_position).normalized() * data.move_speed

	velocity = new_velocity
	move_and_slide()


func _exit_tree() -> void:
	queue_free.call_deferred()


func setup_uc(uc_data:UnknownContactData, pos:Vector2, id:int) -> void:
	data = uc_data
	data.setup_data()
	origin_coords = pos
	global_position = pos
	uc_id.text = "UC" + str(id)
	data.id = "UC_" + str(id) 
	name = "UC_" + str(id)
	prisoners = get_tree().get_nodes_in_group("prisoner")
	hp_bar.value = float(data.current_hp) / float(data.max_hp)


func receive_damage(damage:Damage) -> void:
	if is_alive:
		if damage:
			var value:float = data.receive_damage(damage)
			Signals.DisplayDamageNumber.emit(value, global_position)
			if display_debug: Debug.log("%s received %s damage." % [data.display_name, value])
			_flash_for_damage()
			if display_debug: Debug.log("current hp: ", data.current_hp, " max hp: ", data.max_hp)
			hp_bar.value = float(data.current_hp) / float(data.max_hp)

			if data.current_hp <= 0:
				is_alive = false
				Signals.UnknownContactDeath.emit(data)


func _flash_for_damage() -> void:
	if is_alive and not flash_panel.is_visible():
		flash_panel.show()
		if get_tree() != null: get_tree().create_timer(Prisoner.FLASH_TIME).timeout.connect(flash_panel.hide)


func _set_move_to_target(target_position:Vector2) -> void:
	nav_agent.target_position = target_position
	data.set_state(UnknownContactData.State.MOVETOTARGET)


func _move_to(delta:float, current_velocity:Vector2, _direction:Vector2, multi:float = 1.0) -> Vector2:
	var speed:float = data.move_speed if data else 100.0
	return current_velocity.move_toward(_direction * speed, delta * multi)


func _attack(target:Prisoner) -> void:
	if data.state != UnknownContactData.State.COMBAT:
		data.set_state(UnknownContactData.State.COMBAT)
		
	if can_attack and current_attack_target != null and current_attack_target.is_alive:
		if display_debug: Debug.log(name, " is perfoming its attack!")
		can_attack = false
		nav_agent.target_position = global_position
		if target != null:
			_perform_one_attack(data.active_weapon.get_damage(), data.active_weapon.attack_count, data.active_weapon.time_between_attacks)
	
	elif can_attack and current_attack_target != null and not current_attack_target.is_alive:
		_reset_state()
		

func _perform_one_attack(damage:Damage, attack_count_left:int = 0, time:float = 0.0) -> void:
	if damage and attack_count_left > 0:
		#Debug.log("%s attack # %s for %s." % [name, attack_count_left, damage.final_damage])
		current_attack_target.receive_damage(damage)
		attack_count_left -= 1
		if data.active_weapon.weapon_type == WeaponData.Weapon_Type.MELEE: _flash_melee()
		else: Signals.SpawnProjectile.emit(global_position, current_attack_target.global_position)
		await get_tree().create_timer(time).timeout
		_perform_one_attack(damage, attack_count_left, time)
	else:
		_attack_ended()


func _attack_ended() -> void:
	await get_tree().create_timer(data.active_weapon.delay_before_next_attack).timeout
	can_attack = true


func _display_react() -> void:
	if not uc_top_label.is_visible():
		#uc_top_label.text = "P"+str(current_attack_target.data.display_id)
		uc_top_label.show()
		get_tree().create_timer(0.3).timeout.connect(uc_top_label.hide)


func _reset_state() -> void:
	if data.state != UnknownContactData.State.IDLE:
		data.set_state(UnknownContactData.State.IDLE)


func _detect() -> void:
	current_attack_target = _get_closest_prisoner()
	if current_attack_target != null:
		var distance:float = global_position.distance_squared_to(current_attack_target.global_position)
		if distance > pow(data.detection_distance, 2):
			_reset_state()

		elif distance <= pow(data.detection_distance, 2) and distance > pow(data.active_weapon.attack_distance, 2):
			_set_move_to_target(current_attack_target.global_position)

		elif distance <= pow(data.active_weapon.attack_distance, 2):
			_attack(current_attack_target)


func _get_closest_prisoner() -> Prisoner:
	var closest:Prisoner = null
	var last_distance:float = -1.0
	for each in prisoners:
		if each != null and each.is_alive:
			var new_distance:float = global_position.distance_squared_to(each.global_position)
			if last_distance == -1:
				closest = each
				last_distance = new_distance
			if new_distance <= last_distance:
				closest = each
				last_distance = new_distance

	return closest


func _get_detection_time() -> float:
	match data.state:
		UnknownContactData.State.MOVETOTARGET, UnknownContactData.State.PATROL:
			return MOVE_TO_DETECTION_TIME
		UnknownContactData.State.COMBAT:
			return COMBAT_DETECTION_TIME
		_:
			return FAR_DETECTION_TIME


func _flash_melee() -> void:
	if not melee_flashing:
		melee_flashing = true
		if current_attack_target.global_position.x >= global_position.x: right_melee.show()
		else: left_melee.show()
		await get_tree().create_timer(Prisoner.FLASH_TIME).timeout
		right_melee.hide()
		left_melee.hide()
		melee_flashing = false