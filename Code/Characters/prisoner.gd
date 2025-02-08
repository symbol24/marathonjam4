class_name Prisoner extends CharacterBody2D


const ACCELERATION:float = 400
const FRICTION:float = 1500


@onready var sprite: Sprite2D = %sprite
@onready var mouse_area: Area2D = %mouse_area
@onready var selected: Panel = %selected
@onready var nav_agent: NavigationAgent2D = %nav_agent

var data:PrisonerData = null
var move_to:bool = false
var target:TextureRect = null


func _ready() -> void:
	Signals.SelectPrisoner.connect(_set_selected)
	Signals.PrisonerMoveTo.connect(_set_move_to_target)
	mouse_area.mouse_entered.connect(_mouse_enter)
	mouse_area.mouse_exited.connect(_mouse_exit)
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
	


func _mouse_enter() -> void:
	Signals.MouseEnterPrisoner.emit(self)
	#Debug.log("Mouse entered ", name)


func _mouse_exit() -> void:
	Signals.MouseExitPrisoner.emit()
	#Debug.log("Mouse exited ", name)


func _set_selected(_prisoner:Prisoner = null) -> void:
	if _prisoner == self: selected.show()
	else: selected.hide()


func _set_move_to_target(prisoner:Prisoner, _target:TextureRect) -> void:
	if prisoner == self and _target != null:
		target = _target
		nav_agent.target_position = target.global_position
		Debug.log("Prisoner %s moving towards pos: %s" % [name, _target.global_position])
		if not nav_agent.is_target_reachable():
			target = null
			nav_agent.target_position = global_position
			Debug.log("Navigation target unreachable.")