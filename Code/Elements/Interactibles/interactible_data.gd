class_name InteractibleData extends Resource


@export var type:Interactible.Type
@export var base_state:Interactible.State
@export var base_interact_time:float = 0.0
@export var loot_table:LootTable
@export var options:Dictionary = {}
@export var required_key:int = 0


var current_state:Interactible.State
var loot:Array = []


func setup_interactible() -> void:
	if required_key > 0: base_state = Interactible.State.LOCKED
	current_state = base_state


func attempt_to_pick_up() -> Dictionary:
	var result:Dictionary = {}
	match type: 
		Interactible.Type.PICKUP:
			loot = loot_table.get_loot() if loot_table != null else []
			result = {
					"result":true,
					"loot": loot,
			}
		_:
			result = {
					"result":false,
					"reason":"not pickup",
			}
	return result


func attempt_to_search() -> Dictionary:
	var result:Dictionary = {}
	match type:
		Interactible.Type.SEARCHABLE:
			loot = loot_table.get_loot() if loot_table != null else []
			result = {
					"result":true,
					"loot": loot,
			}
		_:
			result = {
					"result":false,
					"reason":"not searchable",
			}

	return result


func attempt_to_on_open(_action:String, _key_value:int = 0) -> Dictionary:
	var result:Dictionary = {}
	match type:
		Interactible.Type.OPENABLE:
			match _action:
				"open":
					if current_state == Interactible.State.CLOSED:
						result = {
									"result":true,
									"state":Interactible.State.OPEN,
								}
					elif current_state == Interactible.State.LOCKED:
						if required_key == _key_value:
							result = {
									"result":true,
									"state":Interactible.State.OPEN,
							}
						else:
							result = {
								"result":false,
								"reason": "no access",
								}
					else:
						result = {
								"result":false,
								"reason": "not closed",
								}
				"close":
					if current_state == Interactible.State.OPEN:
						result = {
									"result":true,
									"state":Interactible.State.CLOSED,
								}
					else:
						result = {
								"result":false,
								"reason": "not open",
								}
				"seal":
					if current_state == Interactible.State.CLOSED or current_state == Interactible.State.OPEN:
						result = {
									"result":true,
									"state":Interactible.State.SEALED,
								}
					else:
						result = {
								"result":false,
								"reason": "cannot be sealed",
								}
		_:
			result = {
					"result":false,
					"reason":"not an open",
			}

	return result