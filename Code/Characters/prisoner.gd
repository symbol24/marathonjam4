class_name Prisoner extends CharacterBody2D


const ACCELERATION:float = 400
const FRICTION:float = 1500
const FLASH_TIME:float = 0.3

@export var display_debug:bool = false

@onready var prisoner_btn: Button = %prisoner_btn
@onready var nav_agent: NavigationAgent2D = %nav_agent
@onready var area_detector: Area2D = %area_detector
@onready var action_progress: TextureProgressBar = %action_progress
@onready var prisoner_id: Label = %prisoner_id
@onready var flash_panel: Panel = %flash_panel

var data:PrisonerData = null
var selected:bool = false
var move_to:bool = false
var areas_in:Dictionary = {}
var interactible_name:StringName = ""
var is_alive:bool:
	get:
		if data == null: return true
		return data.current_status != PrisonerData.Health_Status.DEAD or data.current_status != PrisonerData.Health_Status.CRYO

# Actions 
var actions:Array[PrisonerActionData] = []
var current_action:PrisonerActionData = null
var action_timer_active:bool = false
var max_time:float = 1.0
var action_timer:float = 0.0:
	set(value):
		action_timer = value
		if action_timer > 0.0 and not action_progress.visible: action_progress.show()
		
		if action_timer <= 0.0:
			action_timer_active = false
			action_progress.hide()
			_finish_interaction()

		action_progress.value = (action_timer / max_time) * 100

# Combat
var target_by:Array[UnknownContact] = []
var attack_time:bool = false
var attack_timer:float = 0.01:
	set(value):
		attack_timer = value
		if attack_timer <= 0.0:
			_perform_one_attack()
			attack_timer = data.active_weapon.time_between_attacks
var attack_count:int = 0
var attack_delay_time:bool = false
var delay_timer:float = 1.0:
	set(value):
		delay_timer = value
		if delay_timer <= 0.01:
			_attack()
			delay_timer = data.active_weapon.delay_before_next_attack


func _ready() -> void:
	process_mode = PROCESS_MODE_PAUSABLE
	area_detector.area_entered.connect(_area_entered)
	area_detector.area_exited.connect(_area_exited)
	#Signals.PrisonerMoveTo.connect(add_move_to_action)
	Signals.SelectPrisoner.connect(_check_selected)
	Signals.PrisonerInteract.connect(_add_interact_action)
	Signals.SelecetPrisonerByData.connect(_select_prisoner_by_data)
	prisoner_btn.pressed.connect(_select_prisoner)
	nav_agent.path_desired_distance = 1.0
	nav_agent.target_desired_distance = 1.0
	nav_agent.path_max_distance = 30.0
	action_progress.hide()


func _process(delta: float) -> void:
	if is_alive:
		if current_action is InteractActionData and current_action.is_active and current_action.interactible.data.base_interact_time > 0.0: action_timer -= delta
		if current_action is AttackActionData and current_action.is_active:
			if attack_time: attack_timer -= delta
			if attack_delay_time: delay_timer -= delta



func _physics_process(delta: float) -> void:
	if is_alive:
		if actions.is_empty() and current_action == null:
			if data.current_action_state != PrisonerData.Action_State.IDLE: data.current_action_state = PrisonerData.Action_State.IDLE

		if not actions.is_empty() and current_action == null:
			if display_debug: Debug.log("Actions: ", actions)
			current_action = actions.pop_front()
			if display_debug: Debug.log("Getting new action ", current_action.id)

		if current_action != null:
			if current_action is MoveToActionData:
				if data.current_action_state != PrisonerData.Action_State.MOVING: data.current_action_state = PrisonerData.Action_State.MOVING
				if nav_agent.target_position != current_action.target_pos: _set_nav_agent_target_pos()
				var direction:Vector2 = (nav_agent.get_next_path_position() - global_position).normalized()
				
				if display_debug and current_action.move_type == MoveToActionData.Move_Type.TO_ATTACK:
					Debug.log("Attack distance: ", current_action.target_distance)
					Debug.log("Distance to target: ", global_position.distance_squared_to(current_action.target_pos))

				if not nav_agent.is_target_reached() and not global_position.distance_squared_to(current_action.target_pos) <= current_action.target_distance:
					if direction != Vector2.ZERO:
						velocity = _move_to(delta, velocity, direction, ACCELERATION)
						velocity = velocity.clamp(-data.move_speed * Vector2(1,1), data.move_speed * Vector2(1,1))
				
				else:
					direction = Vector2.ZERO
					velocity = _move_to(delta, velocity, direction, FRICTION)
					_complete_move_action()
					
				move_and_slide()
			elif current_action is InteractActionData and not current_action.is_active:
				_start_interact_action()
			
			elif current_action is AttackActionData and not current_action.is_active:
				_start_attack_action()


func setup_prisoner(new_data:PrisonerData) -> void:
	data = new_data
	prisoner_id.text = "P" + str(data.display_id)
	data.current_status = data.default_status


func grab_prisoner_focus() -> void:
	prisoner_btn.grab_click_focus()


func receive_damage(damage:Damage) -> void:
	if is_alive:
		if damage:
			var value:float = data.receive_damage(damage)
			Signals.DisplayDamageNumber.emit(value, global_position)
			if display_debug: Debug.log("%s received %s damage." % [data.display_name, value])
			_flash_for_damage()
			Signals.PrisonerHpUpdated.emit(data)
		
		if data.current_hp <= 0:
			data.current_status = PrisonerData.Health_Status.DEAD
			data.current_action_state = PrisonerData.Action_State.DEAD
			Signals.PrisonerDeath.emit(data)


func add_attack_action(target:UnknownContact) -> void:
	if target:
		var attack_action:AttackActionData = AttackActionData.new()
		attack_action.target = target
		attack_action.id = "attack"
		if global_position.distance_squared_to(target.global_position) > data.active_weapon.attack_distance:
			add_move_to_action(target.global_position,  MoveToActionData.Move_Type.TO_ATTACK, pow(data.active_weapon.attack_distance, 2))

		actions.append(attack_action)
		if display_debug: Debug.log("Attack Action added to actions on prisoner %s." % self.name)


func add_move_to_action(_target:Vector2, _type:MoveToActionData.Move_Type = MoveToActionData.Move_Type.NORMAL, _target_distance:float = -1.0) -> void:
	if is_alive and _target != null:
		_clear_current_action()
		var new_action:MoveToActionData = MoveToActionData.new()
		new_action.target_pos = _target
		new_action.target_distance = _target_distance
		new_action.id = "move_to"
		new_action.move_type = _type
		actions.append(new_action)


func _set_nav_agent_target_pos() -> void:
	nav_agent.target_position = current_action.target_pos
	if not nav_agent.is_target_reachable():
		nav_agent.target_position = global_position
		if display_debug: Debug.log("Navigation target unreachable.")
	else:
		if display_debug: Debug.log("Action move to added to actions on prisoner %s." % self.name)


func _flash_for_damage() -> void:
	if not flash_panel.is_visible():
		flash_panel.show()
		await get_tree().create_timer(FLASH_TIME).timeout
		flash_panel.hide()


func _move_to(delta:float, current_velocity:Vector2, _direction:Vector2, multi:float = 1.0) -> Vector2:
	var speed:float = data.move_speed if data else 100.0
	return current_velocity.move_toward(_direction * speed, delta * multi)


func _clear_current_action() -> void:
	nav_agent.target_position = global_position
	current_action = null
	Signals.ClearMoveToTargets.emit(self)


func _select_prisoner() -> void:
	if is_alive:
		selected = true
		Signals.SelectPrisoner.emit(self)
		Signals.CloseContextMenu.emit()


func _select_prisoner_by_data(_data:PrisonerData) ->void:
	if data == _data and is_alive:
		prisoner_btn.set_pressed_no_signal(true)
		_select_prisoner()


func _check_selected(_prisoner:Prisoner) -> void:
	if _prisoner != self:
		prisoner_btn.set_pressed_no_signal(false)
		selected = false


func _add_interact_action(_action:String, interactible:Interactible) -> void:
	if is_alive and selected:
		_clear_current_action()
		if global_position.distance_squared_to(interactible.global_position) > 150:
			add_move_to_action(interactible.global_position,  MoveToActionData.Move_Type.TO_INTERACT)
			
		var interact_action:InteractActionData = InteractActionData.new()
		interact_action.action = _action
		interact_action.interactible = interactible
		interact_action.id = "interact"
		actions.append(interact_action)
		if display_debug: Debug.log("Action %s added to actions on prisoner %s." % [_action, self.name])


func _complete_move_action() -> void:
	if current_action is MoveToActionData:
		if not actions.is_empty() and actions[0].get("in_range") != null:
			actions[0].in_range = true
		
			if display_debug: Debug.log("next action is range: ", actions[0].in_range)

		current_action = null
		Signals.PrisonerReachedTarget.emit(self)


func _start_interact_action() -> void:
	if is_alive and current_action.in_range:
		if data.current_action_state != PrisonerData.Action_State.INTERACTING: data.current_action_state = PrisonerData.Action_State.INTERACTING
		current_action.is_active = true
		interactible_name = current_action.interactible.name
		var int_data:InteractibleData = current_action.interactible.data
		if int_data.base_interact_time > 0.0:
			max_time = int_data.base_interact_time
			action_timer = int_data.base_interact_time
			action_timer_active = true
		else:
			_finish_interaction()
	else:
		current_action = null


func _start_attack_action() -> void:
	if is_alive and current_action.in_range:
		if data.current_action_state != PrisonerData.Action_State.COMBAT: data.current_action_state = PrisonerData.Action_State.COMBAT
		current_action.is_active = true
		_attack()
	else:
		current_action = null


func _attack() -> void:
	if current_action is AttackActionData and current_action.is_active:
		attack_timer = data.active_weapon.time_between_attacks
		_perform_one_attack()


func _perform_one_attack() -> void:
	current_action.target.receive_damage(data.active_weapon.get_damage())
	attack_count += 1
	if attack_count >= data.active_weapon.attack_count:
		delay_timer = data.active_weapon.delay_before_next_attack
		attack_delay_time = true
		attack_time = false
	else:
		attack_delay_time = false
		attack_time = true


func _area_entered(area:Area2D) -> void:
	if display_debug: Debug.log("Entered area: ", area.name)
	if area is Interactible: areas_in[area.name] = area.data


func _area_exited(area:Area2D) -> void:
	if areas_in.has(area.data): areas_in[area.data] = null


func _finish_interaction() -> void:
	if is_alive and current_action is InteractActionData:
		if areas_in.has(interactible_name) and areas_in[interactible_name]:
			var int_data:InteractibleData = current_action.interactible.data
			var result:Dictionary = int_data.attempt_to_interact(current_action.action)
			if result.has("result"):
				var loot = result["loot"]  if result.has("loot") and not result["loot"].is_empty() else []
				match current_action.action:
					"pickup":
						if result["result"]:
							if data != null: data.add_items_to_intentory(loot)
							Signals.DisplayPopup.emit(RidPopupManager.Type.SMALL, "pickup_loot", RidPopupManager.Severity.NORMAL, "", "Items picked up", 3)
							Signals.InteractibleStateUpdate.emit(int_data, Interactible.State.DEPLETED)
					"search":
						if result["result"]:
							# TODO: display list of items and allow choosing which to take
							Signals.DisplayPopup.emit(RidPopupManager.Type.SMALL, "searched_loot", RidPopupManager.Severity.NORMAL, "", "Missing popup to show selection of items.", 3)
					_:
						if result["result"] and result.has("state"):
							Signals.InteractibleStateUpdate.emit(int_data, result["state"])
						else:
							Signals.DisplayPopup.emit(RidPopupManager.Type.SMALL, "seal_thing", RidPopupManager.Severity.NORMAL, "", "Unable to complete action.", 3)

			if display_debug: Debug.log("Action complete")

	current_action.is_active = false
	current_action = null
