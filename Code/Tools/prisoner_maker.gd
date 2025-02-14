@tool
extends Node2D


const PORTRAITFOLDER:String = "res://Textures/Prisoners/Portraits/"
const DATAFOLDER:String = "res://Data/Prisoners/"
const DATAMANAGERPATH:String = "res://Scenes/utilities/Managers/data_manager.tscn"


@export var make_prisoner_data:bool = false:
	set(value):
		_make_prisoner_data()
		make_prisoner_data = false

@export var push_prisoners_to_data_manager:bool = false:
	set(value):
		_push_prisoners_to_data_manager()
		push_prisoners_to_data_manager = false


func _make_prisoner_data() -> void:
	var portrait_dir:DirAccess = DirAccess.open(PORTRAITFOLDER)
	if portrait_dir == null:
		var error = DirAccess.get_open_error()
		push_error("Error open portrait folder: ", error)
		return

	var data_dir:DirAccess = DirAccess.open(DATAFOLDER)
	if data_dir == null:
		var error = DirAccess.get_open_error()
		push_error("Error open data folder: ", error)
		return

	var files:PackedStringArray = portrait_dir.get_files()
	for file in files:
		if file.get_extension() == "png":
			var npd:PrisonerData = PrisonerData.new()
			var slices = file.split(".")
			npd.id = slices[0]
			npd.display_name = slices[0]
			npd.head_shot = ResourceLoader.load(PORTRAITFOLDER + file)

			npd.base_strength = randi_range(1, 100)
			npd.base_agility = randi_range(1, 100)
			npd.base_constitution = randi_range(1, 100)
			npd.base_intelligence = randi_range(1, 100)
			npd.base_dissruptive = randi_range(1, 100)

			npd.base_hp = randi_range(85, 115) + floori(npd.base_constitution + 0.1)
			npd.base_movement_speed = randi_range(35, 65) + floori(npd.base_agility + 0.1)

			var result = ResourceSaver.save(npd, DATAFOLDER + slices[0] + ".tres")
			if result != OK:
				push_error("Error %s while saving new prisoner data." % result)
				

func _push_prisoners_to_data_manager() -> void:
	var data_dir:DirAccess = DirAccess.open(DATAFOLDER)
	if data_dir == null:
		var error = DirAccess.get_open_error()
		push_error("Error open data folder: ", error)
		return
	
	var to_insta = load(DATAMANAGERPATH)
	var data_manager:DataManager = to_insta.instantiate()

	var to_add:Array[PrisonerData] = []
	var files:PackedStringArray = data_dir.get_files()
	for file in files:
		if file.get_extension() == "tres":
			var pd:PrisonerData = ResourceLoader.load(DATAFOLDER + file)
			to_add.append(pd)
			
	data_manager.prisoner_datas = to_add
	add_child(data_manager)
	if not data_manager.is_node_ready(): await data_manager.ready

	var scene:PackedScene = PackedScene.new()
	scene.pack(data_manager)

	var result = ResourceSaver.save(scene, DATAMANAGERPATH)
	if result != OK:
		push_error("Error %s while saving Data Manager." % result)
		return
	
	print("Save of Data Manager complete")

			