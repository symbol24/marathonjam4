class_name UnknownContactData extends Resource


enum State {
			IDLE = 0,
			PATROL = 1,
			MOVETOTARGET = 2,
			COMBAT = 3,
			DEAD = 4,
}

var id:String = ""
var base_strength:int = 1
var base_agility:int = 1
var base_constitution:int = 1
var base_intelligence:int = 1

var state:State = State.IDLE
var current_hp:int
var max_hp:int
var move_speed:float
var detection_distance:float = 750.0

# Combat
var active_weapon:WeaponData = WeaponData.new()
var active_armor:ArmourData = ArmourData.new()


func setup_data(_difficulty:int = 1) -> void:
	base_strength = randi_range(1, 100)
	base_agility = randi_range(1, 100)
	base_constitution = randi_range(1, 100)
	base_intelligence = randi_range(1, 100)
	var hp_offset:int = floori(base_constitution * 0.1)
	current_hp = randi_range(80 + hp_offset, 120 + hp_offset)
	max_hp = current_hp

	var move_offset:float = base_agility * 0.25
	move_speed = randf_range(30 + move_offset, 70 + move_offset)


func get_attack_action_as_string() -> String:
	if active_weapon.type == WeaponData.Weapon_Type.MELEE:
		return "melee"
	return "shoot"


func set_state(new_state:State) -> void:
	if new_state != state: state = new_state


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