class_name Interactible extends Area2D


enum Type {
			PICKUP = 0,
			OPEN = 1,
			SEARCHABLE = 2,
}

enum State {
			LOCKED = 0,
			OPEN = 1,
			CLOSED = 2,
			SEALED = 3,
}


@export var data:InteractibleData

@onready var interact_collider: CollisionShape2D = %interact_collider
@onready var interact_btn: TextureButton = %interact_btn

var displayed:bool = false
var top_left:Vector2:
	get: return Vector2(global_position.x + interact_btn.position.x, global_position.y + interact_btn.position.y)
var bottom_right:Vector2:
	get: return Vector2(global_position.x + (interact_btn.size.x / 2), global_position.y + (interact_btn.size.y / 2))


func _ready() -> void:
	Signals.ContextPopupToggled.connect(_check_displayed)
	interact_btn.pressed.connect(_interact_btn_pressed)


func iteract() -> Array[LootItem]:
	return []


func _interact_btn_pressed() -> void:
	Signals.DisplayContextPopup.emit(self)


func _check_displayed(id:StringName, _displayed:bool = false) -> void:
	if id == name:
		displayed = _displayed