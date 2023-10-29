extends Node

var health_vial_scene: PackedScene = preload("res://scenes/game_object/health_vial/health_vial.tscn")
@onready var player: CharacterBody2D = %Player
@onready var player_node = get_tree().get_first_node_in_group("player") as Node2D
@onready var crt_filter: CanvasLayer = $CrtFilter
@onready var castle_door_area: Area2D = $CastleDoorArea
@onready var game_camera: Camera2D = $GameCamera
@onready var objects: Node2D = $Objects
@onready var remove_enemies_area: Area2D = $RemoveEnemiesArea
@onready var entities: Node2D = $Entities
@export var end_screen_scene: PackedScene
var pause_menu_scene = preload("res://scenes/ui/pause_menu.tscn")


func _ready():
	crt_filter.visible = GameOptions.is_crt_filter_active
	player.health_component.died.connect(on_player_died)
	remove_enemies_area.body_entered.connect(on_remove_enemies_body_entered)

	var treasure_chests = get_tree().get_nodes_in_group("treasure_chest")
	for treasure_chest in treasure_chests:
		treasure_chest.connect("open", on_treasure_chest_opened)


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


#func on_castle_entered(_other_body: Node2D):
#	ScreenTransition.transition()
#	await ScreenTransition.transition_halfway
#	player_node.get_parent().remove_child(player_node)
#	get_tree().change_scene_to_file("res://scenes/castle/castle.tscn")
#	castle.add_child(player_node)


func on_treasure_chest_opened(pos, dir):
	var health_vial = health_vial_scene.instantiate()
	health_vial.position = pos
	health_vial.direction = dir
	objects.call_deferred("add_child", health_vial)


func on_remove_enemies_body_entered(body):
	if body.is_in_group("enemy"):
		body.queue_free()

