class_name GameManager extends RidManager


@export var use_debug:bool = false
@export var debug_current_prisoners:Array[PrisonerData]

var data_manager:DataManager
var current_prisoners:Array[PrisonerData]


func _ready() -> void:
	if use_debug: current_prisoners = debug_current_prisoners
	data_manager = get_tree().get_first_node_in_group("data_manager")
	if data_manager == null: push_error("Data Manager is missing!")