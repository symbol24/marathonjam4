class_name Prisoner extends CharacterBody2D


const ACCELERATION:float = 400
const FRICTION:float = 1500


@onready var prisoner_btn: TextureButton = %prisoner_btn
@onready var nav_agent: NavigationAgent2D = %nav_agent

var data:PrisonerData = null
var move_to:bool = false
var target:TextureRect = null
var top_left:Vector2:
	get: return Vector2(global_position.x + prisoner_btn.position.x, global_position.y + prisoner_btn.position.y)
var bottom_right:Vector2:
	get: return Vector2(global_position.x + (prisoner_btn.size.x / 2), global_position.y + (prisoner_btn.size.y / 2))


func _ready() -> void:
	Signals.PrisonerMoveTo.connect(_set_move_to_target)
	Signals.SelectPrisoner.connect(_check_selected)
	prisoner_btn.pressed.connect(_select_prisoner)
	nav_agent.path_desired_distance = 1.0
	nav_agent.target_desired_distance = 1.0
	nav_agent.path_max_distance = 1.0


func _physics_process(delta: float) -> void:
	if target != null:
		var direction:Vector2 = (nav_agent.get_next_path_position() - global_position).normalized()
		
		if not nav_agent.is_target_reached():
			if direction != Vector2.ZERO:
				velocity = _move_to(delta, velocity, direction, ACCELERATION)
		
		else:
			velocity = _move_to(delta, velocity, direction, FRICTION)
			target.queue_free()
			target = null
			
		move_and_slide()	


func _move_to(delta:float, current_velocity:Vector2, _direction:Vector2, multi:float = 1.0) -> Vector2:
	var speed:float = data.move_speed if data else 100.0
	return current_velocity.move_toward(_direction * speed, delta * multi)


func _set_move_to_target(prisoner:Prisoner, _target:TextureRect) -> void:
	if prisoner == self and _target != null:
		target = _target
		nav_agent.target_position = target.global_position
		Debug.log("Prisoner %s moving towards pos: %s" % [name, _target.global_position])
		if not nav_agent.is_target_reachable():
			target = null
			nav_agent.target_position = global_position
			Debug.log("Navigation target unreachable.")


func _select_prisoner() -> void:
	Signals.SelectPrisoner.emit(self)


func _check_selected(_prisoner:Prisoner) -> void:
	if _prisoner != self:
		prisoner_btn.set_pressed_no_signal(false)