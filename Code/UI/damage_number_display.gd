class_name DamageNumbersDisplay extends Control


@export var dmg_nbr_scene:PackedScene

var buffered_damages:Array[Damage] = []
var node2d:Node2D
var data_manager:DataManager:
	get:
		if data_manager == null: data_manager = get_tree().get_first_node_in_group("data_manager")
		return data_manager


func _ready() -> void:
	Signals.DisplayDamageNumber.connect(_display_damage)
	node2d = Node2D.new()
	add_child(node2d)


func _display_damage(damage:float, target_pos:Vector2) -> void:
	if data_manager == null: Debug.log("Wheres the data manager?")
	if dmg_nbr_scene:
		var new:DamageNumber = dmg_nbr_scene.instantiate()
		add_child(new)
		if not new.is_node_ready(): await new.ready
		var x:float = randf_range(target_pos.x - (new.size.x/2) - 10, target_pos.x - (new.size.x/2) + 10)
		var new_pos:Vector2 = Vector2(x, target_pos.y - 80)
		new.global_position = node2d.to_local(new_pos)
		new.display(str(damage))