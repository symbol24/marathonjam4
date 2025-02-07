class_name PlayerSaveData extends Resource


@export var hash_id:int = -1
@export var id:int = -1


func setup_id(new_id:int = -1) -> bool:
	if new_id == id: return false
	id = new_id
	hash_id = hash(id)
	return true