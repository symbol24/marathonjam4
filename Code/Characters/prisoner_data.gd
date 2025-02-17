class_name PrisonerData extends Resource


enum Health_Status {
						DEAD = 0,
						SICKLY = 1,
						SICK = 2,
						HEALTHY = 3,
						ROBUST = 4,
						CRYO = 5,
}


@export var id:String
@export var display_name:String
@export var headshot_path:String = ""

@export var base_hp:int = 100
## Values not below 30 to start
@export var base_movement_speed:float = 50

@export var base_strength:int = 1
@export var base_agility:int = 1
@export var base_constitution:int = 1
@export var base_intelligence:int = 1
@export var base_criminality:int = 1

@export var height:int = 1
@export var weight:int = 1
@export var dob:String = ""
@export var doi:String = ""
@export var sentence:String = ""
@export var location_of_origin:String = ""
@export var criminal_record:String = ""
@export var education:String = ""

@export var current_status:Health_Status = Health_Status.CRYO

var headshot:CompressedTexture2D
var default_status:Health_Status:
	get: return get_default_value()
var move_speed:float:
	get: return base_movement_speed
var current_hp:int
var inventory:Array[LootItem] = []


func add_items_to_intentory(new_items:Array[LootItem] = []) -> void:
	inventory.append_array(new_items)
	Debug.log("Prisoner %s has an inventory of: %s" % [id, inventory])


func get_default_value(_const:int = 1, _str:int = 1) -> Health_Status:
	var rating:int = (_const + _str) / 2
	var result:Health_Status = Health_Status.ROBUST
	if rating >= 1 and rating < 25:
		result = Health_Status.SICKLY
	elif rating >= 25 and rating < 50:
		result = Health_Status.SICK
	elif rating >= 50 and rating < 75:
		result = Health_Status.HEALTHY

	return result


