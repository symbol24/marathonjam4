class_name PrisonerData extends Resource


@export var id:String
@export var display_name:String
@export var head_shot:CompressedTexture2D

@export var base_hp:int = 100
## Values not below 30 to start
@export var base_movement_speed:float = 50

@export var base_strength:int = 1
@export var base_agility:int = 1
@export var base_constitution:int = 1
@export var base_intelligence:int = 1
@export var base_dissruptive:int = 1

var move_speed:float:
	get: return base_movement_speed
var current_hp:int
var is_dead:bool = false
var inventory:Array[LootItem] = []


func add_items_to_intentory(new_items:Array[LootItem] = []) -> void:
	inventory.append_array(new_items)
	Debug.log("Prisoner %s has an inventory of: %s" % [id, inventory])
