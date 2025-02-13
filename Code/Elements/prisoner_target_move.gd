class_name  PrisonerMoveToTarget extends TextureRect


var prisoner:Prisoner


func _ready() -> void:
	Signals.PrisonerReachedTarget.connect(_prisoner_reached_target)
	Signals.PrisonerMoveTo.connect(_check_if_still_active)


func _check_if_still_active(_prisoner:Prisoner, target:Vector2) -> void:
	if target == global_position and prisoner == null:
		prisoner = _prisoner
	elif global_position != target and prisoner == _prisoner:
		queue_free.call_deferred()


func _prisoner_reached_target(_prisoner:Prisoner) -> void:
	if _prisoner == prisoner:
		queue_free.call_deferred()
