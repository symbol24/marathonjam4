class_name BtnLoadReference extends Button


var hash_id:int = -1


func _ready() -> void:
	Signals.SelectHashIdForLoad.connect(_deselect_if_not)


func _pressed() -> void:
	Signals.SelectHashIdForLoad.emit(hash_id)


func setup_button(data:PlayerData) -> void:
	hash_id = data.hash_id
	text = data.id + " - " + _get_date(data.last_save_date_time) + " - " + _get_playtime(data.playtime)


func _deselect_if_not(_hash_id:int) -> void:
	if hash_id != _hash_id:
		set_pressed_no_signal(false)


func _get_playtime(playtime:float) -> String:
	var hours:int = floori(playtime/3600)
	playtime -= hours * 3600
	var mins:int = floori(playtime/60)
	return str(hours) + "h:" + str(mins) + "m"


func _get_date(old_dat:String) -> String:
	var new_date:String = ""
	var split:PackedStringArray = old_dat.split("T")
	if not split.is_empty():
		new_date = split[0] + " " + split[1]
	return new_date