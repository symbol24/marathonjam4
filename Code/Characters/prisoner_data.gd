class_name PrisonerData extends Resource


@export var id:String
@export var display_name:String
@export var head_shot:CompressedTexture2D

@export var base_hp:int = 100
## Values not below 30 to start
@export var base_movement_speed:float = 50


var move_speed:float:
	get: return base_movement_speed

var inventory:Array[LootItem] = []


func add_items_to_intentory(new_items:Array[LootItem] = []) -> void:
	inventory.append_array(new_items)
	Debug.log("Prisoner %s has an inventory of: %s" % [id, inventory])
