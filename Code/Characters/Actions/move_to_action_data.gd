class_name MoveToActionData extends PrisonerActionData

enum Move_Type {
					NORMAL = 0,
					TO_INTERACT = 1,
					TO_ATTACK = 2,
}


var target_pos:Vector2 = Vector2.ZERO
var move_type:Move_Type = Move_Type.NORMAL
var target_distance:float = 150

