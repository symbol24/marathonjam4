@tool
extends Node2D


const PORTRAITFOLDER:String = "res://Textures/Prisoners/Portraits/"
const PORTRAITFOLDERNORMAL:String = "res://Textures/Prisoners/Portraits/Normal/"
const PORTRAITFOLDERSMALL:String = "res://Textures/Prisoners/Portraits/Small/"
const DATAFOLDER:String = "res://Data/Prisoners/"
const DATAMANAGERPATH:String = "res://Scenes/utilities/Managers/data_manager.tscn"


@export var update_prisoner_data:bool = false:
	set(value):
		_update_prisoner_datas()
		#print("update_prisoner_data disabled")
		update_prisoner_data = false

@export var push_prisoners_to_data_manager:bool = false:
	set(value):
		_push_prisoners_to_data_manager()
		#print("push_prisoners_to_data_manager disabled")
		push_prisoners_to_data_manager = false

@export var resize_portraits:bool = false:
	set(value):
		_resize_images()
		resize_portraits = false


func _resize_images() -> void:
	var portrait_dir:DirAccess = _get_dir(PORTRAITFOLDER)

	var _normal_dir:DirAccess = _get_dir(PORTRAITFOLDERNORMAL)
	
	var _small_dir:DirAccess = _get_dir(PORTRAITFOLDERSMALL)
	
	var files:PackedStringArray = portrait_dir.get_files()
	for file in files:
		var ext:String = file.get_extension()
		if ext == "jpg" or ext == "png":
			var splits:PackedStringArray = file.split(".")
			var original:CompressedTexture2D = ResourceLoader.load(PORTRAITFOLDER + file)

			var image:Image = original.get_image()

			image.resize(276.76, 374, 3)
			if ext == "jpg":
				image.save_jpg(PORTRAITFOLDERNORMAL + splits[0] + "_normal." + ext)
			else:
				image.save_png(PORTRAITFOLDERNORMAL + splits[0] + "_normal." + ext)

			image = original.get_image()
			image.resize(74, 100, 3)
			if ext == "jpg":
				image.save_jpg(PORTRAITFOLDERSMALL + splits[0] + "_small." + ext)
			else:
				image.save_png(PORTRAITFOLDERSMALL + splits[0] + "_small." + ext)


func _update_prisoner_datas() -> void:
	var _portrait_dir:DirAccess = _get_dir(PORTRAITFOLDER)

	var normal_dir:DirAccess = _get_dir(PORTRAITFOLDERNORMAL)
	
	var small_dir:DirAccess = _get_dir(PORTRAITFOLDERSMALL)

	var data_dir:DirAccess = _get_dir(DATAFOLDER)
	
	var normal_files:PackedStringArray = normal_dir.get_files()
	var small_files:PackedStringArray = small_dir.get_files()
	var datas:PackedStringArray = data_dir.get_files()

	var j:int = 0
	for i in normal_files.size():
		var ext:String = normal_files[i].get_extension()
		var ext2:String = small_files[i].get_extension()
		if (ext == "jpg" or ext == "png") and (ext2 == "jpg" or ext2 == "png"):
			var data:PrisonerData
			var id:String = "prisoner_%04d" % j
			if i < datas.size():
				data = ResourceLoader.load(DATAFOLDER + datas[i])	
			else:
				data = PrisonerData.new()
				data.base_strength = randi_range(1, 100)
				data.base_agility = randi_range(1, 100)
				data.base_constitution = randi_range(1, 100)
				data.base_intelligence = randi_range(1, 100)
				data.base_criminality = randi_range(1, 100)
				data.dob = id + "_do_birth"
				data.doi = id + "_do_incarceration"
				data.sentence = id + "_sentence"
				data.location_of_origin = id + "_location_origin"
				data.criminal_record = id + "_criminal_record"
				data.education = id + "_education"
				data.height = randi_range(120, 180) + floori((data.base_strength + data.base_agility) * 0.30)
				data.weight = randi_range(40, 100) + floori(data.base_constitution * 0.10)
				data.base_hp = randi_range(85, 115) + floori(data.base_constitution * 0.2)
				data.base_movement_speed = randi_range(35, 65) + floori(data.base_agility * 0.2)

			data.headshot_normal_path = PORTRAITFOLDERNORMAL + normal_files[i]
			print(data.headshot_normal_path)
			data.headshot_small_path = PORTRAITFOLDERSMALL + small_files[i]
			print(data.headshot_small_path)
			data.id = id
			data.display_name = id
			ResourceSaver.save(data, DATAFOLDER + id + ".tres")
			#print("Prionser data %s has been created and updated." % id)
			j += 1


func _push_prisoners_to_data_manager() -> void:
	var data_dir:DirAccess = _get_dir(DATAFOLDER)
	
	var to_insta = load(DATAMANAGERPATH)
	var data_manager:DataManager = to_insta.instantiate()
	data_manager.prisoner_datas = []

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



func _get_dir(folder_path:String) -> DirAccess:
	var dir:DirAccess = DirAccess.open(folder_path)
	if dir == null:
		var result = dir.make_dir(folder_path)
		if result != OK:
			var error = DirAccess.get_open_error()
			push_error("Error making folder: ", error)

		dir = DirAccess.open(PORTRAITFOLDERNORMAL)
		if dir == null:
			var error = DirAccess.get_open_error()
			push_error("Error open folder: ", error)

	return dir