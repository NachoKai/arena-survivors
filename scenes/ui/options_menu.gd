extends CanvasLayer

signal back_pressed

@onready var sfx_volume_slider: HSlider = %SfxVolumeSlider
@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var window_mode_button: Button = %WindowModeButton
@onready var back_button: Button = %BackButton


func _ready():
	window_mode_button.pressed.connect(on_window_button_pressed)
	sfx_volume_slider.value_changed.connect(on_audio_slider_changed.bind("sfx"))
	music_volume_slider.value_changed.connect(on_audio_slider_changed.bind("music"))
	back_button.pressed.connect(on_back_button_pressed)
	update_display()


func update_display():
	window_mode_button.text = "Windowed"
	var window_mode = DisplayServer.window_get_mode()
	var is_fullscreen = window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN
	if is_fullscreen: window_mode_button.text = "Fullscreen"
	sfx_volume_slider.value = get_bus_volume_percent("sfx")
	music_volume_slider.value = get_bus_volume_percent("music")


func get_bus_volume_percent(bus_name: String):
	if bus_name == null: return
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume_db)


func set_bus_volume_percent(bus_name: String, percent: float):
	if bus_name == null || percent == null: return
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = linear_to_db(percent)
	AudioServer.set_bus_volume_db(bus_index, volume_db)


func on_window_button_pressed():
	var window_mode = DisplayServer.window_get_mode()
	if window_mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	update_display()


func on_audio_slider_changed(value: float, bus_name: String):
	if value == null || bus_name == null: return
	set_bus_volume_percent(bus_name, value)


func on_back_button_pressed():
	back_pressed.emit()
