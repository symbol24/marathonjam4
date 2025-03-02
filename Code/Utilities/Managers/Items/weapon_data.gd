class_name WeaponData extends ItemData

enum Weapon_Type {
			MELEE = 0,
			PROJECTILE = 1,
			EXPLOSIVE = 2,
}


enum Firemode {
				SEMIAUTO = 0,
				BURST = 1,
				FULLAUTO = 2,
}


@export var weapon_type:Weapon_Type = Weapon_Type.PROJECTILE
@export var damage_type:Damage.Type = Damage.Type.PHYSICAL
@export var base_damage:float = 1.0
@export var base_critical_chance:float = 0.0
@export var base_critical_bonus:float = 0.0
## Time between bursts of attacks
@export var delay_before_next_attack:float = 1.0 
@export var fire_mode:Firemode = Firemode.SEMIAUTO
@export var attack_count:int = 1
## Time between single attacks in a burst
@export var time_between_attacks:float = 0.01
@export var attack_distance:float = 500.0


func get_damage() -> Damage:
	var final:float = base_damage
	var is_crit:bool = false
	var chance:float = randf()
	if chance <= base_critical_chance:
		final += base_damage * base_critical_bonus
		is_crit = true
	return Damage.new(damage_type, weapon_type, final, is_crit)