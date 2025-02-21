class_name Prisoner extends CharacterBody2D


const ACCELERATION:float = 400
const FRICTION:float = 1500

@export var display_debug:bool = false

@onready var prisoner_btn: Button = %prisoner_btn
@onready var nav_agent: NavigationAgent2D = %nav_agent
@onready var area_detector: Area2D = %area_detector
@onready var action_progress: TextureProgressBar = %action_progress
@onready var prisoner_id: Label = %prisoner_id

var data:PrisonerData = null
var selected:bool = false
var move_to:bool = false
#var target:TextureRect = null
var top_left:Vector2:
	get: return Vector2(global_position.x + prisoner_btn.position.x, global_position.y + prisoner_btn.position.y)
var bottom_right:Vector2:
	get: return Vector2(global_position.x + (prisoner_btn.size.x / 2), global_position.y + (prisoner_btn.size.y / 2))
var areas_in:Dictionary = {}
var interactible_name:StringName = ""

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
	process_mode = PROCESS_MODE_PAUSABLE
	area_detector.area_entered.connect(_area_entered)
	area_detector.area_exited.connect(_area_exited)
	Signals.PrisonerMoveTo.connect(_add_move_to_action)
	Signals.SelectPrisoner.connect(_check_selected)
	Signals.PrisonerInteract.connect(_add_interact_action)
	Signals.SelecetPrisonerByData.connect(_select_prisoner_by_data)
	prisoner_btn.pressed.connect(_select_prisoner)
	nav_agent.path_desired_distance = 1.0
	nav_agent.target_desired_distance = 32.0
	nav_agent.path_max_distance = 30.0
	action_progress.hide()


func _process(delta: float) -> void:
	if action_timer_active: action_timer -= delta


func _physics_process(delta: float) -> void:
	if not actions.is_empty() and current_action == null:
		if display_debug: Debug.log("getting new action")
		current_action = actions.pop_front()

	if current_action != null:
		if current_action is MoveToActionData:
			var direction:Vector2 = (nav_agent.get_next_path_position() - global_position).normalized()
			
			if not nav_agent.is_target_reached():
				if direction != Vector2.ZERO:
					velocity = _move_to(delta, velocity, direction, ACCELERATION)
					velocity = velocity.clamp(-data.move_speed * Vector2(1,1), data.move_speed * Vector2(1,1))
			
			else:
				velocity = _move_to(delta, velocity, direction, FRICTION)
				_complete_move_action()
				
			move_and_slide()
		elif current_action is InteractActionData and not current_action.is_active:
			_start_interact_action()


func setup_prisoner(new_data:PrisonerData) -> void:
	data = new_data
	prisoner_id.text = "P" + str(data.display_id)


func grab_prisoner_focus() -> void:
	prisoner_btn.grab_click_focus()


func _move_to(delta:float, current_velocity:Vector2, _direction:Vector2, multi:float = 1.0) -> Vector2:
	var speed:float = data.move_speed if data else 100.0
	return current_velocity.move_toward(_direction * speed, delta * multi)


func _add_move_to_action(prisoner:Prisoner, _target:Vector2) -> void:
	if prisoner == self and _target != null:
		_clear_current_action()
		var new_action:MoveToActionData = MoveToActionData.new()
		new_action.target_pos = _target
		nav_agent.target_position = new_action.target_pos
		if not nav_agent.is_target_reachable():
			nav_agent.target_position = global_position
			if display_debug: Debug.log("Navigation target unreachable.")
		else:
			actions.append(new_action)
			if display_debug: Debug.log("Action move to added to actions on prisoner %s." % self.name)


func _clear_current_action() -> void:
	nav_agent.target_position = global_position
	current_action = null
	Signals.ClearMoveToTargets.emit(self)


func _select_prisoner() -> void:
	selected = MIDI_MESSAGE_TUNE_REQUEST
	Signals.SelectPrisoner.emit(self)


func _select_prisoner_by_data(_data:PrisonerData) ->void:
	if data == _data:
		prisoner_btn.set_pressed_no_signal(true)
		_select_prisoner()


func _check_selected(_prisoner:Prisoner) -> void:
	if _prisoner != self:
		prisoner_btn.set_pressed_no_signal(false)
		selected = false


func _add_interact_action(_action:String, interactible:Interactible) -> void:
	if selected:
		_clear_current_action()
		if global_position.distance_squared_to(interactible.global_position) > 150:
			_add_move_to_action(self, interactible.global_position)
			
		var interact_action:InteractActionData = InteractActionData.new()
		interact_action.action = _action
		interact_action.interactible = interactible
		actions.append(interact_action)
		if display_debug: Debug.log("Action %s added to actions on prisoner %s." % [_action, self.name])


func _complete_move_action() -> void:
	if current_action is MoveToActionData:
		current_action = null
		Signals.PrisonerReachedTarget.emit(self)


func _start_interact_action() -> void:
	if current_action is InteractActionData:
		current_action.is_active = true
		interactible_name = current_action.interactible.name
		var int_data:InteractibleData = current_action.interactible.data
		if int_data.base_interact_time > 0.0:
			max_time = int_data.base_interact_time
			action_timer = int_data.base_interact_time
			action_timer_active = true
		else:
			_finish_interaction()
		

func _area_entered(area:Area2D) -> void:
	if display_debug: Debug.log("Entered area: ", area.name)
	if area is Interactible: areas_in[area.name] = area.data


func _area_exited(area:Area2D) -> void:
	if areas_in.has(area.data): areas_in[area.data] = null


func _finish_interaction() -> void:
	if current_action is InteractActionData:
		if areas_in.has(interactible_name) and areas_in[interactible_name]:
			var int_data:InteractibleData = current_action.interactible.data
			var result:Dictionary = int_data.attempt_to_interact(current_action.action)
			if result.has("result"):
				var loot = result["loot"]  if result.has("loot") and not result["loot"].is_empty() else []
				match current_action.action:
					"pickup":
						if result["result"]:
							if data != null: data.add_items_to_intentory(loot)
							Signals.DisplayPopup.emit(PopupManager.Type.SMALL, "pickup_loot", PopupManager.Severity.NORMAL, "", "Items picked up", 3)
							Signals.InteractibleStateUpdate.emit(int_data, Interactible.State.DEPLETED)
					"search":
						if result["result"]:
							# TODO: display list of items and allow choosing which to take
							Signals.DisplayPopup.emit(PopupManager.Type.SMALL, "searched_loot", PopupManager.Severity.NORMAL, "", "Missing popup to show selection of items.", 3)
					_:
						if result["result"] and result.has("state"):
							Signals.InteractibleStateUpdate.emit(int_data, result["state"])
						else:
							Signals.DisplayPopup.emit(PopupManager.Type.SMALL, "seal_thing", PopupManager.Severity.NORMAL, "", "Unable to complete action.", 3)

			if display_debug: Debug.log("Action complete")

		current_action.is_active = false
		current_action = null