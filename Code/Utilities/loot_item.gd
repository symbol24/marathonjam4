class_name LootItem extends Resource


@export var id:String = ""
@export var weight:int = 1
@export var is_unique:bool = false

var current_weight:int = 0
var loot_rewarded:bool = false
var can_be_rewarded:bool:
	get: return false if is_unique and loot_rewarded else true