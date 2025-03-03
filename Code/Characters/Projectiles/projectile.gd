class_name Projectile extends Control


const SPEED:float = 1800.0
const DISTANCE_TO_FREE:float = 4000.0


var target_pos:Vector2 = Vector2.ONE
var direction:Vector2 = Vector2.RIGHT
var queued:bool = false
var shot:bool = false


func _physics_process(delta: float) -> void:
	if shot and not queued: global_position += direction * SPEED * delta
	if global_position.distance_squared_to(target_pos) <= DISTANCE_TO_FREE:
		queued = true
		queue_free.call_deferred()


func setup_projectile(_target:Vector2 = Vector2.ONE) -> void:
	target_pos = _target
	rotation = global_position.angle_to_point(target_pos)
	direction = global_position.direction_to(target_pos)
	shot = true

