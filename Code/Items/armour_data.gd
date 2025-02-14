class_name ArmourData extends ItemData

enum Armour_Type {
					LIGHT = 0,
					MEDIUM = 1,
					HEAVY = 2,
}

const LIGHT:float = 0.05
const MEDIUM:float = 0.15
const HEAVY:float = 0.45


@export var armour_type:Armour_Type = Armour_Type.LIGHT
@export var base_durability:float = 1.0

var current_durability:float = -1.0
var armour_value:float:
	get:
		var value:float = LIGHT
		match armour_type:
			Armour_Type.MEDIUM:
				value = MEDIUM
			Armour_Type.HEAVY:
				value = HEAVY
			_:
				pass
		if current_durability <= 0.0:
			value = 0.0
		return value


func setup_armor() -> void:
	if current_durability == -1.0:
		current_durability = base_durability


func update_durability(value:float = 0.0) -> void:
	current_durability = clamp(current_durability - value, 0, base_durability)
	if current_durability <= 0:
		Signals.ArmourBroken.emit(self)