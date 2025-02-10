class_name SmallPopup extends RidPopup


@onready var text: RichTextLabel = %text

var timing:bool = false
var close_timer:int = -1:
	set(value):
		var pre:int = close_timer
		close_timer = value
		if close_timer == 0 and pre == 1:
			_close_popup()
var delta_timer:float = 0.0:
	set(value):
		delta_timer = value
		if delta_timer>= 1.0:
			delta_timer = 0
			close_timer -= 1


func _ready() -> void:
	modulate = Color.TRANSPARENT


func _process(delta: float) -> void:
	if timing: delta_timer += delta


func display_popup(_timer:int = 0, _text:String = "") -> void:
	if _timer > 0:
		close_timer = _timer
		timing = true
	
	text.text = tr(_text)
	
	var tween:Tween = create_tween()
	tween.finished.connect(show)
	tween.tween_property(self, "modulate", Color.WHITE, FADETIME)


func _close_popup() -> void:
	hide()
	id = ""
	timing = false
	delta_timer = 0
	close_timer = -1

	var tween:Tween = create_tween()
	tween.finished.connect(hide)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, FADETIME)