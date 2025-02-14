class_name LootTable extends Resource


@export var table:Array[LootItem] = []


func get_loot(amount:int = 1) -> Array[LootItem]:
	var total:int = 0
	for each in table:
		total += each.weight
		each.current_weight = total

	var result:Array[LootItem] = []
	for i in amount:
		var loot_item:LootItem = null
		var loop_break:int = 0
		while loot_item == null:
			loot_item = _get_item(randi_range(0, total))
			loop_break += 1
			if loop_break > 100:
				break
		
		if result != null: result.append(loot_item)

	return result


func _get_item(rng:int = -1) -> LootItem:
	for each in table:
		if each.current_weight <= rng and each.can_be_rewarded:
			each.loot_rewarded = true
			return each.duplicate()
	return null