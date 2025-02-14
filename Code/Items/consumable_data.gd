class_name ConsumableData extends ItemData


enum Consumable_Type {
						NOTHING = 0,
						HP = 1,
						AMMO = 2,
						ARMOR = 3,
}


@export var consumable_type:Consumable_Type = Consumable_Type.NOTHING
@export var charges:int = 1
@export var amount:float = 1.0