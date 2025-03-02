class_name DamageNumber extends Label


const DISPLAY_TIME:float = 2.0
const UP_DISTANCE:float = -100

func display(value:String) -> void:
	text = value
	var tween:Tween = create_tween()
	tween.finished.connect(_clear)
	tween.set_parallel(true)
	tween.tween_property(self, "position", Vector2(position.x, position.y+UP_DISTANCE), DISPLAY_TIME)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, DISPLAY_TIME)


func _clear() -> void:
	queue_free.call_deferred()