class_name Damage extends Resource


enum Type {
			PHYSICAL = 0,
			FIRE = 1,
			COLD = 2,
			CORROSIVE = 3,
}


var damage_type:Type = Type.PHYSICAL
var weapon_type:WeaponData.Weapon_Type
var final_damage:float = 0.0
var is_critical:bool = false


func _init(_damage_type:Type, _weapon_type:WeaponData.Weapon_Type, _final_damage:float, _is_critical:bool):
	damage_type = _damage_type
	weapon_type = _weapon_type
	final_damage = _final_damage
	is_critical = _is_critical