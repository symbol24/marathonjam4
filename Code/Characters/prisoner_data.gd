class_name PrisonerData extends Resource


enum Health_Status {
						DEAD = 0,
						SICKLY = 1,
						SICK = 2,
						HEALTHY = 3,
						ROBUST = 4,
						CRYO = 5,
}

enum Action_State {
					DEAD = 0,
					IDLE = 1,
					MOVING = 2,
					INTERACTING = 3,
					COMBAT = 4,
					IGNORE = 5,
}

@export var id:String
@export var display_name:String
@export var headshot_normal_path:String = ""
@export var headshot_small_path:String = ""

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

var headshot_normal:CompressedTexture2D = null
var headshot_small:CompressedTexture2D = null
var default_status:Health_Status:
	get: return get_default_value()
var move_speed:float:
	get: return base_movement_speed
var current_hp:int = base_hp
var inventory:Array[LootItem] = []
var active_armor:ArmourData = null
var active_weapon:WeaponData = WeaponData.new()
var current_action_state:Action_State = Action_State.IDLE:
	set(value):
		current_action_state = value
		Signals.PrisonerActionStateUpdated.emit(self)
var display_id:int


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


func receive_damage(damage:Damage) -> float:
	if damage:
		var value = damage.final_damage
		if active_armor: 
			value -= value * active_armor.armour_value
			var new_durability:float = active_armor.base_durability - (active_armor.base_durability * damage.get_armour_effect())
			active_armor.update_durability(new_durability)
		
		if value >= current_hp:
			value = current_hp
		
		current_hp -= value
		return value
	return 0