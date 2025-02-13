class_name Prisoner extends CharacterBody2D


const ACCELERATION:float = 400
const FRICTION:float = 1500


@onready var prisoner_btn: TextureButton = %prisoner_btn
@onready var nav_agent: NavigationAgent2D = %nav_agent
@onready var area_detector: Area2D = %area_detector
@onready var action_progress: TextureProgressBar = %action_progress

var data:PrisonerData = null
var selected:bool = false
var move_to:bool = false
#var target:TextureRect = null
var top_left:Vector2:
	get: return Vector2(global_position.x + prisoner_btn.position.x, global_position.y + prisoner_btn.position.y)
var bottom_right:Vector2:
	get: return Vector2(global_position.x + (prisoner_btn.size.x / 2), global_position.y + (prisoner_btn.size.y / 2))
var area_in_id:StringName = ""

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


func _ready() -> void:
	area_detector.area_entered.connect(_area_entered)
	area_detector.area_exited.connect(_area_exited)
	Signals.PrisonerMoveTo.connect(_add_move_to_action)
	Signals.SelectPrisoner.connect(_check_selected)
	Signals.PrisonerInteract.connect(_add_interact_action)
	prisoner_btn.pressed.connect(_select_prisoner)
	nav_agent.path_desired_distance = 1.0
	nav_agent.target_desired_distance = 1.0
	nav_agent.path_max_distance = 1.0
	action_progress.hide()


func _process(delta: float) -> void:
	if action_timer_active: action_timer -= delta


func _physics_process(delta: float) -> void:
	if not actions.is_empty() and current_action == null:
		Debug.log("getting new action")
		current_action = actions.pop_front()

	if current_action != null:
		if current_action is MoveToActionData:
			var direction:Vector2 = (nav_agent.get_next_path_position() - global_position).normalized()
			
			if not nav_agent.is_target_reached():
				if direction != Vector2.ZERO:
					velocity = _move_to(delta, velocity, direction, ACCELERATION)
			
			else:
				velocity = _move_to(delta, velocity, direction, FRICTION)
				_complete_move_action()
				
			move_and_slide()
		elif current_action is InteractActionData and not current_action.is_active:
			_start_interact_action()


func _move_to(delta:float, current_velocity:Vector2, _direction:Vector2, multi:float = 1.0) -> Vector2:
	var speed:float = data.move_speed if data else 100.0
	return current_velocity.move_toward(_direction * speed, delta * multi)


func _add_move_to_action(prisoner:Prisoner, _target:Vector2) -> void:
	if prisoner == self and _target != null:
		var new_action:MoveToActionData = MoveToActionData.new()
		new_action.target_pos = _target
		nav_agent.target_position = new_action.target_pos
		if not nav_agent.is_target_reachable():
			nav_agent.target_position = global_position
			Debug.log("Navigation target unreachable.")
		else:
			actions.append(new_action)
			Debug.log("Action move to added to actions on prisoner %s." % self.name)


func _select_prisoner() -> void:
	selected = true
	Signals.SelectPrisoner.emit(self)


func _check_selected(_prisoner:Prisoner) -> void:
	if _prisoner != self:
		prisoner_btn.set_pressed_no_signal(false)
		selected = false


func _add_interact_action(_action:String, interactible:Interactible) -> void:
	if selected:
		if global_position.distance_squared_to(interactible.global_position) > 150:
			_add_move_to_action(self, interactible.global_position)
			
		var interact_action:InteractActionData = InteractActionData.new()
		interact_action.action = _action
		interact_action.interactible = interactible
		actions.append(interact_action)
		Debug.log("Action %s added to actions on prisoner %s." % [_action, self.name])


func _complete_move_action() -> void:
	if current_action is MoveToActionData:
		current_action = null
		Signals.PrisonerReachedTarget.emit(self)


func _start_interact_action() -> void:
	if current_action is InteractActionData:
		Debug.log("Interact action started")
		current_action.is_active = true
		var int_data:InteractibleData = current_action.interactible.data
		if int_data.base_interact_time > 0.0:
			max_time = int_data.base_interact_time
			action_timer = int_data.base_interact_time
			action_timer_active = true
		else:
			_finish_interaction()
		

func _area_entered(area:Area2D) -> void:
	Debug.log("Entered area: ", area.name)
	area_in_id = area.name


func _area_exited(area:Area2D) -> void:
	if area.name == area_in_id: area_in_id = ""


func _finish_interaction() -> void:
	if current_action is InteractActionData:
		var int_data:InteractibleData = current_action.interactible.data
		var result:Dictionary
		match current_action.action:
			"pickup":
				result = int_data.attempt_to_pick_up()
				if result.has("result") and result["result"]:
					if result.has("loot") and not result["loot"].is_empty():
						data.add_items_to_intentory(result["loot"])
						Signals.DisplayPopup.emit(PopupManager.Type.SMALL, "pickup_loot", PopupManager.Severity.NORMAL, "", "Items picked up", 3)
					else:
						Signals.DisplayPopup.emit(PopupManager.Type.SMALL, "pickup_loot", PopupManager.Severity.NORMAL, "", "Nothing picked up", 3)
					Signals.InteractibleStateUpdate.emit(int_data, Interactible.State.DEPLETED)
			"search":
				result = int_data.attempt_to_search()
				if result.has("result") and result["result"]:
					if result.has("loot") and not result["loot"].is_empty():
						# TODO: display list of items and allow choosing which to take
						Signals.DisplayPopup.emit(PopupManager.Type.SMALL, "searched_loot", PopupManager.Severity.NORMAL, "", "Items picked up", 3)
					else:
						Signals.DisplayPopup.emit(PopupManager.Type.SMALL, "searched_loot", PopupManager.Severity.NORMAL, "", "Nothing to find", 3)
					Signals.InteractibleStateUpdate.emit(int_data, Interactible.State.DEPLETED)
			_:
				result = int_data.attempt_to_on_open(current_action.action)
				if result.has("result") and result["result"] and result.has("state"):
					Signals.InteractibleStateUpdate.emit(int_data, result["state"])
				else:
					Signals.DisplayPopup.emit(PopupManager.Type.SMALL, "seal_thing", PopupManager.Severity.NORMAL, "", "Unable to complete action.", 3)


		Debug.log("Action complete")

		current_action.is_active = false
		current_action = null