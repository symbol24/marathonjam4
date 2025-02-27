class_name UIManager extends CanvasLayer


const SAVE_ICON_DISPLAY_TIME:float = 6.0
const SAVE_ICON_TWEEN_TIME:float = 0.5


var play_ui:PlayUi = null
var pause_menu:PauseMenu = null
var save_icon:Control = null
var data_manager:DataManager:
	get:
		if data_manager == null: data_manager = get_tree().get_first_node_in_group("data_manager")
		return data_manager
var scene_manager:SceneManager:
	get:
		if scene_manager == null: scene_manager = get_tree().get_first_node_in_group("scene_manager")
		return scene_manager


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		_press_pause()


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	Signals.TogglePlayUi.connect(_toggle_play_ui)
	Signals.DisplaySaveIcon.connect(_display_save_icon)


func _toggle_play_ui(display:bool = false) -> void:
	if display:
		if play_ui == null:
			play_ui = data_manager.play_ui.instantiate()
			if play_ui:
				add_child.call_deferred(play_ui)
				if not play_ui.is_node_ready(): await play_ui.ready
				play_ui.hide()

		await play_ui.generate_prisoner_ui()
		play_ui.show()
	else:
		if play_ui != null:
			play_ui.hide()
			remove_child.call_deferred(play_ui)


func _press_pause() -> void:
	if scene_manager != null:
		if scene_manager.active_scene != null:
			match scene_manager.active_scene.id:
				"story_intro_menu", "play_level", "ship_naming_menu", "prisoner_selection_menu", "map_selection_menu", "shop_menu", "derelect_menu", "station_menu", "boss_menu":
					_toggle_pause_menu()
				_:
					pass


func _toggle_pause_menu() -> void:
	if pause_menu == null:
		if data_manager.pause_menu != null:
			pause_menu = data_manager.pause_menu.instantiate()
			add_child.call_deferred(pause_menu)
			if not pause_menu.is_node_ready(): await pause_menu.ready
			Signals.TogglePauseGame.emit(true)
			pause_menu.toggle_pause_menu(true)
	
	else:
		if pause_menu.visible:
			pause_menu.toggle_pause_menu(false)
		else:
			pause_menu.toggle_pause_menu(true)


func _display_save_icon() -> void:
	if save_icon == null:
		save_icon = data_manager.save_icon.instantiate()
		add_child(save_icon)
		if not save_icon.is_node_ready(): await save_icon.ready
		save_icon.position = Vector2(1920 - (save_icon.size.x * 1.5), 1080 - (save_icon.size.y * 1.5))
		save_icon.hide()
	
	if save_icon != null and not save_icon.is_visible():
		if save_icon.get_index() < get_child_count()-1:
			move_child(save_icon, get_child_count()-1)
		
		var i:int = floori(SAVE_ICON_DISPLAY_TIME / 2)
		while i > 0:
			save_icon.show()
			await get_tree().create_timer(SAVE_ICON_TWEEN_TIME).timeout
			save_icon.hide()
			await get_tree().create_timer(SAVE_ICON_TWEEN_TIME).timeout
			i -= 1
