extends RidControl


const LOAD_TIME:float = 4.0

@export var manager_loader:PackedScene

@onready var godot: AnimatedSprite2D = %godot
@onready var loading_progression_bar: TextureProgressBar = %loading_progression_bar

var can_load:bool = false
var load_done:bool = false
var timer:float = LOAD_TIME:
	set(value):
		timer = value
		loading_progression_bar.value = 1 - (timer/LOAD_TIME)
		if timer <= 0.0:
			can_load = true


func _ready() -> void:
	Signals.ManagerLoaded.connect(_loading)
	_load_loader()
	await get_tree().create_timer(0.3).timeout
	godot.play("godot")


func _process(delta: float) -> void:
	if not can_load: timer -= delta
	if can_load and load_done: _load_done()


func _load_loader() -> void:
	if manager_loader != null:
		var loader:ManagerLoader = manager_loader.instantiate()
		get_parent().add_child.call_deferred(loader)
		if not loader.is_node_ready(): await loader.ready
		Signals.LoadManager.emit("save_manager")


func _loading(manager_name:String) -> void:
	match manager_name:
		"save_manager":
			Signals.LoadManager.emit("data_manager")
		"data_manager":
			Signals.LoadManager.emit("ui_manager")
		"ui_manager":
			Signals.LoadManager.emit("scene_manager")
		"scene_manager":
			Signals.LoadManager.emit("game_manager")
		"game_manager":
			load_done = true


func _load_done() -> void:
	Signals.LoadScene.emit("logos")
	queue_free()