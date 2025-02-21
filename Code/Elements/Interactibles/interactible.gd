class_name Interactible extends Area2D


enum Type {
			PICKUP = 0,
			OPENABLE = 1,
			SEARCHABLE = 2,
}

enum State {
			LOCKED = 0,
			OPEN = 1,
			CLOSED = 2,
			SEALED = 3,
			DEPLETED = 4,
}


@export var data:InteractibleData

@onready var interact_collider: CollisionShape2D = %interact_collider

var displayed:bool = false


func _ready() -> void:
	Signals.ContextPopupToggled.connect(_check_displayed)
	Signals.ContextPopupResult.connect(_popup_result)
	Signals.InteractibleStateUpdate.connect(_state_update)
	#interact_btn.pressed.connect(_interact_btn_pressed)

	data.setup_interactible()
	_toggle_visuals()


func iteract() -> Array[LootItem]:
	return []


func _interact_btn_pressed() -> void:
	Signals.DisplayContextPopup.emit(self)


func _check_displayed(id:StringName, _displayed:bool = false) -> void:
	if id == name:
		displayed = _displayed


func _popup_result(_interactible:Interactible, _result:String) -> void:
	if _interactible == self and data.options.has(_result):
		Signals.PrisonerInteract.emit(_result, self)


func _state_update(_data:InteractibleData, new_state:State) -> void:
	if _data == data:
		match data.type:
			Type.PICKUP:
				match new_state:
					State.DEPLETED:
						queue_free.call_deferred()
					_:
						pass
			Type.OPENABLE:
				match new_state:
					State.OPEN:
						data.current_state = new_state
					State.CLOSED:
						data.current_state = new_state
					_:
						pass
			Type.SEARCHABLE:
				match new_state:
					State.DEPLETED:
						if data.loot.is_empty(): 
							data.current_state = State.DEPLETED
					_:
						pass
		_toggle_visuals()


func _toggle_visuals() -> void:
	pass