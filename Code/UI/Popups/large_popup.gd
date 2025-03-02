class_name LargePopup extends RidPopup


@export var warning:CompressedTexture2D
@export var error:CompressedTexture2D

@onready var icon: TextureRect = %icon
@onready var title: RichTextLabel = %title
@onready var timer: Label = %timer
@onready var text: RichTextLabel = %text
@onready var btn_popup_confirm: Button = %btn_popup_confirm
@onready var btn_popup_cancel: Button = %btn_popup_cancel

var timing:bool = false
var close_timer:int = -1:
	set(value):
		var pre:int = close_timer
		close_timer = value
		timer.text = str(close_timer)
		if close_timer == 0 and pre == 1:
			_cancel()
var delta_timer:float = 0.0:
	set(value):
		delta_timer = value
		if delta_timer>= 1.0:
			delta_timer = 0
			close_timer -= 1


func _ready() -> void:
	btn_popup_confirm.pressed.connect(_confirm)
	btn_popup_cancel.pressed.connect(_cancel)
	modulate = Color.TRANSPARENT


func _process(delta: float) -> void:
	if timing: delta_timer += delta


func display_popup(_id:String = "", _severity:RidPopupManager.Severity = RidPopupManager.Severity.NORMAL , _timer:int = 0, _title:String = "", _text:String = "") -> void:
	if _timer > 0:
		close_timer = _timer
		timer.text = str(close_timer)
		timer.show()
		timing = true
	else: timer.hide()

	title.text = tr(_title)
	text.text = tr(_text)
	id = _id

	match _severity:
		RidPopupManager.Severity.NORMAL:
			icon.hide()
		RidPopupManager.Severity.WARNING:
			if warning != null:
				icon.texture = warning
				icon.show()
			else: icon.hide()
		RidPopupManager.Severity.ERROR:
			if error != null:
				icon.texture = error
				icon.show()
			else: icon.hide()
	
	var tween:Tween = create_tween()
	tween.finished.connect(show)
	tween.tween_property(self, "modulate", Color.WHITE, FADETIME)


func _confirm() -> void:
	Signals.PopupResult.emit(id, true)
	_close_popup()


func _cancel() -> void:
	Signals.PopupResult.emit(id, false)
	_close_popup()


func _close_popup() -> void:
	id = ""
	timing = false
	delta_timer = 0
	close_timer = -1

	var tween:Tween = create_tween()
	tween.finished.connect(hide)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, FADETIME)
