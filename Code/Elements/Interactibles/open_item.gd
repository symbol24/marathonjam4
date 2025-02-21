class_name OpenItem extends Interactible



@onready var closed: Panel = %closed
@onready var sealed: Panel = %sealed
@onready var locked: Panel = %locked


func _toggle_visuals() -> void:
	if data.current_state == State.OPEN: 
		closed.hide()
		sealed.hide()
		locked.hide()
	elif data.current_state == State.CLOSED:
		closed.show()
		sealed.hide()
		locked.hide()
	elif data.current_state == State.LOCKED:
		closed.hide()
		sealed.hide()
		locked.show()
	elif data.current_state == State.SEALED:
		closed.hide()
		sealed.show()
		locked.hide()