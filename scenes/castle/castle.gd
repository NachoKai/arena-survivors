#extends Node
#
#@onready var player: CharacterBody2D = %Player
#@onready var crt_filter: CanvasLayer = $CrtFilter
#@onready var castle_door_area: Area2D = $CastleDoorArea
#@onready var game_camera: Camera2D = $GameCamera
#@export var end_screen_scene: PackedScene
#var pause_menu_scene = preload("res://scenes/ui/pause_menu.tscn")
#
#
#func _ready():
#	crt_filter.visible = GameOptions.is_crt_filter_active
#	player.health_component.died.connect(on_player_died)
#	castle_door_area.area_entered.connect(on_castle_exited)
#
#
#func _unhandled_input(event):
#	if not pause_menu_scene: return
#	if event.is_action_pressed("pause"):
#		add_child(pause_menu_scene.instantiate())
#		get_tree().root.set_input_as_handled()
#
#
#func on_player_died():
#	var end_screen_instance = end_screen_scene.instantiate()
#	if not end_screen_instance: return
#	add_child(end_screen_instance)
#	end_screen_instance.set_defeat()
#	MetaProgression.save_file()
#
#
#func on_castle_exited(_other_body: Node2D):
#	ScreenTransition.transition()
#	await ScreenTransition.transition_halfway
#	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
#	# Spawn character at the castle doors
