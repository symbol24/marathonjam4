class_name Damage extends Resource


enum Type {
			PHYSICAL = 0,
			FIRE = 1,
			COLD = 2,
			CORROSIVE = 3,
}


const PHYSICAL_EFFECT:float = 0.05
const FIRE_EFFECT:float = 0.15
const COLD_EFFECT:float = 0.1
const CORROSIVE_EFFECT:float = 0.2


var damage_type:Type = Type.PHYSICAL
var weapon_type:WeaponData.Weapon_Type
var final_damage:float = 0.0
var is_critical:bool = false


func _init(_damage_type:Type, _weapon_type:WeaponData.Weapon_Type, _final_damage:float, _is_critical:bool):
	damage_type = _damage_type
	weapon_type = _weapon_type
	final_damage = _final_damage
	is_critical = _is_critical


func get_armour_effect() -> float:
	match damage_type:
		Type.PHYSICAL:
			return PHYSICAL_EFFECT
		Type.FIRE:
			return FIRE_EFFECT
		Type.COLD:
			return COLD_EFFECT
		_:
			return CORROSIVE_EFFECT