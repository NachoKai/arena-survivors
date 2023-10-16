extends CanvasLayer

var options_scene = preload("res://scenes/ui/options_menu.tscn")
var upgrades_scene = preload("res://scenes/ui/meta_menu.tscn")
@onready var play_button: Button = %PlayButton
@onready var options_button: Button = %OptionsButton
@onready var quit_button: Button = %QuitButton
@onready var upgrades_button: Button = %UpgradesButton
@onready var version_label: Label = $VersionLabel


func _ready():
	play_button.pressed.connect(on_play_pressed)
	options_button.pressed.connect(on_options_pressed)
	quit_button.pressed.connect(on_quit_pressed)
	upgrades_button.pressed.connect(on_upgrades_pressed)
	
	var preset = ConfigFile.new()
	preset.load("res://export_presets.cfg")
	var game_version = preset.get_value("preset.0.options", "application/version", "")
	version_label.text = "v. " + game_version


func on_play_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")


func on_upgrades_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	get_tree().change_scene_to_file("res://scenes/ui/meta_menu.tscn")


func on_options_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	var options_instance = options_scene.instantiate()
	add_child(options_instance)
	options_instance.back_pressed.connect(on_options_closed.bind(options_instance))


func on_options_closed(options_instance: Node):
	options_instance.queue_free()


func on_quit_pressed():
	get_tree().quit()
