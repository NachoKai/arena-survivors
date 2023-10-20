extends Node

@onready var player: CharacterBody2D = %Player
@onready var crt_filter: CanvasLayer = $CrtFilter
@export var end_screen_scene: PackedScene
var pause_menu_scene = preload("res://scenes/ui/pause_menu.tscn")


func _ready():
	player.health_component.died.connect(on_player_died)
	crt_filter.visible = GameOptions.is_crt_filter_active


func _unhandled_input(event):
	if not pause_menu_scene: return
	if event.is_action_pressed("pause"):
		add_child(pause_menu_scene.instantiate())
		get_tree().root.set_input_as_handled()


func on_player_died():
	var end_screen_instance = end_screen_scene.instantiate()
	if not end_screen_instance: return
	add_child(end_screen_instance)
	end_screen_instance.set_defeat()
	MetaProgression.save_file()
