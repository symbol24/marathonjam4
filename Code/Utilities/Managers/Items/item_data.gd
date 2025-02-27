class_name ItemData extends Resource


enum Type {
			MATERIAL = 0,
			CONSUMABLE = 1,
			WEAPON = 2,
			ARMOR = 3,
			JUNK = 4,
}


@export var item_id:String = ""
@export var can_stack:bool = true
@export var display_name:String = ""
@export var display_text:String = ""
@export var icon_texture:CompressedTexture2D
@export var type:Type = Type.JUNK

var hash_id:int = -1
var current_stack:int = 1


func add_to_item() -> int:
	if can_stack:
		current_stack += 1
	return current_stack


func remove_from_item() -> int:
	current_stack -= 1
	return current_stack