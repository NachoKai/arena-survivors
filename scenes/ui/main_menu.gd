extends CanvasLayer

var options_scene = preload("res://scenes/ui/options_menu.tscn")
var upgrades_scene = preload("res://scenes/ui/meta_menu.tscn")
@onready var play_button: Button = %PlayButton
@onready var characters: Button = %Characters
@onready var upgrades_button: Button = %UpgradesButton
@onready var options_button: Button = %OptionsButton
@onready var quit_button: Button = %QuitButton
@onready var version_label: Label = $VersionLabel
@onready var crt_filter: CanvasLayer = $CrtFilter


func _ready():
	play_button.pressed.connect(on_play_pressed)
	options_button.pressed.connect(on_options_pressed)
	quit_button.pressed.connect(on_quit_pressed)
	upgrades_button.pressed.connect(on_upgrades_pressed)
	characters.pressed.connect(on_characters_pressed)
	version_label.text = "v. " + str(GameEvents.game_version)
	crt_filter.visible = GameOptions.is_crt_filter_active


func on_play_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	crt_filter.visible = GameOptions.is_crt_filter_active
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")


func on_upgrades_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	get_tree().change_scene_to_file("res://scenes/ui/meta_menu.tscn")


func on_characters_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	get_tree().change_scene_to_file("res://scenes/ui/characters_menu.tscn")


func on_options_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	var options_instance = options_scene.instantiate()
	add_child(options_instance)
	options_instance.back_pressed.connect(on_options_closed.bind(options_instance))


func on_options_closed(options_instance: Node):
	crt_filter.visible = GameOptions.is_crt_filter_active
	options_instance.queue_free()


func on_quit_pressed():
	get_tree().quit()
