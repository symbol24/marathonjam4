class_name Settings extends PanelContainer


const WINDOW_SIZES:Array[Vector2i] = [Vector2i(3840, 2160), 
									Vector2i(2560, 1440), 
									Vector2i(1920, 1080), 
									Vector2i(1366, 768), 
									Vector2i(1280, 720), 
									Vector2i(1920, 1200), 
									Vector2i(1680, 1050), 
									Vector2i(1440, 900), 
									Vector2i(1280, 800), 
									Vector2i(1024, 768), 
									Vector2i(800, 600), 
									Vector2i(640, 480), 
									]


enum Window_Mode {
					FULLSCREEN = 0,
					WINDOWED = 1,
					BORDERLESS_WINDOWED = 2,
}


# Floating Buttons
@onready var floating_control: Control = %floating_control
@onready var btn_main_menu_settings_close: Button = %btn_main_menu_settings_close
@onready var btn_main_menu_settings_apply: Button = %btn_main_menu_settings_apply

# General
@onready var language_options: OptionButton = %language_options
var current_language:int = 0
@onready var dyslexic_friendly_font_btn: Button = %dyslexic_driendly_font_btn
var dyslexic_friendly_font:bool = false
@onready var crt_effects_btn: Button = %crt_effects_btn
var crt_effects:bool = true
@onready var flash_effects_btn: Button = %flash_effects_btn
var flash_effects:bool = true
@onready var btn_reset_general: Button = %btn_reset_general

# Video
@onready var normal_window_mode: HBoxContainer = %normal_window_mode
@onready var window_option_btn: OptionButton = %window_option_btn
var window_mode:Window_Mode = Window_Mode.FULLSCREEN
@onready var normal_window_sizes: HBoxContainer = %normal_window_sizes
@onready var window_sizes_btn: OptionButton = %window_sizes_btn
var current_size:Vector2i = Vector2i(1920, 1080)
@onready var web_fullscreen_hbox: HBoxContainer = %web_fullscreen
@onready var web_fullscreen_btn: Button = %web_fullscreen_btn
@onready var btn_reset_video: Button = %btn_reset_video
var full_screen:bool = false

# Audio
@onready var master_hslider: HSlider = %master_hslider
var master_volume:float = 0.5
@onready var music_hslider: HSlider = %music_hslider
var music_volume:float = 0.5
@onready var sfx_hslider: HSlider = %sfx_hslider
var sfx_volume:float = 0.5
@onready var btn_reset_audio: Button = %btn_reset_audio

# Controls
@onready var click_btn: Button = %click_btn
var current_click
@onready var deselect_btn: Button = %deselect_btn
var current_deselect
@onready var pause_btn: Button = %pause_btn
var current_pause:Key
@onready var btn_reset_controls: Button = %btn_reset_controls

var save_manager:SaveManager:
	get:
		if save_manager == null: save_manager = get_tree().get_first_node_in_group("save_manager")
		if save_manager == null: Debug.error("Settings cannot find save manager")
		return save_manager
var data_manager:DataManager:
	get:
		if data_manager == null: data_manager = get_tree().get_first_node_in_group("data_manager")
		if data_manager == null: Debug.error("Settings cannot find data manager")
		return data_manager
var input_manager:InputManager:
	get:
		if input_manager == null: input_manager = get_tree().get_first_node_in_group("input_manager")
		if input_manager == null: Debug.error("Settings cannot find input manager")
		return input_manager
var pending_changes:bool = false


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	Signals.PopupResult.connect(_check_popup_results)

	# Floating Buttons
	btn_main_menu_settings_close.pressed.connect(_btn_main_menu_settings_close_pressed)
	btn_main_menu_settings_apply.pressed.connect(_btn_main_menu_settings_apply_pressed)

	# General
	language_options.item_selected.connect(_language_options_item_selected)
	dyslexic_friendly_font_btn.pressed.connect(_dyslexic_friendly_font_btn_pressed)
	crt_effects_btn.pressed.connect(_crt_effects_btn_pressed)
	flash_effects_btn.pressed.connect(_flash_effects_btn_pressed)
	btn_reset_general.pressed.connect(_reset_general_to_defaults)

	# Video
	if OS.get_name() == "Web":
		normal_window_mode.hide()
		normal_window_sizes.hide()
		web_fullscreen_hbox.show()
	else:
		normal_window_mode.show()
		normal_window_sizes.show()
		web_fullscreen_hbox.hide()
	window_option_btn.item_selected.connect(_window_option_btn_item_selected)
	window_sizes_btn.item_selected.connect(_window_sizes_btn_item_selected)
	web_fullscreen_btn.pressed.connect(_web_fullscreen_btn_pressed)

	# Audio 
	btn_reset_audio.pressed.connect(_reset_audio_btn_pressed)
	master_hslider.value_changed.connect(_master_hslider_value_updated)
	music_hslider.value_changed.connect(_music_hslider_value_updated)
	sfx_hslider.value_changed.connect(_sfx_hslider_value_updated)

	# Controls 
	


func toggle_display(display:bool = false) -> void:
	if display:
		_setup_general_values()
		_setup_video_values()
		_setup_audio_values()
		_setup_controls_values()
	else:
		hide()


# Floating Buttons
func _btn_main_menu_settings_close_pressed() -> void:
	if pending_changes:
		Signals.DisplayPopup.emit(PopupManager.Type.LARGE, "setting_pending_changes_close", PopupManager.Severity.WARNING, "setting_pending_changes_close_title", "setting_pending_changes_close_text", 0)
	else:
		toggle_display(false)


func _btn_main_menu_settings_apply_pressed() -> void:
	if pending_changes:
		_save_updates_to_player_data()
		Signals.DisplayPopup.emit(PopupManager.Type.LARGE, "setting_pending_changes_apply", PopupManager.Severity.NORMAL, "setting_pending_changes_apply_title", "setting_pending_changes_apply_text", 0)


# General
func _setup_general_values() -> void:
	current_language = _get_int_from_locale(save_manager.active_save.language)
	language_options.select(current_language)
	dyslexic_friendly_font = save_manager.active_save.dyslexic_font
	dyslexic_friendly_font_btn.text = tr("ON") if dyslexic_friendly_font else tr("OFF")
	crt_effects = save_manager.active_save.filters_active
	crt_effects_btn.text = tr("ON") if crt_effects else tr("OFF")
	flash_effects = save_manager.active_save.flashes_active
	flash_effects_btn.text = tr("ON") if flash_effects else tr("OFF")


func _language_options_item_selected(value:int) -> void:
	if value != current_language:
		current_language = value
		var lang:String = _get_locale_from_int(current_language)
		TranslationServer.set_locale(lang)
		pending_changes = true
	

func _dyslexic_friendly_font_btn_pressed() -> void:
	if data_manager.default_theme.default_font == data_manager.normal_font:
		data_manager.default_theme.default_font = data_manager.dyslexia_friendly_font
		dyslexic_friendly_font_btn.text = tr("ON")
		dyslexic_friendly_font = true
	else:
		data_manager.default_theme.default_font = data_manager.normal_font
		dyslexic_friendly_font_btn.text = tr("OFF")
		dyslexic_friendly_font = false
	pending_changes = true


func _crt_effects_btn_pressed() -> void:
	crt_effects = !crt_effects
	crt_effects_btn.text = tr("ON") if crt_effects else tr("OFF")
	pending_changes = true
	Signals.ToggleCRTEffects.emit(crt_effects)


func _flash_effects_btn_pressed() -> void:
	flash_effects = !flash_effects
	flash_effects_btn.text = tr("ON") if flash_effects else tr("OFF")
	pending_changes = true
	Signals.ToggleFlashEffects.emit(flash_effects)


# Video
func _setup_video_values() -> void:
	if OS.get_name() != "Web":
		window_mode = save_manager.active_save.window_mode
		window_option_btn.select(window_mode)
		_setup_window_resolutions()
		current_size = save_manager.active_save.window_size
		window_sizes_btn.select(_get_id_for_resolution(current_size))


func _window_option_btn_item_selected(new_value:int) -> void:
	window_mode = new_value as Window_Mode
	_set_display_mode(window_mode)
	Signals.DisplayPopup.emit(PopupManager.Type.LARGE, "setting_window_mode_changes", PopupManager.Severity.NORMAL, "setting_window_mode_changes_title", "setting_window_mode_changes_text", 15)


func _keep_window_mode_change() -> void:
	save_manager.active_save.window_mode = window_mode
	Signals.Save.emit()


func _revert_window_mode_change() -> void:
	window_mode = save_manager.active_save.window_mode
	_set_display_mode(window_mode)
	window_option_btn.select(window_mode)


func _window_sizes_btn_item_selected(new_value:int) -> void:
	if new_value != _get_id_for_resolution(current_size):
		_update_window_size(new_value)


func _update_window_size(new_size_id:int) -> void:
	current_size = WINDOW_SIZES[new_size_id]
	get_window().size = current_size
	Signals.DisplayPopup.emit(PopupManager.Type.LARGE, "setting_resolution_changes", PopupManager.Severity.NORMAL, "setting_resolution_changes_title", "setting_resolution_changes_text", 15)


func _setup_window_resolutions() -> void:
	if window_sizes_btn.item_count > 0: window_sizes_btn.clear()
	for res in WINDOW_SIZES:
		window_sizes_btn.add_item(str(res))


func _keep_resolution_change() -> void:
	save_manager.active_save.window_size = current_size
	Signals.Save.emit()


func _revert_resolution_change() -> void:
	current_size = save_manager.active_save.window_size
	get_window().size = current_size
	window_sizes_btn.select(_get_id_for_resolution(current_size))


func _get_id_for_resolution(current:Vector2i) -> int:
	var result:int = -1
	var i:int = 0
	for res in WINDOW_SIZES:
		if current == res:
			result = i
			break
		i += 1
	return result


func _web_fullscreen_btn_pressed() -> void:
	if full_screen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		web_fullscreen_btn.text = tr("OFF")
		full_screen = false
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		web_fullscreen_btn.text = tr("ON")
		full_screen = true


# Audio
func _setup_audio_values() -> void:
	master_volume = save_manager.active_save.master_volume
	master_hslider.set_value_no_signal(master_volume)
	music_volume = save_manager.active_save.music_volume
	music_hslider.set_value_no_signal(music_volume)
	sfx_volume = save_manager.active_save.sfx_volume
	sfx_hslider.set_value_no_signal(sfx_volume)


func _master_hslider_value_updated(value:float) -> void:
	master_volume = value
	Audio.set_volumes(master_volume, music_volume, sfx_volume)
	pending_changes = true


func _music_hslider_value_updated(value:float) -> void:
	music_volume = value
	Audio.set_volumes(master_volume, music_volume, sfx_volume)
	pending_changes = true


func _sfx_hslider_value_updated(value:float) -> void:
	sfx_volume = value
	Audio.set_volumes(master_volume, music_volume, sfx_volume)
	pending_changes = true


# Controls
func _setup_controls_values() -> void:
	current_click = save_manager.active_save.click
	click_btn.text = _get_string_from_mouse_button(current_click) if current_click is MouseButton else OS.get_keycode_string(current_click)
	current_deselect = save_manager.active_save.deselect
	deselect_btn.text = _get_string_from_mouse_button(current_click) if current_deselect is MouseButton else OS.get_keycode_string(current_deselect)
	current_pause = save_manager.active_save.keyboard_cancel
	pause_btn.text = OS.get_keycode_string(current_pause)


# MORE FUNCTIONS
func _save_updates_to_player_data() -> void:
	# General
	save_manager.active_save.language = _get_locale_from_int(current_language)
	save_manager.active_save.dyslexic_font = dyslexic_friendly_font
	save_manager.active_save.filters_active = crt_effects
	save_manager.active_save.flashes_active = flash_effects

	# Video
	save_manager.active_save.window_mode = window_mode
	save_manager.active_save.window_size = current_size

	# Audio
	save_manager.active_save.master_volume = master_volume
	save_manager.active_save.music_volume = music_volume
	save_manager.active_save.sfx_volume = sfx_volume

	# Controls
	save_manager.active_save.click = current_click
	save_manager.active_save.deselect = current_deselect
	save_manager.active_save.keyboard_cancel = current_pause

	Signals.Save.emit()
	pending_changes = false


func _get_int_from_locale(lang:String) -> int:
	match lang:
		"fr":
			return 1
		"fr_CA":
			return 2
		_:
			return 0


# RESETS
func _reset_general_to_saved() -> void:
	if current_language != _get_int_from_locale(save_manager.active_save.language):
		current_language = _get_int_from_locale(save_manager.active_save.language)
		language_options.select(current_language)

	if dyslexic_friendly_font != save_manager.active_save.dyslexic_font:
		dyslexic_friendly_font = save_manager.active_save.dyslexic_font
		data_manager.default_theme.default_font = data_manager.normal_font if not dyslexic_friendly_font else data_manager.dyslexia_friendly_font
		dyslexic_friendly_font_btn.text = tr("OFF") if not dyslexic_friendly_font else tr("ON")

	if crt_effects != save_manager.active_save.filters_active:
		crt_effects = save_manager.active_save.filters_active
		Signals.ToggleCRTEffects.emit(crt_effects)
		crt_effects_btn.text = tr("ON") if crt_effects else tr("OFF")

	if flash_effects != save_manager.active_save.flashes_active:
		flash_effects = save_manager.active_save.flashes_active
		Signals.ToggleFlashEffects.emit(flash_effects)
		flash_effects_btn.text = tr("ON") if flash_effects else tr("OFF")


func _reset_general_to_defaults() -> void:
	if dyslexic_friendly_font != save_manager.active_save.dyslexic_font_default or save_manager.active_save.dyslexic_font != save_manager.active_save.dyslexic_font_default:
		dyslexic_friendly_font = save_manager.active_save.dyslexic_font_default
		data_manager.default_theme.default_font = data_manager.normal_font
		dyslexic_friendly_font_btn.text = tr("OFF")
		pending_changes = true
	
	if crt_effects != save_manager.active_save.filters_active_default or save_manager.active_save.filters_active != save_manager.active_save.filters_active_default:
		crt_effects = save_manager.active_save.filters_active_default
		Signals.ToggleCRTEffects.emit(crt_effects)
		crt_effects_btn.text = tr("ON")
		pending_changes = true

	if flash_effects != save_manager.active_save.flashes_active_default or save_manager.active_save.flashes_active != save_manager.active_save.flashes_active_default:
		flash_effects = save_manager.active_save.flashes_active_default
		Signals.ToggleFlashEffects.emit(flash_effects)
		flash_effects_btn.text = tr("ON")
		pending_changes = true


# VIDEO
func _reset_video_to_saved() -> void:
	if current_size != save_manager.active_save.window_size: _revert_resolution_change()
	if window_mode != save_manager.active_save.window_mode: _revert_window_mode_change()


func _reset_video_btn_pressed() -> void:
	save_manager.active_save.window_mode = save_manager.active_save.window_mode_default
	save_manager.active_save.window_size = save_manager.active_save.window_size_default

	pending_changes = true


# AUDIO
func _reset_audio_to_saved() -> void:
	if master_volume != save_manager.active_save.master_volume:
		master_volume = save_manager.active_save.master_volume
		master_hslider.value = master_volume
		pending_changes = true
	
	if music_volume != save_manager.active_save.music_volume:
		music_volume = save_manager.active_save.music_volume
		music_hslider.value = music_volume
		pending_changes = true

	if sfx_volume != save_manager.active_save.sfx_volume:
		sfx_volume = save_manager.active_save.sfx_volume
		sfx_hslider.value = sfx_volume
		pending_changes = true

	Audio.set_volumes(master_volume, music_volume, sfx_volume)


func _reset_audio_btn_pressed() -> void:
	if master_volume != Audio.default.master_volume:
		master_volume = Audio.default.master_volume
		master_hslider.value = master_volume
		pending_changes = true
	
	if music_volume != Audio.default.music_volume:
		music_volume = Audio.default.music_volume
		music_hslider.value = music_volume
		pending_changes = true

	if sfx_volume != Audio.default.sfx_volume:
		sfx_volume = Audio.default.sfx_volume
		sfx_hslider.value = sfx_volume
		pending_changes = true
	
	Audio.reset_volumes()

	
# Controls
func _reset_controls_to_saved() -> void:
	if current_click != save_manager.active_save.click:
		current_click = save_manager.active_save.click
		click_btn.text = input_manager.get_string_from_mouse_button(current_click)

	if current_deselect != save_manager.active_save.deselect:
		current_deselect = save_manager.active_save.deselect
		deselect_btn.text = input_manager.get_string_from_mouse_button(current_deselect)

	if current_pause != save_manager.active_save.keyboard_cancel:
		current_pause = save_manager.active_save.keyboard_cancel
		pause_btn.text = OS.get_keycode_string(current_pause)


func _reset_controls_btn_pressed() -> void:
	if current_click != save_manager.active_save.click_default:
		current_click = save_manager.active_save.click_default
		click_btn.text = input_manager.get_string_from_mouse_button(current_click)
		pending_changes = true

	if current_deselect != save_manager.active_save.deselect_default:
		current_deselect = save_manager.active_save.deselect_default
		deselect_btn.text = input_manager.get_string_from_mouse_button(current_deselect)
		pending_changes = true

	if current_pause != save_manager.active_save.keyboard_cancel_default:
		current_pause = save_manager.active_save.keyboard_cancel_default
		pause_btn.text = OS.get_keycode_string(current_pause)
		pending_changes = true


func _get_string_from_mouse_button(input:MouseButton) -> String:
	var result:String = ""
	match input:
		MOUSE_BUTTON_LEFT:
			result = tr("mouse_btn_left")
		MOUSE_BUTTON_RIGHT:
			result = tr("mouse_btn_right")
		MOUSE_BUTTON_MIDDLE:
			result = tr("mouse_btn_middle")
		_:
			result = tr("unknown_mouse_input")

	return result


func _check_popup_results(popup_id:String, result:bool) -> void:
	match popup_id:
		"setting_pending_changes_apply":
			if result:
				_save_updates_to_player_data()
		"setting_pending_changes_close":
			if result:
				_reset_general_to_saved()
				_reset_video_to_saved()
				_reset_audio_to_saved()
				_reset_controls_to_saved()
				pending_changes = false
				toggle_display(false)
		"setting_resolution_changes":
			if result:
				_keep_resolution_change()
			else:
				_revert_resolution_change()
		"setting_window_mode_changes":
			if result:
				_keep_window_mode_change()
			else:
				_revert_window_mode_change()
		"pause_settings_pending_changes":
			if result:
				_reset_general_to_saved()
				_reset_video_to_saved()
				_reset_audio_to_saved()
				_reset_controls_to_saved()
				pending_changes = false
		_:
			pass


func _get_window_mode_enum(mode:int, borderless:bool) -> Window_Mode:
	var result:Window_Mode= Window_Mode.FULLSCREEN

	if mode == DisplayServer.WINDOW_MODE_WINDOWED:
		if borderless:
			result = Window_Mode.BORDERLESS_WINDOWED
		else:
			result = Window_Mode.WINDOWED

	return result


func _set_display_mode(mode:Window_Mode) -> void:
	match mode:
		Window_Mode.BORDERLESS_WINDOWED:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		Window_Mode.WINDOWED:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _get_locale_from_int(id:int) -> String:
	var lang:String = "en"
	match id:
		1:
			lang = "fr"
		2:
			lang = "fr-CA"
		_:
			pass
	return lang