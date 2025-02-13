class_name PrisonerData extends Resource


@export var id:String
@export var display_name:String
@export var head_shot:CompressedTexture2D

@export var base_hp:int = 100
@export var base_movement_speed:float = 400


var move_speed:float:
	get: return base_movement_speed

var inventory:Array = []


func add_items_to_intentory(new_items:Array = []) -> void:
	inventory.append_array(new_items)
