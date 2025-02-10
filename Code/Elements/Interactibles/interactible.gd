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


func iteract() -> Array[LootItem]:
	return []