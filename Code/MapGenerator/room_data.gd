class_name RoomData extends Resource


enum Type {
			NOT_ASSIGNED = 0,
			ENCOUNTER = 1,
			TREASURE = 2, 
			STATION = 3,
			SHOP = 4,
			BOSS = 5,
			START = 6,
}


@export var type: Type = Type.NOT_ASSIGNED
@export var row:int = -1
@export var column:int = -1
@export var position:Vector2 = Vector2.ZERO
@export var next_rooms: Array[RoomData] = []
@export var selected:bool = false
@export var icon:CompressedTexture2D

var coords_on_map:Vector2 = Vector2.ZERO
var button_can_be_pressed:bool = false


func _to_string() -> String:
	return "%s (%s)" % [column, Type.keys()[type][0]]